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
--- @param prefix Name  @The prefix name
--- @param ... any      @Print any
function ns.tr(prefix, ...)
  local _ns = cns; _ns.__trace(ns.LOG_NAME, prefix, ...)
end

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- Creates a trace function
--- ### Example:
--- ```
--- local tr = traceFn('Util')
--- tr('hello world)  -- prints to EventTrace UI
--- ```
--- @param prefix string|any
--- @return TraceFn_ABP_2_0 @Printer function that outputs plain values to Blizzard Trace UI (like print)
local function traceFn(prefix)
  return function(...) local trfn = ns.tr; return trfn(prefix, ...) end
end

--[[-----------------------------------------------------------------------------
BarsUI:: Namespace Overrides for Dev Namespace
-------------------------------------------------------------------------------]]

do
  local h = ns.logHolder
  h.printer = cns.__CreatePrinterFn(ns.printer)
  --- @see ActionbarPlus-Core/Libs/Developer/DeveloperSetup.lua
  h.tracer = traceFn
end
