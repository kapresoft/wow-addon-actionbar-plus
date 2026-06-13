--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local UnitUtil = ns.O.UnitUtil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
--- @type string
local libName = ns.M.ShamanUtil()
--- @class ShamanUtil_ABP_2_0 : UnitUtil_ABP_2_0
local o = UnitUtil:New('SHAMAN'); ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
o.GHOST_WOLF_SPELL_ID = 2645
o.GHOST_WOLF_FORM_ACTIVE_ICON = 136116

---@param spellID SpellID
function o:IsGhostWolfSpell(spellID) return spellID == o.GHOST_WOLF_SPELL_ID end

--- The Ghost Wolf form is not part of GetShapeshiftFormInfo(index),
--- Ghost Wolf form is not a real form, but it does honor GetShapeshiftForm() when active.
--- @return boolean @true if in Ghost Wolf form, false otherwise.
function o:IsInGhostWolfForm()
  return self:IsShaman() and GetShapeshiftForm() == 1
end

--- @protected
--- @see UnitUtil_ABP_2_0.GetShapeshiftSpellState
--- @param spellID SpellID
--- @return boolean? @If {spellID} is a shapeshift spellID
--- @return boolean? @If {spellID} is active
--- @return Icon? @The form active icon
function o:GetShapeshiftSpellState(spellID)
  local active = self:IsInGhostWolfForm()
  return self:IsGhostWolfSpell(spellID),
          active, active and self:GetActiveShapeshiftFormIcon() or nil
end
