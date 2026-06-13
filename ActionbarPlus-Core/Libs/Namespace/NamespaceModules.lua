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
  --- @type ABP_BarsUI_2_0
  ['ActionbarPlus-BarsUI'] = {},
  --- @type ABP_OptionsUI_2_0
  ['ActionbarPlus-OptionsUI'] = {},

  --- @type Constants_ABP_2_0
  Constants = {},
  --- @type Compat_ABP_2_0
  Compat = {},
  --- @type ActionUtil_ABP_2_0
  ActionUtil = {},
  --- @type HashUtil_ABP_2_0
  HashUtil = {},
  --- @type SpellUtil_ABP_2_0
  SpellUtil = {},
  --- @type UnitUtil_ABP_2_0
  UnitUtil = {},
  --- @type DruidUtil_ABP_2_0
  DruidUtil = {},
  --- @type PriestUtil_ABP_2_0
  PriestUtil = {},
  --- @type RogueUtil_ABP_2_0
  RogueUtil = {},
  --- @type ShamanUtil_ABP_2_0
  ShamanUtil = {},
  --- @type CursorProvider_ABP_2_0
  CursorProvider = {},
  --- @type PickupHooks_ABP_2_0
  PickupHooks = {},
  --- @type Backdrops_ABP_2_0
  Backdrops = {},
  --- @type DatabaseMixin_ABP_2_0
  DatabaseMixin = {},
  --- @type DatabaseSchema_ABP_2_0
  DatabaseSchema = {},
  
}; ModuleUtil:EnrichModules(ModuleNames); ns.M = ModuleNames

