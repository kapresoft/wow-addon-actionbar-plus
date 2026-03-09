--- @type Namespace_ABP_BarsUI_Impl_2_0 | Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

--- @class DeveloperNamespace_BarsUI_ABP_2_0 : Namespace_ABP_BarsUI_Impl_2_0

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param prefix string|any
--- @return ABP_2_0_TraceFn @Printer function that outputs plain values to Blizzard Trace UI (like print)
local function traceFn1(prefix)
  if type(prefix) ~= 'string' then return function(...) return ns.tracer and ns.tracer:td(...) end end
  return function(...) return ns.tracer and ns.tracer:t(strtrim(prefix), ...) end
end

--- With auto formatting of objects
--- @param prefix string|nil
--- @return ABP_2_0_TraceFnFormatted @Printer function that outputs formatted values to Blizzard Trace UI (like print)
local function traceFn2(prefix)
  if type(prefix) ~= 'string' then return function(...) return ns.tracer and ns.tracer:tdf(...) end end
  return function(...) return ns.tracer and ns.tracer:tf(strtrim(prefix), ...) end
end

--[[-----------------------------------------------------------------------------
BarsUI:: Namespace Overrides for Dev Namespace
-------------------------------------------------------------------------------]]

--- Returns the print, delayed-print, tracer, formatted-tracer functions
--- ```
--- local p, pd, t, tf = ns:log('EventHandler')
--- ```
--- TODO: Create BarsUI tracer
--- ns.tracer = ns:cns():NewTracer(ns.nameShort, predicateFn)
---
--- @param moduleName Name
--- @return LogBuilderFn
function ns:log(moduleName)
  if not self.logBuilder then self.logBuilder = self:cns():NewLogBuilder(self.printer, traceFn1, traceFn2) end
  return self.logBuilder(moduleName)
end

--[[-------------------------------------------------------------------
Verbose Logging in Dev Mode
---------------------------------------------------------------------]]
local _, pd = ns:log('DeveloperNamespace')
pd('loaded...')
