--[[-----------------------------------------------------------------------------
WoW Vars
-------------------------------------------------------------------------------]]
local PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent =
    PickupSpell, ClearCursor, GetCursorInfo, CreateFrame, UIParent
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
    GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show
local InCombatLockdown, GameFontHighlightSmallOutline = InCombatLockdown, GameFontHighlightSmallOutline
local GetMacroSpell, GetMacroItem, GetItemInfoInstant = GetMacroSpell, GetMacroItem, GetItemInfoInstant

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
local WU = ABP_LibGlobals:LibPack_WidgetUtil()
local E = ABP_WidgetConstants.E

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
        --p:log(20, 'Received drag event with invalid cursor info. Skipping...')w
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

    if InCombatLockdown() or not WU:IsDragKeyDown() then return end
    w:Reset()
    p:log(20, 'DragStarted| Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()))

    local btnData = btnUI.widget:GetConfig()
    PH:Pickup(btnData)

    w:SetButtonAsEmpty()
    btnUI.widget:Fire('OnDragStart')
end

--- Used with `button:RegisterForDrag('LeftButton')`
---@param btnUI ButtonUI
local function OnReceiveDrag(btnUI)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')
    --p:log('OnReceiveDrag|_state_type: %s', pformat(btnUI._state_type))

    -- TODO: Move to TBC/API
    local actionType, info1, info2, info3 = GetCursorInfo()

    local cursorInfo = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }
    --p:log(20, 'OnReceiveDrag Cursor-Info: %s', ToStringSorted(cursorInfo))
    if not IsValidDragSource(cursorInfo) then return end
    ClearCursor()

    ---@type ReceiveDragEventHandler
    local dragEventHandler = W:LibPack_ReceiveDragEventHandler()
    dragEventHandler:Handle(btnUI, actionType, cursorInfo)

    btnUI.widget:Fire('OnReceiveDrag')
end

---@param widget ButtonUIWidget
---@param down boolean true if the press is KeyDown
local function RegisterForClicks(widget, event, down)
    if E.ON_LEAVE == event then
        widget.button:RegisterForClicks('AnyDown')
    elseif E.ON_ENTER == event then
        widget.button:RegisterForClicks(WU:IsDragKeyDown() and 'AnyUp' or 'AnyDown')
    elseif E.MODIFIER_STATE_CHANGED == event or 'PreClick' == event then
        widget.button:RegisterForClicks(down and WU:IsDragKeyDown() and 'AnyUp' or 'AnyDown')
    end
end

---@param widget ButtonUIWidget
local function OnEnter(widget)
    RegisterForClicks(widget, E.ON_ENTER)
    -- handle stuff before event
    ---@param down boolean true if the press is KeyDown
    widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, function(w, event, mouseButton, down)
        RegisterForClicks(w, E.MODIFIER_STATE_CHANGED, down)
    end, widget)
end

---@param widget ButtonUIWidget
local function OnLeave(widget)
    widget:UnregisterEvent(E.MODIFIER_STATE_CHANGED)
    RegisterForClicks(widget, E.ON_LEAVE)
end

local function OnClick(btn, mouseButton, down)
    --p:log(20, 'SecureHookScript| Actionbar: %s', pformat(btn.widget:GetActionbarInfo()))
    btn:RegisterForClicks(WU:IsDragKeyDown() and 'AnyUp' or 'AnyDown')
    if not PH:IsPickingUpSomething() then return end
    OnReceiveDrag(btn)
end

local function invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return (String.IsBlank(d['id']) and String.IsBlank(d['index'])) end
    end
    return true
end

