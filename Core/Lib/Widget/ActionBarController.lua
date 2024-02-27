--- @alias ActionBarController __ActionBarController | ActionBarHandlerMixin

local ns = abp_ns(...)
local O, GC, M, LibStub, LC = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.LogCategories()

local H = O.ActionBarHandlerMixin
local E, MSG, UnitId = GC.E, GC.M,  GC.UnitId
local PR, WMX, B = O.Profile, O.WidgetMixin, O.BaseAPI
local Un = O.UnitMixin:New()

local libName = M.ActionBarController
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local RegisterFrameForEvents, RegisterFrameForUnitEvents
        = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return ActionBarController, LoggerV2, Kapresoft_LibUtil_Safecall
local function CreateLib()
    --- @class __ActionBarController : BaseLibraryObject_WithAceEvent
    local lib = LibStub:NewLibrary(libName); if not lib then return end
    ns:AceEvent(lib); H:Embed(lib)
    return lib, ns:CreateDefaultLogger(libName), ns:CreateSafecall(libName)
end; local L, p, safecall = CreateLib()

local sp = LC.SPELL:NewLogger(libName)
local bagL = LC.BAG:NewLogger(libName)
local df = ns:CreateDefaultLogger(libName)
local ua = LC.UNIT:NewLogger(libName)
local pe = LC.EVENT:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local ABPI = function() return O.ActionbarPlusAPI  end
local addon = function() return ABP  end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param bw ButtonUIWidget
local function UpdateIcon(bw)
    local icon = O.API:GetSpellIcon(bw:GetSpellData())
    if icon then bw:SetIcon(icon) end
end

--[[-----------------------------------------------------------------------------
Event Handlers
-------------------------------------------------------------------------------]]
local function OnStealthIconUpdate() L:ForEachStealthButton(UpdateIcon) end

--- Update Items and Macros referencing items
local function OnBagUpdate()
    bagL:t( 'OnBagU(): called..')
    L:ForEachItemButton(function(bw)
        local success, itemInfo = safecall(function() return bw:GetItemData() end)
        if not (success and itemInfo) then return end
        bw:UpdateItemOrMacroState()
    end)

    --- @param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnBagUpdateExt, libName, CallbackFn)
end

--- Not fired in classic-era
local function OnCompanionUpdate()
    L:ForEachCompanionButton(function(bw)
        C_Timer.NewTicker(0.5, function() bw:UpdateCompanionActiveState() end, 3)
    end)
end

local function OnUpdateStealth() OnStealthIconUpdate() end
local function OnShapeShift()
    C_Timer.NewTicker(0.2, function()
        L:ForEachShapeshiftButton(UpdateIcon)
    end, 2)
end
local function OnUpdateBindings() addon():UpdateKeyBindings() end

--- @param event string The event name
local function OnPlayerUnitAura(event, unit)
    ua:t('OnPlayerUnitAura(): called...')
    Un:UpdateShapeshiftBuffs()
end

--- Order is: SENT, START, SUCCEEDED
--- START is triggered for spell duration > 0
--- @param event string The event name
local function OnPlayerSpellCastStart(event, ...)
    local spellCastEvent = B:ParseSpellCastEventArgs(...)
    L:ForEachMatchingSpellButton(spellCastEvent.spellID, function(bw)
        sp:d(function()
            local spellName, spellID = bw:GetEffectiveSpellName(), bw:GetEffectiveSpellID()
            return 'cast started: %s,id=%s [%s]', spellName, spellID, bw:GN()
        end)
        bw:SetHighlightInUse()
    end)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStartExt, libName, CallbackFn)
end

