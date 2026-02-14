--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local p, t, tt = ns:log()
local O = ns:cns().O
local EMBEDS = { 'AceEvent-3.0', 'AceBucket-3.0', 'AceConsole-3.0', 'AceHook-3.0'}

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]
--- @alias ABP_BarsUI_2_0 ABP_BarsUI_2_0_Impl | Addon_Type2_Libs
--
--
--- @class ABP_BarsUI_2_0_Impl : AceAddonObj_3_0
local A = O.AceAddon:NewAddon(ns.name, unpack(EMBEDS)); ABP_BarsUI_2_0 = A

--- @type ABP_BarsUI_2_0_Impl | ABP_BarsUI_2_0
local o = A

o:SetDefaultModuleLibraries(unpack(EMBEDS))
o:SetDefaultModuleState(false)


function A:OnEnable()
    p('xx OnEnable...')
end
function A:OnDisable()
    p('xx OnDisable...')
end

ABP_BarModuleFactory_2_0:CreateAddonModules()

C_Timer.After(1, function()
    p('AddOn created. name=', A:GetName())
end)
