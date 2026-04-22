--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local AceAddon, MF = cns.O.AceAddon, ns.O.BarModuleFactory
local EMBEDS = { 'AceEvent-3.0', 'AceBucket-3.0', 'AceConsole-3.0', 'AceHook-3.0' }
local p, t = ns:log()

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]
--- @class ABP_BarsUI_2_0 : AceEvent-3.0, AceBucket-3.0, AceConsole-3.0, AceHook-3.0
local o = cns:AceAddon():NewAddon(ns.name, unpack(EMBEDS)); ABP_BarsUI_2_0 = o

o:SetDefaultModuleLibraries(unpack(EMBEDS))
o:SetDefaultModuleState(false)

function o:OnEnable()
  t('OnEnable', 'called...')
  C_Timer.After(1, function()
      p('OnDisable', 'called...')
  end)
  MF:CreateAddonModules()
end

function o:OnDisable()
  t('OnDisable', 'called...')
end
