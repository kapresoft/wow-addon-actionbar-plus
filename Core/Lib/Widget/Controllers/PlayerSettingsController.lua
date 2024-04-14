--[[-----------------------------------------------------------------------------
PlayerSettingsController: Handles the features configured in Settings
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG = GC.M
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'PlayerSettingsController'
--- @class PlayerSettingsController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o PlayerSettingsController | ControllerV2
local function PropsAndMethods(o)

    function o.OnCombatLockState()
        o:o():SetActionBarsLockState(true);
    end

    function o.OnCombatUnlockState()
        o:o():SetActionBarsLockState(false);
    end

    function o.OnCooldownTextSettingsChanged()
        o:ForEachButton(function(bw) bw:RefreshTexts() end)
    end

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:RegisterMessage(MSG.OnPlayerEnterCombat, o.OnCombatLockState)
        self:RegisterMessage(MSG.OnPlayerLeaveCombat, o.OnCombatUnlockState)
        self:RegisterMessage(MSG.OnCooldownTextSettingsChanged, o.OnCooldownTextSettingsChanged)
    end

end; PropsAndMethods(L)

