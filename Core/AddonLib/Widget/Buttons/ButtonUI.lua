--[[-----------------------------------------------------------------------------
WoW Vars
-------------------------------------------------------------------------------]]
local PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent =
    PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show

--[[-----------------------------------------------------------------------------
LUA Vars
-------------------------------------------------------------------------------]]
local pack, fmod = table.pack, math.fmod
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, A, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local _, AceGUI, AceHook = G:LibPack_AceLibrary()
local ButtonDataBuilder = G:LibPack_ButtonDataBuilder()
local AceEvent = ABP_LibGlobals:LibPack_AceLibrary()

local _, Table, String, LogFactory = G:LibPackUtils()
local ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()
local IsBlank = String.IsBlank
local PH = ABP_PickupHandler
local WU = ABP_WidgetUtil

---@type LogFactory
local p = LogFactory:NewLogger('ButtonUI')

local noIconTexture = LSM:Fetch(LSM.MediaType.BACKGROUND, "Blizzard Dialog Background")

local AssertThatMethodArgIsNotNil, AssertNotNil = A.AssertThatMethodArgIsNotNil, A.AssertNotNil
local SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI = SECURE_ACTION_BUTTON_TEMPLATE, CONFIRM_RELOAD_UI
local TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT = TOPLEFT, BOTTOMLEFT, ANCHOR_TOPLEFT
local TEXTURE_EMPTY, TEXTURE_HIGHLIGHT, TEXTURE_CASTING = ABP_WidgetConstants:GetButtonTextures()
local SPELL,ITEM,MACRO = 'spell','item','macro'

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function IsValidDragSource(cursorInfo)
    if IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        p:log(5, 'Received drag event with invalid cursor info. Skipping...')
        return false
    end
    if not (cursorInfo.type == SPELL or cursorInfo.type == ITEM or cursorInfo.type == MACRO) then
        return false
    end

    return true
