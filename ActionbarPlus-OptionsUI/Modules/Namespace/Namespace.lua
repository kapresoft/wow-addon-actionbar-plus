--[[-------------------------------------------------------------------
Namespace_ABP_OptionsUI
---------------------------------------------------------------------]]
local addon, xns = ...

--- @class Namespace_ABP_OptionsUI_2_0
--- @field name Name The addon name
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field LOG_NAME Name
--- @field logHolder LogHolder_ABP_2_0
--- @field colorDef Kapresoft-ColorDefinition-2-0
--- @field M OptionsUI_Modules_ABP_2_0 The module names
--- @field O OptionsUI_Modules_ABP_2_0 The module objects
local ns = xns

ns.name = addon; ns.nameShort = 'ABP2|cff8EB9FFOptionsUI|r'
ABP_OPTIONSUI_NS = ns

--- @type OptionsUI_Modules_ABP_2_0
ns.O = ns.O or {}
ns.LOG_NAME = 'ABP_OPTIONSUI'

--- Core Namespace and Core modules
--- #### Usage:  `local cns, O, L = ns:cns()`
--- @return Namespace_ABP_2_0, Core_Modules_ABP_2_0, table<string, string>
function ns:cns() return ABP_CORE_NS, ABP_CORE_NS.O, ABP_CORE_NS:GetLocale() end

--[[-------------------------------------------------------------------
LibPrettyPrint::Formatter/Printer
---------------------------------------------------------------------]]
local prefixColor, subPrefixColor = '466EFF', '9CFF9C'
ns.colorDef = {
  primary = CreateColorFromRGBHexString(prefixColor),
  secondary = CreateColorFromRGBHexString(subPrefixColor),
}

ns.fmt = ns:cns().fmt
ns.printer = LibPrettyPrint:Printer({
    prefix = ns.nameShort, formatter = ns.fmt,
    prefix_color = prefixColor, sub_prefix_color = subPrefixColor,
})

--[[-------------------------------------------------------------------
Namespace Methods
---------------------------------------------------------------------]]
--- @return ABP_Core_2_0
function ns:core() return ABP_Core_2_0 end
--- @return ABP_OptionsUI_2_0
function ns:a() return ABP_OptionsUI_2_0 end

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

--- @generic T
--- @param libName Name
--- @param obj? any
--- @return table|T library
function ns:NewLib(libName, obj) return ns:Register(libName, obj or {}) end

ns.logHolder = {}; do
  local h = ns.logHolder; local noop = function(moduleName) return function() end end
  h.printer, h.tracer = noop, noop
end

--[[-------------------------------------------------------------------
Loggers/Tracers:: NoOp in Official Releases
---------------------------------------------------------------------]]
--- @param moduleName Name
--- @return LibPrettyPrint_PrintFn, TraceFn_ABP_2_0
function ns:log(moduleName)
  local h = self.logHolder
  return h.printer(moduleName), h.tracer(moduleName)
end

--- Message Format:  ActionbarPlus-OptionsUI::<Message>
--- @param message Name @The base message name; used for AceEvent messages
--- @return string
function ns:msg(message)
  assert(type(message) == 'string' and #strtrim(message) > 0,
    'msg(message): {message} should be a string')
  return ('%s::%s'):format(self.name, message)
end

