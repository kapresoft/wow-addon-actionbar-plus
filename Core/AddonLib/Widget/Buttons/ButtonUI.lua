--[[-----------------------------------------------------------------------------
WoW Vars
-------------------------------------------------------------------------------]]
local ClearCursor, GetCursorInfo, CreateFrame, UIParent = ClearCursor, GetCursorInfo, CreateFrame, UIParent
local InCombatLockdown, GameFontHighlightSmallOutline = InCombatLockdown, GameFontHighlightSmallOutline
local  C_Timer = C_Timer

--[[-----------------------------------------------------------------------------
LUA Vars
-------------------------------------------------------------------------------]]
local pack, fmod = table.pack, math.fmod
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--local M , G = ABP_LibGlobals:LibPack_Module()

local LibStub, M, LogFactory, G = ABP_LibGlobals:LibPack_UI()
local AceEvent, AceGUI, AceHook = G:LibPack_AceLibrary()
local O = G.O()
local CC = O.CommonConstants()
local A = O.Assert()
local P = O.Profile()
local ButtonDataBuilder = O.ButtonDataBuilder()
local PH = O.PickupHandler()
local String = O.String()
local WC = O.WidgetConstants()
local WMX = O.WidgetMixin()

---@type LoggerTemplate
local p = LogFactory:NewLogger('ButtonUI')

local IsBlank = String.IsBlank
local E = WC.E
local AssertThatMethodArgIsNotNil = A.AssertThatMethodArgIsNotNil
local SECURE_ACTION_BUTTON_TEMPLATE = SECURE_ACTION_BUTTON_TEMPLATE
local SPELL, ITEM, MACRO = WC:LibPack_SpellItemMacro()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ButtonUIWidgetBuilder : WidgetMixin
local _B = LibStub:NewLibrary(M.ButtonUIWidgetBuilder)
WMX:Mixin(_B)

---@class ButtonUILib
local _L = LibStub:NewLibrary(M.ButtonUI, 1)

---@return ButtonUIWidgetBuilder
function _L:WidgetBuilder() return _B end

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

---@param widget ButtonUIWidget
---@param down boolean true if the press is KeyDown
local function RegisterForClicks(widget, event, down)
    if E.ON_LEAVE == event then
        widget.button:RegisterForClicks('AnyDown')
    elseif E.ON_ENTER == event then
        widget.button:RegisterForClicks(WMX:IsDragKeyDown() and 'AnyUp' or 'AnyDown')
    elseif E.MODIFIER_STATE_CHANGED == event or 'PreClick' == event then
        widget.button:RegisterForClicks(down and WMX:IsDragKeyDown() and 'AnyUp' or 'AnyDown')
    end
end

---@param btn ButtonUI
---@param key string The key clicked
---@param down boolean true if the press is KeyDown
local function OnPreClick(btn, key, down)
    -- This prevents the button from being clicked
    -- on sequential drag-and-drops (one after another)
    if PH:IsPickingUpSomething(btn) then btn:SetAttribute("type", "empty") end
    RegisterForClicks(btn.widget, 'PreClick', down)
end

---@param btnUI ButtonUI
local function OnDragStart(btnUI)
    ---@type ButtonUIWidget
    local w = btnUI.widget

    if InCombatLockdown() or not WMX:IsDragKeyDown() then return end
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
    local dragEventHandler = G(M.ReceiveDragEventHandler)
    dragEventHandler:Handle(btnUI, actionType, cursorInfo)

    btnUI.widget:Fire('OnReceiveDrag')
end

---Triggered by SetCallback('event', fn)
---@param widget ButtonUIWidget
local function OnReceiveDragCallback(widget) widget:UpdateStateDelayed(0.01) end

---@param widget ButtonUIWidget
---@param down boolean true if the press is KeyDown
local function OnModifierStateChanged(widget, down)
    RegisterForClicks(widget, E.MODIFIER_STATE_CHANGED, down)
    if widget:IsMacro() then
        C_Timer.After(0.05, function() widget:Fire('OnModifierStateChanged') end)
    end
end

---@param widget ButtonUIWidget
local function OnModifierStateChangedCallback(widget, event)
    local scd = widget:GetMacroSpellCooldown()
    if not (scd and scd.spell) then return end
    --p:log('OnModifierStateChangedCallback: update cooldown: %s', scd.spell.name)
    widget:SetIcon(scd.spell.icon)
    widget:UpdateCooldown()
end

---@param widget ButtonUIWidget
local function OnBeforeEnter(widget)
    RegisterForClicks(widget, E.ON_ENTER)
    widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, OnModifierStateChanged, widget)

    -- handle stuff before event
    ---@param down boolean true if the press is KeyDown
    --widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, function(w, event, key, down)
    --    RegisterForClicks(w, E.MODIFIER_STATE_CHANGED, down)
    --end, widget)
end
---@param widget ButtonUIWidget
local function OnBeforeLeave(widget)
    --RegisterMacroEvent(widget)
    if not widget:IsMacro() then
        --widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, OnModifierStateChanged, widget)
        widget:UnregisterEvent(E.MODIFIER_STATE_CHANGED)
    end
    RegisterForClicks(widget, E.ON_LEAVE)
end
---@param btn ButtonUI
function OnEnter(btn)
    OnBeforeEnter(btn.widget)
    ---Receiver will get a func(widget, event) {}
    btn.widget:Fire(E.ON_ENTER)
end
---@param btn ButtonUI
function OnEnter(btn)
    OnBeforeEnter(btn.widget)
    ---Receiver will get a func(widget, event) {}
    btn.widget:Fire(E.ON_ENTER)