end
---@param btnUI ButtonUI
local function OnDragStart(btnUI)
    ---@type ButtonUIWidget
    local w = btnUI.widget

    if InCombatLockdown() then return end
    if w.buttonData:IsLockActionBars() and not IsShiftKeyDown() then return end
    w:Reset()
    p:log(20, 'DragStarted| Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()))

    local btnData = btnUI.widget:GetConfig()
    PH:Pickup(btnData)

    w:SetButtonAsEmpty()
    btnUI:SetScript("OnEnter", nil)
    btnUI.widget:Fire('OnDragStart')
    -- TODO NEXT: Handle Drag-And-Drop for Macrotexts
end

--- Used with `button:RegisterForDrag('LeftButton')`
---@param btnUI ButtonUI
local function OnReceiveDrag(btnUI)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')

    -- TODO: Move to TBC/API
    local actionType, info1, info2, info3 = GetCursorInfo()

    local cursorInfo = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    p:log(20, 'OnReceiveDrag Cursor-Info: %s', ToStringSorted(cursorInfo))
    if not IsValidDragSource(cursorInfo) then return end
    ClearCursor()

    local dragEventHandler = W:LibPack_ReceiveDragEventHandler()
    dragEventHandler:Handle(btnUI, actionType, cursorInfo)

    btnUI.widget:Fire('OnReceiveDrag')
end

local function OnLeave(_) GameTooltip:Hide() end
local function OnClick(btn, mouseButton, down)
    p:log(20, 'SecureHookScript| Actionbar: %s', pformat(btn.widget:GetActionbarInfo()))
    local actionType = GetCursorInfo()
    if String.IsBlank(actionType) then return end
    OnReceiveDrag(btn)
end

local function invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return String.IsBlank(d['id']) end
    end
    return true
end

---@param widget ButtonUIWidget
---@param event string Event string
local function OnUpdateButtonState(widget, event)
    if not widget.button:IsShown() then return end
    widget:UpdateState()
end

---@param widget ButtonUIWidget
---@param event string Event string
local function OnUpdateButtonUsable(widget, event)
    if not widget.button:IsShown() then return end
    WU:UpdateUsable(widget)
end

---@param widget ButtonUIWidget
---@param event string Event string
local function OnBagUpdateDelayed(widget, event)
    if not widget.button:IsShown() then return end
    widget:UpdateItemState()
end

---#### Non-Instant Start-Cast Handler
---@param widget ButtonUIWidget
---@param event string Event string
local function OnSpellCastStart(widget, event, ...)
    if not widget.button:IsShown() then return end

    local unitTarget, castGUID, spellID = ...
    if 'player' ~= unitTarget then return end
    local profileButton = widget:GetConfig()
    if widget:IsMatchingItemSpell(profileButton, spellID)
            or widget:IsMatchingSpell(profileButton, spellID) then
        --local spellInfo = _API:GetSpellInfo(spellID)
        --p:log('Match[%s]: %s[%s]', event, spellInfo.name, spellID)
        widget:SetHighlightInUse()
    end
end

---#### Non-Instant Stop-Cast Handler
---@param widget ButtonUIWidget
---@param event string Event string
local function OnSpellCastStop(widget, event, ...)
    if not widget.button:IsShown() then return end

    local unitTarget, castGUID, spellID = ...
    if 'player' ~= unitTarget then return end
    --p:log('Event[%s]: unitTarget=%s spellID=%s', event, unitTarget, spellID)
    local profileButton = widget:GetConfig()
    if widget:IsMatchingItemSpell(profileButton, spellID)
            or widget:IsMatchingSpell(profileButton, spellID) then
        widget:ResetHighlight()
    end
end
local function OnPlayerControlLost(widget, event, ...)
    if not widget.buttonData:IsHideWhenTaxi() then return end
    WU:SetEnabledActionBarStatesDelayed(false, 1)
end

---@param widget ButtonUIWidget
local function OnPlayerControlGained(widget, event, ...)
    --p:log('Event[%s] received flying=%s', event, flying)
    if not widget.buttonData:IsHideWhenTaxi() then return end
    WU:SetEnabledActionBarStatesDelayed(true, 2)
end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

---@param widget ButtonUIWidget
---@param name string The widget name.
local function RegisterWidget(widget, name)
    assert(widget ~= nil)
    assert(name ~= nil)

    local WidgetBase = AceGUI.WidgetBase
    widget.userdata = {}
    widget.events = {}
    widget.base = WidgetBase
    widget.frame.obj = widget
    local mt = {
        __tostring = function() return name  end,
        __index = WidgetBase
    }
    setmetatable(widget, mt)
end

local function RegisterCallbacks(widget)

    widget:RegisterEvent(ACTIONBAR_UPDATE_STATE, OnUpdateButtonState, widget)
    widget:RegisterEvent(ACTIONBAR_UPDATE_USABLE, OnUpdateButtonUsable, widget)
    widget:RegisterEvent(BAG_UPDATE_DELAYED, OnBagUpdateDelayed, widget)
    widget:RegisterEvent(UNIT_SPELLCAST_START, OnSpellCastStart, widget)
    widget:RegisterEvent(UNIT_SPELLCAST_STOP, OnSpellCastStop, widget)
    widget:RegisterEvent(PLAYER_CONTROL_LOST, OnPlayerControlLost, widget)
    widget:RegisterEvent(PLAYER_CONTROL_GAINED, OnPlayerControlGained, widget)

    --widget:SetCallback('OnDragStart', function(self, event)
    --    --p:log(50, '%s:: %s', event, tostring(self))
    --end)
    ---@param _widget ButtonUIWidget
    widget:SetCallback("OnReceiveDrag", function(_widget)
        --_widget:UpdateCooldown()
        _widget:UpdateStateDelayed(0.01)
    end)
end

---@param widget ButtonUIWidget
---@param rowNum number The row number
---@param colNum number The column number
local function SetButtonLayout(widget, rowNum, colNum)
    ---@type FrameWidget
    local dragFrame = widget.dragFrame
    local barConfig = dragFrame:GetConfig()
    local buttonSize = barConfig.widget.buttonSize
    local buttonPadding = widget.buttonPadding
    local frameStrata = widget.frameStrata
    local button = widget.button
    local dragFrameWidget = widget.dragFrame

    local widthPaddingAdj = dragFrameWidget.padding
    local heightPaddingAdj = dragFrameWidget.padding + dragFrameWidget.dragHandleHeight
    local widthAdj = ((colNum - 1) * buttonSize) + widthPaddingAdj
    local heightAdj = ((rowNum - 1) * buttonSize) + heightPaddingAdj

    button:SetFrameStrata(frameStrata)
    button:SetSize(buttonSize - buttonPadding, buttonSize - buttonPadding)
    button:SetPoint(TOPLEFT, dragFrameWidget.frame, TOPLEFT, widthAdj, -heightAdj)
end

local function CreateFontString(button)
    local fs = button:CreateFontString(button:GetName() .. 'Text', nil, "NumberFontNormal")
    fs:SetPoint("BOTTOMRIGHT",-3, 2)
    button.text = fs
end

--[[-----------------------------------------------------------------------------
Widget Methods
-------------------------------------------------------------------------------]]
---@param widget ButtonUIWidget
local function WidgetMethods(widget)

    function widget:GetName() return self.button:GetName() end
    function widget:IsParentFrameShown() return self.dragFrame:IsShown() end

    ---#### Get Profile Button Config Data
    ---@return ProfileButton
    function widget:GetConfig()
        return self.buttonData:GetData()
    end

    function widget:SetText(text)
        if text == nil then text = '' end
        widget.button.text:SetText(text)
    end
    function widget:ClearText() self:SetText('') end

    ---@return CooldownInfo
    function widget:GetCooldownInfo()
        local btnData = self:GetConfig()
        if btnData == nil or String.IsBlank(btnData.type) then return nil end
        local type = btnData.type

        ---@class CooldownInfo
        local cd = {
            start=nil,
            duration=nil,
            enabled=0,
            details = {}
        }
        if type == SPELL then
            ---@type SpellCooldown
            local spellCD = self:GetSpellCooldown()
            if spellCD ~= nil then
                cd.details = spellCD
                cd.start = spellCD.start
                cd.duration = spellCD.duration
                cd.enabled = spellCD.enabled
                return cd
            end
        elseif type == ITEM then
            ---@type ItemCooldown
            local itemCD = self:GetItemCooldown()
            if itemCD ~= nil then
                cd.details = itemCD
                cd.start = itemCD.start
                cd.duration = itemCD.duration
                cd.enabled = itemCD.enabled
                return cd
            end
        end

        return nil
    end

    function widget:GetSpellData()
        local btnData = self:GetConfig()
        if invalidButtonData(btnData, SPELL) then return nil end
        return btnData[SPELL]
    end

    function widget:GetItemData()
        local btnData = self:GetConfig()
        if invalidButtonData(btnData, ITEM) then return nil end
        return btnData[ITEM]
    end

    function widget:SetButtonAsEmpty()
        self:ResetConfig()
        self:SetTextureAsEmpty()
    end

    function widget:ResetConfig()
        P:ResetButtonData(self)
        self:ResetWidgetAttributes()
    end

    ---@return ActionBarInfo
    function widget:GetActionbarInfo()
        local index = self.index
        local dragFrame = self.dragFrame;
        local frameName = dragFrame:GetName()
        local btnName = format('%sButton%s', frameName, tostring(index))

        ---@class ActionBarInfo
        local info = {
            name = frameName, index = dragFrame:GetFrameIndex(),
            button = { name = btnName, index = index },
        }
        return info
    end

    function widget:Reset()
        self:ResetCooldown()
        self:ClearText()
    end

    function widget:ResetCooldown() self:SetCooldown(0, 0) end
    function widget:SetCooldown(start, duration) self.cooldown:SetCooldown(start, duration) end
    function widget:UpdateUsable() WU:UpdateUsable(self) end
    function widget:UpdateState()
        self:UpdateCooldown()
        self:UpdateItemState()
        self:UpdateUsable()
    end
    function widget:UpdateStateDelayed(inSeconds)
        C_Timer.After(inSeconds, function() self:UpdateState() end)
    end

    function widget:UpdateCooldown()
        local cd = self:GetCooldownInfo()
        if not cd or cd.enabled == 0 then return end
        -- Instant cast spells have zero duration, skip
        if cd.duration <= 0 then
            self:ResetCooldown()
            return
        end
        self:SetCooldown(cd.start, cd.duration)
    end

    function widget:UpdateItemState()
        self:ClearText()
        local btnData = self:GetConfig()
        if invalidButtonData(btnData, ITEM) then return end
        local itemID = btnData.item.id
        local itemInfo = _API:GetItemInfo(itemID)
        if itemInfo == nil then return end
        local stackCount = itemInfo.stackCount or 1
        btnData.item.count = itemInfo.count
        btnData.item.stackCount = stackCount
        if stackCount > 1 then self:SetText(btnData.item.count) end
    end

    ---@return SpellCooldown
    function widget:GetSpellCooldown()
        local spell = self:GetSpellData()
        if not spell then return nil end
        return _API:GetSpellCooldown(spell.id, spell)
    end
    ---@return ItemCooldown
    function widget:GetItemCooldown()
        local item = self:GetItemData()
        if not item then return nil end
        return _API:GetItemCooldown(item.id, item)
    end

    function widget:ResetWidgetAttributes()
        for _, v in pairs(self.buttonAttributes) do
            self.button:SetAttribute(v, nil)
        end
    end

    function widget:HasActionAssigned()
        local d = self.buttonData:GetData()
        local type = d.type
        if String:IsBlank(type) then return false end
        local spellDetails = d[type]
        if Table.size(spellDetails) <= 0 then return false end
        return true
    end

    function widget:ClearHighlight() self.button:SetHighlightTexture(nil) end
    function widget:ResetHighlight() WU:ResetHighlight(self) end
    function widget:SetTextureAsEmpty() self:SetTextures(noIconTexture) end
    function widget:SetTextures(icon) WU:SetTextures(self, icon) end
    function widget:SetHighlightInUse() WU:SetHighlightInUse(self.button) end
    function widget:SetHighlightDefault() WU:SetHighlightDefault(self.button) end
    function widget:IsMatchingItemSpell(profileButton, spellID) return WU:IsMatchingItemSpell(profileButton, spellID) end
    function widget:IsMatchingSpell(profileButton, spellID) return WU:IsMatchingSpell(profileButton, spellID) end

    ---@param rowNum number
    ---@param colNum number
    function widget:Resize(rowNum, colNum)
        SetButtonLayout(self, rowNum, colNum)
    end
end

--[[-----------------------------------------------------------------------------
Builder Methods
-------------------------------------------------------------------------------]]
---@class ButtonUIWidgetBuilder
local _B = LogFactory:NewLogger('ButtonUIWidgetBuilder', {})

---Creates a new ButtonUI
---@param dragFrameWidget FrameWidget The drag frame this button is attached to
---@param rowNum number The row number
---@param colNum number The column number
---@param btnIndex number The button numeric index
---@return ButtonUIWidget
function _B:Create(dragFrameWidget, rowNum, colNum, btnIndex)

    local frameName = dragFrameWidget:GetName()
    local btnName = format('%sButton%s', frameName, tostring(btnIndex))

    ---@class ButtonUI
    local button = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)



    AceHook:SecureHookScript(button, 'OnClick', OnClick)
    button:SetScript('OnDragStart', OnDragStart)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
    button:SetScript('OnLeave', OnLeave)
    CreateFontString(button)
    button:RegisterForDrag('LeftButton')

    ---@class Cooldown
    local cooldown = CreateFrame("Cooldown", btnName .. 'Cooldown', button,  "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetSwipeColor(1, 1, 1)

    ---@class ButtonUIWidget
    local widget = {
        ---@type Logger
        p = p,
        ---@type Profile
        profile = P,
        ---@type number
        index = btnIndex,
        ---@type number
        frameIndex = dragFrameWidget:GetFrameIndex(),
        --@type string
        buttonName = btnName,
        ---@type FrameWidget
        dragFrame = dragFrameWidget,
        ---@type ButtonUI
        button = button,
        ---@type ButtonUI
        frame = button,
        ---@type Cooldown
        cooldown = cooldown,
        ---@type table
        cooldownInfo = nil,
        ---Don't make this 'LOW'. ElvUI AFK Disables it after coming back from AFK
        ---@type string
        frameStrata = 'MEDIUM',
        ---@type number
        buttonPadding = 2,
        ---@type table
        buttonAttributes = CC.ButtonAttributes,
    }
    AceEvent:Embed(widget)

    ---@type ButtonData
    local buttonData = ButtonDataBuilder:Create(widget)
    widget.buttonData =  buttonData

    button.widget, cooldown.widget, buttonData.widget = widget, widget, widget

    --for method, func in pairs(methods) do widget[method] = func end
    WidgetMethods(widget)
    SetButtonLayout(widget, rowNum, colNum)
    widget:SetTextures(noIconTexture)

    RegisterWidget(widget, btnName .. '::Widget')
    RegisterCallbacks(widget)

    return widget
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@return ButtonUILib
local function NewLibrary()

    ---@class ButtonUILib
    local _L = LibStub:NewLibrary(M.ButtonUI, 1)

    ---@return ButtonUIWidgetBuilder
    function _L:WidgetBuilder() return _B end

    return _L
end

NewLibrary()

