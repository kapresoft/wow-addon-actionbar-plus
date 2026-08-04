--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @see BlizzardInterfaceCode::Interface/SharedXML/Mixin.lua#CreateAndInitFromMixin(...)
local CreateAndInitFromMixin = CreateAndInitFromMixin

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local errorPrefix = '::ERROR::'

--- @type LibStub
local LibStub = LibStub
local MAJOR_VERSION = 'Kapresoft-Safecall-1.0'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Kapresoft_Safecall
local L = LibStub:NewLibrary(MAJOR_VERSION, 1); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o Kapresoft_LibUtil_Safecall
local function PropsAndMethods(o)

    --- Create By:
    --- ```
    --- local safecall = SafeCall:New(logger)
    --- ```
    --- @return Kapresoft_LibUtil_Safecall
    function o:New(...) return CreateAndInitFromMixin(o, ...) end

    ---@param logger Logger
    function o:Init(logger)
        assert(logger, 'Logger is required')
        self.logger = logger
        self.mt = { __call = self.call }
        setmetatable(self, self.mt)
    end

    --- ```
    --- local success, ret = safecall(function() print('hello'); return 'hi' end)
    --- // OR
    --- local success, ret = safecall:call(function() print('hello'); return 'hi' end)
    --- ```
    --- @return boolean, any
    function o:call(fn, ...)
        if not fn then return end
        local success, ret = xpcall(fn, function(errMsg) self:DefaultErrorHandler(errMsg) end, ...)
        return success, ret
    end

    function o:DefaultErrorHandler(errMsg)
        self.logger:log("%s: %s",  errorPrefix, tostring(errMsg))
    end

end

PropsAndMethods(L)

