--This mixin handles events for the addon
--
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, LibStub = ns.O, ns.O.GlobalConstants, ns.O.LibStub

local BaseAPI, API, pformat = O.BaseAPI, O.API, ns.pformat
local E, MSG, UnitId = GC.E, GC.M,  GC.UnitId
local B = O.BaseAPI
local AceEvent, AceHook, Table = O.AceLibrary.AceEvent, O.AceLibrary.AceHook, O.Table
local SizeOfTable, IsEmptyTable = Table.Size, Table.IsEmpty
local CURSOR_ITEM_TYPE = 1
local AceBucket = ns:AceBucket()

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
local ABPI = function() return O.ActionbarPlusAPI  end
local AU = function() return O.PlayerAuraUtil  end
local PR = function() return O.Profile  end
local BF = function() return O.ButtonFactory end

--- @class EventFrameInterface : _Frame
local _EventFrame = {
    --- @type EventContext
    ctx = {}
}

--- @class EventContext
local _EventContext = {
    --- @type EventFrameInterface
    frame = {},
    --- @type ActionbarPlus
    addon = {},
    --- @type ButtonFactory
    buttonFactory = {},
    --- @type WidgetMixin
    widgetMixin = {},
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ActionbarPlusEventMixin : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(ns.M.ActionbarPlusEventMixin)
AceEvent:Embed(L)
AceBucket:Embed(L)
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param f EventFrameInterface
--- @param event string
local function OnPlayerCombatEvent(f, event, ...)
    -- p:log(40, 'Event[%s] received...', event)
    if E.PLAYER_REGEN_ENABLED == event then
        f.ctx.buttonFactory:Fire(E.OnPlayerLeaveCombat)
    end

    f.ctx.buttonFactory:Fire(E.OnUpdateItemStates)
    -- This second fire is for fail-safety
    C_Timer.After(2, function() f.ctx.buttonFactory:Fire(E.OnUpdateItemStates) end)
end

--- @param f EventFrameInterface
--- @param event string
local function OnUpdateBindings(f, event, ...)
    if E.UPDATE_BINDINGS ~= event then return end
    f.ctx.buttonFactory:UpdateKeybindText()
end

--- @param f EventFrameInterface
--- @param event string
local function OnPetBattleEvent(f, event, ...)
    if E.PET_BATTLE_OPENING_START == event then
        f.ctx.buttonFactory:Fire(E.OnActionbarHideGroup)
        return
    end
    f.ctx.buttonFactory:Fire(E.OnActionbarShowGroup)
end

--- @param f EventFrameInterface
--- @param event string
local function OnVehicleEvent(f, event, ...)
    local unitTarget = ...
    if UnitId.player ~= unitTarget then return end
    if E.UNIT_ENTERED_VEHICLE == event then
        f.ctx.buttonFactory:Fire(E.OnActionbarHideGroup)
        return
    end
    f.ctx.buttonFactory:Fire(E.OnActionbarShowGroup)
end

--- @param f EventFrameInterface
--- @param event string
local function OnActionbarGrid(f, event, ...)
    p:log(30, 'Event received: %s', event)
    if InCombatLockdown() then return end
    if E.ACTIONBAR_SHOWGRID == event then
        f.ctx.buttonFactory:Fire(E.OnActionbarShowGrid)
        return
    end
    f.ctx.buttonFactory:Fire(E.OnActionbarHideGrid)
end

--- See Also: [https://wowpedia.fandom.com/wiki/CURSOR_CHANGED](https://wowpedia.fandom.com/wiki/CURSOR_CHANGED)
--- @param f EventFrameInterface
--- @param event string
local function OnCursorChangeInBags(f, event, ...)
    local isDefault, newCursorType, oldCursorType, oldCursorVirtualID = ...
    if true == isDefault and oldCursorType == CURSOR_ITEM_TYPE then
        f.ctx.buttonFactory:Fire(E.OnActionbarHideGrid)
        ABP.ActionbarEmptyGridShowing = false
        return
    end
    if InCombatLockdown() then return end
    if newCursorType ~= CURSOR_ITEM_TYPE then return end
    f.ctx.buttonFactory:Fire(E.OnActionbarShowGrid)
    ABP.ActionbarEmptyGridShowing = true
end

--- Non-Instant Start-Cast Handler
--- @param f EventFrameInterface
--- @param spellID number
local function OnSpellCastStart(f, spellID)
    --p:log(10, 'OSCStart[%s]: %s (%s)', spellID, GetSpellInfo(spellID), GetTime())
    local w = f.ctx
    --- @param fw FrameWidget
    w.buttonFactory:fevf(function(fw)
        fw:fesmb(spellID, function(btnWidget)
            btnWidget:SetHighlightInUse() end)
    end)

    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStartExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- i.e. Casting a portal and moving triggers this event
--- @param f EventFrameInterface
---@param spellID number
local function OnSpellCastStop(f, spellID)
    local w = f.ctx
    w.buttonFactory:fevf(function(fw)
        fw:fesmb(spellID, function(btn)
            btn:ResetHighlight() end)
    end)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStopExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- i.e. Conjure mana gem when there is already a mana gem in bag
--- @param f EventFrameInterface
---@param spellID number
local function OnSpellCastFailed(f, spellID)
    --p:log(10, 'OSCFailed[%s]: %s (%s)', spellID, GetSpellInfo(spellID), GetTime())

    local w = f.ctx
    w.buttonFactory:fevf(function(fw)
        fw:fesmb(spellID, function(btn)
            btn:SetButtonStateNormal() end)
    end)

    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastFailedExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- This handles 3-state spells like mage blizzard, hunter flares,
--- or basic campfire in retail
--- @param f EventFrameInterface
---@param spellID number
local function OnSpellCastSent(f, spellID)
    local w = f.ctx
    --- @param fw FrameWidget
    w.buttonFactory:fevf(function(fw)
        fw:fesmb(spellID, function(btn)
            btn:SetButtonStateNormal() end)
    end)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastSentExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- @param f EventFrameInterface
---@param spellID number
local function OnSpellCastSucceeded(f, spellID)
    --p:log(10, 'OSCSucceeded[%s]: %s (%s)', spellID, GetSpellInfo(spellID), GetTime())

    --- @type ButtonFactory
    local bf = f.ctx.buttonFactory

    bf:fevf(function(fw)
        fw:feb(function(bw)
            if bw:IsSpell() then
                C_Timer.NewTicker(0.1, function() bw:UpdateSpellState() end, 2)
            elseif bw:IsItemOrMacro() then
                C_Timer.NewTicker(0.1, function() bw:UpdateItemOrMacroState() end, 2)
            end
        end)
    end)
    L:SendMessage(GC.M.OnSpellCastSucceeded, ns.M.ActionbarPlusEventMixin)
end

--- @param eventCtx EventContext
local function OnPlayerControlLost(eventCtx)

    C_Timer.NewTicker(1, function()
        local inPetBattle = O.BaseAPI:PlayerInPetBattle()
        local onTaxi = UnitOnTaxi(GC.UnitId.player)
        p:log(10, 'ControlLost: onTaxi=%s inPetBattle=%s [%s]',
                onTaxi, inPetBattle, GetTime())
        if inPetBattle then return end
        if not (onTaxi == true and PR():IsHideWhenTaxi() == true) then return end

        O.WidgetMixin:ShowActionbars(false)

    end, 2)

end

--- @param eventCtx EventContext
local function OnPlayerControlGained(eventCtx)

    C_Timer.NewTicker(1, function()
        local inPetBattle = O.BaseAPI:PlayerInPetBattle()
        local onTaxi = UnitOnTaxi(GC.UnitId.player)
        p:log(10, 'ControlGained: onTaxi=%s inPetBattle=%s [%s]',
                onTaxi, inPetBattle, GetTime())
        if inPetBattle then return end

        O.WidgetMixin:ShowActionbars(true)
        eventCtx.buttonFactory:fevf(function(fw)
            fw:feb(function(bw) bw:UpdateState() end)
        end)

    end, 2)

end

--- @param f EventFrameInterface
--- @param event string
local function OnActionbarEvents(f, event, ...)
    local spellCastEvent = B:ParseSpellCastEventArgs(...)
    if not spellCastEvent then return end
    if UnitId.player ~= spellCastEvent.unitTarget then return end
    local spellID = spellCastEvent.spellID
    if not spellID then return end

    if E.UNIT_SPELLCAST_START == event then
        OnSpellCastStart(f, spellID)
    elseif E.UNIT_SPELLCAST_STOP == event then
        OnSpellCastStop(f, spellID)
    elseif E.UNIT_SPELLCAST_SENT == event then
        OnSpellCastSent(f, spellID)
    elseif E.UNIT_SPELLCAST_SUCCEEDED == event then
        OnSpellCastSucceeded(f, spellID)
    elseif E.UNIT_SPELLCAST_FAILED_QUIET == event then
        OnSpellCastFailed(f, spellID)
    end
end

--- @param eventWidget EventContext
local function OnStealth(eventWidget)
    --- @param fw FrameWidget
    eventWidget.buttonFactory:fevf(function(fw)
        --- @param bw ButtonUIWidget
        fw:fevb(
                function(bw) return bw:IsStealthSpell() end,
                function(bw)
                    local icon = API:GetSpellIcon(bw:GetSpellData())
                    bw:SetIcon(icon)
                    bw:UpdateSpellStealthState()
                end)
    end)
end

--- @param f EventFrameInterface
--- @param event string
---@param updateInfo UnitAuraUpdateInfo
local function OnPlayerAura(f, event, unitTarget, updateInfo)
    --p:log('E[%s]: unit=%s u=[%s] (%s)', event, unitTarget, pformat(updateInfo), GetTime())
    if GC.UnitId.player ~= unitTarget then return end

    local playerAuras = AU():GetPlayerSpellsFromAura(updateInfo)
    if SizeOfTable(playerAuras) > 0 then L:SendMessage(MSG.OnPlayerAurasAdded, playerAuras) end

    local removedAuras = AU():GetRemovedAuras(updateInfo)
    if SizeOfTable(removedAuras) > 0 then
        for rID, aura in pairs(removedAuras) do
            L:SendMessage(MSG.OnPlayerAuraRemoved, aura)
            AU():RemoveAura(aura)
        end
    end
end

--- @param f EventFrameInterface
--- @param event string
local function OnBagEvent(f, event, ...)

    L:SendMessage(MSG.OnBagUpdate, ns.M.ActionbarPlusEventMixin)

    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnBagUpdateExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- ShapeShift Sequence:
---     UPDATE_SHAPESHIFT_FORM, UPDATE_STEALTH, UPDATE_SHAPESHIFT_FORM
--- @param f EventFrameInterface
--- @param event string
local function OnEvent(f, event, ...)
    local eventCtx = f.ctx

    if E.UPDATE_STEALTH == event then
        p:log(10, '%s [%s]', event, GetTime())
        OnStealth(eventCtx)
    elseif E.PLAYER_CONTROL_LOST == event then
        OnPlayerControlLost(eventCtx)
    elseif E.PLAYER_CONTROL_GAINED == event then
        OnPlayerControlGained(eventCtx)
    end
end

local function OnUpdateCooldownsAndState() BF():UpdateCooldownsAndState() end
local function OnSpellUpdateUsable() BF():UpdateUsable() end

--- @param f EventFrameInterface
--- @param event string
local function OnMessageTransmitter(f, event, ...) L:SendMessage(GC.newMsg(event), ns.name, ...) end

---@param o ActionbarPlusEventMixin | AceBucket
local function OnAddOnInitializedMessage(o)
    --- @param abp ActionbarPlus
    o:RegisterMessage(MSG.OnAddOnInitialized, function(msg, abp)
        p:log(10, 'MSG::R: %s', msg)
        local AddOnEvents = abp.addonEvents()
        AddOnEvents:RegisterEvents()
        AddOnEvents:RegisterMessages()
    end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionbarPlusEventMixin | AceBucket
local function PropsAndMethods(o)

    --- @param addon ActionbarPlus
    function o:Init(addon)
        self.addon = addon
        self.buttonFactory = O.ButtonFactory
        self.widgetMixin = O.WidgetMixin

        OnAddOnInitializedMessage(self)
    end

    --- @return EventFrameInterface
    function o:CreateEventFrame()
        local f = CreateFrame("Frame", nil, self.addon.frame)
        f.ctx = self:CreateContext(f)
        return f
    end

    --- @param eventFrame _Frame
    --- @return EventContext
    function o:CreateContext(eventFrame)
        local ctx = {
            frame = eventFrame,
            addon = self.addon,
            buttonFactory = self.buttonFactory,
            widgetMixin = self.widgetMixin
        }
        return ctx
    end

    function o:RegisterDefaultEventFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnEvent)
        RegisterFrameForEvents(f, {
            E.PLAYER_CONTROL_LOST, E.PLAYER_CONTROL_GAINED,
            E.UPDATE_STEALTH
        })

        self:RegisterBucketEvent({ E.SPELL_UPDATE_COOLDOWN },
                0.1, OnUpdateCooldownsAndState)
        self:RegisterBucketEvent({ E.SPELL_UPDATE_USABLE, E.UNIT_POWER_FREQUENT },
                1, OnSpellUpdateUsable)
    end


    function o:RegisterActionbarsEventFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnActionbarEvents)
        RegisterFrameForUnitEvents(f, {
            E.UNIT_SPELLCAST_START,
            E.UNIT_SPELLCAST_STOP,
            E.UNIT_SPELLCAST_SENT,
            E.UNIT_SPELLCAST_SUCCEEDED,
            E.UNIT_SPELLCAST_FAILED_QUIET,
        })
    end

    function o:RegisterKeybindingsEventFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnUpdateBindings)
        RegisterFrameForEvents(f, { E.UPDATE_BINDINGS })
    end

    function o:RegisterVehicleFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnVehicleEvent)
        RegisterFrameForUnitEvents(f, { E.UNIT_ENTERED_VEHICLE, E.UNIT_EXITED_VEHICLE }, GC.UnitId.player)
    end

    function o:RegisterActionbarGridEventFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnActionbarGrid)
        RegisterFrameForEvents(f, { E.ACTIONBAR_SHOWGRID, E.ACTIONBAR_HIDEGRID })
    end

    function o:RegisterCursorChangesInBagEvents()
        if BaseAPI:IsClassicEra() then return end
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnCursorChangeInBags)
        -- Note that this event does not fire in WoW Classic (i.e. 1.14.x)
        -- for non-consumable items in the bag like quest items
        RegisterFrameForEvents(f, { E.CURSOR_CHANGED })
    end

    function o:RegisterPetBattleFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPetBattleEvent)
        RegisterFrameForEvents(f, { E.PET_BATTLE_OPENING_START, E.PET_BATTLE_CLOSE })
    end

    --- Use PLAYER_REGIN[ENABLED|DISABLED] is more reliable than using
    --- PLAYER_[ENTER|LEAVE]_COMBAT event
    function o:RegisterCombatFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPlayerCombatEvent)
        RegisterFrameForEvents(f, { E.PLAYER_REGEN_ENABLED, E.PLAYER_REGEN_DISABLED })
    end
    function o:RegisterBagEvents()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnBagEvent)
        RegisterFrameForEvents(f, { E.BAG_UPDATE, E.BAG_UPDATE_DELAYED })
    end
    function o:RegisterEventToMessageTransmitter()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnMessageTransmitter)
        --- @see GlobalConstants#M (Messages)
        RegisterFrameForEvents(f, {
            E.PLAYER_ENTERING_WORLD,
            E.EQUIPMENT_SETS_CHANGED, E.EQUIPMENT_SWAP_FINISHED,
            E.PLAYER_MOUNT_DISPLAY_CHANGED, E.ZONE_CHANGED_NEW_AREA,
            E.MODIFIER_STATE_CHANGED,
        })
    end
    function o:RegisterPlayerEnteringWorld()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPlayerEnteringWorld)
        RegisterFrameForEvents(f, { E.PLAYER_ENTERING_WORLD })
    end
    function o:RegisterPlayerAura()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPlayerAura)
        RegisterFrameForUnitEvents(f, { E.UNIT_AURA }, GC.UnitId.player)
    end

    function o:RegisterEvents()
        p:log(30, 'RegisterEvents called..')
        self:RegisterActionbarsEventFrame()
        self:RegisterDefaultEventFrame()
        self:RegisterKeybindingsEventFrame()
        self:RegisterActionbarGridEventFrame()
        self:RegisterCursorChangesInBagEvents()
        self:RegisterCombatFrame()
        self:RegisterBagEvents()
        self:RegisterEventToMessageTransmitter()
        self:RegisterPlayerEnteringWorld()
        self:RegisterPlayerAura()
        if B:SupportsPetBattles() then self:RegisterPetBattleFrame() end
        --TODO: Need to investigate Wintergrasp (hides/shows intermittently)
        if B:SupportsVehicles() then self:RegisterVehicleFrame() end
    end

    function o:RegisterMessages()
        self:RegisterMessage(MSG.OnAddOnReady, function() BF():UpdateShapeshiftActions() end)
        self:RegisterMessage(MSG.OnBagUpdate, function() BF():UpdateItems() end)
        self:RegisterMessage(MSG.PLAYER_MOUNT_DISPLAY_CHANGED, function() BF():UpdateMounts() end)
        self:RegisterMessage(MSG.ZONE_CHANGED_NEW_AREA, function() BF():UpdateMounts() end)
    end

end; PropsAndMethods(L)
