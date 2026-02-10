--[[-------------------------------------------------------------------
Namespace_ABP_BarsUI
---------------------------------------------------------------------]]
--- @alias Namespace_ABP_BarsUI Namespace_ABP_BarsUIImpl
--
--- @class Namespace_ABP_BarsUIImpl
--- @field name Name The addon name
--- @field nameShort Name The short version of the addon name used for logging and tracing.
--- @field tracer EventTracePrinter_ABP_2_0
--- @field private fmt LibPrettyPrint_Formatter
--- @field private printer LibPrettyPrint_Printer
--
--
--- @type string
local addon
--- @type Namespace_ABP_BarsUIImpl | Namespace_ABP_BarsUI
local ns
addon, ns = ...; ns.name = addon; ns.nameShort = 'ABP2|cff8EB9FFBarsUI|r'

--- @type Namespace_ABP_2_0
function ns:cns() return ABP_CORE_NS end

--[[-------------------------------------------------------------------
LibPrettyPrint::Formatter/Printer
---------------------------------------------------------------------]]
--- @return boolean
local function predicateFn() return ns:cns():IsDev() end

ns.tracer = ns:cns():NewTracer(ns.nameShort, predicateFn)

ns.fmt = LibPrettyPrint:Formatter({
    show_all = true, depth_limit = 3
})
ns.printer = LibPrettyPrint:Printer({
    prefix    = ns.nameShort, prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
    formatter = ns.fmt
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
function ns:a() return ABP_BarsUI end
