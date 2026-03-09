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
local S = {}; ns:Register(libName, S)

--[[-----------------------------------------------------------------------------
Module::Constants (Methods)
-------------------------------------------------------------------------------]]
--- @type Constants_ABP_2_0
local o = S

--- @class AttributeNames_ABP_2_0
local AttributeNames = {
  type = 'type',
  saved_type = 'abp_saved_type',
  dragged_type = 'abp_dragged_type',
}; o.AttributeNames = AttributeNames

--- @class SupportedActionTypes_ABP_2_0
local SupportedActionTypes = {
  spell        = 'spell',
  item         = 'item',
  macro        = 'macro',
  macrotext    = 'macrotext',
  mount        = 'mount',
  companion    = 'companion',
  battlepet    = 'battlepet',
  petaction    = 'petaction',
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
