--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local p, pd, t, tf = ns:log('Developer')

--- @class Developer_ABP_2_0
local o = {}; dd = o
pd('loaded...')

function o:skills()
  for i = 1, GetNumSkillLines() do
    local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank = GetSkillLineInfo(i)
    if not isHeader then
      print(skillName .. ": " .. skillRank .. "/" .. skillMaxRank)
    end
  end
end

--- /dump dd:IsPrimaryProfessionSpell(25230)
function o:IsPrimaryProfessionSpell(spellID)
  local prof1, prof2 = GetProfessions()
  for _, prof in ipairs({prof1, prof2}) do
    if prof then
      local _, _, _, _, _, _, id = GetProfessionInfo(prof)
      if id == spellID then
        return true
      end
    end
  end
  return false
end
