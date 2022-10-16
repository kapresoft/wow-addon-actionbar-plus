--[[-----------------------------------------------------------------------------
WoW Vars
-------------------------------------------------------------------------------]]
local ClearCursor, CreateFrame, UIParent = ClearCursor, CreateFrame, UIParent
local InCombatLockdown, GameFontHighlightSmallOutline = InCombatLockdown, GameFontHighlightSmallOutline
local C_Timer, C_PetJournal = C_Timer, C_PetJournal

--[[-----------------------------------------------------------------------------
LUA Vars
-------------------------------------------------------------------------------]]
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local LogFactory = O.LogFactory
local AO = O.AceLibFactory:A()
local AceEvent, AceGUI, AceHook = AO.AceEvent, AO.AceGUI, AO.AceHook

local String = O.String
local A, P, PH = O.Assert, O.Profile, O.PickupHandler
local GC, WMX = O.GlobalConstants, O.WidgetMixin
local E, API = GC.E, O.API

local IsBlank = String.IsBlank
local AssertThatMethodArgIsNotNil = A.AssertThatMethodArgIsNotNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ButtonUIWidgetBuilder : WidgetMixin
local _B = LibStub:NewLibrary(Core.M.ButtonUIWidgetBuilder)

---@class ButtonUILib
local _L = LibStub:NewLibrary(Core.M.ButtonUI, 1)
local p = LogFactory:NewLogger(Core.M.ButtonUI)

---@return ButtonUIWidgetBuilder
function _L:WidgetBuilder() return _B end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
---@param cursorInfo CursorInfo
local function IsValidDragSource(cursorInfo)
    --p:log("IsValidDragSource| CursorInfo=%s", cursorInfo)
    if not cursorInfo or IsBlank(cursorInfo.type) then
        -- This can happen if a chat tab or others is dragged into
        -- the action bar.
        --p:log(20, 'Received drag event with invalid cursor info. Skipping...')w
        return false
    end
    return O.ReceiveDragEventHandler:IsSupportedCursorType(cursorInfo)
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
    if btn.widget:IsBattlePet() and C_PetJournal then
        C_PetJournal.SummonPetByGUID(btn.widget:GetButtonData():GetBattlePetInfo().guid)
        return
    end
    -- This prevents the button from being clicked
    -- on sequential drag-and-drops (one after another)
    if PH:IsPickingUpSomething(btn) then btn:SetAttribute("type", "empty") end
    RegisterForClicks(btn.widget, 'PreClick', down)
end

---@param btnUI ButtonUI
local function OnDragStart(btnUI)
    ---@type ButtonUIWidget
    local w = btnUI.widget
    if w:IsEmpty() then return end

    if InCombatLockdown() or not WMX:IsDragKeyDown() then return end
    w:Reset()
    p:log(20, 'DragStarted| Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()))

    PH:Pickup(btnUI.widget)

    w:SetButtonAsEmpty()
    w:ShowEmptyGrid()
    w:ShowKeybindText(true)
    w:Fire('OnDragStart')
end

--- Used with `button:RegisterForDrag('LeftButton')`
---@param btnUI ButtonUI
local function OnReceiveDrag(btnUI)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')
    local cursorUtil = ns:CreateCursorUtil()
    if not cursorUtil:IsValid() then
        p:log(10, 'OnReceiveDrag| CursorInfo: %s isValid: false', pformat:B()(cursorUtil:GetCursor()))
        return false
    else
        p:log(1, 'OnReceiveDrag| CursorInfo: %s', pformat:B()(cursorUtil:GetCursor()))
    end
    ClearCursor()

    ---@type ReceiveDragEventHandler
    O.ReceiveDragEventHandler:Handle(btnUI, cursorUtil)

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
local function OnEnter(btn)
    OnBeforeEnter(btn.widget)
    ---Receiver will get a func(widget, event) {}
    btn.widget:Fire(E.ON_ENTER)
end
---@param btn ButtonUI
local function OnLeave(btn)
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
local function OnUpdateButtonUsable(widget, event)
    if not widget.button:IsShown() then return end
    widget:UpdateUsable()
end

---@param widget ButtonUIWidget
---@param event string Event string
local function OnSpellUpdateUsable(widget, event)
    if not widget.button:IsShown() then return end
    --p:log('xOnSpellUpdateUsable[f_%s_%s]: %s',
    --        widget.frameIndex, widget.index, GetTime())
    widget:UpdateRangeIndicator()

    OnUpdateButtonUsable(widget, event)
end

---@param widget ButtonUIWidget
---@param event string Event string
local function OnBagUpdateDelayed(widget, event)
    if not widget.button:IsShown() then return end
    widget:UpdateItemState()
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

---@see "UnitDocumentation.lua"
---@param widget ButtonUIWidget
---@param event string
local function OnPlayerTargetChanged(widget, event) widget:UpdateRangeIndicator() end

---@see "UnitDocumentation.lua"
---@param widget ButtonUIWidget
---@param event string
local function OnPlayerTargetChangedDelayed(widget, event)
    C_Timer.After(0.1, function() OnPlayerTargetChanged(widget, event) end)
end
local function OnPlayerStartedMoving(widget, event) OnPlayerTargetChangedDelayed(widget, event) end
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
    --button:SetScript("PostClick", function(btn, key, down)
    --    p:log('buttonState: %s', btn:GetButtonState())
    --    local spellID = btn:GetAttribute("spell")
    --    if not spellID then return end
    --    p:log('spell: %s', spellID)
    --    p:log('spell-cd: %s', { GetSpellCooldown(spellID) })
    --    local start = GetSpellCooldown(spellID)
    --    if start == 0 then
    --        button.widget:SetHighlightInUse()
    --    end
    --end)
    button:SetScript('OnDragStart', OnDragStart)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
    button:SetScript(E.ON_ENTER, OnEnter)
    button:SetScript(E.ON_LEAVE, OnLeave)

end

---@param widget ButtonUIWidget
local function RegisterCallbacks(widget)

    --TODO: Tracks changing spells such as Covenant abilities in Shadowlands.
    --SPELL_UPDATE_ICON

    --TODO next Move at the frame level
    widget:RegisterEvent(E.SPELL_UPDATE_COOLDOWN, OnUpdateButtonCooldown, widget)
    widget:RegisterEvent(E.SPELL_UPDATE_USABLE, OnSpellUpdateUsable, widget)
    widget:RegisterEvent(E.BAG_UPDATE_DELAYED, OnBagUpdateDelayed, widget)
    widget:RegisterEvent(E.PLAYER_CONTROL_LOST, OnPlayerControlLost, widget)
    widget:RegisterEvent(E.PLAYER_CONTROL_GAINED, OnPlayerControlGained, widget)
    widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, OnModifierStateChanged, widget)
    widget:RegisterEvent(E.PLAYER_STARTED_MOVING, OnPlayerStartedMoving, widget)

    -- Callbacks (fired via Ace Events)
    widget:SetCallback(E.ON_RECEIVE_DRAG, OnReceiveDragCallback)
    widget:SetCallback(E.ON_MODIFIER_STATE_CHANGED, OnModifierStateChangedCallback)

    ---@param w ButtonUIWidget
    widget:SetCallback("OnEnter", function(w)
        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(true)
    end)
    widget:SetCallback("OnLeave", function(w)
        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(false)
    end)
