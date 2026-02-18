--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::Compat
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.Compat()
--- @class Compat_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)
C_Timer.After(1, function() p("xxx Loaded...") end)

--[[-----------------------------------------------------------------------------
Module::Compat (Methods)
-------------------------------------------------------------------------------]]
--- @type Compat_ABP_2_0
local o = S

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return boolean
--- @param o any An object to evaluate
local function IsFn(o) return 'function' == type(o) end

--- C_SpecializationInfo.GetSpecialization
--- 1, 2, 3 retail, 4 for druids ; 1, 2 classic
--- @return number
function o:GetSpecializationID()
  if IsFn(GetSpecialization) then return GetSpecialization()
  elseif IsFn(GetActiveTalentGroup) then return GetActiveTalentGroup()
    -- C_GetActiveSpecGroup: MoP Classic (the active specIndex tab)
  elseif IsFn(C_GetActiveSpecGroup) then return C_GetActiveSpecGroup()
  end
  return 1
end

local GetSpellInfo = GetSpellInfo
local C_GetSpellInfo = C_Spell.GetSpellInfo

--- @param id SpellIdentifier
--- @return SpellInfo|nil
function o:__GetSpellInfoLegacy(id)
  local pt = type(id)
  assert(pt == 'string' or pt == 'number', 'GetSpellInfo::SpellID should be a number or a string.')
  
  local name, rank, icon, castTime, minRange,
      maxRange, id, originalIcon = GetSpellInfo(id)
  
  --- @type SpellInfo
  local sp = {
    id = id, name = name, iconID = icon, castTime = castTime,
    minRange = minRange, maxRange = maxRange,
    originalIconID = originalIcon
  }
  return sp
end

--- @param id SpellIdentifier
--- @return SpellInfo|nil
function o:GetSpellInfo(id)
  local pt = type(id)
  assert(pt == 'string' or pt == 'number', 'GetSpellInfo::SpellID should be a number or a string.')
  if C_GetSpellInfo then return C_GetSpellInfo(id) end
  return self:__GetSpellInfoLegacy(id)
end
c = o
