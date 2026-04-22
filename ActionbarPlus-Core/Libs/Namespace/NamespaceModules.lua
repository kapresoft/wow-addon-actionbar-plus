--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type Kapresoft-ModuleUtil-2-0
local ModuleUtil = LibStub('Kapresoft-ModuleUtil-2-0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class Core_Modules_ABP_2_0
local ModuleNames = {
  
  ---------------------------------------
  ----- ActionbarPlus_2_0 Libs ----------
  ---------------------------------------
  
  --- @type Constants_ABP_2_0
  Constants = {},
  --- @type Compat_ABP_2_0
  Compat = {},
  --- @type ActionUtil_ABP_2_0
  ActionUtil = {},
  --- @type SpellUtil_ABP_2_0
  SpellUtil = {},
  --- @type UnitUtil_ABP_2_0
  UnitUtil = {},
  --- @type DruidUtil_ABP_2_0
  DruidUtil = {},
  --- @type PriestUtil_ABP_2_0
  PriestUtil = {},
  --- @type CursorProvider_ABP_2_0
  CursorProvider = {},
  --- @type Backdrops_ABP_2_0
  Backdrops = {},
  --- @type DatabaseMixin_ABP_2_0
  DatabaseMixin = {},
  --- @type DatabaseSchema_ABP_2_0
  DatabaseSchema = {},
  
}; ModuleUtil:EnrichModules(ModuleNames); ns.M = ModuleNames

