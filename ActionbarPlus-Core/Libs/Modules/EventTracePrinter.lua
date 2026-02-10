local IsAddOnLoaded     = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local LoadAddOn         = C_AddOns.LoadAddOn or LoadAddOn
local EVENT_TRACE_ADDON = 'Blizzard_EventTrace'
local upperc            = string.upper
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]
--- @class EventTracePrinter_ABP_2_0
local S = {}; S.__index = S

--- @param self EventTracePrinter_ABP_2_0
S.__call = function(self, ...) self:t(...) end

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
--- @type EventTracePrinter_ABP_2_0
local o = S

--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
--- @return EventTracePrinter_ABP_2_0
function o:New(addon, predicateFn)
  --- @type EventTracePrinter_ABP_2_0
  local tracer = setmetatable({}, o)
  tracer:__Init(addon, predicateFn)
  return tracer
end

-- light green
local c_base = ns:colorFn('88ff88')

--- @private
--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
function o:__Init(addon, predicateFn)
  assert(addon, "The param addon is required.")

  self.logName     = addon
  self.eventBase   = upperc(c_base(addon))
  self.predicateFn = predicateFn or function() return true  end
  self.evt         = self:LoadEventTrace()
end

--- Trace with default prefix as the addon name
--- @param ... any
function o:td(...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(), ...)
end

--- Trace with default prefix as the addon name
--- @param ... any
function o:tdf(...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(), ns.fmt(...))
end

--- This is the default trace function
--- @param prefix Name
--- @param ... any
function o:t(prefix, ...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(prefix), ...)
end

--- @param prefix Name
--- @param ... any
function o:tf(prefix, ...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(prefix), ns.fmt(...))
end

--- @private
--- @return EventTraceInstance
function o:LoadEventTrace()
  local addOnName = EVENT_TRACE_ADDON
  if IsAddOnLoaded(addOnName) then return EventTrace end

  local success, reason = LoadAddOn(addOnName)
  if not success then
    return print(('%s:: Failed to load [%s], reason=%s'):format(
            self.logName, addOnName, reason))
  end
  assert(EventTrace, ('%s:: Failed to load [%s].'):format(self.logName, addOnName))
  --EventTrace:Hide()
  return EventTrace
end

--- @param prefix Name|nil
function o:_EventName(prefix)
  if prefix == nil then return self.eventBase end
  return ("%s::%s"):format(self.eventBase, upperc(prefix))
end

--[[-------------------------------------------------------------------
Register
---------------------------------------------------------------------]]
ns:RegisterTracer(o)
