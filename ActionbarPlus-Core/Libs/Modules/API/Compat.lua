--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

local C_PickupSpell = C_Spell and C_Spell.PickupSpell or PickupSpell
local C_GetSpellCooldown = C_Spell and C_Spell.GetSpellCooldown
local GetSpellInfo, C_GetSpellInfo = GetSpellInfo, C_Spell and C_Spell.GetSpellInfo

--- return data has the same structure for C_Item or legacy GetItemCooldown
local C_GetItemCooldown = C_Item and C_Item.GetItemCooldown or GetItemCooldown

--[[-----------------------------------------------------------------------------
Module::Compat
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.Compat()
--- @class Compat_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)

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

--- @param id SpellIdentifier
--- @return SpellInfoData|nil
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

--- @param spell SpellIdentifier
--- @return SpellInfoData|nil
function o:GetSpellInfo(spell)
  local pt = type(spell)
  assert(pt == 'string' or pt == 'number', 'GetSpellInfo::SpellID should be a number or a string.')
  if C_GetSpellInfo then return C_GetSpellInfo(spell) end
  return self:__GetSpellInfoLegacy(spell)
end

--- @param id SpellID
--- @return Name|nil
function o:GetSpellName(id)
  assert(type(id) == 'number', 'GetSpellName(id): id should be a number.')
  local sp = self:GetSpellInfo(id); return sp and sp.name
end

--- GetSpellInfo('name:string') will return nil if spell is unknown to player
--- @param id SpellID
--- @boolean true if the player can cast the spell
function o:IsOwnSpell(id) return self:GetSpellInfo(self:GetSpellName(id)) ~= nil end

--- @param spell SpellIdentifier
--- @param callbackFn fun(spell:SpellInfoData)
function o:IfSpell(spell, callbackFn)
  if not spell then return end
  local sp = self:GetSpellInfo(spell)
  return sp and callbackFn(sp)
end


--- Picks up the specified spell, compatible with both Retail and Classic WoW.
--- @param spell SpellIdentifier The ID, name, or index of the spell to pick up.
function o:PickupSpell(spell) if not spell then return end; C_PickupSpell(spell) end

--- @param index Index
--- @return ShapeshiftFormData
function o:GetShapeshiftFormInfo(index)
  if type(index) ~= 'number' then return nil end
  local shapeshiftIcon, active, castable, spellID = GetShapeshiftFormInfo(index)
  if not (shapeshiftIcon or spellID) then return nil end
  --- @type ShapeshiftFormData
  local c = {
    index = index, shapeshiftIcon = shapeshiftIcon,
    spellID = spellID, active = active, castable = castable,
  }
  return c
end

--- Retrieves the cooldown information for a spell, compatible with both Retail and Classic WoW.
--- @param spellID SpellName A known spell name for the character class.
--- @return SpellCooldownInfo
function o:GetSpellCooldown(spellID)
  assert(type(spellID) == 'number', 'GetSpellCooldown(spellID):: spellID should be a number.')
  if C_GetSpellCooldown then return C_GetSpellCooldown(spellID) end
  
  local startTime, duration, isEnabled, modRate = GetSpellCooldown(spellID)
  --- @type SpellCooldownInfo
  local cd = { startTime = startTime, duration = duration,
               isEnabled = isEnabled, modRate = modRate, }
  return startTime and cd
end

--- @param itemName Name
--- @return ItemCooldownData
function o:GetItemCooldown(itemName)
  -- todo: needs to take name or id
  local startTime, duration, enable
  --- @type ItemCooldownData
  local cd
  if C_GetItemCooldown then
    startTime, duration, enable = C_GetItemCooldown(itemName)
  elseif C_Container and C_Container.GetItemCooldown then
    startTime, duration, enable = C_Container.GetItemCooldown(id)
  elseif GetItemCooldown then
    startTime, duration, enable = GetItemCooldown(id)
  end
  if not startTime then return nil end
  cd = { startTime = startTime, duration = duration, enable = enable }
  return cd
end
