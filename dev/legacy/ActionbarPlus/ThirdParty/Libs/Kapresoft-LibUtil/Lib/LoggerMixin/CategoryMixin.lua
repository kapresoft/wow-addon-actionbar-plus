--[[-----------------------------------------------------------------------------
Type Definitions
-------------------------------------------------------------------------------]]
--- @alias Kapresoft_CategoryLogger Kapresoft_CategoryLoggerMixin
--- @alias Kapresoft_LogCallbackFn fun() : string, any, any, any, any | "function() end"
--- @alias Kapresoft_LevelSupplierFn fun() : Kapresoft_LogLevel | "function() return 0 end"
--- @alias Kapresoft_EnabledCategoriesSupplierFn : table<string, number|boolean> | "function() return {} end"
--- @alias Kapresoft_LogLevel number A number 0 or greater

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, stru, strl = string.format, string.upper, string.len
--- @type LibStub
local LibStub = LibStub

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Kapresoft_Base_Namespace
local ns = select(2, ...)

local K, KO = ns.Kapresoft_LibUtil, ns.Kapresoft_LibUtil.Objects
local KC = KO.Constants

local ERROR_LEVEL = 5
local WARN_LEVEL = 10
local INFO_LEVEL = 15
local DEBUG_LEVEL = 20
local FINE_LEVEL = 25
local FINER_LEVEL = 30
local FINEST_LEVEL = 35
local TRACE_LEVEL = 50

--- @type Kapresoft_LibUtil_ColorDefinition
local consoleColors = {
    primary   = 'FF780A',
    secondary = 'fbeb2d',
    tertiary = 'ffffff'
}

--[[-----------------------------------------------------------------------------
Example Usage
-------------------------------------------------------------------------------]]
--[[

local ExampleCategories = {
    --- @type Kapresoft_LogCategory
    DEFAULT = "DEFAULT",
    --- @type Kapresoft_LogCategory
    API = "AP",
}

--- @type Kapresoft_LibUtil_ColorDefinition
local consoleColors = {
    primary   = 'FF780A',
    secondary = 'fbeb2d',
    tertiary = 'ffffff'
}

local CategoryLogger = kns.Kapresoft_LibUtil.Objects.CategoryMixin
CategoryLogger:Configure(addonName, LogCategories, {
    consoleColors = consoleColors,
    levelSupplierFn = function() return DEVS_LOG_LEVEL  end,
    enabledCategoriesSupplierFn = function() return DEVS_DEBUG_ENABLED_CATEGORIES end,
})

logger p1 =ExampleCategories.DEFAULT:NewLogger('ModuleName')
logger p2 = ExampleCategories.API:NewLogger('ModuleName')

]]

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-CategoryMixin-1.0', 5
local libName = MAJOR

--- @alias Kapresoft_LogCategory Kapresoft_CategoryMixin

--- @class Kapresoft_CategoryMixin
--- @field addonName string The addon name
--- @field name string Category name
--- @field short string Category Short name
--- @field labelFn fun() : string The label string
--- @field NewLogger fun(self:Kapresoft_LogCategory, logName:string) : Kapresoft_CategoryLogger
local L = LibStub:NewLibrary(MAJOR, MINOR); if not L then return end
L.mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR]  end }
setmetatable(L, L.mt)

--- @class Kapresoft_CategoryLoggerMixin
local LL = {}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param categoryName Name
local function IsDefaultCategory(categoryName) return 'DEFAULT' == stru(categoryName) end

local function GetSortedKeys(t)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys)
    return keys
end

--- Checks if a string is completely blank, including whitespace characters.
---@param str string The string to check.
---@return boolean Returns true if the string is blank; otherwise, false.
function HasStringLength(str)
    if str and strl(str) > 0 then return true end
    return false
end

local ch = KC:NewConsoleHelper(consoleColors)

--- @param c Kapresoft_LibUtil_ConsoleHelper
--- @param addonName Name Addon Name
--- @param name Name Module Name
local function GetLogPrefix(c, addonName, name)
    return c:T('{{') .. c:P(addonName) .. c:T('::') .. c:S(name) .. c:T('}}:')
