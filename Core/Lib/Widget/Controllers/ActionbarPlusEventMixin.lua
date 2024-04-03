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
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local E, MSG, UnitId = GC.E, GC.M,  GC.UnitId
local B, BF = O.BaseAPI, O.ButtonFactory

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'ActionbarPlusEventMixin'
--- @class ActionbarPlusEventMixin
local L = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)
local pe = ns:LC().EVENT:NewLogger(libName)
local pu = ns:LC().UNIT:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param f Frame
--- @param event string
local function OnPlayerCombatEvent(f, event, ...)
    pu:d(function() return 'Event[%s] received...', event end)
    if E.PLAYER_REGEN_ENABLED == event then
        BF:Fire(E.OnPlayerLeaveCombat)
    end

    BF:Fire(E.OnUpdateItemStates)
    -- This second fire is for fail-safety
    C_Timer.After(2, function() BF:Fire(E.OnUpdateItemStates) end)
end

--- @param f Frame
--- @param event string
local function OnPetBattleEvent(f, event, ...)
    if E.PET_BATTLE_OPENING_START == event then
        BF:Fire(E.OnActionbarHideGroup)
        return
    end
    BF:Fire(E.OnActionbarShowGroup)
end

--- @param f Frame
--- @param event string
local function OnVehicleEvent(f, event, ...)
    local unitTarget = ...
    pe:d(function() return 'Event[%s]:: unitTarget=%s', event, unitTarget end)
    if UnitId.player ~= unitTarget then return end
    if E.UNIT_ENTERED_VEHICLE == event then
        BF:Fire(E.OnActionbarHideGroup)
        return
    end
    BF:Fire(E.OnActionbarShowGroup)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ActionbarPlusEventMixin | ControllerV2
local function PropsAndMethods(o)
    --- @param addon ActionbarPlus
    function o:Init(addon)
        self.addon = addon
        self.buttonFactory = O.ButtonFactory
        self.widgetMixin = O.WidgetMixin
    end

    --- ActionbarPlusEventFrame is in _ParentFrame.xml
    --- @return Frame
    function o:CreateEventFrame()
        return CreateFrame("Frame", nil, ActionbarPlusEventFrame)
    end

    --  todo: Convert to use RegisterStateDriver(..)
    --- @see ConfigDialogController#CreateDialogEventFrame
    function o:RegisterVehicleFrame()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnVehicleEvent)
        RegisterFrameForUnitEvents(f, { E.UNIT_ENTERED_VEHICLE, E.UNIT_EXITED_VEHICLE }, GC.UnitId.player)
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

    function o:OnAddOnReady()
        self:RegisterCombatFrame()

        if B:SupportsPetBattles() then self:RegisterPetBattleFrame() end
        --TODO: Need to investigate Wintergrasp (hides/shows intermittently)
        if B:SupportsVehicles() then self:RegisterVehicleFrame() end
    end
end; PropsAndMethods(L)
