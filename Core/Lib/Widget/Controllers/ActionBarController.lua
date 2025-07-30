--- @alias ActionBarController __ActionBarController | ControllerV2

-- todo next: Issue #501: Pull Out Unit SpellCast Controller
-- https://github.com/kapresoft/wow-addon-actionbar-plus/issues/501

--- @type Namespace
local ns = select(2, ...)
local O, GC, M, Compat, LC = ns.O, ns.GC, ns.M, ns.O.Compat, ns:LC()

local E, MSG, UnitId = GC.E, GC.M,  GC.UnitId
local B, API = O.BaseAPI, O.API
local Un = O.UnitMixin

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local RegisterFrameForEvents, RegisterFrameForUnitEvents
        = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.ActionBarController
--- @class __ActionBarController
local LIB = ns:NewController(libName)
--- @type ActionBarController
local L = LIB

local p = ns:CreateDefaultLogger(libName)
local sp = LC.SPELL:NewLogger(libName)
local bagL = LC.BAG:NewLogger(libName)
local df = ns:CreateDefaultLogger(libName)
local ua = LC.UNIT:NewLogger(libName)
local pe = LC.EVENT:NewLogger(libName)

local enableExternalAPI = GC.F.ENABLE_EXTERNAL_API

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local ABPI = function() return O.ActionbarPlusAPI  end
local addon = function() return ABP end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param bw ButtonUIWidget
local function UpdateIcon(bw)
    local icon = API:GetSpellIcon(bw:GetSpellData())
    if icon then bw:SetIcon(icon) end
    bw:UpdateSpellCheckedStateDelayed()
end

--[[-----------------------------------------------------------------------------
Event Handlers
-------------------------------------------------------------------------------]]
local function OnStealthIconUpdate() L:ForEachStealthButton(UpdateIcon) end

--- Not fired in classic-era
local function OnCompanionUpdate()
    L:ForEachCompanionButton(function(bw)
        C_Timer.NewTicker(0.5, function() bw:UpdateCompanionActiveState() end, 3)
    end)
end
-- TODO: Migrate to a new StealthSpellController, ie. controller:OnStealthIconUpdate()
local function OnUpdateStealth() OnStealthIconUpdate() end
local function OnShapeShift()
    C_Timer.NewTicker(0.2, function()
        L:ForEachShapeshiftButton(UpdateIcon)
    end, 2)
end

-- TODO: Migrate to a new "PlayerUnitAuraController", i.e. controller:OnPlayerUnitAura()
--- @param event string The event name
local function OnPlayerUnitAura(event, unit)
    ua:t(function() return 'OnPlayerUnitAura(): unit=%s called...', unit end)
    Un:UpdateShapeshiftBuffs()
end

--- Order is: SENT, START, SUCCEEDED
--- START is triggered for spell duration > 0
--- @param event string The event name
local function OnPlayerSpellCastStart(event, ...)
    local spellCastEvent = B:ParseSpellCastEventArgs(...)
    L:ForEachMatchingSpellButton(spellCastEvent.spellID, function(bw)
        sp:f1(function()
            local spellName, spellID = bw:GetEffectiveSpellName(), bw:GetEffectiveSpellID()
            return 'cast started: %s,id=%s [%s]', spellName, spellID, bw:GN()
        end)
        bw:SetHighlightInUse()
    end)
    if not enableExternalAPI then return end

    --- @param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStartExt, libName, CallbackFn)
end

--- Triggered for non channeled spells, both instant and non-instant
--- @param evt _SpellCastSentEventArguments
local function OnPlayerSpellCastSent(evt)
    L:ForEachMatchingSpellButton(evt.spellID, function(bw)
        sp:f1(function()
            local r = Compat:GetSpellSubtext(evt.spellID)
            return 'cast sent: %s(%s) rank=%s', evt.spellID, bw:GetEffectiveSpellName(), r
        end)
        bw:SetButtonStateNormal();
    end)
    if not enableExternalAPI then return end

    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastSentExt, libName, CallbackFn)
end

--- @param event string The event name
local function OnSpellCastSentAllUnits(event, ...)
    local evt = B:ParseSpellCastSentEventArgs(...)
    local unit = evt and evt.unit
    if UnitId.player ~= unit then return end
    OnPlayerSpellCastSent(evt)
end

