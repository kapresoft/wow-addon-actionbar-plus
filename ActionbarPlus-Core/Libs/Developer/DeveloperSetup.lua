--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local s = ns.settings
s.developer = true
--s.enableTraceUI = true
--s.traceKeyword = 'barsui'

--- @class DeveloperSetup_ABP_2_0
local o = {}; DeveloperSetup_ABP_2_0 = o

print('DeveloperSetup::', 'loaded...')

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
