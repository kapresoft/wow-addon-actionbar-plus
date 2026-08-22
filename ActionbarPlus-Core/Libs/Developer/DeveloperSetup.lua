--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local libName = 'DeveloperSetup'
local Str_IsBlank = ns:String().IsBlank

ns.settings.developer = true

--- @type LibTraceKit-1.0
local LibTraceKit = LibStub('LibTraceKit-1.0')
assertsafe(LibTraceKit ~= nil, 'Failed to reference LibTraceKit-1.0')

--[[-----------------------------------------------------------------------------
Base Tracer
-------------------------------------------------------------------------------]]
local TRACE_DELIM = '_'

--- @param prefix string|any
--- @return TraceFn
local function traceFn(prefix)
  return LibTraceKit:New(ns.LOG_NAME, prefix):WithDelimiter(TRACE_DELIM) --[[@as TraceFn ]]
end; local t = traceFn(libName)

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
  --- @type AceAddon
  local ds = DevSuite

  if type(ds) == 'table' and type(ds.IsEnabled) == 'function' then
    local dsEnabled = ds:IsEnabled()
    if dsEnabled then return end
  end

  local AU = ns:AddonUtil()
  assert(type(AU) == 'table', 'Missing dependency: Kapresoft-AddonUtil-2-0')
  local DevSuite_AddOn = 'DevSuite'
  local devSuiteEnabled = AU:IsAddOnEnabled(DevSuite_AddOn)

  if not devSuiteEnabled then
    AU:EnableAddOnForCharacter(DevSuite_AddOn)
    devSuiteEnabled = AU:IsAddOnEnabled(DevSuite_AddOn)
    C_Timer.After(0.1, function() StaticPopup_Show(RELOAD_CONFIRMATION_DIALOG) end)
  end
  C_Timer.After(1, function() t('DevSuite is enabled=', devSuiteEnabled == true) end)
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
--- @return PrintFn
local function printerFn(moduleName)
  local printer = ns.printer --[[@as PrintFn ]]
  if type(moduleName) ~= 'string' then return printer end
  local m = strtrim(moduleName)
  if Str_IsBlank(m) then return printer end
  return printer:WithSubPrefix(m) --[[@as PrintFn ]]
end

--- @param printer LibPrettyPrint_Printer
--- @return fun(moduleName:Name)
function ns.__CreatePrinterFn(printer)
  assert(type(printer) == 'table', '__CreatePrinterFn(printer): {printer} is missing.')
  return function(moduleName)
    if type(moduleName) ~= 'string' then return printer end
    local m = strtrim(moduleName)
    if Str_IsBlank(m) then return printer end
    return printer:WithSubPrefix(m)
  end
end

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]
do
  local h = ns.logHolder
  h.printer = printerFn
  h.tracer = traceFn
end
