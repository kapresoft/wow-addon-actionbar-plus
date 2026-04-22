--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local libName = 'DeveloperSetup'
local Str_IsBlank = ns:String().IsBlank
local p, t = ns:log(libName)

local s = ns.settings
s.developer = true
--s.enableTraceUI = true
--s.traceKeyword = 'barsui'

--[[-----------------------------------------------------------------------------
Base Tracer
-------------------------------------------------------------------------------]]
local c1 = ns:ColorFn(ns.colorDef.primary)
function ns:tr(prefix, ...)
  local _c1 = c1
  local baseName = _c1('ABP2_CORE')
  if not Str_IsBlank(prefix) then
    baseName = baseName .. '::' .. prefix
  end
  if not EventTrace then return end; EventTrace:LogEvent(baseName, ...)
end
--[[-------------------------------------------------------------------
DeveloperSetup
---------------------------------------------------------------------]]
--- @class DeveloperSetup_ABP_2_0
local o = {}; DeveloperSetup_ABP_2_0 = o

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
local RELOAD_CONFIRMATION_DIALOG = 'RELOAD_CONFIRMATION_DIALOG'
--- Usage: StaticPopup_Show(RELOAD_CONFIRMATION_DIALOG)
StaticPopupDialogs[RELOAD_CONFIRMATION_DIALOG] = {
    text = "ActionbarPlus dev mode requires DevSuite.\nA UI restart is needed to enable it.\n\nRestart now?",
    button1 = OKAY, button2 = CANCEL,
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = ReloadUI
}

--[[-----------------------------------------------------------------------------
External Dependencies
-------------------------------------------------------------------------------]]
local function LoadDevSuite()
  local AU = ns:AddonUtil()

  --- /dump C_AddOns.IsAddOnEnabled('DevSuite')
  --- /dump { C_AddOns.GetAddOnEnableState('DevSuite', 'Kawatan') }
  local DevSuite_AddOn = 'DevSuite'
  local devSuiteEnabled = AU:IsAddOnEnabled(DevSuite_AddOn)

  if not devSuiteEnabled then
    AU:EnableAddOnForCharacter(DevSuite_AddOn)
    devSuiteEnabled = AU:IsAddOnEnabled(DevSuite_AddOn)
    C_Timer.After(0.1, function()
      StaticPopup_Show(RELOAD_CONFIRMATION_DIALOG)
    end)
  end

  C_Timer.After(1, function()
    ns:tr(libName, 'DevSuite is enabled=', devSuiteEnabled == true)
  end)
end; LoadDevSuite()

--[[-----------------------------------------------------------------------------
Log Setup
-------------------------------------------------------------------------------]]
--- Creates a print function
--- ### Example:
--- ```
--- local pr = traceFn3('Util')
--- pr('hello world)  -- prints to console
--- ```
--- @param moduleName Name
local function printerFn(moduleName)
  local _ns = ns
  if type(moduleName) ~= 'string' then return _ns.printer end
  local m = strtrim(moduleName)
  if Str_IsBlank(m) then return _ns.printer end
  return _ns.printer:WithSubPrefix(m)
end

--- Creates a trace function
--- ### Example:
--- ```
--- local tr = traceFn3('Util')
--- tr('hello world)  -- prints to EventTrace UI
--- ```
--- @param prefix string|any
--- @return TraceFn_ABP_2_0 @Printer function that outputs plain values to Blizzard Trace UI (like print)
local function traceFn(prefix)
  local _ns = ns; return function(...) return _ns:tr(prefix, ...) end
end

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]
do
  local h = ns.logHolder
  h.printer = printerFn
  h.tracer = traceFn
end

--[[-------------------------------------------------------------------
Logger/Trace Functions
---------------------------------------------------------------------]]
function o.ButtonLogMixin(log, p, t)
  --- @param prefix Name
  --- @param ... any
  function log:p(prefix, ...) local a = { ... }; p(self:pid(prefix), unpack(a)) end

  --- @param prefix Name
  --- @param ... any
  function log:t(prefix, ...) local a = { ... }; t(self:pid(prefix), unpack(a)) end

  --- @param prefix Name
  function log:pid(prefix) return ("%s(%s)"):format(prefix, self:__logID()) end
end

--o:ResolveTraceUI()
