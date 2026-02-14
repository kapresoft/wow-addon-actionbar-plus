--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil_Module
local LibModule = LibStub('Kapresoft-LibModule-1.0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class Core_Modules_ABP_2_0
local ModuleNames = {
  
  --- @type Compat_ABP_2_0
  Compat = {},
  
  --- @type Backdrops_ABP_2_0
  Backdrops = {},
  
  --- @type DatabaseMixin_ABP_2_0
  DatabaseMixin = {},
  --- @type DatabaseSchema_ABP_2_0
  DatabaseSchema = {},
  
  -----------------------
  ----- ThirdParty ------
  -----------------------
  
  --- @type AceEvent_3_0
  AceEvent  = {},
  --- @type AceBucket_3_0
  AceBucket = {},
  --- @type AceAddon_3_0
  AceAddon  = {},
  --- @type AceDB_3_0
  AceDB     = {},
  
}; LibModule.EnrichModules(ModuleNames); ns.M = ModuleNames

