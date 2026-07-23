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

local addon, xns = ...

--- @class Namespace_ABP_2_0 : Kapresoft-AceLib-2-0, Kapresoft-GameVersionMixin-2-0
--- @field private LOG_NAME Name
--- @field private DB_NAME Name
--- @field private fmt LibPrettyPrint_Formatter
--- @field private __trace fun(logName:Name, prefix:string, cfFn:cfFn, ...:any)
--- @field private __CreatePrinterFn fun(printer:LibPrettyPrint_Printer)
--- @field name Name The addon name
--- @field settings Settings_ABP_2_0 @Settings
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field printer LibPrettyPrint_Printer
--- @field logHolder LogHolder_ABP_2_0
--- @field colorDef Kapresoft-ColorDefinition-2-0
--- @field tr TraceFn_ABP_2_0
--- @field M Core_Modules_ABP_2_0   @The module names
--- @field O Core_Modules_ABP_2_0   @The module objects
--- @field mountID MountID  @Cached mountID set by PickupHooks at pickup time; consumed by CursorMixin -- used for handling mounts in MoP+
local ns = xns

ns.name = addon; ns.nameShort='ABP2'
Mixin(ns, GVM, AceLib); ABP_CORE_NS = ns

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]

--- @type Core_Modules_ABP_2_0
ns.O = ns.O or {}

ns.DB_NAME = 'ABP_PLUS'
ns.LOG_NAME = 'ABP_CORE'

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
local prefixColor, subPrefixColor = 'FFF803', '9CFF9C'
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

--- ### Usage
---  ```
---  -- @returns 'ActionbarPlus-Core::OnPlayerLogin'
---  local message = ns:msg('OnPlayerLogin')
---  ```
--- @param message Name @The base message name; used for AceEvent messages
--- @return string
function ns:msg(message)
  assert(type(message) == 'string' and #strtrim(message) > 0,
    'msg(message): {message} should be a string')
  return ('%s::%s'):format(self.name, message)
end

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

--[[-------------------------------------------------------------------
Layout Registry
  Plugin addons (e.g. ActionbarPlus-ArcLayout) declare `OptionalDeps:
  ActionbarPlus-Core` and self-register at file-load time:
  ```
  if not ABP_Core_2_0 then return end
  ABP_Core_2_0:ns():RegisterLayout('arc', S)
  ```
  BarsUI's GridLayout is NOT stored here -- it remains BarsUI's own
  static built-in default and is not looked up via this registry.
---------------------------------------------------------------------]]
--- @type table<string, BarLayout_ABP_2_0>
local layoutRegistry = {}

--- @param key string @Layout key, e.g. 'arc'; matches BarUIConfig_ABP_2_0.layout
--- @param layout BarLayout_ABP_2_0
function ns:RegisterLayout(key, layout)
  assert(type(key) == 'string' and #strtrim(key) > 0, 'RegisterLayout(key, layout): key must be a non-empty string')
  assert(type(layout) == 'table', 'RegisterLayout(key, layout): layout must be a table')
  layoutRegistry[key] = layout
end

--- @param key string
--- @return BarLayout_ABP_2_0|nil
function ns:GetLayout(key) return layoutRegistry[key] end

--- @param db DatabaseObj_ABP_2_0
function ns:RegisterDB(db)
  assert(type(db) == 'table', "RegisterDB(db): The param db is required.")
  self.addonDbFn = function() return db end
  -- Fires the moment cns:db()/cns:g()/cns:p() first become safe to call. Other
  -- addons (e.g. layout plugins) that need the DB at their own load time should
  -- wait for this instead of guessing/pcall-ing cns:g() at an arbitrary moment.
  self:a():SendMessage(self:msg('OnDatabaseReady'))
end

--- @return boolean true once RegisterDB has run and cns:db()/cns:g()/cns:p() are safe to call
function ns:IsDatabaseReady() return self.addonDbFn ~= nil end

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
--- @param index Index
--- @return BarConfig_ABP_2_0
function ns:barGlobal(index) return self:a():barGlobal(index) end

--- @return Namespace_ABP_BarsUI_2_0
function ns:BarsNS() return self:BarsUI():ns() end
--- @return Namespace_ABP_OptionsUI_2_0
function ns:OptionsNS() return self:OptionsUI():ns() end

--- @return ABP_BarsUI_2_0
function ns:BarsUI() return self.O['ActionbarPlus-BarsUI'] end
--- @return ABP_OptionsUI_2_0
function ns:OptionsUI() return self.O['ActionbarPlus-OptionsUI'] end

--- @return Cursor_ABP_2_0
function ns:cursor() return self.O.CursorProvider:GetCursor() end

--- #### Usage:
--- ```
--- local attr, atyp = cns:constants()
--- ```
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

--- @return AceGUILabel
function ns:spacer() local s = self:AceGUI():Create('Label'); s:SetText(' '); return s end

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

ns.logHolder = {}; do
  --- These are noop loggers and tracers for non-dev releases
  local h = ns.logHolder; local noop = function(moduleName) return function() end end
  h.printer, h.tracer = noop, noop
end

--[[-------------------------------------------------------------------
  Loggers/Tracers:: NoOp in Official Releases
                    This is overridden in DeveloperSetup
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

--- @class Chain_ABP_2_0
--- @field OrElse fun(fn: fun(...:any))

--- Fluent chain helper; use OrElse() to handle the unmatched case.
--- ### Usage:
--- ```lua
--- ns:Chain(someCondition)
---   .OrElse(function()
---     -- fallback logic
---   end)
--- ```
--- @param matched boolean @If true, the chain is matched; OrElse will not fire. If false, OrElse will fire.
--- @param ... any
--- @return Chain_ABP_2_0
function ns:Chain(matched, ...)
  local args = {...}
  --- @type Chain_ABP_2_0
  local chain = {}
  function chain.OrElse(fn)
    if not matched and type(fn) == 'function' then fn(unpack(args)) end
  end
  return chain
end

--- @param callbackFn fun(abpMasque:Namespace_ABP_Masque_2_0)
--- @return Chain_ABP_2_0
function ns:IfMasque(callbackFn)
  local hasABPMasque = ABP_MASQUE_NS ~= nil
  if hasABPMasque and callbackFn then callbackFn(ABP_MASQUE_NS) end
  return self:Chain(hasABPMasque)
end