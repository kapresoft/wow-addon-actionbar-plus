--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'CategoryLoggerMixin'
--- @class CategoryLoggerMixin
--- @field LogCategories LogCategories
local L = {}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param val EnabledInt|boolean|nil
--- @param key string|nil Category name
--- @return table<string, string>
local function __GetCategories(key, val)
    if key then ABP_DEBUG_ENABLED_CATEGORIES[key] = val end
    return ABP_DEBUG_ENABLED_CATEGORIES or {}
end

--- @param key string The category key
--- @return Enabled
local function __IsEnabledCategory(key)
    ABP_DEBUG_ENABLED_CATEGORIES = ABP_DEBUG_ENABLED_CATEGORIES or {}
    return ABP_DEBUG_ENABLED_CATEGORIES[key]
end

--- @param val number|nil Optional log level to set
--- @return number The new log level passed back
local function __GetLogLevel(val)
    if val then ABP_LOG_LEVEL = val end
    return ABP_LOG_LEVEL or 0
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @type CategoryLoggerMixin
local o = L; do
    --- @param namesp __Namespace
    --- @param logCategories LogCategories
    function o:Configure(namesp, logCategories)
        assert(logCategories, 'CategoryLoggerMixin:Mixin(): LogCategories is required.')
        local C = namesp.GC.C
        namesp.LogCategories = function() return logCategories end
        local CategoryLogger = namesp:KO().CategoryMixin:New()
        CategoryLogger:Configure(namesp.addon, logCategories, {
            consoleColors = C.CONSOLE_COLORS,
            levelSupplierFn = function() return __GetLogLevel() end,
            enabledCategoriesSupplierFn = function() return __GetCategories() end,
            printerFn = ns.print,
            enabled = namesp:IsDev(),
        })
        namesp.CategoryLogger = function() return CategoryLogger end
        namesp:K():Mixin(namesp, o)
        namesp.Mixin = nil
    end

    --- @return number
    function o:GetLogLevel() return __GetLogLevel() end
    --- @param level number
    function o:SetLogLevel(level) __GetLogLevel(level) end

    --- @param name string | "'ADDON'" | "'BAG'" | "'BUTTON'" | "'DRAG_AND_DROP'" | "'EVENT'" | "'FRAME'" | "'ITEM'" | "'MESSAGE'" | "'MOUNT'" | "'PET'" | "'PROFILE'" | "'SPELL'"
    --- @param v boolean|number | "1" | "0" | "true" | "false"
    function o:SetLogCategory(name, val)
        assert(name, 'Debug category name is missing.')
        ---@param v boolean|nil
        local function normalizeVal(v) if v == 1 or v == true then return 1 end; return 0 end
        __GetCategories(name, normalizeVal(val))
    end
    --- @return boolean
    function o:IsLogCategoryEnabled(name)
        assert(name, 'Debug category name is missing.')
        local val = __IsEnabledCategory(name)
        return val == 1 or val == true
    end
    --- @return LogCategories
    function o:LC() return self.LogCategories() end
    --- @return Kapresoft_CategoryLoggerMixin
    function o:CreateDefaultLogger(moduleName) return self:LC().DEFAULT:NewLogger(moduleName) end

    ns.CategoryLoggerMixin = o
end
