--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local KC = K_Constants

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, tableUnpack = string.format, table.unpack
local type, select, tostring, error, setmetatable = type, select, tostring, error, setmetatable

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub
local AceConsole = LibStub('AceConsole-3.0', true)

--- @type Kapresoft_LibUtil
local LibUtil = select(2, ...).Kapresoft_LibUtil

local pformat = LibUtil.pformat:B()
--local consoleHelper = KC:NewConsoleHelper(GC.C.COLOR_DEF)
assert(pformat ~= nil, 'PrettyFormatter pformat is required')

-- Example:
-- K:CreateAndInitFromMixin(LoggerMixin, GC.C.COLOR_DEF)

local MAJOR, MINOR = 'Kapresoft-LoggerMixin-1.0', 1

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]


--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]

--- @class Kapresoft_LoggerMixin
local L = LibStub:NewLibrary(MAJOR, MINOR); if not L then return end
L.mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR]  end }
setmetatable(L, L.mt)

--[[-----------------------------------------------------------------------------
LogUtil
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LogUtil
local _U = { }

--[[-----------------------------------------------------------------------------
LogUtil::Properties-and-Methods
-------------------------------------------------------------------------------]]
---@param o Kapresoft_LogUtil
local function LogUtilPropertiesAndMethods(o)

    function o.getSortedKeys(t)
        if type(t) ~= 'table' then return tostring(t) end
        local keys = {}
        for k in pairs(t) do table.insert(keys, k) end
        table.sort(keys)
        return keys
    end

    --- @param t table The table to format
    function o.format(t, optionalAddNewline)
        local addNewLine = optionalAddNewline or false
        if type(t) ~= 'table' then return tostring(t) end
        local keys = o.getSortedKeys(t)
        local s = '{ '
        if addNewLine then s = s .. '\n' end
        for _, k in pairs(keys) do
            local ko = k
            if type(k) ~= 'number' then k = '"'..k..'"' end
            if type(t[ko]) ~= 'function' then
                s = s .. '['..k..'] = ' .. o.format(t[ko]) .. ','
            end
        end
        return s .. '} '
    end

    function o.s_replace(str, match, replacement)
        if type(str) ~= 'string' then return nil end
        return str:gsub("%" .. match, replacement)
    end

    function o.t_pack(...) return { len = select("#", ...), ... } end

    ---Fail-safe unpack
    --- @param t table The table to unpack
    function o.t_unpack(t)
        if type(unpack) == 'function' then return unpack(t) end
        return tableUnpack(t)
    end

    function o.t_sliceAndPack(t, startIndex)
        local sliced = o.slice(t, startIndex)
        return o.t_pack(o.t_unpack(sliced))
    end

    function o.slice(t, startIndex, stopIndex)
        local pos, new = 1, {}
        if not stopIndex then stopIndex = #t end
        for i = startIndex, stopIndex do
            new[pos] = t[i]
            pos = pos + 1
        end
        return new
    end
end
LogUtilPropertiesAndMethods(_U)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local DEFAULT_FORMATTER = {
    format = function(o)
        local fn = _U.format
        if type(pformat) ~= 'nil' then fn = pformat end
        return fn(o)
    end
}
local TABLE_FORMATTER = { format = function(o) return _U.format(o, false) end }

--[[-----------------------------------------------------------------------------
Logger::Properties-and-Methods
-------------------------------------------------------------------------------]]
--- @param obj Kapresoft_LoggerMixin
--- @param optionalLogName string The optional logger name
local function PropertiesAndMethods(obj)

    ---```
    ---local logger = LoggerMixin:NewLogger(addonName, 'ABP_LOG_LEVEL' , colorDef, 'optionalModuleName')
    ---```
    --- @see Init()
    --- @return Logger A generic object with embedded AceConsole and Logger
    function obj:NewLogger(...)
        local logName, logLevelVar, colorDef, subName = ...
        local o = KC:CreateAndInitFromMixin(obj, logName, logLevelVar, colorDef, subName)
        AceConsole:Embed(o)
        return o
    end

    ---@param logLevelGlobalVarName string
    ---@param name string The log name
    ---@param colorDef Kapresoft_LibUtil_ColorDefinition
    ---@param subName string The optional sub-module name, ie. 'Util', 'String', etc...
    function obj:Init(name, logLevelGlobalVarName, colorDef, subName)
        self.subName = subName
        self.name = name
        self.logLevelGlobalVarName = logLevelGlobalVarName

        --- @type Kapresoft_LibUtil_ConsoleHelper
        self.consoleHelper = KC:NewConsoleHelper(colorDef)

        local function GetLogPrefix(ch) return ch:T('{{') .. ch:P(name) .. ch:S('%s') .. ch:T('}}') end
        self.logPrefix = GetLogPrefix(self.consoleHelper)

        local prefix = ''
        if type(subName) == 'string' then prefix = '::' .. subName end
        if type(self.mt) ~= 'table' then self.mt = {} end
        self.mt = { __tostring = function() return format(self.logPrefix, prefix)  end }
        setmetatable(self, self.mt)

        self.formatter = DEFAULT_FORMATTER
    end

    --- @param level number The level configured by the log function call
    function obj:ShouldLog(level)
        assert(type(level) == 'number', 'Level should be a number between 1 and 100')
        if self:GetLogLevel() >= level then return true end
        return false
    end

    function obj:GetLogLevel() return _G[self.logLevelGlobalVarName] or 0 end

    function obj:format(o) return self.formatter.format(o) end
    ---### Usage
    ---Log with table key-value output.
    ---```
    ---log:T():log(obj)
    ---```
    function obj:T() self.formatter = TABLE_FORMATTER; return self end
    ---### Usage
    ---Log with "All fields".
    ---```
    ---log:A():log(obj)
    ---```
    function obj:A() self.formatter = { format = function(o) return pformat:Default():pformat(o) end }; return self end
    ---### Usage
    ---Log with default formatter.
    ---```
    ---log:D():log(obj)
    ---```
    function obj:D() self.formatter = DEFAULT_FORMATTER; return self end

    -- 1: log('String') or log(N, 'String')
    -- 2: log('String', obj) or log(N, 'String', obj)
    -- 3: log('String', arg1, arg2, etc...) or log(N, 'String', arg1, arg2, etc...)
    -- Where N = 1 to 100
    function obj:log(...)
        local args = _U.t_pack(...)
        local level = 0
        local startIndex = 1
        local len = args.len

        if type(args[1]) == 'number' then
            level = args[1]
            startIndex = 2
            len = len - 1
        end
        if len <= 0 then return end

        -- level=10 LOG_LEVEL=5  --> Don't log
        -- level=10 LOG_LEVEL=10  --> Do Log
        -- level=10 LOG_LEVEL=11  --> Do Log
        --if LOG_LEVEL >= level then log it end

        if not self:ShouldLog(level) then return end

        if len == 1 then
            local singleArg = args[startIndex]
            if type(singleArg) == 'string' then
                self:Print(self:ArgToString(singleArg))
                return
            end
            self:Print(self:format(singleArg))
            return
        end

        if type(args[startIndex]) ~= 'string' then
            error(format('Argument #%s requires a string.format text', startIndex))
        end

        args = _U.t_sliceAndPack({...}, startIndex)
        local newArgs = {}
        for i=1,args.len do
            local formatSafe = i > 1
            newArgs[i] = self:ArgToString(args[i], formatSafe)
        end
        self:Printf(format(_U.t_unpack(newArgs)))
    end

    ---Convert arguments to string
    --- @param optionalStringFormatSafe boolean Set to true to escape '%' characters used by string.forma
    function obj:ArgToString(any, optionalStringFormatSafe)
        local text
        if type(any) == 'table' then text = self:format(any) else text = tostring(any) end
        if optionalStringFormatSafe == true then
            return _U.s_replace(text, '%', '$')
        end
        return text
    end

end

PropertiesAndMethods(L)
