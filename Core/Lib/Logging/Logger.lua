--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, tableUnpack = string.format, table.unpack
local type, select, tostring, error, setmetatable = type, select, tostring, error, setmetatable

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub
local C = LibStub('AceConsole-3.0', true)

local pformat = ns.pformat

assert(pformat ~= nil, 'PrettyFormatter pformat is required')

--- @class LogColors
local colors = {
    primary   = '2db9fb',
    secondary = 'fbeb2d',
    tertiary  = 'ffffff',
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param c LogColors
local function colorMethods(c)
    --- @param text string
    function c:pcolor(text) return format('|cfd%s%s|r', self.primary, text) end
    --- @param text string
    function c:scolor(text) return format('|cfd%s%s|r', self.secondary, text) end
    --- @param text string
    function c:tcolor(text) return format('|cfd%s%s|r', self.tertiary, text) end

    function c:GetLogPrefix(logName)
        return self:tcolor('{{') .. self:pcolor(logName) .. self:scolor('%s') .. self:tcolor('}}')
    end
end
colorMethods(colors)
local logPrefix = colors:GetLogPrefix(ns.name)
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
local major, minor, moduleName = ns:LibName(ns.M.Logger), 1, ns.M.Logger

--- @type Logger
local L = LibStub:NewLibrary(major, minor)
ns:Register(moduleName, L)

--[[-----------------------------------------------------------------------------
LogUtil
-------------------------------------------------------------------------------]]
--- @class LogUtil
local _U = { }

function _U.getSortedKeys(t)
    if type(t) ~= 'table' then return tostring(t) end
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys)
    return keys
end

--- @param t table The table to format
function _U.format(t, optionalAddNewline)
    local addNewLine = optionalAddNewline or false
    if type(t) ~= 'table' then return tostring(t) end
    local keys = _U.getSortedKeys(t)
    local s = '{ '
    if addNewLine then s = s .. '\n' end
    for _, k in pairs(keys) do
        local ko = k
        if type(k) ~= 'number' then k = '"'..k..'"' end
        if type(t[ko]) ~= 'function' then
            s = s .. '['..k..'] = ' .. _U.format(t[ko]) .. ','
        end
    end
    return s .. '} '
end

function _U.s_replace(str, match, replacement)
    if type(str) ~= 'string' then return nil end
    return str:gsub("%" .. match, replacement)
end

function _U.t_pack(...) return { len = select("#", ...), ... } end

---Fail-safe unpack
--- @param t table The table to unpack
function _U.t_unpack(t)
    if type(unpack) == 'function' then return unpack(t) end
    return tableUnpack(t)
end

function _U.t_sliceAndPack(t, startIndex)
    local sliced = _U.slice(t, startIndex)
    return _U.t_pack(_U.t_unpack(sliced))
end

function _U.slice(t, startIndex, stopIndex)
    local pos, new = 1, {}
    if not stopIndex then stopIndex = #t end
    for i = startIndex, stopIndex do
        new[pos] = t[i]
        pos = pos + 1
    end
    return new
end

--- @param level number The level configured by the log function call
local function ShouldLog(level)
    assert(type(level) == 'number', 'Level should be a number between 1 and 100')
    local function GetLogLevel() return ABP_LOG_LEVEL end
    if GetLogLevel() >= level then return true end
    return false
end

local DEFAULT_FORMATTER = {
    format = function(o)
        local fn = _U.format
        if type(pformat) ~= 'nil' then fn = pformat end
        return fn(o)
    end
}
local TABLE_FORMATTER = { format = function(o) return _U.format(o, false) end }

--[[-----------------------------------------------------------------------------
EmbedLogger
-------------------------------------------------------------------------------]]
--- @param obj table
--- @param optionalLogName string The optional logger name
local function _EmbedLogger(obj, optionalLogName)
    local prefix = ''
    if type(optionalLogName) == 'string' then prefix = '::' .. optionalLogName end
    if type(obj.mt) ~= 'table' then obj.mt = {} end
    obj.mt = { __tostring = function() return format(logPrefix, prefix)  end }
    setmetatable(obj, obj.mt)

    local formatter = DEFAULT_FORMATTER

    function obj:format(obj) return formatter.format(obj) end
    ---### Usage
    ---Log with table key-value output.
    ---```
    ---log:T():log(obj)
    ---```
    function obj:T() formatter = TABLE_FORMATTER; return self end
    ---### Usage
    ---Log with "All fields".
    ---```
    ---log:A():log(obj)
    ---```
    function obj:A() formatter = { format = function(o) return pformat:Default():pformat(o) end }; return self end
    ---### Usage
    ---Log with default formatter.
    ---```
    ---log:D():log(obj)
    ---```
    function obj:D() formatter = DEFAULT_FORMATTER; return self end

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

        if not ShouldLog(level) then return end

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

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---Embed on a generic object
--- @param obj table
--- @param optionalLogName string The optional log name
function L:Embed(obj, optionalLogName)
    C:Embed(obj)
    _EmbedLogger(obj, optionalLogName)
end

---Embed in a registered object module
function L:EmbedModule(obj)
    assert(obj ~= nil and type(obj.GetModuleName) == 'function',
            'The passed object is not a valid module object.')
    C:Embed(obj)
    _EmbedLogger(obj, obj:GetModuleName())
end

--- @return Logger
function L:NewLogger(optionalLogName)
    local o = {}
    C:Embed(o)
    _EmbedLogger(o, optionalLogName)
    return o
end
