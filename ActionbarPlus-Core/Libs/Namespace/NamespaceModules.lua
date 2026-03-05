--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil_LibModule
local ModuleUtil = LibStub('Kapresoft-ModuleUtil-2-0')

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class Core_Modules_ABP_2_0
local ModuleNames = {
  
  ---------------------------------------
  ----- ThirdParty::Ace3 ----------------
  ---------------------------------------
  
  --- @type AceEvent_3_0
  AceEvent  = {},
  --- @type AceBucket_3_0
  AceBucket = {},
  --- @type AceAddon_3_0
  AceAddon  = {},
  --- @type AceDB_3_0
  AceDB     = {},
  
  ---------------------------------------
  ----- ThirdParty::Kapresoft Libs ------
  ---------------------------------------
  
  --- @type Kapresoft_Table_2_0
  Table = {},
  
  ---------------------------------------
  ----- ActionbarPlus_2_0 Libs ----------
  ---------------------------------------
  
  --- @type APIConstants_ABP_2_0
  APIConstants = {},
  --- @type Constants_ABP_2_0
  Constants = {},
  --- @type Compat_ABP_2_0
  Compat = {},
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

