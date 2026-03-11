--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local Str_IsBlank = ns.O.String.IsBlank
local p, pd, t, tf = ns:log('DeveloperSetup')

local s = ns.settings
s.developer = true
s.traceKeyword = 'abpv2'
--s.enableTraceUI = true
--s.traceKeyword = 'barsui'

--[[-------------------------------------------------------------------
DeveloperSetup
---------------------------------------------------------------------]]
--- @class DeveloperSetup_ABP_2_0
local o = {}; DeveloperSetup_ABP_2_0 = o

--- @type DeveloperSetup_ABP_2_0
ns.DeveloperSetup = o

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]

local function WrapScriptExample()
  --local controller = CreateFrame("Frame", "MySecureEnv", UIParent, "SecureHandlerBaseTemplate")
  local controller = ActionbarPlusF1Button1
  
  local btn2 = ActionbarPlusF1Button2
  controller:SetFrameRef("target", btn2)
  print('btn2:', btn2.Click)
  
  -- Wrap controller's OnClick to click the target
  controller:WrapScript(controller, "PreClick", [[
  local btn = self:GetFrameRef("target")
  self:SetAttribute("spell", "Kill Command")
  ]])

end
--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
--/console abp_2_0_trace_ui abpv2
--/console abp_2_0_trace_ui barsui
--/console abp_2_0_trace_ui all
--/dump SetCVar('abp_2_0_trace_ui', 'abp')
--/dump GetCVarBool('abp_2_0_trace_ui')
function o:ResolveTraceUI()
  local trace_cvar = 'abp_2_0_trace_ui'; ns.trace_ui_cvar = trace_cvar
  RegisterCVar(trace_cvar, '0')
  local traceVal = strtrim(GetCVar(trace_cvar) or '')
  s.enableTraceUI = not (Str_IsBlank(traceVal) or traceVal == '0' or traceVal == 'false')
  if s.enableTraceUI then s.traceKeyword = traceVal end
  
  C_Timer.After(1.5, function()
    p('Trace::', {
      ['ns.enableTraceUI']=s.enableTraceUI,
      ['ns.traceKeyword'] = s.traceKeyword,
      ['CVAR::trace_cvar'] = traceVal
    })
  end)
end

--[[-------------------------------------------------------------------
Logger/Trace Functions
---------------------------------------------------------------------]]
function o.ButtonLogMixin(log, p, pd, t, tf)
  
  --- @param prefix Name
  function log:pid(prefix) return ("%s(%s)"):format(prefix, self:__logID()) end
  
  --- @param prefix Name
  --- @param ... any
  function log:t(prefix, ...) local a = { ... }; t(self:pid(prefix), unpack(a)) end
  
  --- @param prefix Name
  --- @param ... any
  function log:tf(prefix, ...) local a = { ... }; tf(self:pid(prefix), unpack(a)) end
  
  --- @param prefix Name
  --- @param ... any
  function log:p(prefix, ...) local a = { ... }; p(self:pid(prefix), unpack(a)) end
  
  --- @param prefix Name
  --- @param ... any
  function log:pd(prefix, ...) local a = { ... }; pd(self:pid(prefix), unpack(a)) end
  
end

o:ResolveTraceUI()
