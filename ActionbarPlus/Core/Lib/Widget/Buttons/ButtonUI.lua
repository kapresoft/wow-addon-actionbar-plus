--[[-----------------------------------------------------------------------------
WoW Vars
-------------------------------------------------------------------------------]]
local GetCursorInfo, ClearCursor, CreateFrame, UIParent = GetCursorInfo, ClearCursor, CreateFrame, UIParent
local InCombatLockdown, GameFontHighlightSmallOutline = InCombatLockdown, GameFontHighlightSmallOutline
local C_Timer, C_PetJournal = C_Timer, C_PetJournal

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local E, Ace = GC.E, ns:AceLibrary()
local AceGUI, AceHook = Ace.AceGUI, Ace.AceHook
local A, PH, API = ns:Assert(), O.PickupHandler, O.API
local WMX, ButtonMX = O.WidgetMixin, O.ButtonMixin
local AssertThatMethodArgIsNotNil = A.AssertThatMethodArgIsNotNil
local enableExternalAPI = GC.F.ENABLE_EXTERNAL_API

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ButtonUIWidgetBuilder : WidgetMixin
local _B = LibStub:NewLibrary(M.ButtonUIWidgetBuilder)

local libName = M.ButtonUI
--- @class ButtonUILib
local _L = LibStub:NewLibrary(libName, 1)
local p = ns:LC().BUTTON:NewLogger(libName)
local pe = ns:LC().EVENT:NewLogger(libName)
local ps = ns:LC().SPELL_USABLE:NewLogger(libName)
local pd = ns:LC().DRAG_AND_DROP:NewLogger(libName)

--- @return ButtonUIWidgetBuilder
function _L:WidgetBuilder() return _B end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
---TODO: See the following implementation to mimic keydown
--- - https://wowpedia.fandom.com/wiki/CVar_ActionButtonUseKeyDown
--- - https://www.wowinterface.com/forums/showthread.php?t=58768
--- @param widget ButtonUIWidget
--- @param event string | "'AnyUp'" | "'AnyDown'" | "'PreClick'" | "'PostClick'"
--- @param down boolean|number boolean, 1 or 0
--- @param key string Which key was pressed, i.e. "LeftMouseButton"
local function RegisterForClicks(widget, event, down, key)
    if InCombatLockdown() then return end

    if widget:IsEmpty() then return end
    if down ~= nil then down = down == 1 or down == true end

    widget:UseKeyDownForClicks()

    local useKeyDown = API:IsUseKeyDownActionButton()
    local lockActionBars = API:IsLockActionBars()

    pe:t(function()
        return 'event=%s down=%s key=%s btn=%s lockAB=%s useKD=%s :: RegisterForClicks()',
        event, down, key, widget:GN(), lockActionBars, useKeyDown end)

    --- This has to sync with Blizzard's ActionButton behavior
    --- or else the click won't work
    if lockActionBars ~= true or (O.API:IsDragKeyDown() == true) then
        return widget:UseKeyUpForClicks()
    end
end

--- @param btn ButtonUI
--- @param key string The key clicked
--- @param down boolean true if the press is KeyDown
local function OnPreClick(btn, key, down)
    local w = btn.widget
    w:SendMessage(GC.M.OnButtonBeforePreClick, libName, w)
    if w:IsEmpty() then return end

    if w:IsCompanion() then
        -- WOTLK and below uses 'companion'
        w:SendMessage(GC.M.OnButtonClickCompanion, libName, w)
        return
    elseif w:IsBattlePet() and C_PetJournal then
        -- Retail uses 'battlepet' for both battlepet and companions
        w:SendMessage(GC.M.OnButtonClickBattlePet, libName, w)
        return
    elseif w:IsEquipmentSet() then
        w:SendMessage(GC.M.OnButtonClickEquipmentSet, libName, w)
        return
    elseif w:IsNewLeatherWorkingSpell() then
        w:SendMessage(GC.M.OnButtonClickLeatherworking, libName, w)
        return
    end
    -- This prevents the button from being clicked
    -- on sequential drag-and-drops (one after another)
    if PH:IsPickingUpSomething(btn) then btn:SetAttribute("type", "empty") end

    RegisterForClicks(w, 'PreClick', down, key)

    w:SendMessage(GC.M.OnButtonAfterPreClick, libName, w)
