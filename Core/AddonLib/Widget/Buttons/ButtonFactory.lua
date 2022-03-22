---
--- Button Factory
---
-- ## External -------------------------------------------------
local ClearCursor, GetCursorInfo = ClearCursor, GetCursorInfo
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
    GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show
local format, strlower = string.format, string.lower

-- ## Local ----------------------------------------------------
local LibStub, M, A, P, _, W = ABP_WidgetConstants:LibPack()
local _, _, String = ABP_LibGlobals:LibPackUtils()
local ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()

local ButtonFrameFactory, H, SAS, IAS, MAS, MTAS = W:LibPack_ButtonFactory()
local AssertThatMethodArgIsNotNil, AssertNotNil = A.AssertThatMethodArgIsNotNil, A.AssertNotNil
local ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI = ANCHOR_TOPLEFT, CONFIRM_RELOAD_UI

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

local function FireFrameEvent(event, sourceEvent, ...)
    for _, f in ipairs(P:GetAllFrameWidgets()) do
        f:Fire(event, sourceEvent, ...)
    end
end

--- Var Args: `unitTarget, castGUID, spellID`
local function OnSpellCastSucceeded(_, ...)
    local _, _, spellID = ...
    --P:log('OnSpellCastSucceeded: %s [%s]', spellID, {...})
    FireFrameEvent('OnRefreshSpellCooldowns', 'OnSpellCastSucceeded', spellID)
end

--- Var Args: unitTarget, castGUID, spellID
local function OnSpellCastFailed(_, ...)
    local _, _, spellID = ...
    --P:log(5, 'OnSpellCastFailed: %s [%s]', spellID, {...})
    FireFrameEvent('OnRefreshSpellCooldowns', 'OnSpellCastFailed', spellID)
end

---This event is fired immediately whenever you cast a spell, as well as
---every second while you channel spells.
---### See Also:
--- https://wowpedia.fandom.com/wiki/SPELL_UPDATE_COOLDOWN
local function OnSpellUpdateCooldown(event, ...)
    -- TODO NEXT: Update all button cooldowns
    --L:log(1, 'OnSpellUpdateCooldown')
    --FireFrameEvent('OnRefreshSpellCooldowns', 'OnSpellCastSent')
    FireFrameEvent('OnRefreshSpellCooldowns', 'OnSpellUpdateCooldown')
end

---Fired when the cooldown for an actionbar or inventory slot starts or
---stops. Also fires when you log into a new area.
---### See Also:
---https://wowpedia.fandom.com/wiki/ACTIONBAR_UPDATE_COOLDOWN
--local function OnActionbarUpdateCooldown(event)
--    -- also fired on: refresh, new zone
--    L:log(50, 'Triggered: %s', event)
--end

local function OnBagUpdate(_, ...)
    FireFrameEvent('OnRefreshItemCooldowns', 'OnBagUpdate', ...)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

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
    AceEvent:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnSpellCastSucceeded)
    AceEvent:RegisterEvent('UNIT_SPELLCAST_FAILED', OnSpellCastFailed)
    AceEvent:RegisterEvent('SPELL_UPDATE_COOLDOWN', OnSpellUpdateCooldown)
    AceEvent:RegisterEvent('BAG_UPDATE_DELAYED', OnBagUpdate)
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
    ---@type ButtonUIWidget
    local btnWidget = ButtonUI:WidgetBuilder():Create(dragFrame, row, col, index)
    self:SetButtonAttributes(btnWidget)
    btnWidget:SetCallback("OnMacroChanged", OnMacroChanged)
    btnWidget:UpdateCooldown()
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