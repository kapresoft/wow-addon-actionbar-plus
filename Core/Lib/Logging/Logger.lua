local pformat, ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()
local PrettyPrint, Table, String = ABP_LibGlobals:LibPackUtils()
local _, _, logPrefix = __K_Core:GetAddonInfo()
--local LibStub = __K_Core:LibPack()
local LibStub = LibStub

local format, pack, unpack, sliceAndPack = string.format, Table.pack, Table.unpackIt, Table.sliceAndPack
local type, select, tostring, error, setmetatable = type, select, tostring, error, setmetatable
local sreplace = String.replace

--local LibStub = LibStub

local C = LibStub('AceConsole-3.0', true)

local MAJOR, MINOR =  'ActionbarPlus-Logger-1.0', format("$Revision: %s $", 1)
---@class Logger
local L = LibStub:NewLibrary(MAJOR, MINOR)
if not L then return end

---@param level number The level configured by the log function call
local function ShouldLog(level)
    assert(type(level) == 'number', 'Level should be a number between 1 and 100')
    local function GetLogLevel() return ABP_LOG_LEVEL end
    if GetLogLevel() >= level then return true end
    return false
end

local DEFAULT_FORMATTER = {
    format = function(o)
        local fn = Table.toStringSorted
        if type(pformat) == 'function' then fn = pformat end
        return fn(o)
    end
}
local TABLE_FORMATTER = {
    format = function(o) return Table.toStringSorted(o, false) end
}

---@param obj table
---@param optionalLogName string The optional logger name
local function _EmbedLogger(obj, optionalLogName)
    local prefix = ''
    if type(optionalLogName) == 'string' then prefix = '::' .. optionalLogName end
    if type(obj.mt) ~= 'table' then obj.mt = {} end
    obj.mt = { __tostring = function() return format(logPrefix, prefix)  end }
    setmetatable(obj, obj.mt)

    local formatter = DEFAULT_FORMATTER

    function obj:format(obj)
        return formatter.format(obj)
    end
    function obj:LogWithTableFormatter()
        formatter = TABLE_FORMATTER
        return self
    end
    function obj:LogAll()
        PrettyPrint:_ShowAll()
        return self
    end
    function obj:T() return self:LogWithTableFormatter() end
    function obj:A() return self:LogAll() end

    -- 1: log('String') or log(N, 'String')
    -- 2: log('String', obj) or log(N, 'String', obj)
    -- 3: log('String', arg1, arg2, etc...) or log(N, 'String', arg1, arg2, etc...)
    -- Where N = 1 to 100
    function obj:log(...)
        local args = pack(...)
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

        --if len == 2 then
        --    local textFormat = args[startIndex]
        --    local o = args[startIndex + 1]
        --    self:Printf(format(textFormat, self:format(o)))
        --    return
        --end

        args = sliceAndPack({...}, startIndex)
        local newArgs = {}
        for i=1,args.len do
            local formatSafe = i > 1
            newArgs[i] = self:ArgToString(args[i], formatSafe)
        end
        self:Printf(format(unpack(newArgs)))
    end

    function obj:logOrig(...)
        local args = pack(...)
        if args.len == 1 then
            self:Print(self:ArgToString(args[1]))
            return
        end
        local level = 0
        local startIndex = 1
        if type(args[1]) == 'number' then
            level = args[1]
            startIndex = 2
        end
        if type(args[startIndex]) ~= 'string' then
            error(format('Argument #%s requires a string.format text', startIndex))
        end
        if not ShouldLog(level) then return end

        args = sliceAndPack({...}, startIndex)
        local newArgs = {}
        for i=1,args.len do
            local formatSafe = i > 1
            newArgs[i] = self:ArgToString(args[i], formatSafe)
        end
        self:Printf(format(unpack(newArgs)))
    end

    -- Log a Pretty Formatted Object
    -- self:logp(itemInfo)
    -- self:logp("itemInfo", itemInfo)
    function obj:logp(...)
        local count = select('#', ...)
        if count == 1 then
            self:log(pformat(select(1, ...)))
            return
        end
        local label, obj = select(1, ...)
        self:log(label .. ': %s', pformat(obj))
    end

    -- Backwards compat
    function obj:logf(...) self:log(...) end
    -- Backwards compat
    -- Example print('String value')
    function obj:print(...)
        self:Print(...)
    end

    ---Convert arguments to string
    ---@param optionalStringFormatSafe boolean Set to true to escape '%' characters used by string.forma
    function obj:ArgToString(any, optionalStringFormatSafe)
        local text
        if type(any) == 'table' then text = self:format(any) else text = tostring(any) end
        if optionalStringFormatSafe == true then
            return sreplace(text, '%', '$')
        end
        return text
    end

end

---Embed on a generic object
---@param obj table
---@param optionalLogName string The optional log name
function L:Embed(obj, optionalLogName)
    C:Embed(obj)
    _EmbedLogger(obj, optionalLogName)
end

---Embed in a registered object module
---@see LibGlobals#EmbedNewLib for the available fields
function L:EmbedModule(obj)
    assert(obj ~= null and type(obj.GetModuleName) == 'function',
            'The passed object is not a valid module object.')
    C:Embed(obj)
    _EmbedLogger(obj, obj:GetModuleName())
end
