local AceLib = LibStub('Kapresoft-AceLib-2-0')
local GVM = LibStub('Kapresoft-GameVersionMixin-2-0')
local ColorFormatter = LibStub('Kapresoft-ColorFormatter-2-0')

--[[-------------------------------------------------------------------
Type:Namespace
---------------------------------------------------------------------]]
--- @alias LogBuilderFn fun(moduleName:string) : LibPrettyPrint_PrintFn, LibPrettyPrint_PrintFn, TraceFn_ABP_2_0, TraceFnFormatted_ABP_2_0
--- @alias TraceFn_ABP_2_0 fun(...: any) : void @Printer function that outputs plain values to Blizzard Trace UI (like print)
--- @alias TraceFnFormatted_ABP_2_0 fun(...: any) : void @Printer function that outputs formatted values to Blizzard Trace UI (like print)
--
--
--- @type string
local addon

--- @class Namespace_ABP_2_0 : Kapresoft-AceLib-2-0, Kapresoft-GameVersionMixin-2-0
--- @field name Name The addon name
--- @field settings Settings_ABP_2_0 @Settings
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field gameVersion Kapresoft-GameVersion-2-0
--- @field private fmt LibPrettyPrint_Formatter
--- @field printer LibPrettyPrint_Printer
--- @field logHolder LogHolder_ABP_2_0
--- @field colorDef Kapresoft-ColorDefinition-2-0
--- @field tracer EventTraceUtilObj_ABP_2_0
--- @field tr TraceFn_ABP_2_0
--- @field M Core_Modules_ABP_2_0 The module names
--- @field O Core_Modules_ABP_2_0 The module objects
local ns

addon, ns = ...; ns.name = addon; ns.nameShort='ABP2'; Mixin(ns, GVM, AceLib)
ABP_2_0_NS = ns


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
--- @field developer boolean @if true: enables developer mode
ns.settings = { developer = false }

--[[-------------------------------------------------------------------
Formatter/Printer
---------------------------------------------------------------------]]
local prefixColor, subPrefixColor = '466EFF', '9CFF9C'
ns.colorDef = {
  primary = CreateColorFromRGBHexString(prefixColor),
  secondary = CreateColorFromRGBHexString(subPrefixColor),
}

ns.fmt = LibPrettyPrint:Formatter({ show_all = true, depth_limit = 3 }); fmt = ns.fmt
ns.printer = LibPrettyPrint:Printer({
  prefix = ns.nameShort, formatter = ns.fmt,
  prefix_color = prefixColor, sub_prefix_color = secondaryColor,
})

--[[-------------------------------------------------------------------
External Lib Dependencies
---------------------------------------------------------------------]]
function ns:Ace() return LibStub('Kapresoft-AceLib-2-0') end
function ns:Table() return LibStub('Kapresoft-Table-2-0') end
function ns:String() return LibStub('Kapresoft-String-2-0') end
function ns:ColorFormatter() return ColorFormatter end
--- @return table<string, string>
function ns:GetLocale() return ns:AceLocale():GetLocale(self.name, true) end
function ns:AddonUtil() return LibStub('Kapresoft-AddonUtil-2-0') end

--- Register a Namespace Module
--- @generic T
--- @param anyObj T The library object instance
--- @return T
function ns:Register(libName, anyObj)
  assert(type(libName) == 'string' and type(anyObj) == 'table',
          'Register(libName, obj): libName(string) and obj(table) is required.')
  self.O[libName] = anyObj
  return anyObj
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
function ns:bar(index) return self:a():bar(index) end

--- @return Cursor_ABP_2_0
function ns:cursor() return self.O.CursorProvider:GetCursor() end

--- @return AttributeNames_ABP_2_0, SupportedActionTypes_ABP_2_0
function ns:constants() local C = self.O.Constants; return C.AttributeNames, C.SupportedActionTypes end

--- @param color colorRGBA|HexRGBA|HexRGB|HexRGBA @ RED_THREAT_COLOR | '565656fc' | '565656' | 'fc565656'
--- @return fun(key:string) : string The color formatted key
function ns:ColorFn(color)
  local cfn, _ = ColorFormatter:ColorFn(color); return cfn
end
--[[-------------------------------------------------------------------
Utility Functions
---------------------------------------------------------------------]]
local GLOBAL_ATTRIBUTES = {}

--- @param name Name
--- @param val any
function ns:SetGlobalAttribute(name, val)
  assert(type(name) == "string", "SetGlobalAttribute(name):: Name must be a string")
  if val then GLOBAL_ATTRIBUTES[name] = val end
end

--- @generic T
--- @param name Name
--- @return T|nil
function ns:GetGlobalAttribute(name)
  assert(type(name) == "string", "GetGlobalAttribute(name):: Name must be a string")
  return GLOBAL_ATTRIBUTES[name]
end
--- @param name Name
function ns:ClearGlobalAttribute(name)
  assert(type(name) == "string", "ClearGlobalAttribute(name):: Name must be a string")
  GLOBAL_ATTRIBUTES[name] = nil
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

--- @class LogHolder_ABP_2_0
--- @field printer fun(moduleName:Name) : LibPrettyPrint_PrintFn A simple printer
--- @field tracer fun(moduleName:Name) : TraceFn_ABP_2_0 A simple tracer

ns.logHolder = {}; do
  --- These are noop loggers and tracers for non-dev releases
  local h = ns.logHolder; local noop = function(moduleName) return function() end end
  h.printer, h.tracer = noop, noop
end

--[[-------------------------------------------------------------------
Loggers/Tracers:: NoOp in Official Releases
---------------------------------------------------------------------]]
--- Returns the print, delayed-print, tracer, formatted-tracer functions
--- ```
--- local p, t = ns:log('EventHandler')
--- ```
--- @param moduleName Name
--- @return LibPrettyPrint_PrintFn, TraceFn_ABP_2_0
function ns:log(moduleName)
  local h = self.logHolder
  return h.printer(moduleName), h.tracer(moduleName)
end

