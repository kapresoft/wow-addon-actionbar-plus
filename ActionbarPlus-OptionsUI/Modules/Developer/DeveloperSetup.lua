--[[-----------------------------------------------------------------------------
DeveloperSetup
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_OptionsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
local Str_IsBlank = cns:String().IsBlank

--- @type LibTraceKit-1.0
local LibTraceKit = LibStub('LibTraceKit-1.0')
assertsafe(LibTraceKit ~= nil, 'Failed to reference LibTraceKit-1.0')

--[[-----------------------------------------------------------------------------
Base Tracer
-------------------------------------------------------------------------------]]
local colorDef = ns.colorDef
local TRACE_DELIM = '_'

--- @param prefix string|any
--- @return TraceFn
local function traceFn(prefix)
  return LibTraceKit:New(ns.LOG_NAME, prefix, colorDef.primary)
      :WithDelimiter(TRACE_DELIM) --[[@as TraceFn ]]
end

--[[-----------------------------------------------------------------------------
OptionsUI:: Namespace Overrides for Dev Namespace
-------------------------------------------------------------------------------]]

do
  local h = ns.logHolder
  h.printer = cns.__CreatePrinterFn(ns.printer)
  --- @see ActionbarPlus-Core/Libs/Developer/DeveloperSetup.lua
  h.tracer = traceFn
end
