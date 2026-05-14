--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

local C_PickupSpell        = C_Spell.PickupSpell
local C_PickupItem         = C_Item.PickupItem
local C_GetSpellCooldown   = C_Spell.GetSpellCooldown
local C_GetSpellInfo       = C_Spell.GetSpellInfo, GetSpellInfo
local C_GetActiveSpecGroup = C_SpecializationInfo.GetActiveSpecGroup
local C_GetItemInfoInstant = C_Item.GetItemInfoInstant
local C_GetItemCooldown    = C_Container.GetItemCooldown
local C_GetItemSpell       = C_Item.GetItemSpell

local Str_IsAnyOf = ns:String().IsAnyOf

--[[-----------------------------------------------------------------------------
Module::Compat
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.Compat()
--- @class Compat_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::Compat (Methods)
-------------------------------------------------------------------------------]]
local o = S

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return boolean
--- @param obj any An object to evaluate
local function IsFn(obj) return 'function' == type(obj) end

--- C_SpecializationInfo.GetSpecialization
--- 1, 2, 3 retail, 4 for druids ; 1, 2 classic
--- @return SpecializationIndex|number
function o:GetSpecializationID()
  if IsFn(GetSpecialization) then return GetSpecialization()
  elseif IsFn(GetActiveTalentGroup) then return GetActiveTalentGroup()
    -- C_GetActiveSpecGroup: MoP Classic (the active specIndex tab)
  elseif IsFn(C_GetActiveSpecGroup) then return C_GetActiveSpecGroup()
  end
  return 1
end

--- @param id SpellIdentifier
--- @return SpellInfo?
function o:__GetSpellInfoLegacy(id)
  local pt = type(id)
  assert(pt == 'string' or pt == 'number', 'GetSpellInfo::SpellID should be a number or a string.')

  local name, rank, icon, castTime, minRange,
      maxRange, spid, originalIcon = GetSpellInfo(id)

  --- @type SpellInfo
  local sp = {
    id = id, name = name, iconID = icon, castTime = castTime,
    minRange = minRange, maxRange = maxRange,
    originalIconID = originalIcon
  }
  return sp
end

--- @param spell SpellIdentifier
--- @return SpellInfo?
function o:GetSpellInfo(spell)
  local pt = type(spell)
  assert(pt == 'string' or pt == 'number', 'GetSpellInfo::SpellID should be a number or a string.')
  return C_GetSpellInfo(spell)
end

--- @param spell SpellIdentifier
--- @return Name?
function o:GetSpellName(spell)
  assert(type(spell) == 'number', 'GetSpellName(id): id should be a number.')
  local sp = self:GetSpellInfo(spell); return sp and sp.name
end

--- GetSpellInfo('name:string') will return nil if spell is unknown to player
--- @param spell SpellIdentifier
--- @boolean @Returns true if the player can cast the spell
function o:IsOwnSpell(spell) return self:GetSpellInfo(self:GetSpellName(spell)) ~= nil end

--- @param spell SpellIdentifier
--- @param callbackFn fun(spell:SpellInfo)
function o:IfSpell(spell, callbackFn)
  if not spell then return end
  local sp = self:GetSpellInfo(spell)
  return sp and callbackFn(sp)
end

--- @param spell SpellIdentifier
--- @return string|SpellIdentifier? @debug info for spells
function o:__debug_SpellInfo(spell)
  if not spell then return nil end
  local sp = self:GetSpellInfo(spell); if not sp then return spell end
  return ('%s(%s)'):format(sp.name, sp.spellID)
end


--- Picks up the specified spell, compatible with both Retail and Classic WoW.
--- @param spell SpellIdentifier The ID, name, or index of the spell to pick up.
function o:PickupSpell(spell) if not spell then return end; C_PickupSpell(spell) end

--- @param itemID ItemID
function o:PickupItem(itemID) if not itemID then return end; C_PickupItem(itemID) end

--- @param index Index
--- @return ShapeshiftFormData?
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
--- @param spell SpellIdentifier
--- @return SpellCooldownInfo
function o:GetSpellCooldown(spell)
  assert(Str_IsAnyOf(type(spell), 'number', 'string'),
    'GetSpellCooldown(spell):: spell should be a string (spell name) or number (spell ID).')
  return C_GetSpellCooldown(spell)
