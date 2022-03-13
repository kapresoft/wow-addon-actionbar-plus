---
--- Button Factory
---
-- ## External -------------------------------------------------
local ClearCursor, GetCursorInfo, CreateFrame, UIParent =
    ClearCursor, GetCursorInfo, CreateFrame, UIParent
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
    GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show
local pack, fmod = table.pack, math.fmod
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

-- ## Local ----------------------------------------------------
local LibStub, M, A, P, LSM, W = ABP_WidgetConstants:LibPack()
local PrettyPrint, Table, String = ABP_LibGlobals:LibPackUtils()
local ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()

local ButtonFrameFactory, H, SAS, IAS, MAS, MTAS = W:LibPack_ButtonFactory()
local AssertThatMethodArgIsNotNil, AssertNotNil = A.AssertThatMethodArgIsNotNil, A.AssertNotNil
local SECURE_ACTION_BUTTON_TEMPLATE, TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI =
    SECURE_ACTION_BUTTON_TEMPLATE, BOTTOMLEFT, TOPLEFT, ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI

local ButtonUI = ABP_WidgetConstants:LibPack_ButtonUI()
local AceEvent = ABP_LibGlobals:LibPack_AceLibrary()

---@class ButtonFactory
local L = LibStub:NewLibrary(M.ButtonFactory)
if not L then return end


local AttributeSetters = { ['spell'] = SAS, ['item'] = IAS, ['macro'] = MAS, ['macrotext'] = MTAS, }

-- Initialized on Logger#OnAddonLoaded()
L.addon = nil
L.profile = nil

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function ShowConfigTooltip(frame)
    local widget = frame.widget
    GameTooltip:SetOwner(frame, ANCHOR_TOPLEFT)
    GameTooltip:AddLine(format('Actionbar #%s: Right-click to open config UI', widget:GetFrameIndex(), 1, 1, 1))
    GameTooltip:Show()
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function OnMacroChanged(btnWidget)
    --L:log(10, 'OnMacroChanged Event received: %s', btnWidget.buttonName)
    L:log(50, 'OnMacroChanged New Data: %s', pformat(btnWidget:GetConfig()))
    L:SetButtonAttributes(btnWidget)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function OnLeaveFrame(_) GameTooltip:Hide() end
local function OnShowFrameTooltip(frame)
    ShowConfigTooltip(frame)
    C_Timer.After(3, function() GameTooltip:Hide() end)
end

local function OnMouseDownFrame(frameHandle, mouseButton)
    --F:log(1, 'Mouse Button Clicked: %s', mouseButton or '')
    frameHandle.widget.frame:StartMoving()
    GameTooltip:Hide()
    if IsShiftKeyDown() and strlower(mouseButton) == 'leftbutton' then
        ReloadUI()
    elseif strlower(mouseButton) == 'rightbutton' then
        L.addon:OpenConfig()
    elseif strlower(mouseButton) == 'button5' then
        StaticPopup_Show(CONFIRM_RELOAD_UI)
    end
end

--- Var Args: `unit, target, castGUID, spellID`
local function OnSpellCastSent(event, ...)
    --L:log('OnSpellCastSent:: %s', pformat({...}))
    local _, _, _, spellID = ...
    local buttons = P:FindButtonsBySpellById(spellID)
    ---@param spell SpellInfo
    for btnName, spell in pairs(buttons) do
        local btnUI = _G[btnName]
        if btnUI and btnUI.widget then
            btnUI.widget:Fire('OnSpellCastSent', spell)
        end
    end
end

--- Var Args: `unitTarget, castGUID, spellID`
local function OnSpellCastSucceeded(event, ...)
    --L:log('OnSpellCastSucceeded:: %s', pformat({...}))
    local _, _, spellID = ...
    local buttons = P:FindButtonsBySpellById(spellID)
    ---@param spell SpellInfo
    for btnName, spell in pairs(buttons) do
        local btnUI = _G[btnName]
        if btnUI and btnUI.widget then
            btnUI.widget:Fire('OnSpellCastSucceeded', spell)
        end
    end

    -- iterate through all buttons and fire an event
    -- handle cooldown in Ace SetCallback()
    local barFrames = P:GetAllFrameWidgets()
    --TODO: Call GetSpellInfo('GCD Spell') to get the actual global cooldown
    local globalCooldownInSeconds = 1.5
    for _, f in ipairs(barFrames) do
        ---@type FrameWidget
        local fw = f
        --L:log(1, "Frame #%s: %s", fw:GetName(), fw:GetButtonCount())
        for _, btnName in ipairs(fw:GetButtons()) do
            ---@type ButtonUIWidget
            local btnUI = _G[btnName].widget
            --btnUI.widget:Fire('OnSpellCastSent', spell)
            local btnData = btnUI:GetConfig()
            if btnData.type == 'spell' then
                local spellInfo = btnData['spell']
                if String.IsNotBlank(spellInfo.id) then
                    if spellInfo.id ~= spellID then
                        local cooldownMS, gcdMS = GetSpellBaseCooldown(spellInfo.id)
                        local cd = _API_Spell:GetSpellCooldown(spellInfo.id)
                        local now = GetTime()
                        local timeCd = cd.start + cooldownMS
                        local afterCd = now + cooldownMS
                        L:log("spell: %s duration=%s now=%s timeCd=%s afterCd=%s BGCD=%s",
                        spellInfo.name, cd.duration, now, timeCd, afterCd, pformat({cooldownMS, gcdMS}))
                        --L:log('basecd: %s, cd: %s spellInfo: %s',
                        --        pformat({cooldownMS, gcdMS}), Table.toStringSorted(cd), spellInfo.name)
                        if gcdMS > 0 and afterCd >= timeCd then
                            btnUI:SetCooldownDelegate(now, gcdMS/1000)
                        end
                    end
                end
            end
        end
    end
