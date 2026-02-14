--[[-------------------------------------------------------------------
Type:Namespace
---------------------------------------------------------------------]]
--- @alias Namespace_ABP_2_0 NamespaceImpl_ABP_2_0 | GameVersionMixin_ABP_2_0
--
--
--- @class NamespaceImpl_ABP_2_0
--- @field name Name The addon name
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field gameVersion GameVersion
--- @field private fmt LibPrettyPrint_Formatter
--- @field private printer LibPrettyPrint_Printer
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

--[[-------------------------------------------------------------------
Formatter/Printer
---------------------------------------------------------------------]]
ns.fmt = LibPrettyPrint:Formatter({ show_all = true, depth_limit = 3 })
ns.printer = LibPrettyPrint:Printer({
  prefix = ns.nameShort, formatter = ns.fmt,
  prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
}, predicateFn)

--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
do
  local obj = ns.O
  --- @type AceEvent
  obj.AceEvent = LibStub("AceEvent-3.0")
  --- @type AceBucketObj
  obj.AceBucket = LibStub("AceBucket-3.0")
  --- @type AceAddonObj
  obj.AceAddon = LibStub("AceAddon-3.0")
  --- @type AceDB
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

--- @param db AceDBObject
function ns:RegisterDB(db)
  assert(type(db) == 'table', "RegisterDB(db): The param db is required.")
  self.addonDbFn = function() return db end
end

--- @return Database_ABP_2_0
function ns:db() return self.addonDbFn() end

--- @param tracer EventTracePrinter_ABP_2_0
function ns:RegisterTracer(tracer)
  self.tracerMixin = tracer
  self.tracer = tracer:New(ns.nameShort, predicateFn)
  if not (ns:IsDev() and settings.enableTraceUI) then
    self.tracer.evt:Hide()
  end
end

--- @param name Name
--- @param predicateFn fun():boolean @Optional - The predicate function
--- @return EventTracePrinter_ABP_2_0
function ns:NewTracer(name, predicateFn)
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

--- @param prefix string
--- @return fun(...): any
function ns:traceFn(prefix)
  if type(prefix) ~= 'string' then
    return function(...) return self.tracer:td(...) end
  end
  return function(...) return self.tracer:t(strtrim(prefix), ...) end
end

--- @param prefix string
--- @return fun(...): any
function ns:traceFnWithFormatting(prefix)
  if type(prefix) ~= 'string' then
    return function(...) return self.tracer:tdf(...) end
  end
  return function(...) return self.tracer:tf(strtrim(prefix), ...) end
end

--- Returns the print, tracer1, tracer2 functions
--- @param moduleName Name
--- @return LibPrettyPrint_Printer | LibPrettyPrint_PrintFn, fun(...), fun(...)
function ns:log(moduleName)
  local m = moduleName
  if type(m) == 'string' then m = strtrim(m)
  else m = nil end
  
  local printer = self.printer
  if m and #m > 0 then
    printer = self.printer:WithSubPrefix(m)
  end
  local tracer1 = ns:traceFnWithFormatting(m)
  local tracer2 = ns:traceFn(m)
  return printer, tracer1, tracer2
end

--- @type Namespace_ABP_2_0
ABP_CORE_NS = ns
