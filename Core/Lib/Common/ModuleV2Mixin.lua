--[[-----------------------------------------------------------------------------
Aliases
-------------------------------------------------------------------------------]]
--- @alias AceEventPlus AceEvent | AceBucket

--- Use ModuleV2 for standard module libraries
--- @alias ModuleV2 ModuleV2Mixin | AceEventPlus

--- Use ControllerV2 for Controllers (has the ActionbarHandlerMixin trait)
--- @alias ControllerV2 ModuleV2Mixin | ActionBarHandlerMixin | AceEventPlus


--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace | Kapresoft_Base_Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M
local K = ns.Kapresoft_LibUtil
local Ace = ns:AceLibrary()
local AceEvent, AceBucket = Ace.AceEvent, Ace.AceBucket
local StringReplace = ns:String().Replace

local eventTraceEnabled = ns.debug.flag.eventTrace

--[[-----------------------------------------------------------------------------
New Instance: ModuleV2Mixin
This is the base mixin for ModuleV2 and ControllerV2 libraries
-------------------------------------------------------------------------------]]
local libName = 'ModuleV2Mixin'
-- todo: rename to something else? ModuleV2Mixin?
--- @class ModuleV2Mixin
local L = AceEvent:Embed({}); AceBucket:Embed(L);
ns:Register(libName, L)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function safeArgs(...)
    local a = {...}
    for i, elem in ipairs(a) do
        if type(elem) == "table" then a[i] = tostring(elem) end
    end
    return a
end

--- @param callback fun(msg:string, source:string, ...:any)
--- @param logger Kapresoft_CategoryLoggerMixin
--- @param isBucket boolean Is AceBucket message
local function CreateTraceFn(logger, callback, isBucket)
    local fn = callback
    if eventTraceEnabled ~= true then return fn end
    local prefix = "MSG:R"
    if isBucket == true then prefix = "MSGB:R" end
    fn = function(msg, source, ...)
        local a = safeArgs(...)
        if type(source) == 'table' then source = tostring(source) end
        logger:i(function() return prefix .. "[%s] src=%s args=%s", msg, source, a end)
        callback(msg, source, ...)
    end
    return fn
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ModuleV2Mixin | AceEventPlus
local function PropsAndMethods(o)

    --- @param moduleName Name
    --- @vararg any
    function o:Init(moduleName, ...)
        assert(moduleName, "LibName is required")
        self.pm = ns:LC().MESSAGE_TRACE:NewLogger(moduleName)

        local len = select("#", ...)
        if len > 0 then K:Mixin(self, ...) end

        self.mt = { __tostring = function() return moduleName  end }
        setmetatable(self, self.mt)

        self:RegisterMessage(GC.M.OnAddOnInitialized, function(msg, source)
            return self.OnAddOnInitialized and self:OnAddOnInitialized(msg, source)
        end)
        self:RegisterMessage(GC.M.OnAddOnReady, function(msg, source)
            return self.OnAddOnReady and self:OnAddOnReady(msg, source)
        end)
    end

    --- @param moduleName Name
    --- @vararg any
    function o:New(moduleName, ...)
        local newLib = K:CreateAndInitFromMixin(o, moduleName, ...)
        ns:Register(moduleName, newLib)
        return newLib
    end

    --- @param fromEvent Name Use the GlobalConstant.E event names
    --- @param callback MessageCallbackFn | "function() print('Called...') end"
    function o:RegisterAddOnMessage(fromEvent, callback)
        self:RegisterMessage(GC.toMsg(fromEvent), CreateTraceFn(self.pm, callback))
    end

    --- @param fromEvent Name The event name from GC.E enum
    --- @param interval number The Bucket interval (burst interval)
    --- @param callbackFn HandlerFnNoArg|string The callback function, either as a function reference, or a string pointing to a method of the addon object.
    function o:RegisterBucketAddOnMessage(fromEvent, interval, callbackFn)
        self:RegisterBucketMessage(GC.toMsg(fromEvent), interval, callbackFn)
    end

    --- @param event Name Use the GlobalConstant.E event names
    function o:SendAddOnMessage(event, ...) self:SendMessage(GC.toMsg(event), ...) end

    local _RegisterMessage = o.RegisterMessage
    local _RegisterBucketMessage = o.RegisterBucketMessage

    --- @param msg string The message name
    --- @param callbackFn fun(msg:string, source:string, ...:any) The callback function name or function(msg, src,...) in the instance of this object
    function o:RegisterMessage(msg, callbackFn)
        _RegisterMessage(self, msg, CreateTraceFn(self.pm, callbackFn))
    end

    if _RegisterBucketMessage then
        --- @param msg string|table
        --- @param interval number The Bucket interval (burst interval)
        --- @param callbackFn HandlerFnNoArg|string The callback function, either as a function reference, or a string pointing to a method of the addon object.
        function o:RegisterBucketMessage(msg, interval, callbackFn)
            _RegisterBucketMessage(self, msg, interval, CreateTraceFn(self.pm, callbackFn, true))
        end
    end

    --- @param msg string The message name
    --- @param self PlayerSettingsController
    local function ResolveHandlerFunction(self, msg)
        assert(type(msg) == 'string', 'Expected message to be a string but was: ' .. type(msg))
        local handlerName = StringReplace(msg, ns.name .. '::', '')
        local handlerFn = self[handlerName]
        assert(type(handlerFn) == 'function', 'Expected handler to be a function: ' .. handlerName)
        return handlerFn
    end

    --- @param msg string The message name
    function o:RegisterMessageHandler(msg)
        self:RegisterMessage(msg, ResolveHandlerFunction(self, msg))
    end

end; PropsAndMethods(L)

