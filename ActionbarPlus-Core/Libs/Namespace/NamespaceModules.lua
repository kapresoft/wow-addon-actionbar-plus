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
--- @class Modules_ABP_2_0
local ModuleNames = {
  
  --- @type DatabaseMixin_ABP_2_0
  DatabaseMixin = {},
  --- @type DatabaseSchema_ABP_2_0
  DatabaseSchema = {},
  
  -----------------------
  ----- ThirdParty ------
  -----------------------
  
  --- @type AceEvent
  AceEvent  = {},
  --- @type AceBucketObj
  AceBucket = {},
  --- @type AceAddonObj
  AceAddon  = {},
  --- @type AceDBObj
  AceDB     = {},
  
}; LibModule.EnrichModules(ModuleNames); ns.M = ModuleNames

