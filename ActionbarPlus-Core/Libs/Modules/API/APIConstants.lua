--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::APIConstants
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.APIConstants()
--- @class APIConstants_ABP_2_0
--- @field UnitClasses UnitClassesType
local S = {}; ns:Register(libName, S)

--[[-----------------------------------------------------------------------------
Module::APIConstants (Methods)
-------------------------------------------------------------------------------]]
--- @type APIConstants_ABP_2_0
local o = S



--[[-------------------------------------------------------------------
Types
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
  local entry = { id = classID, name = className, }
  --- allows UnitClasses.Priest() : string
  setmetatable(entry, { __call = function(self) return self.name end })
  UnitClasses[className] = entry
end

o.UnitClasses = UnitClasses
