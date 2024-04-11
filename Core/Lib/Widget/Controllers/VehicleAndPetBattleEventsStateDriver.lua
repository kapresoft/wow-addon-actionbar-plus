--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local M, E = GC.M, GC.E
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'VehicleAndPetBattleEventsStateDriver'
--- @class VehicleAndPetBattleEventsStateDriver
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o VehicleAndPetBattleEventsStateDriver | ControllerV2
local function PropsAndMethods(o)

    function o.OnHide()
        p:f3(function() return 'OnHide called... InCombatLockdown: %s', InCombatLockdown() end)
        o:o():HideActionBars()
    end

    function o.OnShow()
        o:o():ShowActionBars()
    end

    --- ### See: [Macro_conditionals](https://wowpedia.fandom.com/wiki/Macro_conditionals)
    --- /dump UIParent.ActionbarPlusEventFrame
    --- @see PlayerLostControlHandler#OnPlayerControlGained
    --- @private
    function o:initStateDriver()
        --- @type Frame
        local f = CreateFrame("Frame", nil, ActionbarPlusEventFrame, "SecureHandlerStateTemplate")
        f:SetScript("OnHide", o.OnHide)
        f:SetScript("OnShow", o.OnShow)
        f:SetParentKey(libName);

        -- what works: [actionbar:2], mounted, vehicleui, petbattle
        -- [@target,exists], indoors, possessbar, [nomod:shift], [@mouseover,help]
        -- Note: The state driver will not work if there's an issue with the values in "stateType".
        RegisterStateDriver(f, "visibility", "[vehicleui][petbattle]hide;show")
    end

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:initStateDriver()
        if not self:a():SupportsVehicles() then return end
        if self:a():IsPlayerInVehicle() then o.OnHide() end
    end

end; PropsAndMethods(L)

