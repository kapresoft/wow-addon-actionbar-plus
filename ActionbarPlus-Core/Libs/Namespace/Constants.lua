--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::Constants
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.Constants()
--- @class Constants_ABP_2_0
--- @field UnitClasses UnitClassesType
--- @field AttributeNames AttributeNames_ABP_2_0
local o = {}; ns:Register(libName, o)

--[[-----------------------------------------------------------------------------
Module::Constants (Methods)
-------------------------------------------------------------------------------]]
--- @class AttributeNames_ABP_2_0
local AttributeNames = {
  type              = 'type',

  -- ## addon-based custom attributes ##
  -- used for drag and drop transitional states
  suspended_type    = 'abp_suspended_type',
  abp_type          = 'abp_type',      -- ABP Custom type
  -- used for custom implementations
  abp_battlepet     = 'abp_battlepet', -- ABP Custom Battlepet

}; o.AttributeNames = AttributeNames

--- The following are not supported:
--- - petaction
--- @class SupportedActionTypes_ABP_2_0
local SupportedActionTypes = {
  spell        = 'spell',
  item         = 'item',
  macro        = 'macro',
  macrotext    = 'macrotext',
  -- custom type handling below this line --
  mount        = 'mount',
  companion    = 'companion',
  battlepet    = 'battlepet',
  equipmentset = 'equipmentset',
}; o.SupportedActionTypes = SupportedActionTypes
o.SupportedActionTypesAsMap = function()
  local map = {}
  for _, name in pairs(SupportedActionTypes) do map[name] = true end
  return map
end
--[[-------------------------------------------------------------------
UnitClass
@see FrameXMLBase\Constants.lua#CLASS_SORT_ORDER
---------------------------------------------------------------------]]
local UnitClassID = {
  WARRIOR = 1,
  PALADIN = 2,
  HUNTER = 3,
  ROGUE = 4,
  PRIEST = 5,
  DEATHKNIGHT = 6,
  SHAMAN = 7,
  MAGE = 8,
  WARLOCK = 9,
  MONK = 10,        -- Note: Monk class was added in Mists of Pandaria
  DRUID = 11,
  DEMONHUNTER = 12, -- Note: Demon Hunter class was added in Legion
  EVOKER = 13,      -- Note: Evoker class was added in Dragonflight
}

--- @type UnitClassesType
local UnitClasses = {}
for className, classID in pairs(UnitClassID) do
  --- @type UnitClassType
  local entry = { id = classID, name = className, }
  --- allows UnitClasses.PRIEST() : string
  setmetatable(entry, { __call = function(self) return self.name end })
  UnitClasses[className] = entry
end; o.UnitClasses = UnitClasses

-- Temporary Keybind items for Bindings.xml
ABPV2_CATEGORY           = "AddOns/ActionbarPlus-2.0"
ABPV2_HEADER_ACTIONBAR1 = "Header"
_G['BINDING_NAME_CLICK ABP_2_0_F1Button1:LeftButton'] = 'Bar #1: Button 1'