---@param widget ButtonUIWidget
---@param event string Event string
local function OnUpdateButtonCooldown(widget, event)
    widget:UpdateCooldown()
    local cd = widget:GetCooldownInfo();
    if (cd == nil or cd.icon == nil) then return end
    widget:SetCooldownTextures(cd.icon)
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
    if widget:IsMatchingItemSpellID(spellID, profileButton)
            or widget:IsMatchingSpellID(spellID, profileButton) then
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
    local profileButton = widget:GetConfig()
    if widget:IsMatchingItemSpellID(spellID, profileButton)
            or widget:IsMatchingSpellID(spellID, profileButton) then
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
---Font Flags: OUTLINE, THICKOUTLINE, MONOCHROME
---@see "https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont"
---@param b ButtonUI The button UI
local function CreateIndexTextFontString(b)
    local font = LSM:Fetch(LSM.MediaType.FONT, LSM.DefaultMedia.font)
    local fs = b:CreateFontString(b, "OVERLAY", "NumberFontNormalSmallGray")
    local fontName, fontHeight = fs:GetFont()
    fs:SetFont(fontName, fontHeight - 1, "OUTLINE")
    --fs:SetFont(font, 9, "THICKOUTLINE")
    fs:SetTextColor(100/255, 100/255, 100/255)
    --fs:SetTextColor(200/255, 200/255, 200/255)
    fs:SetPoint("BOTTOMLEFT", 4, 4)
    return fs
end

---Font Flags: OUTLINE, THICKOUTLINE, MONOCHROME
---@see "https://wowpedia.fandom.com/wiki/API_FontInstance_SetFont"
---@param b ButtonUI The button UI
local function CreateKeybindTextFontString(b)
    local fs = b:CreateFontString(b, "OVERLAY", "NumberFontNormalSmallGray")
    --local fontName, fontHeight, fontFlags = fs:GetFont()
    --fs:SetFont(fontName, fontHeight, "OUTLINE")
    fs:SetTextColor(200/255, 200/255, 200/255)
    fs:SetPoint("TOP", 2, -2)
    return fs
end

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

---@param button ButtonUI
local function RegisterScripts(button)
    AceHook:SecureHookScript(button, 'OnClick', OnClick)

    ---@param btn ButtonUI
    button:SetScript("PreClick", function(btn, mouseButton, down)
        -- This prevents the button from being clicked
        -- on sequential drag-and-drops (one after another)
        if PH:IsPickingUpSomething(btn) then btn:SetAttribute("type", "empty") end
        RegisterForClicks(btn.widget, 'PreClick', down)
    end)

    button:SetScript('OnDragStart', OnDragStart)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)

    ---@param b ButtonUI
    button:SetScript(E.ON_ENTER, function(b)
        OnEnter(b.widget)
        ---Receiver will get a func(widget, event) {}
        b.widget:Fire(E.ON_ENTER)
    end)
    ---@param b ButtonUI
    button:SetScript(E.ON_LEAVE, function(b)
        OnLeave(b.widget)
        ---Receiver will get a func(widget, event) {}
        b.widget:Fire(E.ON_LEAVE)
    end)

end

