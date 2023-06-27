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
local AceEvent, Table = O.AceLibrary.AceEvent, O.Table
local SizeOfTable, IsEmptyTable = Table.Size, Table.IsEmpty
local CURSOR_ITEM_TYPE = 1
local AceBucket = ns:AceBucket()
local PAM = O.PlayerAuraMapping

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
    ns:AB():SetChecked(spellID, true)
    ns:AB():UpdateAll()
    -- todo next: update cooldown
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStartExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- i.e. Casting a portal and moving triggers this event
--- @param f EventFrameInterface
---@param spellID number
local function OnSpellCastStop(f, spellID)
    ns:AB():SetChecked(spellID, false)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastStopExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- i.e. Conjure mana gem when there is already a mana gem in bag
--- @param f EventFrameInterface
---@param spellID number
local function OnSpellCastFailed(f, spellID)
    ns:AB():SetChecked(spellID, false)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastFailedExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- This handles 3-state spells like mage blizzard, hunter flares,
--- or basic campfire in retail
--- @param f EventFrameInterface
---@param spellID number
local function OnSpellCastSent(f, spellID)
    ---@param handlerFn ButtonHandlerFunction
    local function CallbackFn(handlerFn) ABPI():UpdateM6Macros(handlerFn) end
    L:SendMessage(MSG.OnSpellCastSentExt, ns.M.ActionbarPlusEventMixin, CallbackFn)
end

--- @alias NumberOfIterations number
--- @alias AdditionalDelay Time
---
--- @return AdditionalDelay
--- @param spellInfo SpellInfo
local function GetAdditionalDelay(spellInfo)
    assert(spellInfo, 'SpellInfo is required.')
    local hasForms = API:HasShapeshiftForms()
    local isShapeshiftSpell = false
    local delay = 0.1
    if hasForms then isShapeshiftSpell = API:IsShapeshiftSpell(spellInfo) end
    if ns:IsWOTLK() and hasForms and isShapeshiftSpell then
        delay = delay + 0.2
    elseif spellInfo.castTime > 0 then
        delay = delay + spellInfo.castTime/1000
    end
    return delay
end

--- @param spellInfo SpellInfo
local function GetIterationCount(spellInfo)
    if ns:IsWOTLK() and API:HasShapeshiftForms() then return 2 end
    return 0
end

--- @param spellID number
local function OnAfterSpellCastSucceeded(spellID)
    --BF():UpdateCooldownsAndState()
    --BF():UpdateUsable()
    --ns:AB():UpdateUsable()
    C_Timer.After(0.2, function() ns:AB():UpdateAll() end)
end

--- @param f EventFrameInterface
--- @param spellID number
local function OnSpellCastSucceeded(f, spellID)
    --p:log(10, 'OSCSucceeded[%s]: %s (%s)', spellID, GetSpellInfo(spellID), GetTime())
    OnAfterSpellCastSucceeded(spellID)
    L:SendMessage(GC.M.OnSpellCastSucceeded, ns.M.ActionbarPlusEventMixin)
end

