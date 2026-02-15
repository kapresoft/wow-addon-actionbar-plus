--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local s = ns.settings
s.developer = true
--s.enableTraceUI = true

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