end
---@param btn ButtonUI
function OnLeave(btn)
    OnBeforeLeave(btn.widget)
    ---Receiver will get a func(widget, event) {}
    btn.widget:Fire(E.ON_LEAVE)
end

local function OnClick_SecureHookScript(btn, mouseButton, down)
    --p:log(20, 'SecureHookScript| Actionbar: %s', pformat(btn.widget:GetActionbarInfo()))
    btn:RegisterForClicks(WMX:IsDragKeyDown() and 'AnyUp' or 'AnyDown')
    if not PH:IsPickingUpSomething() then return end
    OnReceiveDrag(btn)
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
    widget:UpdateUsable()
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

---@param widget ButtonUIWidget
---@param event string
local function OnPlayerControlLost(widget, event, ...)
    if not widget.buttonData:IsHideWhenTaxi() then return end
    WMX:SetEnabledActionBarStatesDelayed(false, 1)
end

---@param widget ButtonUIWidget
---@param event string
local function OnPlayerControlGained(widget, event, ...)
    --p:log('Event[%s] received flying=%s', event, flying)
    if not widget.buttonData:IsHideWhenTaxi() then return end
    WMX:SetEnabledActionBarStatesDelayed(true, 2)
end

---@param widget ButtonUIWidget
---@param event string
local function OnSpellCastSent(widget, event, ...)
    local castingUnit, _, _, spellID = ...
    if not 'player' == castingUnit then return end
    if not ('player' == castingUnit and widget:IsMatchingMacroOrSpell(spellID)) then return end
    widget.button:SetButtonState('NORMAL')

    C_Timer.After(0.5, function()
        widget:Fire('OnAfterSpellCastSent')
    end)
end

---@param widget ButtonUIWidget
---@param event string
local function OnSpellCastFailedQuiet(widget, event, ...)
    local castingUnit, _, spellID = ...
    if not 'player' == castingUnit then return end
    if not ('player' == castingUnit and widget:IsMatchingMacroOrSpell(spellID)) then return end

    widget.button:SetButtonState('NORMAL')
end

---@see "UnitDocumentation.lua"
---@param widget ButtonUIWidget
---@param event string
local function OnPlayerTargetChanged(widget, event)
    widget:UpdateRangeIndicator()
end

---@see "UnitDocumentation.lua"
---@param widget ButtonUIWidget
---@param event string
local function OnPlayerTargetChangedDelayed(widget, event)
    C_Timer.After(0.1, function() OnPlayerTargetChanged(widget, event) end)
end
local function OnPlayerStartedMoving(widget, event) OnPlayerTargetChangedDelayed(widget, event) end
local function OnPlayerStoppedMoving(widget, event) OnPlayerTargetChangedDelayed(widget, event) end
local function OnCombatLogEventUnfiltered(widget, event) OnPlayerTargetChangedDelayed(widget, event) end
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

---@param button ButtonUI
local function RegisterScripts(button)
    AceHook:SecureHookScript(button, 'OnClick', OnClick_SecureHookScript)

    button:SetScript("PreClick", OnPreClick)
    button:SetScript('OnDragStart', OnDragStart)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
    button:SetScript(E.ON_ENTER, OnEnter)
    button:SetScript(E.ON_LEAVE, OnLeave)

end

---@param w ButtonUIWidget
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
    widget:RegisterEvent(E.UNIT_SPELLCAST_SENT, OnSpellCastSent, widget)
    widget:RegisterEvent(E.UNIT_SPELLCAST_FAILED_QUIET, OnSpellCastFailedQuiet, widget)
    widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, OnModifierStateChanged, widget)
    widget:RegisterEvent(E.PLAYER_TARGET_CHANGED, OnPlayerTargetChanged, widget)
    widget:RegisterEvent(E.PLAYER_STARTED_MOVING, OnPlayerStartedMoving, widget)
    widget:RegisterEvent(E.PLAYER_STOPPED_MOVING, OnPlayerStoppedMoving, widget)
    widget:RegisterEvent(E.UNIT_HEALTH, OnPlayerStartedMoving, widget)
    widget:RegisterEvent(E.COMBAT_LOG_EVENT_UNFILTERED, OnCombatLogEventUnfiltered, widget)

    -- Callbacks (fired via Ace Events)
    widget:SetCallback(E.ON_RECEIVE_DRAG, OnReceiveDragCallback)
    widget:SetCallback(E.ON_MODIFIER_STATE_CHANGED, OnModifierStateChangedCallback)
end

--[[-----------------------------------------------------------------------------
Widget Methods
-------------------------------------------------------------------------------]]
---@param widget ButtonUIWidget
local function ApplyMixins(widget) G:Mixin(widget, G:LibPack_ButtonMixin()) end

--[[-----------------------------------------------------------------------------
Builder Methods
-------------------------------------------------------------------------------]]

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
    button.indexText = self:CreateIndexTextFontString(button)
    button.keybindText = self:CreateKeybindTextFontString(button)

    RegisterScripts(button)
    self:CreateFontString(button)

    button:RegisterForDrag("LeftButton", "RightButton");
    button:RegisterForClicks("AnyDown");

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

    ---@class ButtonUIWidget : ButtonMixin @ButtonUIWidget extends ButtonMixin
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
        placement = { rowNum = rowNum, colNum = colNum },
    }
    AceEvent:Embed(widget)
    function widget:GetName() return self.button:GetName() end

    ---@type ButtonData
    local buttonData = ButtonDataBuilder:Create(widget)
    widget.buttonData =  buttonData
    button.widget, cooldown.widget, buttonData.widget = widget, widget, widget

    --for method, func in pairs(methods) do widget[method] = func end
    ApplyMixins(widget)
    RegisterWidget(widget, btnName .. '::Widget')
    RegisterCallbacks(widget)
    widget:Init()

    return widget
end