end

--- @see C_Spell.GetSpellCharges()
--- @param spell SpellIdentifier
--- @return SpellChargeInfo chargeInfo
function o:GetSpellCharges(spell)
  assert(Str_IsAnyOf(type(spell), 'number', 'string'),
    'GetSpellCharges(spell):: spell should be a string (spell name) or number (spell ID).')
  return C_Spell.GetSpellCharges(spell)
end

--- @return UnitCastingData
function o:GetCastingInfo(unit)
  local _unit = unit or 'player'
  local name, _, iconID, _, _, _, guid, _, spellID = UnitCastingInfo(_unit)

  --- @class UnitCastingData
  local data = {
    name = name, iconID = iconID, guid=guid, spellID = spellID
  }
  return spellID and data
end

--- The player is casting a spell that matches {matchSpellID}.
--- @param matchSpellID SpellID @The spellID to match
--- @return boolean
function o:IsPlayerCastingSpell(matchSpellID)
  assert(type(matchSpellID) == 'number', 'IsPlayerCastingSpell(matchSpellID):: expected a spellID(number).')
  local info = self:GetCastingInfo()
  return (info and info.spellID and info.spellID == matchSpellID) or false
end
--- The player is casting a spell (any spell)
--- @return boolean
function o:IsPlayerCasting()
  local info = self:GetCastingInfo()
  if info and info.spellID then return true end
  return false
end

--- @param spell SpellIdentifier
--- @return boolean
function o:IsInstantCastSpellByID(spell)
  local sp = self:GetSpellInfo(spell)
  if not (sp and sp.castTime) then return false end
  return sp.castTime == 0
end

--- Use for hot paths (cooldown, icon, id)
--- Fast; from client cache; no server query
--- @param itemInfo ItemID|ItemLink|ItemName
--- @return ItemInfoDetails?
function o:GetItemInfoInstant(itemInfo)
  local id, type, subType, equipLoc,
    icon, classID, subclassID = C_GetItemInfoInstant(itemInfo)
  if not id then return nil end
  --- @type ItemInfoDetails
  local item = {
    id = id, type = type, subType = subType,
    equipLoc = equipLoc, classID = classID,
    subclassID = subclassID, icon = icon,
  }
  return item
end

--- May trigger a server query if the item isn't cached yet
--- @param itemID ItemID
--- @return ItemInfoDetails?
function o:GetItemInfo(itemID)
  local name, link, quality,
    level, minLevel,
    type, subType, stackCount,
    equipLoc, icon, sellPrice,
    classID, subclassID, bindType,
    expansionID, setID, isCraftingReagent, desc = C_Item.GetItemInfo(itemID)

  if not name then return nil end
  --- @type ItemInfoDetails
  local item = {
    id = itemID, name=name, link=link, type = type, subType = subType,
    equipLoc = equipLoc, classID = classID,
    subclassID = subclassID, icon = icon,
  }
  return item
end

--- @see C_Container.GetItemCooldown(itemID)
--- @param itemInfo ItemID|ItemName|ItemLink
--- @return ItemCooldownInfo?
function o:GetItemCooldown(itemInfo)
  assert(Str_IsAnyOf(type(itemInfo), 'number', 'string'),
    'GetItemCooldown(itemInfo): {itemInfo} should be an number or a string')
  --- @type ItemCooldownInfo
  local cd

  --- @type ItemCooldownData
  local itemID = itemInfo
  -- itemInfo can an be a ItemName or ItemLink if not an ItemID
  if type(itemInfo) == 'string' then itemID = C_GetItemInfoInstant(itemInfo) end

  local startTime, duration, enable = C_GetItemCooldown(itemID)
  if startTime then
    local isEnabled = enable == 1 or enable == true
    cd = { startTime = startTime, duration = duration, isEnabled = isEnabled }
  end

  return cd
end

--- @see C_Item.GetItemSpell(itemID)
--- @param itemInfo ItemID|ItemName|ItemLink
--- @return number spellID?
--- @return string spellName?
function o:GetItemSpell(itemInfo)
  -- return SpellID first
  local name, id = C_GetItemSpell(itemInfo)
  return id, name
end
