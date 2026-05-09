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

function o:IsRogueClass()
    local _, id = self:GetPlayerUnitClass(); return GC.UnitClasses.ROGUE.id == id
end

--- @param spellID SpellID
--- @return Boolean
function o:IsStealth(spellID) return spellID == self.STEALTH_SPELL_ID end
