--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type CoreNamespace
local kns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'AceEventWithTraceMixin'
--- @class AceEventWithTraceMixin
local L = {}; kns.O[libName] = L

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function safeArgs(...)
    local a = {...}
    for i, elem in ipairs(a) do
        if type(elem) == "table" then
            a[i] = tostring(elem)
        end
    end
    return a
end

--- @param logger Kapresoft_CategoryLoggerMixin
--- @param callback fun(msg:string, source:string, ...:any)
local function CreateTraceFn(logger, callback)
    assert(callback, "callback function is required.")
    local fn = callback
    if kns.enableEventTrace == true then
        fn = function(msg, source, ...)
            local a = safeArgs(...)
            if type(source) == 'table' then source = tostring(source) end
            logger:i(function() return "ALM::MSG:R[%s] src=%s args=%s", msg, source, a end)
            callback(msg, source, ...)
        end
    end
    return fn
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @see Base.lua
--- @param o AceEventWithTraceMixin | Namespace
local function PropsAndMethods(o)

    -- todo: AceEventWithTrace will eventually replace AceEvent(..)
    --- Create a new instance of AceEvent or embed to an obj if passed
    --- @return AceEvent
    --- @param moduleName Name
    function o:AceEventWithTrace(moduleName)
        assert(moduleName, "moduleName is required.")
        local o2 = kns:AceEvent()
        o2.pm = self:LC().MESSAGE_TRACE:NewLogger(moduleName)
        local _RegisterMessage = o2.RegisterMessage

        --- @param msg string The message name
        --- @param callbackFn fun(self:any, ...)|string The callback function name or function(self,...) in the instance of this object
        function o2:RegisterMessage(msg, callbackFn)
            _RegisterMessage(o2, msg, CreateTraceFn(o2.pm, callbackFn))
        end
        return o2
    end

    --- AceLocale needs to be called after the _Locales.xml has been loaded
    --- @return AceLocale
    function o:AceLocale() return LibStub("AceLocale-3.0"):GetLocale(self.name, true) end

end; PropsAndMethods(L)