--- @param eventCtx EventContext
local function OnPlayerControlLost(eventCtx)
    if InCombatLockdown() then return end

    C_Timer.NewTicker(1, function()
        local inPetBattle = O.BaseAPI:PlayerInPetBattle()
        local onTaxi = UnitOnTaxi(GC.UnitId.player)
        --p:log(10, 'ControlLost: onTaxi=%s inPetBattle=%s [%s]',
        --        onTaxi, inPetBattle, GetTime())
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
        --p:log(10, 'ControlGained: onTaxi=%s inPetBattle=%s [%s]',
        --        onTaxi, inPetBattle, GetTime())
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

--- @param f EventFrameInterface
--- @param event string
local function OnPlayerEnteringWorld(f, event, ...)
    p:log(30, 'OnPlayerEnteringWorld')
end

--- ShapeShift Sequence:
---     UPDATE_SHAPESHIFT_FORM, UPDATE_STEALTH, UPDATE_SHAPESHIFT_FORM
--- @param f EventFrameInterface
--- @param event string
local function OnEvent(f, event, ...)
    local eventCtx = f.ctx

    if E.UPDATE_STEALTH == event then
        return OnStealth(eventCtx)
    end

    if E.PLAYER_CONTROL_LOST == event then
        OnPlayerControlLost(eventCtx)
    elseif E.PLAYER_CONTROL_GAINED == event then
        OnPlayerControlGained(eventCtx)
    end
end

--- @param f EventFrameInterface
--- @param event string
local function OnMessageTransmitter(f, event, ...) L:SendMessage(GC.newMsg(event), ns.name, ...) end

--- @param self ActionbarPlusEvent ActionbarPlusEventMixin instance
local function OnAddOnInitializedMessage(self)
    --- @param abp ActionbarPlus
    self:RegisterMessage(MSG.OnAddOnInitialized, function(msg, abp)
        p:log(10, 'MSG::R: %s', msg)
        self:RegisterEvents()
        self:RegisterMessages()
    end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @alias AceHookHandle table

--- @param o ActionbarPlusEventMixin | AceBucket
local function PropsAndMethods(o)

    --- @param addon ActionbarPlus
    function o:Init(addon)
        self.addon = addon
        self.buttonFactory = O.ButtonFactory
        self.widgetMixin = O.WidgetMixin

        --- @type AceHookHandle
        self.idleTimeHandle = nil
        --- @type AceHookHandle
        self.updateCooldownHandle = nil
        --- @type Time
        self.idleTime = GetTime()

        --- @type Number The number in seconds
        self.expiryTimeInSeconds = 30

        OnAddOnInitializedMessage(self)
    end

    function o:GetIdleTimeInSeconds() return GetTime() - self.idleTime end
    function o:IsIdleTimeExpired() return IsFlying() or self:GetIdleTimeInSeconds() > self.expiryTimeInSeconds end

    function o:UpdateIdleTime()
        self.idleTime = GetTime()
        if self:ShouldRegisterEventCD() then self:RegisterEventCD() end
    end

    function o:RegisterEventCD()
        self.updateCooldownHandle = self:RegisterBucketEvent({ E.SPELL_UPDATE_USABLE },
                0.2, function() self:OnUpdateCooldownsAndState() end)
        --[[PR():IfLogCooldownEvents(function()
            p:log(1, 'Registered UpdateCooldownHandle')
        end)]]
    end

    function o:ShouldRegisterEventCD()
        return self.updateCooldownHandle == nil and IsFlying() ~= true
    end

    function o:UnRegisterEventCD()
        if self:IsIdleTimeExpired() and self.updateCooldownHandle then
            self:UnregisterBucket(self.updateCooldownHandle)
            self.updateCooldownHandle = nil
            PR():IfLogCooldownEvents(function()
                p:log(1, 'Unregistered UpdateCooldownHandle')
            end)
        end
    end

    function o:OnUpdateCooldownsAndState()
        local expired = self:IsIdleTimeExpired()
        local idleSeconds = self:GetIdleTimeInSeconds()

        --[[PR():IfLogCooldownEvents(function()
            p:log(5, 'IdleInSeconds=%s lastActivity=%s hasEventHandle=%s expired=%s flying=%s',
                    idleSeconds, self.idleTime, self.idleTimeHandle ~= nil, expired, IsFlying())
        end)]]
        if expired then self:UnRegisterEventCD(); return end

        -- todo next: secure hook on ActionButton_UpdateUsable
        ns:AB():UpdateAll()
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
        local enableCooldowns = true
        if enableCooldowns == true then
            self.idleTimeHandle = self:RegisterBucketEvent({ E.PLAYER_STOPPED_MOVING,
                                                        'UNIT_SPELLCAST_SENT',
                                                        'UNIT_POWER_FREQUENT',
                                                        'PLAYER_STOPPED_LOOKING',
            }, 2, function() self:UpdateIdleTime() end)
        end
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
        local classMapping = O.PlayerAuraMapping:GetPlayerClassMapping()
        if not classMapping or SizeOfTable(classMapping) <= 0 then
            p:log('Player class has no registered auras glows')
            return
        end
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPlayerAura)
        RegisterFrameForUnitEvents(f, { E.UNIT_AURA }, GC.UnitId.player)
    end

    function o:RegisterEvents()
        p:log(30, 'RegisterEvents called..')

        if GC.F.ENABLE_ACTION_BUTTON_GLOW then
            ---@param checkButton _CheckButton
            hooksecurefunc("ActionButton_ShowOverlayGlow", function(checkButton)
                if checkButton:GetObjectType() == 'CheckButton' and checkButton.action then
                    ns:AB():HandleShowOverlayGlow(checkButton)
                end
            end)
            hooksecurefunc("ActionButton_HideOverlayGlow", function(checkButton)
                if checkButton:GetObjectType() == 'CheckButton' and checkButton.action then
                    ns:AB():HandleHideOverlayGlow(checkButton)
                end
            end)

        end

        -- secure hook on update usable?
        hooksecurefunc("ActionButton_UpdateCooldown", function(checkButton)
            local spellID = ns:AB():GetActionSpellID(checkButton)
            if not spellID then return end
            if spellID ~= 18562 then return end
            local spellName = GetSpellInfo(spellID) or ''
            p:log('UpdateUsable: %s %s [%s]', tostring(spellID), spellName, GetTime())
        end)

        local enableSecureButtonOnClickHandler = true
        if enableSecureButtonOnClickHandler == true then
            --- @param down ButtonName
            --- @param btn _CheckButton | ButtonUI
            hooksecurefunc("SecureActionButton_OnClick", function(btn, down)
                if not btn.widget then return end
                local bw = btn.widget
                --p:log('SAB_OnClick:: data=%s', pformat(bw:GetConfig()))
                local spellID = bw:GetEffectiveSpellID() or ''
                local spellName
                if spellID then spellName = GetSpellInfo(spellID) end
                --p:log('SAB_OnClick::Hook: %s sp=%s [b4]', btn:GetName(), tostring(spellName))
                C_Timer.After(0.2, function()
                    --bw:UpdateStateLight()
                    bw:UpdateUsable()
                    bw:UpdateCooldown()
                end)
                p:log('SAB_OnClick: %s sp=%s', btn:GetName(), btn.widget:GetAbilityName())
            end)
        end

        self:RegisterActionbarsEventFrame()
        self:RegisterDefaultEventFrame()
        self:RegisterKeybindingsEventFrame()
        self:RegisterActionbarGridEventFrame()
        self:RegisterCursorChangesInBagEvents()
        self:RegisterCombatFrame()
        self:RegisterBagEvents()
        self:RegisterEventToMessageTransmitter()
        self:RegisterPlayerEnteringWorld()
        --self:RegisterPlayerAura()
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
