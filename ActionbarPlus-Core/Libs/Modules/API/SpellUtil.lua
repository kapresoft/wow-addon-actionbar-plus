--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

local BOOKTYPE_SPELL = BOOKTYPE_SPELL

--- {highestSpellRankCache} - The key is SpellID and value is spell rank text
--- Example:  SpellID=10001, Rank='Rank 1'
--- @type table<number, string>
local spellRankCache = {}

--[[-----------------------------------------------------------------------------
Module::SpellUtil
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.SpellUtil()
--- @class SpellUtil_ABP_2_0
local S = {}; ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)

--[[-----------------------------------------------------------------------------
Module::SpellUtil (Methods)
-------------------------------------------------------------------------------]]
--- @type SpellUtil_ABP_2_0
local o = S

function o:GetHighestSpellRank(spellID)
  if not (GetSpellBookItemName or BOOKTYPE_SPELL) then return nil end
  assert(type(spellID) == 'number', 'GetHighestSpellRank(spellID):: Param spellID should be a number.')
  
  -- Check cache first
  local rank = spellRankCache[spellID]
  if rank ~= nil then return rank end
  
  local i = 1
  local lastRank
  while true do
    local name, r, spID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
    if not name then break end
    if r and spID == spellID then lastRank = r end
    i = i + 1
  end
  
  spellRankCache[spellID] = lastRank
  return lastRank
end
