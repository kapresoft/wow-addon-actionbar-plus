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

-- TODO: Move to config
--local INTERNAL_BUTTON_PADDING = 2

---@class ButtonFactory
local L = LibStub:NewLibrary(M.ButtonFactory)
if not L then return end

--local noIconTexture = LSM:Fetch(LSM.MediaType.BACKGROUND, "Blizzard Dialog Background")
--local buttonSize = 40
--local frameStrata = 'LOW'

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

local function OnSpellCastSent(event, ...)
    --L:log('OnSpellCastSent:: %s', btnUI)

    local unit, unitTarget, castGUID, spellID = ...
    --
    --btnUI:SetHighlightTexture(TEXTURE_CASTING)
    --btnUI:LockHighlight()
    --
    --updateCooldown(btnUI, event, spellID)

    --local btnUI = findButtonBySpellId(spellID)
    --btnUI.widget:Fire('OnSpellCastSent')

    local buttons = P:FindButtonsBySpellById(spellID)
    --print('btnsize:', Table.size(buttons))
    ---@param spell SpellInfo
    for btnName, spell in pairs(buttons) do
        local btnUI = _G[btnName]
        if btnUI and btnUI.widget then
            btnUI.widget:Fire('OnSpellCastSent', spell)
            --L:log('OnSpellCastSent:: Fired Event[%s]: %s(%s)', btnName, spell.name, spell.id)
        end
    end
    --L:log('OnSpellCastSent::Buttons: %s', pformat(buttons))
end

local function OnSpellCastSucceeded(event, ...)
    --L:log('OnSpellCastSucceeded:: %s', btnUI)
    local unitTarget, castGUID, spellID = ...

    --btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    --btnUI:UnlockHighlight()
    --btnUI.widget:ClearCooldown()
    --
    --ABP_wait(0, function() updateCooldown(btnUI, event, spellID)  end)
    --local btnUI = findButtonBySpellId(spellID)
    --btnUI.widget:Fire('OnSpellCastSucceeded')
    local buttons = P:FindButtonsBySpellById(spellID)
    --print('btnsize:', Table.size(buttons))
    ---@param spell SpellInfo
    for btnName, spell in pairs(buttons) do
        local btnUI = _G[btnName]
        if btnUI and btnUI.widget then
            btnUI.widget:Fire('OnSpellCastSucceeded', spell)
            --L:log('OnSpellCastSucceeded:: Fired Event[%s]: %s(%s)', btnName, spell.name, spell.id)
        end
    end
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

    AceEvent:RegisterEvent('UNIT_SPELLCAST_SENT', OnSpellCastSent)
    AceEvent:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', OnSpellCastSucceeded)
end

function L:CreateActionbarGroup(frameIndex)
    -- TODO: config should be in profiles
    local config = P:GetActionBarSizeDetailsByIndex(frameIndex)
    local f = ButtonFrameFactory(frameIndex)
    --f.dragHandleHeight = 5
    --f.padding = 2
    --f.halfPadding = f.padding/2
    --f:SetWidth((config.colSize * buttonSize) - INTERNAL_BUTTON_PADDING)
    --f:SetScale(1.0)
    --f:SetFrameStrata(frameStrata)
    ----f.widthAdjust = config.colSize * INTERNAL_BUTTON_PADDING
    ----f.heightAdjust = config.rowSize * INTERNAL_BUTTON_PADDING
    --local widthAdj = f.padding
    --local heightAdj = f.padding + f.dragHandleHeight
    --f:SetWidth(config.colSize * buttonSize + widthAdj)
    --f:SetHeight(config.rowSize * buttonSize + heightAdj)

    self:CreateButtons(f, config.rowSize, config.colSize)
    f:MarkRendered()
    self:AttachFrameEvents(f)
    return f
end

function L:CreateButtons(dragFrame, rowSize, colSize)
    local index = 0
    for row=1, rowSize do
        for col=1, colSize do
            index = index + 1
            --local btnUI = self:CreateSingleButton(dragFrame, row, col, index)
            local btnWidget = ButtonUI:WidgetBuilder():Create(dragFrame, row, col, index)
            self:SetButtonAttributes(btnWidget)
            --btnUI:SetScript("OnReceiveDrag", function(_btnUI) self.OnReceiveDrag(self, _btnUI) end)
            dragFrame:AddButton(btnWidget:GetName())
        end
    end
end

---@param btnWidget ButtonUIWidget
function L:SetButtonAttributes(btnWidget)
    local actionbarInfo = btnWidget:GetActionbarInfo()
    local btnName = btnWidget:GetName()
    --local btnData = P:GetButtonData(actionbarInfo.index, btnName)
    local btnData = btnWidget:GetConfig()

    --local key = actionbarInfo.name .. btnName
    --local btnData = P.profile[key]

    if btnData == nil or btnData.type == nil then return end

    -- TODO
    --btnUI:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local setter = self:GetAttributesSetter(btnData.type)
    if not setter then
        self:log(1, 'No Attribute Setter found for type: %s', btnData.type)
        return
    end
    setter:SetAttributes(btnWidget.button, btnData)
