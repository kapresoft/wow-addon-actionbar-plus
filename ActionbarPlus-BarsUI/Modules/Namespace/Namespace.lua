--[[-------------------------------------------------------------------
Namespace_ABP_BarsUI
---------------------------------------------------------------------]]
--- @alias Namespace_ABP_BarsUI_2_0 Namespace_ABP_BarsUI_Impl_2_0
--
--- @class Namespace_ABP_BarsUI_Impl_2_0
--- @field name Name The addon name
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field buttonTemplate Name The button template name to use for action buttons (see BarFrame.xml and BarModuleFactory.lua)
--- @field M BarsUI_Modules_ABP_2_0 The module names
--- @field O BarsUI_Modules_ABP_2_0 The module objects
--- @field tracer EventTracePrinter_ABP_2_0
--- @field private logBuilder LogBuilderFn
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

--- @return Namespace_ABP_2_0
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

--- Returns the print, delayed-print, tracer, formatted-tracer functions
--- ```
--- local p, pd, t, tf = ns:log('EventHandler')
--- ```
--- @param moduleName Name
--- @return LogBuilderFn
function ns:log(moduleName)
    if not self.logBuilder then self.logBuilder = self:cns():__CreateLogBuilder(self.printer) end
    return self.logBuilder(moduleName)
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
