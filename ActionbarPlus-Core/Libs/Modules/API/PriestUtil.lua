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
local libName = ns.M.PriestUtil()
--- @class PriestUtil_ABP_2_0 : UnitUtil_ABP_2_0
local o = UnitUtil:New('PRIEST'); ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

o.SHADOW_FORM_SPELL_ID = 15473
o.SHADOW_FORM_SPELL_ID_RETAIL = 232698

local formActiveIcon = (function()
  return {
    retail  = 136116,
    mop     = 136200,
    default = 136130,
  }
end)()

---@param spellID SpellID
function o:IsShadowFormSpell(spellID)
  return spellID == self.SHADOW_FORM_SPELL_ID
          or spellID == self.SHADOW_FORM_SPELL_ID_RETAIL
end

--- @return boolean
function o:IsInShadowForm()
  return self:IsBuffActive(self.SHADOW_FORM_SPELL_ID)
          or self:IsBuffActive(self.SHADOW_FORM_SPELL_ID_RETAIL)
end

--- @deprecated
--- @see GetActiveShapeshiftFormIcon()
function o:GetShadowFormActiveIcon() return self:GetActiveShapeshiftFormIcon() end

function o:GetActiveShapeshiftFormIcon()
  if ns:IsShadowlandsOrLater() then return formActiveIcon.retail
  elseif ns:IsMists() then return formActiveIcon.mop end
  return formActiveIcon.default
end

--- @protected
--- @see UnitUtil_ABP_2_0.GetShapeshiftSpellState
--- @param spellID SpellID
--- @return boolean? @If {spellID} is a shapeshift spellID
--- @return boolean? @If {spellID} is active
--- @return Icon? @The form active icon
function o:GetShapeshiftSpellState(spellID)
  local active = self:IsShapeShifted()
  return self:IsShadowFormSpell(spellID),
          active, active and self:GetActiveShapeshiftFormIcon() or nil
end
