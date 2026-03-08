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

ns.fmt = LibPrettyPrint:Formatter({ show_all = true, depth_limit = 8 })
ns.printer = LibPrettyPrint:Printer({
    prefix = ns.nameShort, formatter = ns.fmt,
    prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
}, predicateFn)

--[[-------------------------------------------------------------------
LogBuilder
---------------------------------------------------------------------]]
do
  --- @param prefix string|any
  --- @return ABP_2_0_TraceFn @Printer function that outputs plain values to Blizzard Trace UI (like print)
  local function traceFn1(prefix)
    if type(prefix) ~= 'string' then return function(...) return ns.tracer and ns.tracer:td(...) end end
    return function(...) return ns.tracer and ns.tracer:t(strtrim(prefix), ...) end
  end
  
  --- With auto formatting of objects
  --- @param prefix string|nil
  --- @return ABP_2_0_TraceFnFormatted @Printer function that outputs formatted values to Blizzard Trace UI (like print)
  local function traceFn2(prefix)
    if type(prefix) ~= 'string' then return function(...) return ns.tracer and ns.tracer:tdf(...) end end
    return function(...) return ns.tracer and ns.tracer:tf(strtrim(prefix), ...) end
  end
  
  --- Returns the print, delayed-print, tracer, formatted-tracer functions
  --- ```
  --- local p, pd, t, tf = ns:log('EventHandler')
  --- ```
  --- TODO: Create BarsUI tracer
  --- ns.tracer = ns:cns():NewTracer(ns.nameShort, predicateFn)
  ---
  --- @param moduleName Name
  --- @return LogBuilderFn
  function ns:log(moduleName)
    if not self.logBuilder then self.logBuilder = self:cns():__CreateLogBuilder(self.printer, traceFn1, traceFn2) end
    return self.logBuilder(moduleName)
  end

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

--[[-------------------------------------------------------------------
Init Tracer
---------------------------------------------------------------------]]
do
  local cns = ns:cns(); if not predicateFn() then return end
  cns:NewAceEvent():RegisterMessage('ABP_2_0::CORE_READY', function(src, isLogin, isReload)
    ns.tracer = cns:NewTracer(ns.nameShort, predicateFn)
    local _, _, t = ns:log('Namespace')
    t('Namespace::InitTracer', 'name=', ns.nameShort, 'isLogin=', isLogin, 'isReload=', isReload, 'tracer=', ns.tracer, 'sourceMessage=', src)
  end)
end
