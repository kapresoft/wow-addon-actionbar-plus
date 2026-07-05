--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

--- @type Kapresoft-ModuleUtil-2-0
local ModuleUtil = LibStub('Kapresoft-ModuleUtil-2-0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class BarsUI_Modules_ABP_2_0
local ModuleNames = {
  
  --- @type Backdrops_ABP_2_0
  Backdrops = {},
  --- @type BarAnchorController_ABP_2_0
  BarAnchorController = {},
  --- @type ButtonHandlerMixin_ABP_2_0
  ButtonHandlerMixin = {},
  --- @type ButtonWidgetMixin_ABP_2_0
  ButtonWidgetMixin = {},
  --- @type BarModuleFactory_ABP_2_0
  BarModuleFactory = {},
  --- @type ButtonConfigAccessorMixin_ABP_2_0
  ButtonConfigAccessorMixin = {},
  --- @type DragStateController_ABP_2_0
  DragStateController = {},
  --- @type BarVisibilityController_ABP_2_0
  BarVisibilityController = {},


}; ModuleUtil:EnrichModules(ModuleNames); ns.M = ModuleNames