--- Triggered for non channeled spells, both instant and non-instant
--- @param evt _SpellCastSentEventArguments
local function OnPlayerSpellCastSent(evt)
    L:ForEachMatchingSpellButton(evt.spellID, function(bw)
        sp:d(function() return 'cast sent: %s(%s)', evt.spellID, bw:GetEffectiveSpellName() end)
        bw:SetButtonStateNormal();
    end)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastSentExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
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
    L:ForEachMatchingSpellButton(evt.spellID, function(bw)
        sp:d(function() return 'cast succeeded: %s(%s)', evt.spellID, bw:GetEffectiveSpellName() end)
        bw:UpdateItemOrMacroState();
    end)
    L:SendMessage(GC.M.OnSpellCastSucceeded, ns.M.ActionbarPlusEventMixin)
end

--- i.e. Conjure mana gem when there is already a mana gem in bag
--- @param event string The event name
local function OnPlayerSpellCastFailedQuietly(event, ...)
    local evt = B:ParseSpellCastEventArgs(...)
    L:ForEachMatchingSpellButton(evt.spellID, function(bw)
        bw:SetButtonStateNormal()
    end)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastFailedExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- @param event string The event name
local function OnPlayerSpellCastStop(event, ...)
    local evt = B:ParseSpellCastEventArgs(...)
    L:ForEachMatchingSpellButton(evt.spellID, function(bw)
        sp:d(function() return 'cast stopped: %s(%s)', evt.spellID, bw:GetEffectiveSpellName() end)
        bw:ResetHighlight()
    end)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStopExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o __ActionBarController | ActionBarHandlerMixin
local function PropsAndMethods(o)
    ---@param evt string
    o[E.PLAYER_TARGET_CHANGED] = function(evt, ...)
        local t = UnitName('target') or 'NONE'
        df:f1(function() return 'PLAYER_TARGET_CHANGED: %s', t end)
    end

    o[E.BAG_UPDATE] = OnBagUpdate
    o[E.BAG_UPDATE_DELAYED] = OnBagUpdate
    o[E.COMPANION_UPDATE] = OnCompanionUpdate

    o[E.PLAYER_CONTROL_LOST] = function()
        if not PR:IsHideWhenTaxi() then return end
        C_Timer.After(1, function()
            local playerOnTaxi = UnitOnTaxi(GC.UnitId.player)
            if playerOnTaxi ~= true then return end
            WMX:ShowActionbarsDelayed(false, 1)
        end)
    end

    o[E.PLAYER_CONTROL_GAINED] = function()
        if not PR:IsHideWhenTaxi() then return end
        WMX:ShowActionbarsDelayed(true, 2)
    end
    o[E.UPDATE_BINDINGS]        = OnUpdateBindings
    o[E.UPDATE_STEALTH]         = OnUpdateStealth
    o[E.UPDATE_SHAPESHIFT_FORM] = OnShapeShift

    o[E.UNIT_AURA] = OnPlayerUnitAura
    o[E.UNIT_SPELLCAST_SENT] = OnSpellCastSentAllUnits
    o[E.UNIT_SPELLCAST_START] = OnPlayerSpellCastStart
    o[E.UNIT_SPELLCAST_STOP] = OnPlayerSpellCastStop
    o[E.UNIT_SPELLCAST_SUCCEEDED] = OnSpellCastSucceeded
    o[E.UNIT_SPELLCAST_FAILED_QUIET] = OnPlayerSpellCastFailedQuietly

end; PropsAndMethods(L)

---@param frame _Frame
local function OnAddOnReady(frame)
    Un:UpdateShapeshiftBuffs();

    OnStealthIconUpdate();
    OnShapeShift()
    OnCompanionUpdate();
    OnUpdateBindings();

    RegisterFrameForEvents(frame, {
        E.PLAYER_TARGET_CHANGED,
        E.BAG_UPDATE,
        E.BAG_UPDATE_DELAYED,
        E.COMPANION_UPDATE,
        E.PLAYER_CONTROL_LOST, E.PLAYER_CONTROL_GAINED,
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

    RegisterFrameForUnitEvents(frame, { E.UNIT_SPELLCAST_SENT })
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
