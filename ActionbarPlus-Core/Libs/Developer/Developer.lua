--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local trace_cvar = ns.trace_ui_cvar
local Str_IsBlank = ns:String().IsBlank
local p, t = ns:log('Developer')
local unit = ns.O.UnitUtil

--- @class Developer_ABP_2_0 : AceEvent_3_0
local o = ns:NewAceEvent(); Developer_ABP_2_0 = o; dd = o

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

--- @param msg string
function o:devMsg(msg)
  UIErrorsFrame:AddMessage('ABP: ' .. msg, 0, 1, 0)
end