end
--- @param c Kapresoft_LibUtil_ConsoleHelper
--- @param addonName Name Addon Name
--- @param name Name Module Name
local function GetLogPrefixWithCategory(c, addonName, name, cat)
    name = name or ''
    local px = c:T('{{') .. c:P(addonName)
    if stru(name) ~= stru(addonName) then
        px = px .. c:T('::') .. c:S(name)
    end
    if 'DEFAULT' ~= stru(cat) and HasStringLength(cat) then
        px = px .. c:T('::') .. c:P(cat)
    end
    px = px .. '%s' .. c:T('}}:')
    return px
end

--- @alias PrefixStrategyV2 fun(name:string, category:string)
--- @alias LogStrategyV2 fun(logPrefix:string, val:string, categorySuffix:string, logSuffix:string)

--- @param o Kapresoft_CategoryLoggerMixin | Kapresoft_CategoryLoggerMixin
--- @return PrefixStrategyV2, LogStrategyV2
local function logStrategy1(o)
    local fn = function(p, v, cp, sf) print(p, v, cp, sf) end
    return GetLogPrefix, fn
end
--- @param o Kapresoft_CategoryLogger
--- @return PrefixStrategyV2, LogStrategyV2
local function logStrategy2(o)
    ---@param prefix string The log prefix
    ---@param text string The text to log
    local fn = function(prefix, text, catSuffix, s)
        local sf = ''
        if HasStringLength(s) then sf = '::' .. ch:P(s) end
        if o.printerFn then
            return o.printerFn(sformat(prefix, sf) .. ' ' .. tostring(text))
        end
        print(sformat(prefix, sf), text)
    end
    return GetLogPrefixWithCategory, fn
end

--- Safely formats a string using variable arguments.
--- @param formatStr string The format string.
--- @vararg any The values to format.
--- @return string The safely formatted string.
local function safeFormat(formatStr, ...)
    -- Capture the varargs into a table.
    local args = {...}
    local numArgsProvided = select("#", ...)

    -- Count the number of format specifiers in the format string.
    local numFormatSpecifiers = select(2, formatStr:gsub("%%[^%%]", ""))

    -- Prepare a table to hold the actual arguments passed to string.format.
    local actualArgs = {}

    local pformat = pformat or K.pformat

    for i = 1, numFormatSpecifiers do
        if i <= numArgsProvided then
            -- Use the provided argument.
            local a = args[i]
            if type(a) == 'boolean' then a = tostring(a)
            elseif type(a) == 'table' or type(a) == 'function' then a = pformat(a)
            elseif a == nil then a = 'nil' end
            actualArgs[i] = a
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

--- @class Kapresoft_CategoryMixin_Options
--- @field consoleColors Kapresoft_LibUtil_ColorDefinition
--- @field levelSupplierFn Kapresoft_LevelSupplierFn | "function() return 0 end"
--- @field enabledCategoriesSupplierFn Kapresoft_EnabledCategoriesSupplierFn | "function() return {} end"
--- @field printerFn fun(...:any) : void
--- @field enabled Enabled

