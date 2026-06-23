--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local AceAddon = cns.O.AceAddon
local MF = ns.O.BarModuleFactory
local EMBEDS = { 'AceEvent-3.0', 'AceBucket-3.0', 'AceConsole-3.0', 'AceHook-3.0' }

local quickKeybindModeActive = false

--[[-------------------------------------------------------------------
Addon
---------------------------------------------------------------------]]

--- @class ABP_BarsUI_2_0 : AceAddon, AceEvent-3.0, AceBucket-3.0, AceConsole-3.0, AceHook-3.0
local o = cns:AceAddon():NewAddon(ns.name, unpack(EMBEDS)); ABP_BarsUI_2_0 = o
local p, t = ns:log()

o:SetDefaultModuleLibraries(unpack(EMBEDS))
o:SetDefaultModuleState(false)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

local function ResyncAllButtonsEmptyState()
  ns:a():ForEach(function(bm)
    local showEmptyButtons = bm:c().ui.showEmptyButtons
    bm:ForEach(function(btn) btn.widget:UpdateEmptyState(showEmptyButtons) end)
  end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- Called once, after:
--- - ActionbarPlus-Core is loaded
--- - SavedVariables are loaded
--- - All addon Lua/XML files are loaded
--- - AceDB initialized
function o:OnInitialize()
  self:SendMessage(ns:msg('OnInitialize'))
  self:RegisterMessage(cns:msg('OnCoreDependentsReady'), self.OnCoreDependentsReady, self)
end

function o:OnCoreDependentsReady()
  local optionsNS = cns:OptionsNS()
  ns:a():RegisterMessage(optionsNS:msg('OnQuickKeybindModeActive'), function()
    quickKeybindModeActive = true
    ResyncAllButtonsEmptyState()
  end)
  ns:a():RegisterMessage(optionsNS:msg('OnQuickKeybindModeNotActive'), function()
    quickKeybindModeActive = false
    ResyncAllButtonsEmptyState()
  end)
end

--- @return boolean
function o:IsQuickKeybindModeActive() return quickKeybindModeActive end

function o:OnEnable()
  MF:CreateAddonModules()
  self:SendMessage(ns:msg('OnEnable'), self)
end

function o:OnDisable()
  self:SendMessage(ns:msg('OnDisable'))
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

--- @return Namespace_ABP_BarsUI_2_0
function o:ns() return ns end
