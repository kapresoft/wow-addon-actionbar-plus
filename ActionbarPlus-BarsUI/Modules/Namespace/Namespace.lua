--[[-------------------------------------------------------------------
Namespace_ABP_BarsUI
---------------------------------------------------------------------]]
--- @alias Namespace_ABP_BarsUI_2_0 Namespace_ABP_BarsUI_Impl_2_0
--
--- @class Namespace_ABP_BarsUI_Impl_2_0
--- @field name Name The addon name
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field M BarsUI_Modules_ABP_2_0 The module names
--- @field O BarsUI_Modules_ABP_2_0 The module objects
--- @field tracer EventTracePrinter_ABP_2_0
--- @field private fmt LibPrettyPrint_Formatter
--- @field private printer LibPrettyPrint_Printer
--
--
--- @type string
local addon
--- @type Namespace_ABP_BarsUI_Impl_2_0 | Namespace_ABP_BarsUI_2_0
local ns
addon, ns = ...; ns.name = addon; ns.nameShort = 'ABP2|cff8EB9FFBarsUI|r'

--- @type BarsUI_Modules_ABP_2_0
ns.O = ns.O or {}

--- @type Namespace_ABP_2_0
function ns:cns() return ABP_CORE_NS end

--[[-------------------------------------------------------------------
LibPrettyPrint::Formatter/Printer
---------------------------------------------------------------------]]
--- @return boolean
local function predicateFn() return ns:cns():IsDev() end

ns.tracer = ns:cns():NewTracer(ns.nameShort, predicateFn)

ns.fmt = LibPrettyPrint:Formatter({ show_all = true, depth_limit = 3 })
ns.printer = LibPrettyPrint:Printer({
    prefix = ns.nameShort, formatter = ns.fmt,
    prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
}, predicateFn)

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
    local tracer1 = ns:cns():traceFnWithFormatting(m)
    local tracer2 = ns:cns():traceFn(m)
    return printer, tracer1, tracer2
end

--[[-------------------------------------------------------------------
Namespace Methods
---------------------------------------------------------------------]]
--- @type ABP_BarsUI_2_0
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