end

--- Var Args: unitTarget, castGUID, spellID
local function OnSpellCastFailed(event, ...)
    --L:log('OnSpellCastFailed:: %s', pformat({...}))
    local _, _, spellID = ...
    local buttons = P:FindButtonsBySpellById(spellID)
    ---@param spell SpellInfo
    for btnName, spell in pairs(buttons) do
        local btnUI = _G[btnName]
        if btnUI and btnUI.widget then
            btnUI.widget:Fire('OnSpellCastFailed', spell)
        end
    end
end

---This event is fired immediately whenever you cast a spell, as well as
---every second while you channel spells.
---### See Also:
--- https://wowpedia.fandom.com/wiki/SPELL_UPDATE_COOLDOWN
local function OnSpellUpdateCooldown(event)
    -- TODO NEXT: Update all button cooldowns
    L:log(50, 'Triggered: %s', event)
end

---Fired when the cooldown for an actionbar or inventory slot starts or
---stops. Also fires when you log into a new area.
---### See Also:
---https://wowpedia.fandom.com/wiki/ACTIONBAR_UPDATE_COOLDOWN
local function OnActionbarUpdateCooldown(event)
    -- also fired on: refresh, new zone
    L:log(50, 'Triggered: %s', event)
end


function L:OnAfterInitialize()
    local frames = P:GetAllFrameNames()
    --error(format('frames: %s', ABP_Table.toString(frames)))
    for i,_ in ipairs(frames) do
        local frameEnabled = P:IsBarIndexEnabled(i)
        local f = self:CreateActionbarGroup(i)
        if frameEnabled then
            f:ShowGroup()
        else
            f:HideGroup()
        end
    end

    -- TODO NEXT: Refactor to Widget/SpellEventsHandler
    AceEvent:RegisterEvent('UNIT_SPELLCAST_SENT', OnSpellCastSent)
    AceEvent:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnSpellCastSucceeded)
    AceEvent:RegisterEvent('UNIT_SPELLCAST_FAILED', OnSpellCastFailed)
    AceEvent:RegisterEvent('SPELL_UPDATE_COOLDOWN', OnSpellUpdateCooldown)
    AceEvent:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN', OnActionbarUpdateCooldown)
end

function L:CreateActionbarGroup(frameIndex)
    -- TODO: config should be in profiles
    local config = P:GetActionBarSizeDetailsByIndex(frameIndex)
    local f = ButtonFrameFactory(frameIndex)
    self:CreateButtons(f, config.rowSize, config.colSize)
    f:MarkRendered()
    self:AttachFrameEvents(f)
    return f
end

function L:CreateButtons(frameWidget, rowSize, colSize)
    local index = 0
    for row=1, rowSize do
        for col=1, colSize do
            index = index + 1
            local btnWidget = self:CreateSingleButton(frameWidget, row, col, index)
            frameWidget:AddButton(btnWidget:GetName())
        end
    end
end

-- TODO NEXT: Register Buttons so we can fire button events
--      for all buttons, btn:Fire('OnCooldown') on click
function L:CreateSingleButton(dragFrame, row, col, index)
    local btnWidget = ButtonUI:WidgetBuilder():Create(dragFrame, row, col, index)
    self:SetButtonAttributes(btnWidget)
    btnWidget:SetCallback("OnMacroChanged", OnMacroChanged)
    btnWidget:RefreshCooldown()
    return btnWidget
end

---@param btnWidget ButtonUIWidget
function L:SetButtonAttributes(btnWidget)
    local btnData = btnWidget:GetConfig()
    if btnData == nil or String.IsBlank(btnData.type) then return end
    local setter = self:GetAttributesSetter(btnData.type)
    if not setter then
        self:log(1, 'No Attribute Setter found for type: %s', btnData.type)
        return
    end
    setter:SetAttributes(btnWidget.button, btnData)
end

-- See: https://wowpedia.fandom.com/wiki/API_GetCursorInfo
--      This one is incorrect:  https://wowwiki-archive.fandom.com/wiki/API_GetCursorInfo
-- spell: spellId=info1 bookType=info2 ?=info3
-- item: itemId = info1, itemName/Link = info2
-- macro: macro-index=info1
function L:OnReceiveDrag(btnUI)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')
    -- TODO: Move to TBC/API
    local actionType, info1, info2, info3 = GetCursorInfo()
    ClearCursor()

    local cursorInfo = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    self:log(20, 'OnReceiveDrag Cursor-Info: %s', ToStringSorted(cursorInfo))
    if not self:IsValidDragSource(cursorInfo) then return end
    H:Handle(btnUI, actionType, cursorInfo)
end

function L:IsValidDragSource(cursorInfo)
    if String.IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        self:log(5, 'Received drag event with invalid cursor info. Skipping...')
        return false
    end

    return true
end

function L:AttachFrameEvents(frameWidget)
    local frame = frameWidget.frameHandle
    frame:SetScript("OnMouseDown", OnMouseDownFrame)
    frame:SetScript("OnEnter", OnShowFrameTooltip)
    frame:SetScript("OnLEave", OnLeaveFrame)
end

function L:GetAttributesSetter(actionType)
    AssertNotNil(actionType, 'actionType')
    return AttributeSetters[actionType]
end