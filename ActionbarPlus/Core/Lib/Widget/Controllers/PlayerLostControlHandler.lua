--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local E, MSG = GC.E, GC.M
local PR, WMX = O.Profile, O.WidgetMixin

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'PlayerLostControlHandler'
--- @class PlayerLostControlHandler
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o PlayerLostControlHandler | ControllerV2
local function PropsAndMethods(o)

    function o.OnPlayerControlLost()
        p:f3(function() return 'OnPlayerControlLost() called..' end)
        if not PR:IsHideWhenTaxi() then return end
        o:o():HideActionBars()
    end

    function o.OnPlayerControlGained()
        local inPetBattle = o:a():IsPlayerInPetBattle()
        p:f3(function() return 'OnPlayerControlGained() called: InPetBattle=%s', inPetBattle end)
        if inPetBattle then return end
        if not PR:IsHideWhenTaxi() then return end
        o:o():ShowActionBars()
    end

    function o.OnHideWhenTaxiSettingsChanged()
        if o:a():IsPlayerOnTaxi() ~= true then return end
        if PR:IsHideWhenTaxi() then return o:o():HideActionBars() end
        o:o():ShowActionBars()
    end

    --- Handles Activities:
    --- 1) Player on Taxi
    --- 2) Player on Pet Battle
    --- 3) An attack which can put the player in a state of lost control, like a stun
    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:RegisterAddOnMessage(E.PLAYER_CONTROL_LOST, o.OnPlayerControlLost)
        self:RegisterAddOnMessage(E.PLAYER_CONTROL_GAINED, o.OnPlayerControlGained)
        self:RegisterMessage(MSG.OnHideWhenTaxiSettingsChanged, o.OnHideWhenTaxiSettingsChanged)

        -- In case a refresh occurs while flying
        o.OnHideWhenTaxiSettingsChanged()
    end

end; PropsAndMethods(L)

