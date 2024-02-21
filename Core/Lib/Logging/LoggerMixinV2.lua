--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns, _, _, M = ABP_NS:namespace(...)
local K = ns:K()
local KC = K.Objects.Constants

local sformat, stru, strl = string.format, string.upper, string.len

local addon = ns.name
local libName = M.LoggerMixinV2

local ERROR_LEVEL = 5
local WARN_LEVEL = 10
local INFO_LEVEL = 15
local DEBUG_LEVEL = 20
local FINE_LEVEL = 25
local FINER_LEVEL = 30
local FINEST_LEVEL = 35
local TRACE_LEVEL = 50
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return LoggerMixinV2
local function CreateLib()
    --- @class LoggerMixinV2
    local newLib = {}
    ns:Register(libName, newLib)
    return newLib
end; local L = CreateLib(); if not L then return end
--print(string.format("{{%s:%s}}::Loaded: %s", ns.name, libName, libName))

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function GetLogLevel() return ABP_LOG_LEVEL end
local function GetCategoryData() return ABP_DEBUG_ENABLED_CATEGORIES  or {} end
--- Checks if a string is completely blank, including whitespace characters.
---@param str string The string to check.
---@return boolean Returns true if the string is blank; otherwise, false.
function HasStringLength(str)
    if str and strl(str) > 0 then return true end
    return false
end

--- @type Kapresoft_LibUtil_ColorDefinition
local consoleColors = {
    primary   = '2db9fb',
    secondary = 'fbeb2d',
    tertiary  = 'ffffff',
}
local ch = KC:NewConsoleHelper(consoleColors)

local function GetLogPrefix(name)
    local px = ch:T('{{')
            .. ch:P(addon) .. ch:T('::') .. ch:S(name)
            .. ch:T('}}:')
    return px
end
local function GetLogPrefixWithCategory(name, cat)
    local px = ch:T('{{') .. ch:P(addon) .. ch:T('::') .. ch:S(name)
    if HasStringLength(cat) then px = px .. ch:T('::') .. ch:P(cat) end
    px = px .. '%s' .. ch:T('}}:')
    return px
end

--- @alias PrefixStrategy fun(name:string, category:string)
--- @alias LogStrategy fun(logPrefix:string, val:string, categorySuffix:string, logSuffix:string)

--- @param o LoggerV2 | LoggerMixinV2
--- @return PrefixStrategy, LogStrategy
function logStrategy1(o)
    local fn = function(p, v, cp, sf) print(p, v, cp, sf) end
    return GetLogPrefix, fn
end
--- @param o LoggerV2 | LoggerMixinV2
--- @return PrefixStrategy, LogStrategy
function logStrategy2(o)
    local fn = function(p, v, catSuffix, s)
        local sf = ''
        if HasStringLength(s) then sf = '::' .. ch:P(s) end
        print(sformat(p, sf), v)
    end
    return GetLogPrefixWithCategory, fn
end

--- Safely formats a string using variable arguments.
-- @param formatStr string The format string.
-- @param ... any The values to format.
-- @return string The safely formatted string.
local function safeFormat(formatStr, ...)
    -- Capture the varargs into a table.
    local args = {...}
    local numArgsProvided = select("#", ...)

    -- Count the number of format specifiers in the format string.
    local numFormatSpecifiers = select(2, formatStr:gsub("%%[^%%]", ""))

    -- Prepare a table to hold the actual arguments passed to string.format.
    local actualArgs = {}

    for i = 1, numFormatSpecifiers do
        if i <= numArgsProvided then
            -- Use the provided argument.
            actualArgs[i] = args[i]
        else
            -- Use a placeholder for missing arguments.
            actualArgs[i] = "<missing>"
        end
    end

    -- Use pcall to catch any errors during formatting.
    local success, result = pcall(string.format, formatStr, unpack(actualArgs))
    if success then
        return result
    else
        return "Formatting error: " .. result
    end
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @alias LM_LogCallbackFn fun() : string, any, any, any, any | "function() end"
--- @alias LogLevel number A number 0 or greater