--- @param event string The event name
local function OnSpellCastSucceeded(event, ...)
    local evt = B:ParseSpellCastEventArgs(...)
    L:ForEachButton(function(bw)
        sp:f1(function()
            local r = Compat:GetSpellSubtext(evt.spellID)
            return 'cast succeeded: %s(%s) rank=%s', evt.spellID, bw:GetEffectiveSpellName(), r
        end)
        if bw:IsMatchingMacroOrSpell(evt.spellID) then bw:UpdateItemOrMacroState()
        elseif bw:IsMacro() then bw:SetHighlightDefault() end
    end)
    L:SendMessage(GC.M.OnSpellCastSucceeded, libName)
end

--- i.e. Conjure mana gem when there is already a mana gem in bag
--- @param event string The event name
local function OnPlayerSpellCastFailedQuietly(event, ...)
    local evt = B:ParseSpellCastEventArgs(...)
    L:ForEachMatchingSpellButton(evt.spellID, function(bw)
        bw:SetButtonStateNormal()
    end)
    if not enableExternalAPI then return end

    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastFailedExt, libName, CallbackFn)
end

--- @param event string The event name
local function OnPlayerSpellCastStop(event, ...)
    local evt = B:ParseSpellCastEventArgs(...)
    L:ForEachMatchingSpellButton(evt.spellID, function(bw)
        local spell = bw:GetEffectiveSpellName()
        if spell then
            sp:f1(function() return 'cast stopped: %s(%s :: %s)', evt.spellID, spell, bw:conf().type end)
            bw:ResetHighlight()
        end
    end)
    if not enableExternalAPI then return end

    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStopExt, libName, CallbackFn)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __ActionBarController | ActionBarController
local function PropsAndMethods(o)

    o[E.COMPANION_UPDATE] = OnCompanionUpdate
    o[E.UPDATE_STEALTH]         = OnUpdateStealth
    o[E.UPDATE_SHAPESHIFT_FORM] = OnShapeShift

    o[E.UNIT_AURA] = OnPlayerUnitAura
    o[E.UNIT_SPELLCAST_SENT] = OnSpellCastSentAllUnits
    o[E.UNIT_SPELLCAST_START] = OnPlayerSpellCastStart
    o[E.UNIT_SPELLCAST_STOP] = OnPlayerSpellCastStop
    o[E.UNIT_SPELLCAST_SUCCEEDED] = OnSpellCastSucceeded
    o[E.UNIT_SPELLCAST_FAILED_QUIET] = OnPlayerSpellCastFailedQuietly

    if not ns:IsRetail() then return end

    o[E.UNIT_SPELLCAST_EMPOWER_START] = OnPlayerSpellCastStart
    o[E.UNIT_SPELLCAST_EMPOWER_STOP] = OnPlayerSpellCastStop

end; PropsAndMethods(LIB)

---@param frame _Frame
local function OnAddOnReady(frame)
    Un:UpdateShapeshiftBuffs();

    OnStealthIconUpdate();
    OnShapeShift()
    OnCompanionUpdate();

    RegisterFrameForEvents(frame, {
        E.COMPANION_UPDATE,
        E.UPDATE_BINDINGS,
        E.UPDATE_STEALTH, E.UPDATE_SHAPESHIFT_FORM,
    })
    RegisterFrameForUnitEvents(frame, {
        E.UNIT_AURA,
        E.UNIT_SPELLCAST_START,
        E.UNIT_SPELLCAST_STOP,
        E.UNIT_SPELLCAST_SUCCEEDED,
        E.UNIT_SPELLCAST_FAILED_QUIET,
    }, 'player')

    --- This applies to all units
    RegisterFrameForUnitEvents(frame, { E.UNIT_SPELLCAST_SENT })

    if not ns:IsRetail() then return end

    RegisterFrameForUnitEvents(frame, {
        E.UNIT_SPELLCAST_EMPOWER_START, E.UNIT_SPELLCAST_EMPOWER_STOP
    }, 'player')

end

--[[-----------------------------------------------------------------------------
OnLoad & OnEvent Hooks
-------------------------------------------------------------------------------]]
---@param frame _Frame
function ABP_ActionBarController_OnLoad(frame)
    L:RegisterMessage(GC.M.OnAddOnReady, function() OnAddOnReady(frame)  end)
    ABP_ActionBarController_OnLoad = nil
end

---@param frame _Frame
function ABP_ActionBarController_OnEvent(frame, event, ...)
    --- @type fun(evt:string, ...: any)
    local handler = L[event]; if type(L[event]) ~= 'function' then return end
    handler(event, ...)
    ABP_ActionBarController_OnEvent = nil;
end