local function RegisterCallbacks(widget)

    --TODO: Tracks changing spells such as Covenant abilities in Shadowlands.
    --SPELL_UPDATE_ICON

    widget:RegisterEvent(E.SPELL_UPDATE_COOLDOWN, OnUpdateButtonCooldown, widget)
    widget:RegisterEvent(E.SPELL_UPDATE_USABLE, OnUpdateButtonUsable, widget)

    widget:RegisterEvent(E.BAG_UPDATE_DELAYED, OnBagUpdateDelayed, widget)
    widget:RegisterEvent(E.UNIT_SPELLCAST_START, OnSpellCastStart, widget)
    widget:RegisterEvent(E.UNIT_SPELLCAST_STOP, OnSpellCastStop, widget)
    widget:RegisterEvent(E.PLAYER_CONTROL_LOST, OnPlayerControlLost, widget)
    widget:RegisterEvent(E.PLAYER_CONTROL_GAINED, OnPlayerControlGained, widget)

    ---@param _widget ButtonUIWidget
    widget:SetCallback(E.ON_RECEIVE_DRAG, function(_widget)
        p:log('drag')
        _widget:UpdateStateDelayed(0.01)
    end)

    ---@param _widget ButtonUIWidget
    ---@param event string
    widget:RegisterEvent(E.UNIT_SPELLCAST_SENT, function(_widget, event, ...)
        local castingUnit, target, castGUID, spellID = ...
        if not ('player' == castingUnit and _widget:IsMatchingSpellID(spellID)) then return end
        _widget.button:SetButtonState('NORMAL')
    end, widget)

    ---@param _widget ButtonUIWidget
    ---@param event string
    widget:RegisterEvent(E.UNIT_SPELLCAST_FAILED_QUIET, function(_widget, event, ...)
        --p:log('%s', event)
        local unitTarget, castGUID, spellID = ...
        if not 'player' == unitTarget then return end
        if _widget:IsTypeMacro() and _widget:IsMatchingMacroSpellID(spellID) then
            p:log('macro')
            _widget.button:SetButtonState('NORMAL')
            return
        end
        if _widget:IsMatchingSpellID(spellID) then return end
        _widget.button:SetButtonState('NORMAL')
        --p:log('spell')
    end, widget)

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
    function widget:GetIndex() return self.index end
    function widget:GetFrameIndex() return self.dragFrameWidget:GetIndex() end

    function widget:IsParentFrameShown() return self.dragFrame:IsShown() end

    function widget:IsTypeMacro() return MACRO == self:GetConfig().type end
    function widget:IsTypeSpell() return SPELL == self:GetConfig().type end
    function widget:IsTypeItem() return ITEM == self:GetConfig().type end

    ---@type BindingInfo
    function widget:GetBindings()
        return (self.addon.barBindings and self.addon.barBindings[self.buttonName]) or nil
    end
    ---@param text string
    function widget:SetText(text)
        if String.IsBlank(text) then text = '' end
        widget.button.text:SetText(text)
    end
    ---@param state boolean true will show the button index number
    function widget:ShowIndex(state)
        local text = ''
        if true == state then text = widget.index end
        widget.button.indexText:SetText(text)
    end
    ---@param state boolean true will show the button index number
    function widget:ShowKeybindText(state)
        local text = ''
        if not self:HasKeybindings() then
            widget.button.keybindText:SetText(text)
            return
        end

        if true == state then
            local bindings = self:GetBindings()
            if bindings and bindings.key1Short then
                text = bindings.key1Short
            end
        end
        widget.button.keybindText:SetText(text)
    end
    function widget:HasKeybindings()
        local b = self:GetBindings()
        if not b then return false end
        return b and String.IsNotBlank(b.key1)
    end
    function widget:ClearText() self:SetText('') end

    ---@return CooldownInfo
    function widget:GetCooldownInfo()
        local btnData = self:GetConfig()
        if btnData == nil or String.IsBlank(btnData.type) then return nil end
        local type = btnData.type

        ---@class CooldownInfo
        local cd = {
            type=type,
            start=nil,
            duration=nil,
            enabled=0,
            details = {}
        }
        if type == SPELL then return self:GetSpellCooldown(cd)
        elseif type == MACRO then return self:GetMacroCooldown(cd)
        elseif type == ITEM then return self:GetItemCooldown(cd)
        end
        return nil
    end

    ---@param cd CooldownInfo The cooldown info
    ---@return SpellCooldown
    function widget:GetSpellCooldown(cd)
        local spell = self:GetSpellData()
        if not spell then return nil end
        local spellCD = _API:GetSpellCooldown(spell.id, spell)
        if spellCD ~= nil then
            cd.details = spellCD
            cd.start = spellCD.start
            cd.duration = spellCD.duration
            cd.enabled = spellCD.enabled
            return cd
        end
        return nil
    end

    ---@param cd CooldownInfo The cooldown info
    ---@return ItemCooldown
    function widget:GetItemCooldown(cd)
        local item = self:GetItemData()
        if not item then return nil end
        local itemCD = _API:GetItemCooldown(item.id, item)
        if itemCD ~= nil then
            cd.details = itemCD
            cd.start = itemCD.start
            cd.duration = itemCD.duration
            cd.enabled = itemCD.enabled
            return cd
        end
        return nil
    end

    ---@param cd CooldownInfo The cooldown info
    function widget:GetMacroCooldown(cd)
        local spellCD = self:GetMacroSpellCooldown();

        if spellCD ~= nil then
            cd.details = spellCD
            cd.start = spellCD.start
            cd.duration = spellCD.duration
            cd.enabled = spellCD.enabled
            cd.icon = spellCD.spell.icon
            return cd
        else
            local itemCD = self:GetMacroItemCooldown()
            if itemCD ~= nil then
                cd.details = itemCD
                cd.start = itemCD.start
                cd.duration = itemCD.duration
                cd.enabled = itemCD.enabled
                return cd
            end
        end

        return nil;
    end

    ---@return SpellCooldown
    function widget:GetMacroSpellCooldown()
        local macro = self:GetMacroData();
        if not macro then return nil end
        local spellId = GetMacroSpell(macro.index)
        if not spellId then return nil end
        return _API:GetSpellCooldown(spellId)
    end

    ---@return number The spellID for macro
    function widget:GetMacroSpellId()
        local macro = self:GetMacroData();
        if not macro then return nil end
        return GetMacroSpell(macro.index)
    end

    ---@return ItemCooldown
    function widget:GetMacroItemCooldown()
        local macro = self:GetMacroData();
        if not macro then return nil end

        local itemName = GetMacroItem(macro.index)
        if not itemName then return nil end

        local itemID = GetItemInfoInstant(itemName)
        return _API:GetItemCooldown(itemID)
    end

    ---#### Get Profile Button Config Data
    ---@return ProfileButton
    function widget:GetConfig()
        return self.buttonData:GetData()
    end
    function widget:GetConfigActionbarData(type)
        local btnData = self:GetConfig()
        if invalidButtonData(btnData, type) then return nil end
        return btnData[type]
    end

    ---@return SpellData
    function widget:GetSpellData()
        return self:GetConfigActionbarData(SPELL)
    end

    ---@return ItemData
    function widget:GetItemData()
        return self:GetConfigActionbarData(ITEM)
    end

    ---@return MacroData
    function widget:GetMacroData()
        return self:GetConfigActionbarData(MACRO)
        --local btnData = self:GetConfig()
        --return btnData[MACRO];
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

    function widget:UpdateCooldownDelayed(inSeconds)
        C_Timer.After(inSeconds, function() self:UpdateCooldown() end)
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
    function widget:SetTextureAsEmpty() self:SetIcon(noIconTexture) end
    function widget:SetIcon(icon) WU:SetIcon(self, icon) end
    function widget:SetCooldownTextures(icon) WU:SetCooldownTextures(self, icon) end
    function widget:SetHighlightInUse() WU:SetHighlightInUse(self.button) end
    function widget:SetHighlightDefault() WU:SetHighlightDefault(self.button) end
    function widget:IsMatchingItemSpellID(spellID, profileButton)
        return WU:IsMatchingItemSpellID(spellID, profileButton or self:GetConfig())
    end
    function widget:IsMatchingSpellID(spellID, profileButton)
        return WU:IsMatchingSpellID(spellID, profileButton or self:GetConfig())
    end
    function widget:IsMatchingMacroSpellID(spellID, profileButton)
        return WU:IsMatchingMacroSpellID(spellID, profileButton or self:GetConfig())
    end

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
---@param btnIndex number The button index number
---@return ButtonUIWidget
function _B:Create(dragFrameWidget, rowNum, colNum, btnIndex)

    local frameName = dragFrameWidget:GetName()
    local btnName = format('%sButton%s', frameName, tostring(btnIndex))

    ---@class ButtonUI
    local button = CreateFrame("Button", btnName, UIParent, SECURE_ACTION_BUTTON_TEMPLATE)
    button.indexText = CreateIndexTextFontString(button)
    button.keybindText = CreateKeybindTextFontString(button)

    RegisterScripts(button)
    CreateFontString(button)

    button:RegisterForDrag('LeftButton')
    button:RegisterForClicks("AnyDown")

    ---@class Cooldown
    local cooldown = CreateFrame("Cooldown", btnName .. 'Cooldown', button,  "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetSwipeColor(1, 1, 1)
    cooldown:SetCountdownFont(GameFontHighlightSmallOutline:GetFont())
    cooldown:SetDrawEdge(true)
    --cooldown:SetSize(0, 0)
    cooldown:SetEdgeScale(0.0)
    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetUseCircularEdge(false)
    cooldown:SetPoint('CENTER')

    ---@class ButtonUIWidget
    local widget = {
        ---@type ActionbarPlus
        addon = ABP,
        ---@type Logger
        p = p,
        ---@type Profile
        profile = P,
        ---@type number
        index = btnIndex,
        ---@type number
        frameIndex = dragFrameWidget:GetIndex(),
        ---@type string
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

    WU:InitTextures(widget, noIconTexture)

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

