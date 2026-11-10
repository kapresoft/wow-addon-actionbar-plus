--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Module::SpellUtil
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.SpellUtil()
--- @class SpellUtil_ABP_2_0
local o = {}; ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::SpellUtil (Methods)
-------------------------------------------------------------------------------]]

--- @param spellID SpellID
--- @return SpellRank? @nil if unranked or not loaded yet
function o:GetHighestSpellRank(spellID)
  assert(
    type(spellID) == 'number',
    'GetHighestSpellRank(spellID):: Param spellID should be a number.'
  )
  local rank = C_Spell.GetSpellSubtext(spellID)
  if rank == '' then return nil end
  return rank
end