end

--- @param btn ButtonUI
--- @param key string The key clicked
--- @param down boolean true if the press is KeyDown
local function OnPostClick(btn, key, down)
    local w = btn.widget;
    if w:IsEmpty() then return end
    w:SendMessage(GC.M.OnButtonAfterPostClick, ns.M.ButtonUI, w)

    -- todo: M6 integration to be removed
    if not enableExternalAPI then return end
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) O.ActionbarPlusAPI:UpdateM6Macros(handlerFn) end
    w:SendMessage(GC.M.OnButtonPostClickExt, ns.M.ButtonUI, CallbackFn)
end

--- @param btnUI ButtonUI
local function OnDragStart(btnUI)
    if InCombatLockdown() or not O.API:IsDragKeyDown() then return end

    --- @type ButtonUIWidget
    local w = btnUI.widget
    if w:IsEmpty() then return end

    w:Reset()
    pd:d(function() return 'OnDragStart():Actionbar-Info: %s', pformat(btnUI.widget:GetActionbarInfo()) end)

    local conf = w:conf()
    ABP.mountID = conf and conf.mount and conf.mount.id
    PH:Pickup(btnUI.widget)

    w:SetButtonAsEmpty()
    w:ShowEmptyGrid()

    btnUI.widget:SendMessage(GC.M.OnAfterDragStart, libName, w)
end

--- Used with `button:RegisterForDrag('LeftButton')`
--- @param btnUI ButtonUI
local function OnReceiveDrag(btnUI)
    if InCombatLockdown() then return end
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'OnReceiveDrag(btnUI)')
    local cursorUtil = ns:CreateCursorUtil()
    if not cursorUtil:IsValid() then
        pd:f1(function() return 'OnReceiveDrag():CursorInfo: %s isValid: false', pformat:B()(cursorUtil:GetCursor()) end)
        return false
    else
        pd:f1(function() return 'OnReceiveDrag():CursorInfo: %s', pformat:B()(cursorUtil:GetCursor()) end)
    end
    ClearCursor()

    btnUI.widget:ClearAllText()

    --- @type ReceiveDragEventHandler
    O.ReceiveDragEventHandler:Handle(btnUI, cursorUtil)
    btnUI.widget:UpdateDelayed(0.01)

    -- While the modifier key is held down after dragging
    -- we KeyUp will be active to prevent KeyDown from executing the action
    C_Timer.After(0.3, function() btnUI.widget:UseKeyUpForClicks() end)
    btnUI.widget:SendMessage(GC.M.OnAfterReceiveDrag, libName, btnUI.widget)
end

--- @param widget ButtonUIWidget
--- @param event string
--- @param key string LSHIFT, etc...
--- @param down boolean 1 or true if the press is KeyDown
local function OnModifierStateChanged(widget, event, key, down)
    RegisterForClicks(widget, E.MODIFIER_STATE_CHANGED, down, key)
end

--- @param widget ButtonUIWidget
local function OnBeforeEnter(widget)
    RegisterForClicks(widget, E.ON_ENTER)
    widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, OnModifierStateChanged, widget)
end
--- @param widget ButtonUIWidget
local function OnBeforeLeave(widget)
    widget:UnregisterEvent(E.MODIFIER_STATE_CHANGED)
    RegisterForClicks(widget, E.ON_LEAVE)
end
--- @param btn ButtonUI
local function OnEnter(btn)
    OnBeforeEnter(btn.widget)
    ---Receiver will get a func(widget, event) {}
    btn.widget:Fire(E.OnEnter)

    -- TODO: Will be used in the future in place of widget:Fire(..)
    -- AceEvent:SendMessage(GC.M.OnEnter, libName, btn)
end
--- @param btn ButtonUI
local function OnLeave(btn)
    OnBeforeLeave(btn.widget)
    ---Receiver will get a func(widget, event) {}
    btn.widget:Fire(E.OnLeave)

    -- TODO: Will be used in the future in place of widget:Fire(..)
    -- AceEvent:SendMessage(GC.M.OnLeave, libName, btn)
end

