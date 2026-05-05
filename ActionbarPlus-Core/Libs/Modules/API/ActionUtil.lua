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

--- @param typeVal string The button attribute 'type' value
--- @param id Identifier The context id; 'spell', 'item', etc...
--- @return boolean, boolean
function o.IsUsableAction(typeVal, id)
  if not (typeVal and id) then return false, false end
  if o.IsSpell(typeVal) then
      local isUsable, notEnoughMana = C_IsSpellUsable(id)
      return isUsable, notEnoughMana
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

--- Execute callback if a cooldown exists
--- @param callbackFn fun(info:SpellCooldownInfo) : void
function o.IfSpellCooldown(spellID, callbackFn)
  local info = comp:GetSpellCooldown(spellID)
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
