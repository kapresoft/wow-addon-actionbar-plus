--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O
local comp, SupportedActionTypeMap = O.Compat, O.Constants.SupportedActionTypesAsMap()

local C_IsAutoRepeatSpell = C_Spell and C_Spell.IsAutoRepeatSpell or IsAutoRepeatSpell
local C_IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or IsCurrentSpell

--[[-----------------------------------------------------------------------------
Module::ActionUtil
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.ActionUtil()
--- @class ActionUtil_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)

local attr, atyp = ns:constants()

--[[-----------------------------------------------------------------------------
Module::ActionUtil (Methods)
-------------------------------------------------------------------------------]]
--- @type ActionUtil_ABP_2_0
local o = S

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

--- @param action Name The action name; i.e. 'spell', 'item', etc..
--- @return boolean
function o.IsSupportedAction(action)
  tf('IsSupportedAction:: map=', SupportedActionTypeMap)
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
