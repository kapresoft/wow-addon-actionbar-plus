--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local comp, SupportedActionTypeMap = O.Compat, O.Constants.SupportedActionTypesAsMap()

-- These C_Spell methods exists in classic-era
local C_IsAutoRepeatSpell   = C_Spell.IsAutoRepeatSpell
local C_IsCurrentSpell      = C_Spell.IsCurrentSpell
local C_GetSpellPowerCost   = C_Spell.GetSpellPowerCost
local C_IsSpellKnown        = C_SpellBook.IsSpellKnown
local C_IsSpellUsable       = C_Spell.IsSpellUsable
local C_IsUsableItem        = C_Item.IsUsableItem
local C_GetTalentInfo       = C_SpecializationInfo and C_SpecializationInfo.GetTalentInfo
local C_GetSummonedPetGUID  = C_PetJournal and C_PetJournal.GetSummonedPetGUID

local unit, shaman, priest = O.UnitUtil, O.ShamanUtil, O.PriestUtil

local ATTACK_SPELL_ID     = 6603
local SHOOT_SPELL_ID      = 5019
local MOP_TALENT_TIERS    = 6
local MOP_TALENT_COLUMNS  = 3

--[[-----------------------------------------------------------------------------
Module::ActionUtil
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.ActionUtil()
--- @class ActionUtil_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, t = ns:log(libName)

local attr, atyp = ns:constants()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param spell SpellIdentifier
--- @return SpellID?
local function __SpellID(spell)
  if type(spell) == 'number' then return spell end
  --- @type SpellID
  local spid
  comp:IfSpell(spell, function(sp) spid = sp.spellID end)
  return spid
end

--- @param equipSetID EquipmentSetID
--- @return boolean
local function IsEquipmentSetCurrent(equipSetID)
  local isEquipped = false
  comp:IfEquipmentSet(equipSetID, function(eqSet)
    isEquipped = eqSet.isEquipped
  end)
  return isEquipped
end

--- @param mountID MountID
--- @return boolean
local function IsMountCurrent(mountID)
  local isCurrent = false
  comp:IfMount(mountID, function(mount)
    isCurrent = C_IsCurrentSpell(mount.spellID)
  end)
  return isCurrent
end

--[[-----------------------------------------------------------------------------
Module::ActionUtil (Methods)
-------------------------------------------------------------------------------]]
local o = S

-- increase as needed
local ENCODER_RADIX = 1000

--- Encodes a bar index and button index into a single numeric ID
--- #### Example Use:
--- ```
--- local id = encodeID(2, 1)      -- 2001
--- local bar, btn = decode(2001)  -- bar=2, btn=1
--- ```
--- @param barIndex number The action bar index (higher-order digits)
--- @param buttonIndex number The button index within the bar (lower-order digits, 0-999)
--- @return number encodedID Combined ID where barIndex occupies higher digits
function o.encodeBarID(barIndex, buttonIndex)
    return barIndex * ENCODER_RADIX + buttonIndex
end

--- Decodes a numeric ID back into its bar and button indices
--- @param encodedID number The combined ID from encodeID()
--- @return number @barIndex The action bar index
--- @return number @buttonIndex The button index within the bar
function o.decodeBarID(encodedID)
    local barIndex = math.floor(encodedID / 1000)
    local buttonIndex = encodedID % ENCODER_RADIX
    return barIndex, buttonIndex
end

--- @param spellID SpellID
--- @return boolean, SpellInfo? @If {spellID} is not known, it will try to get the latest spell
function o.IsSpellKnown(spellID)
  assert(type(spellID) == 'number', 'IsSpellKnown(spellID): {spellID} should be a number')
  if C_IsSpellKnown(spellID) then return true end

  local unknownSp = comp:GetSpellInfo(spellID)
  if not (unknownSp and unknownSp.name) then return false end

  -- returns a value if spell is known by name
  local nextSp = comp:GetSpellInfo(unknownSp.name)
  return false, nextSp
end

--- @param itemValue string|number @The itemID attribute value, i.e. 'item:123'
--- @return ItemID?         @returns 123 given {itemIDAttribute} of 'item:123'
function o.ExtractItemID(itemValue)
  if not itemValue then return nil end
  if type(itemValue) == 'number' then return itemValue end
  assert(type(itemValue) == 'string', 'GetAttributeItemID(itemIDAttribute): {itemIDAttribute} should be a string but was: ', type(itemValue))
  return tonumber(itemValue:match("item:(%d+)"))
end

--- @param typ ActionType The button attribute 'type' value
--- @param val ActionValue The context id; 'spell', 'item', etc...
--- @param isCustom boolean?
--- @return boolean?   @true if action is usable
--- @return boolean?   @true if due to not-enough-'energy|mana|rage|etc', false otherwise
function o.IsUsableAction(typ, val, isCustom)
  if not (typ and val) then return false end

  if o.IsSpell(typ) then
      local isUsable, notEnoughMana = C_IsSpellUsable(val)
      return isUsable, notEnoughMana
  elseif o.IsItem(typ) then
    return C_IsUsableItem(val)
  elseif o.IsMacro(typ) then
    local sp = GetMacroSpell(val)
    if sp then
      local isUsable, notEnoughMana = C_IsSpellUsable(sp)
      return isUsable, notEnoughMana
    end
    return true
  elseif isCustom then
    if o.IsMount(typ) then
      local isUsable
      o.IfMount(val, function(mountInfo) isUsable = C_IsSpellUsable(mountInfo.name) end)
      return isUsable, false
    elseif o.IsEquipmentSet(typ) then
      return not InCombatLockdown()
    elseif o.IsBattlePet(typ) then
      return true
    end
  end
  return false
end

--- @param spell SpellIdentifier
--- @return boolean
function o.IsAutoAttackInProgress(spell)
  local spellID = __SpellID(spell)
  return o.IsAutoAttackSpell(spellID) and o.IsCurrentSpell(spellID)
end

--- @param spell SpellIdentifier
--- @return boolean
function o.IsShootingInProgress(spell)
  local spellID = __SpellID(spell)
  return o.IsShootSpell(spellID) and o.IsCurrentSpell(spellID)
end

--- @param spell SpellIdentifier
--- @return boolean
function o.IsAutoAttackSpell(spell) return __SpellID(spell) == ATTACK_SPELL_ID end

--- @param spell SpellIdentifier
--- @return boolean
function o.IsShootSpell(spell) return __SpellID(spell) == SHOOT_SPELL_ID end

--- @param spell SpellIdentifier
--- @return boolean
function o.IsCurrentSpell(spell)
  local spellID = __SpellID(spell)
  return C_IsCurrentSpell(spellID) or C_IsAutoRepeatSpell(spellID)
end

--- @param typ string The button attribute 'type' value
--- @param val Identifier The context id; 'spell', 'item', etc...
--- @param isCustom boolean
--- @return boolean
function o.IsCurrentAction(typ, val, isCustom)
  if not (typ and val) then return false end
  if not isCustom then
    if o.IsSpell(typ) then
      return C_IsCurrentSpell(val) or C_IsAutoRepeatSpell(val)
    elseif o.IsItem(typ) then
        return C_Item.IsCurrentItem(val)
    end
  else
    if o.IsMount(typ) then
      return IsMountCurrent(val --[[@as MountID]])
    elseif o.IsEquipmentSet(typ) then
      return IsEquipmentSetCurrent(val --[[@as EquipmentSetID]])
    elseif C_GetSummonedPetGUID and o.IsBattlePet(typ) then
      return C_GetSummonedPetGUID() == val
    end
  end
  return false
end

--- @param action Name The action name; i.e. 'spell', 'item', etc..
--- @return boolean
function o.IsSupportedAction(action)
  return type(action) == 'string'
          and SupportedActionTypeMap[strlower(action)] == true
end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsSpell(typ) return typ == atyp.spell end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsItem(typ) return typ == atyp.item end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsMount(typ) return typ == atyp.mount end

--- A custom type
--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsEquipmentSet(typ) return typ == atyp.equipmentset end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsMacro(typ) return typ == atyp.macro end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsMacroText(typ) return typ == atyp.macrotext end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsBattlePet(typ) return typ == atyp.battlepet end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsPetAction(typ) return typ == atyp.petaction end

--- @param typ string The button attribute 'type' value
--- @return boolean
function o.IsCompanion(typ) return typ == atyp.companion end

--- MoP only: 6 tiers x 3 columns (left=1, middle=2, right=3)
--- @param spellID SpellID
--- @return boolean
function o.IsTalentSpell(spellID)
  if LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_MISTS_OF_PANDARIA then return false end
  if not (spellID and C_GetTalentInfo) then return false end
  for tier = 1, MOP_TALENT_TIERS do
    for column = 1, MOP_TALENT_COLUMNS do
      local info = C_GetTalentInfo({ tier = tier, column = column })
      if info and info.selected and info.spellID == spellID then return true end
    end
  end
  return false
end

--- @param spell SpellIdentifier
--- @param callbackFn fun(spell: SpellInfo)
function o.IfSpell(spell, callbackFn)
  if not spell then return end
  local spellInfo = comp:GetSpellInfo(spell)
  if spellInfo then callbackFn(spellInfo) end
end

--- @param spell SpellIdentifier
--- @param callbackFn fun(spellID:SpellID, charge: SpellChargeInfo)
function o.IfSpellCharges(spell, callbackFn)
  o.IfSpell(spell, function(sp)
    local charge = comp:GetSpellCharges(sp.spellID)
    if charge then callbackFn(sp.spellID, charge) end
  end)
end

--- Execute callback if a cooldown exists
--- @param callbackFn fun(info:SpellCooldownInfo)
function o.IfSpellCooldown(spellID, callbackFn)
  local info = comp:GetSpellCooldown(spellID)
  if not info then return end
  -- issecretvalue() is a retail function
  if issecretvalue and issecretvalue(info.duration) then return end
  callbackFn(info)
end

--- @param itemID ItemID
--- @param callbackFn fun(itemInfo:ItemInfoDetails)
--- @param withDetails boolean? @If non-instant
function o.IfItem(itemID, callbackFn, withDetails)
  assert(type(itemID) == 'number', 'IfItem(itemID, callbackFn, withDetails): {itemID} should be a number')
  local it
  if withDetails then it = comp:GetItemInfo(itemID)
  else
    it = comp:GetItemInfoInstant(itemID)
    if not (it and it.id and it.icon) then
      it = comp:GetItemInfo(itemID)
    end
  end
  if not (it and it.icon) then return end
  callbackFn(it)
end

--- @param mount MountID|MountInfo
--- @param callbackFn fun(mountInfo:MountInfo)
function o.IfMount(mount, callbackFn)
  local info
  if type(mount) == 'table' and mount.spellID then
    info = mount
  elseif type(mount) == 'number' then
    info = comp:GetMountInfo(mount)
  else
    error('IfMount(mount, callbackFn): {mount} is expected to be a number or MountInfo')
  end
  if not (info and info.spellID) then return end
  callbackFn(info)
end

--- Execute callback if a cooldown exists
--- @param itemInfo ItemID|ItemName|ItemLink
--- @param callbackFn fun(info:ItemCooldownInfo)
function o.IfItemCooldown(itemInfo, callbackFn)
  local info = comp:GetItemCooldown(itemInfo)
  if not info then return end
  -- issecretvalue() is a retail function
  if issecretvalue and issecretvalue(info.duration) then return end
  callbackFn(info)
end

--- Returns the first elem of spell power cost array
--- @param spell SpellIdentifier
--- @return SpellPowerCostInfo?
function o.GetSpellPowerCost(spell)
  local costArr = C_GetSpellPowerCost(spell)
  if costArr and #costArr > 0 then return costArr[1] end
  return nil
end

--- @param macroIdentifier MacroIdentifier
--- @return SpellID?, ItemID?
function o.GetMacroAction(macroIdentifier)
  local spellID = GetMacroSpell(macroIdentifier)
  if spellID then return spellID, nil end

  local _, itemLink = GetMacroItem(macroIdentifier)
  if itemLink then
    local item = comp:GetItemInfoInstant(itemLink)
    if item and item.id then return nil, item.id end
  end

  return nil, nil
end

--- @param spell SpellIdentifier
--- @return boolean
function o.SpellRequiresMana(spell)
  local cost = o.GetSpellPowerCost(spell)
  if cost then return cost.type == Enum.PowerType.Mana end
  return false
end

--- @param spell SpellIdentifier
--- @return boolean
function o.SpellDoesNotRequireMana(spell) return not o.SpellRequiresMana(spell) end

--- @param spellID SpellID
--- @return boolean
function o.IsActiveShapeshiftForm(spellID)
  if shaman:IsShaman() then
    return shaman:IsInGhostWolfForm() and shaman:IsGhostWolfSpell(spellID)
  end
  local index = unit:GetShapeshiftForm()
  if not index or index <= 0 then return false end
  local _, active, _, formSpellID = GetShapeshiftFormInfo(index)
  return active and formSpellID == spellID
end
