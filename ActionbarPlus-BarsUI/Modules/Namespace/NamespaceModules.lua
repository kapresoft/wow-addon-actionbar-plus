--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil_Module
local LibModule = LibStub('Kapresoft-LibModule-1.0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class BarsUI_Modules_ABP_2_0
local ModuleNames = {
  
  --- @type Backdrops_ABP_2_0
  Backdrops = {},
  
}; LibModule.EnrichModules(ModuleNames); ns.M = ModuleNames