--- @param btn ButtonUI
local function OnClick_SecureHookScript(btn, mouseButton, down)
    if InCombatLockdown() then return end
    btn:RegisterForClicks(O.API:IsDragKeyDown() and 'AnyUp' or 'AnyDown')
    if not PH:IsPickingUpSomething() then return end
    OnReceiveDrag(btn)
end

--- @param widget ButtonUIWidget
--- @param event string Event string
local function OnUpdateButtonCooldown(widget, event)
    if widget:IsNotUpdatable() then return end
    widget:UpdateCooldown()
    local cd = widget:GetCooldownInfo();
    if (cd == nil or cd.icon == nil) then return end
    widget:SetCooldownTextures(cd.icon)
end

--- @param w ButtonUIWidget
--- @param event string Event string
local function OnSpellUpdateUsable(w, event)
    if not w:IsShown() or w:IsEmpty() or w:IsNotUpdatable() then return end
    w:UpdateUsable()
    w:UpdateGlow()

    if w:IsEmpty() then return end
    w:SendMessage(GC.M.OnPostUpdateSpellUsable, libName, w)
end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param widget ButtonUIWidget
--- @param name string The widget name.
local function RegisterWidget(widget, name)
    assert(widget ~= nil)
    assert(name ~= nil)

    local WidgetBase = AceGUI.WidgetBase
    widget.userdata = {}
    widget.events = {}
    local mt = {
        __tostring = function() return name  end,
        __index = WidgetBase
    }
    setmetatable(widget, mt)
end

--- @param button ButtonUI
local function RegisterScripts(button)
    AceHook:SecureHookScript(button, 'OnClick', OnClick_SecureHookScript)

    button:SetScript("PreClick", OnPreClick)
    button:SetScript("PostClick", OnPostClick)

    button:SetScript('OnDragStart', OnDragStart)
    button:SetScript('OnReceiveDrag', OnReceiveDrag)
    button:SetScript(E.OnEnter, OnEnter)
    button:SetScript(E.OnLeave, OnLeave)
end

--- @param widget ButtonUIWidget
local function RegisterSpellUpdateUsable(widget)
    if not ns:IsVanilla() then
        widget:RegisterEvent(E.SPELL_UPDATE_USABLE, OnSpellUpdateUsable, widget)
    else
        -- In Vanilla, SPELL_UPDATE_USABLE does not fire very often
        widget:RegisterBucketEvent({ E.SPELL_UPDATE_USABLE, E.ACTIONBAR_UPDATE_USABLE }, 0.1, function(units)
            OnSpellUpdateUsable(widget)
        end);
    end
end

