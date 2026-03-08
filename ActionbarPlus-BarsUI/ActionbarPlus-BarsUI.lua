--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local AceAddon, MF = cns.O.AceAddon, ns.O.BarModuleFactory
local EMBEDS = { 'AceEvent-3.0', 'AceBucket-3.0', 'AceConsole-3.0', 'AceHook-3.0'}
local p, pd, t, tf = ns:log('ABP_BarsUI')

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]
--- @alias ABP_BarsUI_2_0 ABP_BarsUI_2_0_Impl | Addon_Type2_Libs
--
--
--- @class ABP_BarsUI_2_0_Impl : AceAddonObj_3_0
local A = AceAddon:NewAddon(ns.name, unpack(EMBEDS)); ABP_BarsUI_2_0 = A

--- @type ABP_BarsUI_2_0_Impl | ABP_BarsUI_2_0
local o = A

o:SetDefaultModuleLibraries(unpack(EMBEDS))
o:SetDefaultModuleState(false)

function A:OnEnable()
  C_Timer.After(0.1, function() t('OnEnable...') end)
  MF:CreateAddonModules()
end

function A:OnDisable()
  p('xx OnDisable...')
end

C_Timer.After(1, function()
  p('AddOn created. name=', A:GetName())
end)
