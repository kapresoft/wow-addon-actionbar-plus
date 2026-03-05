--[[-------------------------------------------------------------------
Type:Namespace
---------------------------------------------------------------------]]
--- @alias Namespace_ABP_2_0 NamespaceImpl_ABP_2_0 | GameVersionMixin_ABP_2_0
--- @alias LogBuilderFn fun(moduleName:string) : LibPrettyPrint_PrintFn, LibPrettyPrint_PrintFn, ABP_2_0_TraceFn, ABP_2_0_TraceFnFormatted
--- @alias ABP_2_0_TraceFn fun(...: any) : void @Printer function that outputs plain values to Blizzard Trace UI (like print)
--- @alias ABP_2_0_TraceFnFormatted fun(...: any) : void @Printer function that outputs formatted values to Blizzard Trace UI (like print)
--
--
--- @class NamespaceImpl_ABP_2_0
--- @field name Name The addon name
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field gameVersion GameVersion_2_0
--- @field lockActionBars boolean
--- @field private fmt LibPrettyPrint_Formatter
--- @field private printer LibPrettyPrint_Printer
--- @field private logBuilder LogBuilderFn
--- @field tracer EventTracePrinter_ABP_2_0
--- @field M Core_Modules_ABP_2_0 The module names
--- @field O Core_Modules_ABP_2_0 The module objects
--
--
--- @type string
local addon
--- @type NamespaceImpl_ABP_2_0 | Namespace_ABP_2_0
local ns
addon, ns = ...; ns.name = addon; ns.nameShort='ABP2'; ABP_2_0_NS = ns

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
ns.DB_NAME = 'ABP_PLUS_CORE_DB'

--- @type Core_Modules_ABP_2_0
ns.O = ns.O or {}

