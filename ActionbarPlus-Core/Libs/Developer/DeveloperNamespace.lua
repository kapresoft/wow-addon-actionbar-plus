--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type NamespaceImpl_ABP_2_0 | Namespace_ABP_2_0
local ns = select(2, ...)

--- @class DeveloperNamespace_Core_ABP_2_0 : NamespaceImpl_ABP_2_0

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function DelayedCall(delay, fn, ...)
  assert(type(delay) == 'number' and delay > 0)
  return function(...)
    local args = { ... }
    C_Timer.After(delay, function()
      fn(unpack(args))
    end)
  end
end

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

--- @protected
--- @param printer LibPrettyPrint_Printer
--- @return LogBuilderFn
--- @param traceFn1 fun(moduleName:Name) : function
--- @param traceFn2 fun(moduleName:Name) : function
function ns:NewLogBuilder(printer, traceFn1, traceFn2)
  assert(printer, 'Printer is required.')
  
  --- @param moduleName Name
  local function builderFn(moduleName)
    local m = moduleName
    local pr = printer
    if type(m) == 'string' then m = strtrim(m)
    else m = nil end
    
    if m and #m > 0 then pr = printer:WithSubPrefix(m) end
    
    local printerDelayed = DelayedCall(1, pr)
    local tracer1, tracer2 = traceFn1(m), traceFn2(m)
    return pr, printerDelayed, tracer1, tracer2
  end
  
  return builderFn
end

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]

--- Returns the print, delayed-print, tracer, formatted-tracer functions
--- ```
--- local p, pd, t, tf = ns:log('EventHandler')
--- ```
--- @param moduleName Name
--- @return LibPrettyPrint_PrintFn, LibPrettyPrint_PrintFn, ABP_2_0_TraceFn, ABP_2_0_TraceFnFormatted
function ns:log(moduleName)
  if not self.logBuilder then self.logBuilder = self:NewLogBuilder(self.printer, traceFn1, traceFn2) end
  return self.logBuilder(moduleName)
end

--[[-------------------------------------------------------------------
Verbose Logging in Dev Mode
---------------------------------------------------------------------]]
local _, pd = ns:log('DeveloperNamespace')
pd('loaded...')