end

-- TODO: Move somewhere else
---@unused
--function L:CreateSingleButton(dragFrame, rowNum, colNum, index)
--    local frameName = dragFrame:GetName()
--    local btnName = format('%sButton%s', frameName, tostring(index))
--    --self:printf('frame name: %s button: %s index: %s', frameName, btnName, index)
--    local btnUI = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)
--
--    local cdFrameName = btnName .. 'CDFrame'
--    ---@type Cooldown
--    local cdFrame = CreateFrame("Cooldown", cdFrameName, btnUI,  "CooldownFrameTemplate")
--    cdFrame:SetAllPoints(btnUI)
--    cdFrame:SetSwipeColor(1, 1, 1)
--    btnUI.cooldownFrame = cdFrame
--    --error('cdFrame: ' .. pformat:A():pformat(cdFrame))
--    --cdFrame:SetCooldown(GetTime(), 20)
--
--    function btnUI:ClearCooldown()
--        self.cooldownFrame:Clear()
--        self.cooldownFrame:Hide()
--    end
--
--    function btnUI:SetCooldown(optionalInfo)
--        L:log('XXXXXX Cooldown... XXXXXXX')
--        local info = optionalInfo or self.cooldownFrame.info
--        self:SetCooldownInfo(info)
--        self.cooldownFrame:SetCooldown(info.start, info.duration)
--        L:log('Cooldown success: %s', pformat(info))
--    end
--
--    function btnUI:SetCooldownInfo(cooldownInfo)
--        if not cooldownInfo then return end
--        self.cooldownFrame.info = cooldownInfo
--    end
--
--    function btnUI:ResumeCooldown()
--        self:ClearCooldown()
--        self:SetCooldown()
--    end
--
--    ---```
--    ---{
--    ---    index = 2, name = 'ActionbarPlusF2',
--    ---    button = { index = 8, name = 'ActionbarPlusF2Button8' },
--    ---}
--    ---```
--    ---@return ActionBarInfo
--    function btnUI:GetActionbarInfo()
--        ---class ActionBarInfo
--        local info = {
--            name = frameName, index = dragFrame:GetFrameIndex(),
--            button = { name = btnName, index = index },
--        }
--        return info
--    end
--
--    function btnUI:GetProfileButtonData()
--        local info = self:GetActionbarInfo()
--        if not info then return nil end
--        return P:GetButtonData(info.index, info.button.name)
--    end
--
--    btnUI:SetFrameStrata(frameStrata)
--
--    btnUI:SetSize(buttonSize - INTERNAL_BUTTON_PADDING, buttonSize - INTERNAL_BUTTON_PADDING)
--    -- Reference point is BOTTOMLEFT of dragFrame
--    -- dragFrameBottomLeftAdjustX, dragFrameBottomLeftAdjustY adjustments from #dragFrame
--    local referenceFrameAdjustX = buttonSize
--    local referenceFrameAdjustY = 2
--    local adjX = (colNum * buttonSize) - referenceFrameAdjustX
--    local adjY =  (rowNum * buttonSize) + INTERNAL_BUTTON_PADDING - referenceFrameAdjustY
--    btnUI:SetPoint(TOPLEFT, dragFrame, TOPLEFT, adjX, -adjY)
--    btnUI:SetNormalTexture(noIconTexture)
--
--    -- We need OnClick for all buttons
--    btnUI:HookScript('OnClick', function(_btnUI, mouseButton, down)
--
--        --if _btnUI.cooldownFrame.spellInfo then
--        --    local spellInfo = _btnUI.cooldownFrame.spellInfo
--        --    local start, duration, enabled = GetSpellCooldown(spellInfo.id);
--        --    local info = { start = start, duration = duration, enabled = enabled }
--        --    L:log('cooldown info: %s', pformat(info))
--        --    _btnUI:SetCooldownInfo(info)
--        --    _btnUI:SetCooldown()
--        --    L:log('cooldown set done: %s', spellInfo.name)
--        --end
--
--
--        local actionType = GetCursorInfo()
--        if String.IsBlank(actionType) then return end
--        L:log(20, 'HookScript| Actionbar: %s', pformat(_btnUI:GetActionbarInfo()))
--        L:OnReceiveDrag(_btnUI)
--    end)
--
--    return btnUI
--end

--function F:Bind()
--    local button3Binding = getBindingByName('ABP_ACTIONBAR1_BUTTON3')
--    print('Binding[ABP_ACTIONBAR1_BUTTON3]', pformat(button3Binding))
--    local button3 = 'ActionbarPlusF1Button3'
--    SetBindingClick(button3Binding.key1, button3)
--    if button3Binding.key2 then
--        SetBindingClick(button3Binding.key2, button3)
--    end
--end

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

---@deprecated
function L:IsValidDragSource(cursorInfo)
    if String.IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        self:log(5, 'Received drag event with invalid cursor info. Skipping...')
        return false
    end

    return true
end

--TODO: Move to frame
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