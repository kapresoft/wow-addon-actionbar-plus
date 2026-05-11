--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local comp, SupportedActionTypeMap = O.Compat, O.Constants.SupportedActionTypesAsMap()

-- These C_Spell methods exists in classic-era
local C_IsAutoRepeatSpell = C_Spell.IsAutoRepeatSpell
local C_IsCurrentSpell    = C_Spell.IsCurrentSpell
local C_GetSpellPowerCost = C_Spell.GetSpellPowerCost
local C_IsSpellKnown      = C_SpellBook.IsSpellKnown
local C_IsSpellUsable     = C_Spell.IsSpellUsable
local C_IsUsableItem      = C_Item.IsUsableItem

local unit, shaman, priest = O.UnitUtil, O.ShamanUtil, O.PriestUtil
local ATTACK_SPELL_ID = 6603

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
  -- returns a value if spell is known by name
  local nextSp = comp:GetSpellInfo(unknownSp.name)
  return false, nextSp
end

--- @param itemIDAttribute string @The itemID attribute value, i.e. 'item:123'
function o.GetAttributeItemID(itemIDAttribute)
  if not itemIDAttribute then return nil end
  assert(type(itemIDAttribute) == 'string', 'GetAttributeItemID(itemIDAttribute): {itemIDAttribute} should be a string but was: ', type(itemIDAttribute))
  return tonumber(itemIDAttribute:match("item:(%d+)"))
end

--- @param typeVal string The button attribute 'type' value
--- @param id Identifier The context id; 'spell', 'item', etc...
--- @return boolean   @true if action is usable
--- @return boolean   @true if due to not-enough-'energy|mana|rage|etc', false otherwise
function o.IsUsableAction(typeVal, id)
  if not (typeVal and id) then return false, false end
  if o.IsSpell(typeVal) then
      local isUsable, notEnoughMana = C_IsSpellUsable(id)
      return isUsable, notEnoughMana
  elseif o.IsItem(typeVal) then
    --if id == 38233 then
    --  t('IsUsableAction', 'id=', id, 'usable=', C_IsUsableItem(id))
    --end
    return C_IsUsableItem(id), false
  end
  return false, false
end

--- Spells:
--- Attack (6603)
--- @return boolean
function o.SpellRequiresAttackAnim(spellID)
  return spellID == ATTACK_SPELL_ID
end

--- @param typeVal string The button attribute 'type' value
--- @param id Identifier The context id; 'spell', 'item', etc...
--- @return boolean
function o.IsCurrentAction(typeVal, id)
  if not (typeVal and id) then return false end
  if o.IsSpell(typeVal) then
    return C_IsCurrentSpell(id) or C_IsAutoRepeatSpell(id)
  elseif o.IsItem(typeVal) then
      return C_Item.IsCurrentItem(id)
  end
  return false
end

--- @param spellID SpellID
--- @return boolean
function o.IsCurrentSpell(spellID)
  return C_IsCurrentSpell(spellID) or C_IsAutoRepeatSpell(spellID)
end

--- @param action Name The action name; i.e. 'spell', 'item', etc..
--- @return boolean
function o.IsSupportedAction(action)
  return type(action) == 'string'
          and SupportedActionTypeMap[strlower(action)] == true
end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsSpell(typeVal) return typeVal == atyp.spell end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsItem(typeVal) return typeVal == atyp.item end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsMount(typeVal) return typeVal == atyp.mount end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsEquipmentSet(typeVal) return typeVal == atyp.equipmentset end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsMacro(typeVal) return typeVal == atyp.macro end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsMacroText(typeVal) return typeVal == atyp.macrotext end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsBattlePet(typeVal) return typeVal == atyp.battlepet end

--- @param typeVal string The button attribute 'type' value
--- @return boolean
function o.IsCompanion(typeVal) return typeVal == atyp.companion end

--- @param spell SpellIdentifier
--- @param callbackFn fun(spell: SpellInfo)
function o.IfSpell(spell, callbackFn)
  local spellInfo = comp:GetSpellInfo(spell)
  if spellInfo then callbackFn(spellInfo) end
end

--- Execute callback if a cooldown exists
--- @param callbackFn fun(info:SpellCooldownInfo)
function o.IfSpellCooldown(spellID, callbackFn)
  local info = comp:GetSpellCooldown(spellID)
  if not info then return end; callbackFn(info)
end

--- @param itemID ItemID
--- @param callbackFn fun(itemInfo:ItemInfoDetails)
function o.IfItem(itemID, callbackFn)
  local it = comp:GetItemInfoInstant(itemID)
  if not (it and it.id and it.icon) then
    it = comp:GetItemInfo(itemID)
  end
  if not (it and it.icon) then return end
  callbackFn(it)
end

--- Execute callback if a cooldown exists
--- @param itemInfo ItemID|ItemName|ItemLink
--- @param callbackFn fun(info:ItemCooldownInfo)
function o.IfItemCooldown(itemInfo, callbackFn)
  local info = comp:GetItemCooldown(itemInfo)
  if not info then return end; callbackFn(info)
end

--- Returns the first elem of spell power cost array
--- @param spell SpellIdentifier
--- @return SpellPowerCostInfo?
function o.GetSpellPowerCost(spell)
  local costArr = C_GetSpellPowerCost(spell)
  if costArr and #costArr > 0 then return costArr[1] end
  return nil
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