--[[-----------------------------------------------------------------------------
Methods: CategoryMixinV3
-------------------------------------------------------------------------------]]
--- @param o Kapresoft_CategoryMixin
local function CategoryMixinMethods(o)

    --- @private
    function o:Init()
        self.newInstance = true
    end

    --- @public
    --- @return Kapresoft_CategoryMixin
    function o:New()
        return K:CreateAndInitFromMixin(o)
    end

    --- @param addonName string
    --- @param categories table<string, Kapresoft_LogCategory>
    --- @param opts Kapresoft_CategoryMixin_Options
    function o:Configure(addonName, categories, opts)
        assert(self.newInstance, "Must call CategoryMixin:New() to get a new instance")
        local prefix = GetLogPrefix(ch, addonName, libName) .. " "
        assert(addonName, sformat("CategoryMixinV3:: addon name is required."))
        assert(categories, sformat(prefix .. "CategoryMixinV3:: Categories are required."))
        assert(opts, sformat("CategoryMixinV3:: opts is required."))
        assert(opts.levelSupplierFn, sformat(prefix .. "CategoryMixinV3:: Log level supplier function is required."))
        assert(opts.enabledCategoriesSupplierFn, sformat(prefix .. "CategoryMixinV3:: Enabled categories supplier function is required."))
        self:InitCategories(addonName, categories, opts)
    end

    --- @private
    --- @param opts Kapresoft_CategoryMixin_Options
    function o:InitCategories(a, c, opts)
        for k, v in pairs(c) do
            --- @type Kapresoft_LogCategory
            local lc = {
                addonName = a,
                name = k, short = v,
                labelFn = function() return sformat("%s [%s]", k, v) end,
                --- @param self Kapresoft_LogCategory
                --- @param name string
                NewLogger = function(self, name) return LL:New(name, self, opts) end,
                mt = { __tostring = function() return "LogCategoryV3::" .. k end }
            }
            setmetatable(lc, lc.mt)
            c[k] = lc
        end
        self.categories = c

        --- @type table<number, Name>
        self.sortedCategories = {}
        ---@param key Name
        for key in pairs(self.categories) do table.insert(self.sortedCategories, key) end
        table.sort(self.sortedCategories)

    end

    function o:GetCategories() return self.categories end

    --- @return table<number, string>
    function o:GetNames() return GetSortedKeys(self.categories) end
    --- @param catName string
    --- @return Kapresoft_LogCategory
    function o:GetCategory(catName) return self.categories[catName] end

    ---@param consumerFn fun(cat:Kapresoft_LogCategory) | "function(cat)  end"
    function o:ForEachCategory(consumerFn)
        assert(consumerFn, libName .. ":: consumerFn function is missing.")

        ---@param name Name
        for _, name in pairs(self.sortedCategories) do
            --- @type Kapresoft_LogCategory
            local cat = self.categories[name]
            if cat and not IsDefaultCategory(cat.name) then consumerFn(cat) end
        end
    end

end; CategoryMixinMethods(L)