--[[-----------------------------------------------------------------------------
Type: Settings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class Settings_ABP_2_0
--- @field developer boolean if true: enables developer mode
--- @field enableTraceUI boolean if true: shows Blizz EventTrace UI on load
local settings = { developer = false, enableTraceUI = false }; ns.settings = settings
--- @return boolean
function ns:IsDev() return ns.settings.developer == true end

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function predicateFn() return ns:IsDev() end

local function DelayedCall(delay, fn, ...)
  assert(type(delay) == 'number' and delay > 0)
  return function(...)
    local args = { ... }
    C_Timer.After(delay, function()
      fn(unpack(args))
    end)
  end
end

--[[-------------------------------------------------------------------
Formatter/Printer
---------------------------------------------------------------------]]
ns.fmt = LibPrettyPrint:Formatter({ show_all = true, depth_limit = 3 }); fmt = ns.fmt
ns.printer = LibPrettyPrint:Printer({
  prefix = ns.nameShort, formatter = ns.fmt,
  prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
}, predicateFn)

--[[-------------------------------------------------------------------
Ace3 Modules
---------------------------------------------------------------------]]
do
  local obj = ns.O
  --- @type AceEvent_3_0
  obj.AceEvent = LibStub("AceEvent-3.0")
  --- @type AceBucket_3_0
  obj.AceBucket = LibStub("AceBucket-3.0")
  --- @type AceAddon_3_0
  obj.AceAddon = LibStub("AceAddon-3.0")
  --- @type AceDB_3_0
  obj.AceDB = LibStub("AceDB-3.0")
  
  --- @param targetObj any|nil An optional targetObj for embedding
  function ns:NewAceEvent(targetObj)
    if targetObj then return self.O.AceEvent:Embed(targetObj) end
    return self.O.AceEvent:Embed({})
  end
  
  --- @param targetObj any|nil An optional targetObj for embedding
  function ns:NewAceBucket(targetObj)
    if targetObj then return self.O.AceBucket:Embed(targetObj) end
    return self.O.AceBucket:Embed({})
  end
end
--[[-------------------------------------------------------------------
Kapresoft Modules
---------------------------------------------------------------------]]
do
  local obj = ns.O
  --- @type Kapresoft_Table_2_0
  obj.Table = LibStub('Kapresoft-Table-2-0')
end

--- Register a Namespace Module
--- @generic T
--- @param obj T The library object instance
--- @return T
function ns:Register(libName, obj)
  assert(type(libName) == 'string' and type(obj) == 'table',
          'Register(libName, obj): libName(string) and obj(table) is required.')
  self.O[libName] = obj
  return obj
end

--- @param db DatabaseObj_ABP_2_0
function ns:RegisterDB(db)
  assert(type(db) == 'table', "RegisterDB(db): The param db is required.")
  self.addonDbFn = function() return db end
end

--- @return DatabaseObj_ABP_2_0
function ns:db() return self.addonDbFn() end

--- @return ABP_Core_2_0
function ns:a() return ABP_Core_2_0 end
--- @return ProfileConfig_ABP_2_0
function ns:p() return self:a():p() end
--- @return GlobalConfig_ABP_2_0
function ns:g() return self:a():g() end
--- @param index Index
--- @return BarConfig_ABP_2_0
function ns:bars(index) return self:p().bars[index] end

--- @param tracer EventTracePrinter_ABP_2_0
function ns:RegisterTracer(tracer)
  self.tracerMixin = tracer
  self.tracer = tracer:New(ns.nameShort, predicateFn)
  C_Timer.After(0.01, function()
      if not (ns:IsDev() and settings.enableTraceUI) then
        self.tracer.evt:Hide()
      elseif not self.tracer.evt:IsShown() then
          self.tracer.evt:Show()
      end
  end)
end

--- @return Cursor_ABP_2_0
function ns:cursor() return self.O.CursorProvider:GetCursor() end

--- @return AttributeNames_ABP_2_0, SupportedActionTypes_ABP_2_0
function ns:constants() local C = self.O.Constants; return C.AttributeNames, C.SupportedActionTypes end

--- @param name Name
--- @param predicateFn fun():boolean @Optional - The predicate function
--- @return EventTracePrinter_ABP_2_0
function ns:NewTracer(name, predicateFn)
  if not self.tracerMixin then return end
  local tr = self.tracerMixin:New(name, predicateFn)
  if not (ns:IsDev() and settings.enableTraceUI) then
    tr.evt:Hide()
  end
  return tr
end

function ns:MixinGameVersion(gameVersion) Mixin(self, gameVersion) end

--- @param rgbHex RGBHex|nil    @Optional
--- @return fun(key:string) : string The color formatted key
function ns:colorFn(rgbHex)
  return function(text)
    local c = CreateColorFromRGBHexString(rgbHex)
    assert(c, ('Invalid RGBHex color: %s'):format(rgbHex))
    return c:WrapTextInColorCode(text)
  end
end

--- @param prefix string|any
--- @return ABP_2_0_TraceFn @Printer function that outputs plain values to Blizzard Trace UI (like print)
function ns:traceFn(prefix)
  if not self.tracer then return function()  end end
  if type(prefix) ~= 'string' then
    return function(...) return self.tracer:td(...) end
  end
  return function(...) return self.tracer:t(strtrim(prefix), ...) end
end

--- @param prefix string|nil
--- @return ABP_2_0_TraceFnFormatted @Printer function that outputs formatted values to Blizzard Trace UI (like print)
function ns:traceFnWithFormatting(prefix)
  if type(prefix) ~= 'string' then
    return function(...) return self.tracer:tdf(...) end
  end
  return function(...) return self.tracer:tf(strtrim(prefix), ...) end
end

--- Returns the print, delayed-print, tracer, formatted-tracer functions
--- ```
--- local p, pd, t, tf = ns:log('EventHandler')
--- ```
--- @param moduleName Name
--- @return LibPrettyPrint_PrintFn, LibPrettyPrint_PrintFn, ABP_2_0_TraceFn, ABP_2_0_TraceFnFormatted
function ns:log(moduleName)
  if not self.logBuilder then self.logBuilder = self:__CreateLogBuilder(self.printer) end
  return self.logBuilder(moduleName)
end

--- @protected
--- @param printer LibPrettyPrint_Printer
--- @return LogBuilderFn
function ns:__CreateLogBuilder(printer)
  assert(printer, 'Printer is required.')
  
  --- @param moduleName Name
  local function builderFn(moduleName)
    local m = moduleName
    local pr = printer
    if type(m) == 'string' then m = strtrim(m)
    else m = nil end
    
    if m and #m > 0 then pr = printer:WithSubPrefix(m) end
    
    local printerDelayed = DelayedCall(1, pr)
    local tracer1 = self:traceFn(m)
    local tracer2 = self:traceFnWithFormatting(m)
    return pr, printerDelayed, tracer1, tracer2
  end
  
  return builderFn
end

function ns.Str_IsBlank(str)
  if type(str) ~= "string" then return str == nil end
  return strtrim(str) == ""
end

--- Match {match} for any occurrence in ...
--- @param toMatch string
--- @param ... string The string values to match
--- @return boolean true if `toMatch` is found in the varargs, false otherwise.
function ns.Str_IsAnyOf(toMatch, ...)
  if not toMatch then return false end
  if type(toMatch) ~= "string" then return false end
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    if type(v) == "string" and v == toMatch then return true end
  end
  return false
end

function ns.Str_IsAnyOfCaseInsensitive(valueToMatch, ...)
  if not valueToMatch then return false end
  if type(valueToMatch) ~= "string" then return false end
  local toMatch = strlower(valueToMatch)
  for i = 1, select('#', ...) do
    local val = select(i, ...)
    if type(val) == "string" and strlower(val) == toMatch then return true
    end
  end
  return false
end

--- Checks if the first argument matches any of the subsequent arguments.
--- @param toMatch number The value to match against the varargs.
--- @param ... number The number values to check for a match.
--- @return boolean true if `toMatch` is found in the varargs, false otherwise.
function ns.Nbr_IsAnyOf(toMatch, ...)
  if toMatch == nil then return false end
  for i = 1, select('#', ...) do
    if select(i, ...) == toMatch then return true end
  end
  return false
end

--- @param t table
--- @return boolean true if table is empty
function ns.Tbl_IsEmpty(t) return type(t) ~= "table" or next(t) == nil end

--- @type Namespace_ABP_2_0
ABP_CORE_NS = ns
