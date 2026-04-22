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
--- @class EventTraceUtil_ABP_2_0 : AceEvent-3.0
--- @field keyword string
local S = ns:NewAceEvent()

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
--- @class EventTraceUtilObj_ABP_2_0
local o = ns:NewAceEvent()

o.__index = o
--
--
--- @param self EventTraceUtil_ABP_2_0
o.__call = function(self, ...) self:t(...) end

-- light green
local c_base = ns:ColorFn('88ff88')

--- @private
--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
function o:__Init(addon, predicateFn)
  assertsafe(type(addon) == 'string', "__Init(addon, predicateFn): {addon} should be a string")

  self.logName     = addon
  self.eventBase   = upperc(c_base(addon))
  self.predicateFn = predicateFn or function() return true end
  self.evt         = EventTrace
end

function o:ShowUI() self.evt:Show() end
function o:HideUI() self.evt:Hide() end

--- Trace with default prefix as the addon name
--- @param ... any
function o:td(...)
  if not self.predicateFn() then return end
  if not self.evt then return end
  self.evt:LogEvent(self:_EventName(), ...)
end

--- Trace with default prefix as the addon name
--- @param ... any
function o:tdf(...)
  if not self.predicateFn() then return end
  if not self.evt then return end
  self.evt:LogEvent(self:_EventName(), ns.fmt(...))
end

--- This is the default trace function
--- @param prefix Name
--- @param ... any
function o:t(prefix, ...)
  if not self.predicateFn() then return end
  if not self.evt then return end
  self.evt:LogEvent(self:_EventName(prefix), ...)
end

--- @param prefix Name
--- @param ... any
function o:tf(prefix, ...)
  if not self.predicateFn() then return end
  if not self.evt then return end
  self.evt:LogEvent(self:_EventName(prefix), ns.fmt(...))
end

--- @param prefix Name|nil
function o:_EventName(prefix)
  if prefix == nil then return self.eventBase end
  return ("%s::%s"):format(self.eventBase, upperc(prefix))
end

--[[-----------------------------------------------------------------------------
New Instance:

--- @type EventTraceUtilObj_ABP_2_0
local tracerObj = EventTraceUtil:New('addonName', function() return true end)
-------------------------------------------------------------------------------]]
--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
--- @return EventTraceUtilObj_ABP_2_0
function S:New(addon, predicateFn)
  --- @type EventTraceUtilObj_ABP_2_0
  local tracer = setmetatable({}, o)
  tracer:__Init(addon, predicateFn)
  return tracer
end

