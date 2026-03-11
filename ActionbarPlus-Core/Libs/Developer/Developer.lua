--- @type Namespace_ABP_2_0
local ns = select(2, ...)
--- @type DeveloperSetup_ABP_2_0
local ds = ns.DeveloperSetup
local trace_cvar = ns.trace_ui_cvar
local Str_IsBlank = ns.O.String.IsBlank
local p, pd, t, tf = ns:log('Developer')
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

-- /dump Developer_ABP_2_0:ToggleTraceUI()
---@param traceKeyword string
function o:ToggleTraceUI(traceKeyword)
  ds:ResolveTraceUI()
  
  local s = ns.settings
  s.enableTraceUI = s.enableTraceUI or false
  if s.enableTraceUI then
    SetCVar(ns.trace_ui_cvar, '0')
    self:devMsg('ABPV2::TraceUI DISABLED\n/reload to take effect')
  else
    local keyword = traceKeyword or 'abpv2'
    SetCVar(ns.trace_ui_cvar, keyword)
    self:devMsg(('ABPV2::TraceUI ENABLED [keyword: %s]\n/reload to take effect'):format(keyword))
  end
end

--function o:CVAR_UPDATE(event, name, value)
--  if name ~= trace_cvar then return end
--  print('CVAR_UPDATE:: evt=', event, 'cvar=', name, 'val=', value)
--  local s = ns.settings
--  if Str_IsBlank(value) then
--    s.enableTraceUI = false;
--    self:devMsg('TraceUI disabled. /reload to take effect')
--    return
--  end
--  s.enableTraceUI = true
--  s.traceKeyword = value
--  self:devMsg('TraceUI enabled. /reload to take effect')
--end

--o:RegisterEvent('CVAR_UPDATE')