--- @param widget ButtonUIWidget
local function RegisterCallbacks(widget)

    -- TODO Next: Tracks changing spells such as Covenant abilities in Shadowlands.
    widget:RegisterEvent(E.SPELL_UPDATE_COOLDOWN, OnUpdateButtonCooldown, widget)
    widget:RegisterEvent(E.MODIFIER_STATE_CHANGED, OnModifierStateChanged, widget)
    RegisterSpellUpdateUsable(widget)

    -- TODO: Refactor to use messages (see #OnReceiveDrag())
    -- Callbacks (fired via Ace Events)
    --- @param w ButtonUIWidget
    widget:SetCallback("OnEnter", function(w)
        if InCombatLockdown() then return end
        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(true)
    end)
    widget:SetCallback("OnLeave", function(w)
        if InCombatLockdown() then return end
        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(false)
    end)
end

--[[-----------------------------------------------------------------------------
Builder Methods
-------------------------------------------------------------------------------]]

---Creates a new ButtonUI
--- @param dragFrameWidget ActionBarFrameWidget The drag frame this button is attached to
--- @param rowNum number The row number
--- @param colNum number The column number
--- @param btnIndex number The button index number
--- @return ButtonUIWidget
function _B:Create(dragFrameWidget, rowNum, colNum, btnIndex)

    local btnName = GC:ButtonName(dragFrameWidget.index, btnIndex)

    --- @class __ButtonUI
    --- @field CheckedTexture _Texture
    --- @field Cooldown _CooldownFrame
    local button = CreateFrame("Button", btnName, UIParent, GC.C.SECURE_ACTION_BUTTON_TEMPLATE)
    ns:K():Mixin(button, O.MultiOnUpdateFrameMixin)

    --- @alias ButtonUI __ButtonUI | Button | MultiOnUpdateFrameMixin

    --- @type ButtonUI
    local btn = button

    --local button = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate,SecureHandlerBaseTemplate")
    button.text = WMX:CreateFontString(button)
    button.indexText = WMX:CreateIndexTextFontString(button)
    button.keybindText = WMX:CreateKeybindTextFontString(button)
    button.nameText = WMX:CreateNameTextFontString(button)
    RegisterScripts(button)

    -- todo next: add ActionButtonUseKeyDown to options UI; add to abp_info
    --            iterate through all buttons and call #RegisterForClicks()
    -- /run SetCVar("ActionButtonUseKeyDown", 1)
    -- /run SetCVar("ActionButtonUseKeyDown", 0)
    -- /dump GetCVarBool("ActionButtonUseKeyDown")

    btn:RegisterForDrag("LeftButton", "RightButton");
    btn:RegisterForClicks("AnyDown", "AnyUp");

    --- see: Interface/AddOns/Blizzard_APIDocumentationGenerated/CooldownFrameAPIDocumentation.lua
    --- @class CooldownFrame : _CooldownFrame
    local cooldown = CreateFrame("Cooldown", btnName .. 'Cooldown', button, "CooldownFrameTemplate")
    cooldown:SetParentKey('Cooldown')
    cooldown:ClearAllPoints()
    cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
    cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)

    cooldown:SetCountdownFont(GameFontHighlightSmallOutline:GetFont())
    cooldown:SetHideCountdownNumbers(false)
    cooldown:SetEdgeScale(1.0)
    -- todo next: DrawBling, DrawEdge as UI Option
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawBling(true)

    self:CreateCheckedTexture(button)

    --- @alias ButtonUIWidget __ButtonUIWidget | BaseLibraryObject_WithAceEvent | ButtonMixin
    --- @class __ButtonUIWidget
    --- @field AutoRepeatSpell AutoRepeatSpellData
    --- @field private _conf ButtonProfileConfigMixin
    --- @field private _rangeUtil RangeIndicatorUtil_Instance
    local __widget = {
        --- @deprecated Use ns:a()
        --- @type fun() : ActionbarPlus
        addon = function() return ABP end,
        --- The button index number
        --- @type number
        index = btnIndex,
        --- @type number
        frameIndex = dragFrameWidget:GetIndex(),
        --- @type string
        buttonName = btnName,
        --- @type fun() : ActionBarFrameWidget
        dragFrame = function() return dragFrameWidget end,
        --- @type fun() : ButtonUI
        button = function() return button  end,
        --- @type fun() : CooldownFrame
        cooldown = function() return cooldown end,
        --- @type table
        cooldownInfo = nil,
        ---Don't make this 'LOW'. ElvUI AFK Disables it after coming back from AFK
        --- @type string
        frameStrata = dragFrameWidget.frameStrata or 'MEDIUM',
        frameLevel = (dragFrameWidget.frameLevel + 100) or 100,
        --- @type number
        buttonPadding = 1,
        placement = { rowNum = rowNum, colNum = colNum },
    }
    --- @type ButtonUIWidget
    local widget = __widget

    button.widget, cooldown.widget = widget, widget

    ns:AceEvent(widget)
    ns:AceBucket(widget)

    ButtonMX:Mixin(widget)

    RegisterWidget(widget, btnName .. '::Widget')
    RegisterCallbacks(widget)

    widget:InitWidget()

    return widget
end

--- @param button __ButtonUI
function _B:CreateCheckedTexture(button)
    local checkedTexture = button:CreateTexture(nil, "OVERLAY")
    checkedTexture:SetAllPoints() -- Make the texture cover the whole button
    checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    checkedTexture:SetBlendMode("ADD") -- This corresponds to alphaMode="ADD" in XML
    -- set ignore alpha to false so we can control it via settings
    checkedTexture:SetIgnoreParentAlpha(false)
    checkedTexture:SetIgnoreParentScale(false)
    checkedTexture:EnableMouse(false)
    checkedTexture:SetParentKey("CheckedTexture")
    checkedTexture:Hide()
end
