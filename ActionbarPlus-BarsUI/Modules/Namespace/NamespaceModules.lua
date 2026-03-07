--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

--- @type Kapresoft_ModuleUtil_2_0
local ModuleUtil = LibStub('Kapresoft-ModuleUtil-2-0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class BarsUI_Modules_ABP_2_0
local ModuleNames = {
  
  --- @type Backdrops_ABP_2_0
  Backdrops = {},
  
  --- @type ButtonWidgetMixin_ABP_2_0
  ButtonWidgetMixin = {},
  --- @type BarModuleFactory_ABP_2_0
  BarModuleFactory = {},
  --- @type ButtonConfigAccessorMixin_ABP_2_0
  ButtonConfigAccessorMixin = {},
  --- @type ButtonStateMixin_ABP_2_0
  ButtonStateMixin = {},
}; ModuleUtil:EnrichModules(ModuleNames); ns.M = ModuleNames

