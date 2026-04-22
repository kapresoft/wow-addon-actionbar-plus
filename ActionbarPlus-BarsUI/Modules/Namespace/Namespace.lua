--[[-------------------------------------------------------------------
Namespace_ABP_BarsUI
---------------------------------------------------------------------]]
--- @type string
local addon

--- @class Namespace_ABP_BarsUI_2_0
--- @field name Name The addon name
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field logHolder LogHolder_ABP_2_0
--- @field colorDef Kapresoft-ColorDefinition-2-0
--- @field buttonTemplate Name The button template name to use for action buttons (see BarFrame.xml and BarModuleFactory.lua)
--- @field M BarsUI_Modules_ABP_2_0 The module names
--- @field O BarsUI_Modules_ABP_2_0 The module objects
local ns

addon, ns = ...; ns.name = addon; ns.nameShort = 'ABP2|cff8EB9FFBarsUI|r'
ABP_BARSUI_NS = ns

--- @type BarsUI_Modules_ABP_2_0
ns.O = ns.O or {}

--- @return Namespace_ABP_2_0, Core_Modules_ABP_2_0
function ns:cns() return ABP_CORE_NS, ABP_CORE_NS.O end

--[[-------------------------------------------------------------------
LibPrettyPrint::Formatter/Printer
---------------------------------------------------------------------]]
--- @return boolean
local function predicateFn() return ns:cns():IsDev() end

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
--- @return ABP_BarsUI_2_0
function ns:a() return ABP_BarsUI_2_0 end

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

ns.logHolder = {}; do
  local h = ns.logHolder; local noop = function(moduleName) return function() end end
  h.printer, h.tracer = noop, noop
end

--[[-------------------------------------------------------------------
Loggers/Tracers:: NoOp in Official Releases
---------------------------------------------------------------------]]
--- @see ActionbarPlus-BarsUI/Modules/Developer/DeveloperSetup.lua
--- @param moduleName Name
--- @return LibPrettyPrint_PrintFn, TraceFn_ABP_2_0
function ns:log(moduleName)
  local h = self.logHolder
  return h.printer(moduleName), h.tracer(moduleName)
end