end

--[[-----------------------------------------------------------------------------
Widget Methods
-------------------------------------------------------------------------------]]
---@param widget ButtonUIWidget
local function ApplyMixins(widget) O.ButtonMixin:Mixin(widget) end

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

    ---@class ButtonUI : _Button
    local button = CreateFrame("Button", btnName, UIParent, GC.C.SECURE_ACTION_BUTTON_TEMPLATE)
    button.text = WMX:CreateFontString(button)
    button.indexText = WMX:CreateIndexTextFontString(button)
    button.keybindText = WMX:CreateKeybindTextFontString(button)

    RegisterScripts(button)

    button:RegisterForDrag("LeftButton", "RightButton");
    button:RegisterForClicks("AnyDown");

    ---@class Cooldown
    local cooldown = CreateFrame("Cooldown", btnName .. 'Cooldown', button,  "CooldownFrameTemplate")
    cooldown:SetAllPoints(button)
    cooldown:SetSwipeColor(1, 1, 1)
    cooldown:SetCountdownFont(GameFontHighlightSmallOutline:GetFont())
    cooldown:SetDrawEdge(true)
    cooldown:SetEdgeScale(0.0)
    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetUseCircularEdge(false)
    cooldown:SetPoint('CENTER')

    ---@class ButtonUIWidget : ButtonMixin
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
        frameStrata = dragFrameWidget.frameStrata or 'MEDIUM',
        frameLevel = (dragFrameWidget.frameLevel + 100) or 100,
        ---@type number
        buttonPadding = 2,
        buttonAttributes = GC.ButtonAttributes,
        placement = { rowNum = rowNum, colNum = colNum },
    }
    AceEvent:Embed(widget)
    function widget:GetName() return self.button:GetName() end

    local buttonData = O.ButtonData(widget)
    widget.buttonData =  buttonData
    button.widget, cooldown.widget, buttonData.widget = widget, widget, widget

    --for method, func in pairs(methods) do widget[method] = func end
    ApplyMixins(widget)
    RegisterWidget(widget, btnName .. '::Widget')
    RegisterCallbacks(widget)

    -- This is for mouseover effect
    -----@param w ButtonUIWidget
    --widget:SetCallback("OnEnter", function(w)
    --    w.dragFrame.frame:SetAlpha(1.0)
    --    w.dragFrame:ApplyForEachButtons(function(bw)
    --        bw.button:SetAlpha(1)
    --    end)
    --end)
    -----@param w ButtonUIWidget
    --widget:SetCallback("OnLeave", function(w)
    --    w.dragFrame.frame:SetAlpha(0)
    --    w.dragFrame:ApplyForEachButtons(function(bw)
    --        bw.button:SetAlpha(0.4)
    --    end)
    --end)


    widget:Init()

    return widget
end