--- @class LoggerV2 : LoggerMixinV2

--- @param o LoggerV2 | LoggerMixinV2
local function PropsAndMethods(o)

    --- @param name string The log name
    --- @param cat string|nil Category name
    --- @param catSN string|nil Category name (short form)
    function o:Init(name, cat, catSN)
        assert(name, sformat(GetLogPrefix(libName) .. "log name is required."))
        self.name = name
        self.category = nil
        self.categorySuffix = ''

        --- @type string|boolean
        local validCategory = type(cat) == 'string' and strl(cat) > 0 and stru(cat)
        --- @type string|boolean
        local validCategorySN = type(catSN) == 'string' and strl(catSN) > 0 and stru(catSN)
        if validCategorySN then self.categoryShort = validCategorySN end
        if validCategory then
            self.category = validCategory
            --self.categorySuffix = sformat('[%s]', self.categoryShort or self.category)
            self.categorySuffix = self.categoryShort or self.category
        end
        local pfn, logfn = logStrategy2(self)
        self.logfn = logfn
        self.logPrefix = pfn(name, self.categorySuffix)
    end

    --- @return LoggerV2
    function o:New(...) return K:CreateAndInitFromMixin(self, ...) end

    --- @param level LogLevel
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    --- @param logSuffix string | "'INFO" | "'WARN" | "'DEBUG'"
    function o:log(level, strOrCallbackFn, logSuffix)
        if not self:ShouldLog(level) then return end;
        local val
        if type(strOrCallbackFn) == 'function' then val = safeFormat(strOrCallbackFn())
        else val = tostring(strOrCallbackFn) end
        self.logfn(self.logPrefix, val, self.categorySuffix, logSuffix)
    end

    --- Verbose, Always Log
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:v(strOrCallbackFn)
        self:log(0, strOrCallbackFn, 'V')
    end

    --- ERROR_LEVEL = 5
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:e(strOrCallbackFn)
        self:log(ERROR_LEVEL, strOrCallbackFn, ch:FormatColor('FF0000','E'))
    end
    --- WARN_LEVEL = 10
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:w(strOrCallbackFn)
        self:log(WARN_LEVEL, strOrCallbackFn, ch:FormatColor('FFA500','W'))
    end
    --- INFO_LEVEL = 15
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:i(strOrCallbackFn)
        self:log(INFO_LEVEL, strOrCallbackFn)
    end
    --- DEBUG_LEVEL = 20
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:d(strOrCallbackFn)
        self:log(DEBUG_LEVEL, strOrCallbackFn, 'D')
    end
    --- FINE_LEVEL = 25
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:f1(strOrCallbackFn)
        self:log(FINE_LEVEL, strOrCallbackFn, 'F1')
    end
    --- FINER_LEVEL = 30
    --- @param strOrCallbackFn string|LM_LogCallbackFn  | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:f2(strOrCallbackFn)
        self:log(FINER_LEVEL, strOrCallbackFn, 'F2')
    end
    --- FINEST_LEVEL = 35
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:f3(strOrCallbackFn)
        self:log(FINEST_LEVEL, strOrCallbackFn, 'F3')
    end
    --- TRACE_LEVEL = 50
    --- @param strOrCallbackFn string|LM_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:t(strOrCallbackFn)
        self:log(TRACE_LEVEL, strOrCallbackFn, 'T')
    end

    --- @param level number The level configured by the log function call
    function o:ShouldLog(level)
        assert(type(level) == 'number', 'Level should be a number between 1 and 100')
        --print('LoggerV2::' .. self.name, 'log-level:', GetLogLevel(), 'level:', level)
        if GetLogLevel() < level then return false end
        return self:IsCategoryEnabled()
    end

    function o:IsCategoryEnabled()
        if self.category == nil or string.len(self.category) == 0 then return true end
        local cats = GetCategoryData()
        local val = cats[self.category] or false
        local enabled = val == true or val == 1
        return enabled
    end

end; PropsAndMethods(L)