--[[-----------------------------------------------------------------------------
Methods: LoggerMixinV3
-------------------------------------------------------------------------------]]
--- @param o Kapresoft_CategoryLoggerMixin
local function PropsAndMethods(o)

    --- @param name string The log name
    --- @param category Kapresoft_LogCategory|string|nil Category name
    --- @param opts Kapresoft_CategoryMixin_Options
    function o:Init(name, category, opts)
        local thisName = "Kapresoft_CategoryLoggerMixin"
        local addonName = (category and category.addonName) or ''
        assert(addonName, thisName .. ":: addon name is required.")
        assert(opts, thisName .. ":: opts(options) is required.")

        local prefix = GetLogPrefix(ch, addonName, name) .. " %s:: "
        assert(name, sformat(prefix .. "Log name is missing.", thisName))
        assert(category, sformat(prefix .. "LogCategoryV3 is required.", thisName))
        assert(type(name) == 'string', sformat(prefix .. "Expected log name to be a string but got: %s", thisName, tostring(name)))
        assert(opts.levelSupplierFn, sformat(prefix .. "Log level supplier function is required.", thisName))
        assert(opts.enabledCategoriesSupplierFn, prefix .. "Enabled categories supplier function is required.", thisName)

        self.name = name
        self.category = nil
        self.levelSupplierFn = opts.levelSupplierFn
        self.printerFn = opts.printerFn
        self.enabled = opts.enabled == true
        self.enabledCategoriesSupplierFn = opts.enabledCategoriesSupplierFn

        local catName = category.name
        local catSN = category.short

        self.categorySuffix = ''

        --- @type string|boolean
        local validCategory = strl(catName) > 0 and stru(catName)
        --- @type string|boolean
        local validCategorySN = strl(catSN) > 0 and stru(catSN)
        if validCategorySN then self.categoryShort = validCategorySN end
        if validCategory then
            self.category = validCategory
            self.categorySuffix = self.categoryShort or self.category
        end

        local pfn, logfn = logStrategy2(self)
        self.logfn = logfn

        local consoleHelper = (opts.consoleColors and KC:NewConsoleHelper(opts.consoleColors)) or ch
        self.logPrefix = pfn(consoleHelper, addonName, name, self.categorySuffix)
    end

    --- @param name string The log name
    --- @param cat string|Kapresoft_LogCategory|nil LogCategoryV3 or string category name
    --- @param opts Kapresoft_CategoryMixin_Options
    --- @return Kapresoft_CategoryLoggerMixin
    function o:New(name, cat, opts)
        return K:CreateAndInitFromMixin(LL, name, cat, opts)
    end

    --- @param level Kapresoft_LogLevel
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    --- @param logSuffix string | "'INFO" | "'WARN" | "'DEBUG'"
    function o:log(level, strOrCallbackFn, logSuffix)
        if not self:ShouldLog(level) then return end
        local val
        if type(strOrCallbackFn) == 'function' then val = safeFormat(strOrCallbackFn())
        else val = tostring(strOrCallbackFn) end
        self.logfn(self.logPrefix, val, self.categorySuffix, logSuffix)
    end

    --- Always Log: This is used for AddOn console commands
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:a(strOrCallbackFn)
        local val
        if type(strOrCallbackFn) == 'function' then val = safeFormat(strOrCallbackFn())
        else val = tostring(strOrCallbackFn) end
        self.logfn(self.logPrefix, val, self.categorySuffix)
    end

    --- Verbose, Always Log
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:v(strOrCallbackFn)
        if self.enabled ~= true then return false end

        local val
        if type(strOrCallbackFn) == 'function' then val = safeFormat(strOrCallbackFn())
        else val = tostring(strOrCallbackFn) end
        self.logfn(self.logPrefix, val, self.categorySuffix, 'V')
    end

    --- Verbose, Always Log
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:vv(strOrCallbackFn)
        if self.enabled ~= true then return false end

        local val
        if type(strOrCallbackFn) == 'function' then val = safeFormat(strOrCallbackFn())
        else val = tostring(strOrCallbackFn) end
        self.logfn(self.logPrefix, val, self.categorySuffix)
    end

    --- ERROR_LEVEL = 5
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:e(strOrCallbackFn)
        self:log(ERROR_LEVEL, strOrCallbackFn, ch:FormatColor('FF0000','ERROR'))
    end
    --- WARN_LEVEL = 10
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:w(strOrCallbackFn)
        self:log(WARN_LEVEL, strOrCallbackFn, ch:FormatColor('FFA500','WARN'))
    end
    --- INFO_LEVEL = 15
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:i(strOrCallbackFn)
        self:log(INFO_LEVEL, strOrCallbackFn)
    end
    --- DEBUG_LEVEL = 20
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:d(strOrCallbackFn)
        self:log(DEBUG_LEVEL, strOrCallbackFn, 'D')
    end
    --- FINE_LEVEL = 25
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:f1(strOrCallbackFn)
        self:log(FINE_LEVEL, strOrCallbackFn, 'F1')
    end
    --- FINER_LEVEL = 30
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn  | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:f2(strOrCallbackFn)
        self:log(FINER_LEVEL, strOrCallbackFn, 'F2')
    end
    --- FINEST_LEVEL = 35
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:f3(strOrCallbackFn)
        self:log(FINEST_LEVEL, strOrCallbackFn, 'F3')
    end
    --- TRACE_LEVEL = 50
    --- @param strOrCallbackFn string|Kapresoft_LogCallbackFn | "'Hello thar'" | "function() return 'hello' end"| "function() return 'hello: %s', 'thar' end"
    function o:t(strOrCallbackFn)
        self:log(TRACE_LEVEL, strOrCallbackFn, 'T')
    end

    --- @param level number The level configured by the log function call
    function o:ShouldLog(level)
        assert(type(level) == 'number', 'Level should be a number between 1 and 100')
        if ERROR_LEVEL == level or WARN_LEVEL == level then return true end
        if self.enabled ~= true then return false end
        if self.levelSupplierFn() < level then return false end
        return self:IsCategoryEnabled()
    end

    function o:IsCategoryEnabled()
        if self.category == nil or strl(self.category) == 0
                or IsDefaultCategory(self.category) then return true end
        local cats = self.enabledCategoriesSupplierFn()
        local val = cats[self.category] or false
        local enabled = val == true or val == 1
        return enabled
    end

    local mt = { __tostring = function() return MAJOR end }; setmetatable(L, mt)

end; PropsAndMethods(LL)

