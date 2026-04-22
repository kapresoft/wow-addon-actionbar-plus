--[[-----------------------------------------------------------------------------
DeveloperSetup
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()

local Str_IsBlank = cns:String().IsBlank
local p, t = ns:log('DeveloperSetup')

--[[-----------------------------------------------------------------------------
Base Tracer
-------------------------------------------------------------------------------]]
local c1 = cns:ColorFn('4DEDFA') -- cyan-ish
function ns:tr(prefix, ...)
  local _c1 = c1
  local baseName = _c1('ABP2_BARSUI')
  if not Str_IsBlank(prefix) then
    baseName = baseName .. '::' .. prefix
  end
  if not EventTrace then return end; EventTrace:LogEvent(baseName , ...)
end

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
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
function traceFn(prefix)
  local _ns = ns; return function(...) return _ns:tr(prefix, ...) end
end

--[[-----------------------------------------------------------------------------
BarsUI:: Namespace Overrides for Dev Namespace
-------------------------------------------------------------------------------]]

do
  local h = ns.logHolder
  h.printer = printerFn
  --- @see ActionbarPlus-Core/Libs/Developer/DeveloperSetup.lua
  h.tracer = traceFn
end
