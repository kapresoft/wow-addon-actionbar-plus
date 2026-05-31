--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local AceAddon, MF = cns.O.AceAddon, ns.O.BarModuleFactory
local EMBEDS = { 'AceEvent-3.0', 'AceBucket-3.0', 'AceConsole-3.0', 'AceHook-3.0' }
local p, t = ns:log()

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]
--- @class ABP_BarsUI_2_0 : AceAddon, AceEvent-3.0, AceBucket-3.0, AceConsole-3.0, AceHook-3.0
local o = cns:AceAddon():NewAddon(ns.name, unpack(EMBEDS)); ABP_BarsUI_2_0 = o

o:SetDefaultModuleLibraries(unpack(EMBEDS))
o:SetDefaultModuleState(false)

--- Called once, after:
--- - ActionbarPlus-Core is loaded
--- - SavedVariables are loaded
--- - All addon Lua/XML files are loaded
--- - AceDB initialized
function o:OnInitialize()
  self:SendMessage(ns:msg('OnAddOnInitialized'))
end

function o:OnEnable()
  MF:CreateAddonModules()
  self:SendMessage(ns:msg('OnBarsReady'))
end

function o:OnDisable()
  --t('OnDisable', 'called...')
end

--- @param callbackFn fun(module:BarModule_2_0):void
function o:ForEach(callbackFn)
  assert(type(callbackFn) == 'function', "ForEach(callbackFn): callbackFn should be a function")
  for name, module in ns:a():IterateModules() do
    --- @type BarModule_2_0
    local barModule = module
    callbackFn(barModule)
  end
end

function o:EnableBars()
  self:ForEach(function(module)
    module:Enable()
  end)
end

function o:DisableBars()
  self:ForEach(function(module)
    module:Disable()
  end)
end
