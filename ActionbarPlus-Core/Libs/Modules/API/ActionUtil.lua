--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::ActionUtil
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.ActionUtil()
--- @class ActionUtil_ABP_2_0
local S = {}; ns:Register(libName, S)

local attr, atyp = ns:constants()

--[[-----------------------------------------------------------------------------
Module::ActionUtil (Methods)
-------------------------------------------------------------------------------]]
--- @type ActionUtil_ABP_2_0
local o = S

--- @param typeVal string
--- @return boolean
function o.IsSpell(typeVal) return typeVal == atyp.spell end

--- @param typeVal string
--- @return boolean
function o.IsItem(typeVal) return typeVal == atyp.item end

--- @param typeVal string
--- @return boolean
function o.IsMount(typeVal) return typeVal == atyp.mount end

--- @param typeVal string
--- @return boolean
function o.IsEquipmentSet(typeVal) return typeVal == atyp.equipmentset end

--- @param typeVal string
--- @return boolean
function o.IsMacro(typeVal) return typeVal == atyp.macro end

--- @param typeVal string
--- @return boolean
function o.IsMacroText(typeVal) return typeVal == atyp.macrotext end

--- @param typeVal string
--- @return boolean
function o.IsBattlePet(typeVal) return typeVal == atyp.battlepet end

--- @param typeVal string
--- @return boolean
function o.IsCompanion(typeVal) return typeVal == atyp.companion end
