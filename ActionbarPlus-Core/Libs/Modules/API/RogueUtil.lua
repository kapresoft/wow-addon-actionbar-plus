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
local libName = ns.M.RogueUtil()
--- @class RogueUtil_ABP_2_0 : UnitUtil_ABP_2_0
local o = UnitUtil:New('ROGUE'); ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
o.STEALTH_SPELL_ID = 1784
-- TBC has Stealth ranks 1-4; all ranks must be recognized as the stealth shapeshift spell.
o.STEALTH_SPELL_IDS = { [1784]=true, [1785]=true, [1786]=true, [8822]=true }

function o:IsRogueClass()
    local _, id = self:GetPlayerUnitClass(); return GC.UnitClasses.ROGUE.id == id
end

--- @param spellID SpellID
--- @return Boolean
function o:IsStealth(spellID) return self.STEALTH_SPELL_IDS[spellID] == true end

--- @protected
--- @see UnitUtil_ABP_2_0.GetShapeshiftSpellState
--- @param spellID SpellID
--- @return boolean? @If {spellID} is a shapeshift spellID
--- @return boolean? @If {spellID} is active
--- @return Icon? @The form active icon
function o:GetShapeshiftSpellState(spellID)
  local active = self:IsStealthActive()
  return self:IsStealth(spellID),
          active, active and self:GetActiveShapeshiftFormIcon() or nil
end

function o:GetActiveShapeshiftFormIcon() return o.STEALTHED_ICON end
