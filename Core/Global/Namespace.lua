--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, stru, strl = string.format, string.upper, string.len

--- @type LibStub
local LibStub = LibStub

--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
--- @type string
local addonName
--- @type BaseNamespace
local kns
addonName, kns = ...

local GC = kns.O.GlobalConstants; kns.GC = GC
local K = kns.Kapresoft_LibUtil
local KO = K.Objects

--[[-----------------------------------------------------------------------------
Global Variables: Replace with Addon-specific global vars
-------------------------------------------------------------------------------]]
--- @param val EnabledInt|boolean|nil
--- @param key string|nil Category name
--- @return table<string, string>
local function __categories(key, val)
    if key then ABP_DEBUG_ENABLED_CATEGORIES[key] = val end
    return ABP_DEBUG_ENABLED_CATEGORIES or {}
end
local function __category(key)
    ABP_DEBUG_ENABLED_CATEGORIES = ABP_DEBUG_ENABLED_CATEGORIES or {}
    return ABP_DEBUG_ENABLED_CATEGORIES[key]
end
--- @param val number|nil Optional log level to set
--- @return number The new log level passed back
local function __logLevel(val)
    if val then ABP_LOG_LEVEL = val end
    return ABP_LOG_LEVEL or 0
end

---@param obj any The object to merge with "tbl" arg
---@param tbl table The table to merge with "obj" arg
local function mergeArgs(libName, obj, tbl)
    assert(obj, "Object to merge is nil for lib=" .. libName)
    local a = { obj };
    for _, val in ipairs(tbl) do if val then table.insert(a, val) end end
    return a
end
--[[-----------------------------------------------------------------------------
Log Categories
-------------------------------------------------------------------------------]]
local LogCategories = {
    --- @type Kapresoft_LogCategory
    DEFAULT = 'DEFAULT',
    --- @type Kapresoft_LogCategory
    ADDON = "AD",
    --- @type Kapresoft_LogCategory
    API = "AP",
    --- @type Kapresoft_LogCategory
    BAG = "BG",
    --- @type Kapresoft_LogCategory
    BUTTON = "BN",
    --- @type Kapresoft_LogCategory
    DEV = "DV",
    --- @type Kapresoft_LogCategory
    DRAG_AND_DROP = "DD",
    --- @type Kapresoft_LogCategory
    EVENT = "EV",
    --- @type Kapresoft_LogCategory
    EQUIPMENT = "EQ",
    --- @type Kapresoft_LogCategory
    FRAME = "FR",
    --- @type Kapresoft_LogCategory
    ITEM = "IT",
    --- @type Kapresoft_LogCategory
    MESSAGE = "MS",
    --- @type Kapresoft_LogCategory
    MESSAGE_TRACE = "MT",
    --- @type Kapresoft_LogCategory
    MOUNT = "MT",
    --- @type Kapresoft_LogCategory
    PET = "PT",
    --- @type Kapresoft_LogCategory
    PROFILE = "PR",
    --- @type Kapresoft_LogCategory
    SPELL = "SP",
    --- @type Kapresoft_LogCategory
    TRACE = "TR",
    --- @type Kapresoft_LogCategory
    UNIT = "UN",
}
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param ns Namespace
--- @return LocalLibStub
local function NewLocalLibStub(ns)
    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = ns:K().Objects.LibStubMixin:New(ns.name, 1.0,
            function(name, newLibInstance) ns:Register(name, newLibInstance) end)
    return LocalLibStub
end

local function safeArgs(...)
    local a = {...}
    for i, elem in ipairs(a) do
        if type(elem) == "table" then
            a[i] = tostring(elem)
        end
    end
    return a
end

--- @param ns Namespace
--- @param logger Kapresoft_CategoryLoggerMixin
--- @param callback fun(msg:string, source:string, ...:any)
local function CreateTraceFn(ns, logger, callback)
    assert(callback, "callback function is required.")
    local fn = callback
    if ns.enableEventTrace == true then
        fn = function(msg, source, ...)
            local a = safeArgs(...)
            if type(source) == 'table' then source = tostring(source) end
            logger:t(function() return "MSG:R[%s] src=%s args=%s", msg, source, a end)
            callback(msg, source, ...)
        end
    end
    return fn
end

--- @class __GameVersionMixin
local GameVersionMixin = {}

--- @param o __GameVersionMixin | Namespace
local function GameVersionMethods(o)
    -- todo: get rid of ns()
    --- @return GameVersion
    function o:IsVanilla() return self.gameVersion == 'classic' end
    --- @return GameVersion
    function o:IsTBC() return self.gameVersion == 'tbc_classic' end
    --- @return GameVersion
    function o:IsWOTLK() return self == 'wotlk_classic' end
    --- @return GameVersion
    function o:IsRetail() return self.gameVersion == 'retail' end
end; GameVersionMethods(GameVersionMixin)

--- @class __NamespaceLoggerMixin : BaseNamespace
local NamespaceLoggerMixin = {}
--- @param o __NamespaceLoggerMixin
local function NamespaceLoggerMethods(o)

    local CategoryLogger = KO.CategoryMixin:New()
    CategoryLogger:Configure(addonName, LogCategories, {
        consoleColors = GC.C.CONSOLE_COLORS,
        levelSupplierFn = function() return __logLevel() end,
        printerFn = kns.printerFn,
        enabled = kns.debug.flag.debugging == true,
        enabledCategoriesSupplierFn = function() return __categories() end,
    })

    --- @private
    o.LogCategory = CategoryLogger

    --- @deprecated Don't use
    --- @return BooleanOptional
    function o:IsLoggingEnabled() return true == GC.F.ENABLE_LOGGING end
    --- @deprecated Don't use
    --- @return BooleanOptional
    function o:IsLoggingDisabled() return true ~= GC.F.ENABLE_LOGGING end

    --- @return number
    function o:GetLogLevel() return __logLevel() end
    --- @param level number
    function o:SetLogLevel(level) __logLevel(level) end

    --- @param name string | "'ADDON'" | "'BAG'" | "'BUTTON'" | "'DRAG_AND_DROP'" | "'EVENT'" | "'FRAME'" | "'ITEM'" | "'MESSAGE'" | "'MOUNT'" | "'PET'" | "'PROFILE'" | "'SPELL'"
    --- @param v boolean|number | "1" | "0" | "true" | "false"
    function o:SetLogCategory(name, val)
        assert(name, 'Debug category name is missing.')
        --- @param v boolean|nil
        local function normalizeVal(v) if v == 1 or v == true then return 1 end; return 0 end
        __categories(name, normalizeVal(val))
    end
    --- @return boolean
    function o:IsLogCategoryEnabled(name)
        assert(name, 'Debug category name is missing.')
        local val = __category(name)
        return val == 1 or val == true
    end

    function o.LogCategories() return o.LogCategory():GetCategories() end
    function o:LC() return LogCategories end
    function o:CreateDefaultLogger(moduleName) return LogCategories.DEFAULT:NewLogger(moduleName) end

end; NamespaceLoggerMethods(NamespaceLoggerMixin)

--[[-----------------------------------------------------------------------------
Namespace: Create
-------------------------------------------------------------------------------]]
--- @class __NamespaceOther
--- @field gameVersion GameVersion

--- @alias GameVersion string | "'classic'" | "'tbc_classic'" | "'wotlk_classic'" | "'retail'"
--- @alias Namespace __Namespace | __NamespaceOther | AceLibraryMixin | __GameVersionMixin | __NamespaceLoggerMixin

--- @return Namespace
local function CreateNamespace(...)
    --- @type string
    local addon
    --- @class __Namespace : AceLibraryMixin
    --- @field debug DebugSettings
    --- @field gameVersion GameVersion
    --- @field GC GlobalConstants
    --- @field LibStub LocalLibStub
    --- @field LibStubAce LibStub
    --- @field O GlobalObjects
    --- @field ConfigDialogControllerEventFrame ConfigDialogControllerEventFrame
    local ns

    addon, ns = ...

    --- @return Kapresoft_LibUtil
    function ns:K() return ns.Kapresoft_LibUtil end
    --- @return Kapresoft_LibUtil_Objects
    function ns:KO() return KO end

    --- this is in case we are testing outside of World of Warcraft
    addon = addon or GC.C.ADDON_NAME

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- The AddOn Name, i.e. "ActionbarPlus"
    --- @type string
    ns.name = addon
    --- @type ActionbarPlus_AceDB
    ns.db = ns.db or {}

    --- @type Module
    ns.M = ns.M or {}

    --- @type fun(fmt:string, ...)|fun(val:string)
    ns.pformat = ns:K().pformat:B()

    ns.features = {
        enableV2 = false,
    }
    ns.playerBuffs = ns.playerBuffs or {}

    --- script handlers
    ns.xml = {}

    ns:K():Mixin(ns, ns.O.AceLibraryMixin, GameVersionMixin, NamespaceLoggerMixin)

    --- @param o __Namespace | Namespace
    local function PropsAndMethods(o)

        o.sformat = string.format

        --- Used in XML files to hook frame events: OnLoad and OnEvent
        --- Example: <OnLoad>ABP_NS.H.[TypeName]_OnLoad(self)</OnLoad>
        o.H = {}

        --- @return ActionbarPlus
        function o:a() return ABP end
        --- @return Profile_Config
        function o:p() return self.db.profile end

        --- @return CursorUtil
        --- @param cursorInfo CursorInfo Optional cursorInfo instance
        function o:CreateCursorUtil(cursorInfo)
            local _cursorInfo = cursorInfo or o.O.API:GetCursorInfo()
            return self:K():CreateAndInitFromMixin(o.O.CursorMixin, _cursorInfo)
        end

        --- @param start number
        --- @param increment number
        --- @return Kapresoft_Incrementer
        function o:CreateIncrementer(start, increment) return self:K():CreateIncrementer(start, increment) end

        --- @return Kapresoft_LibUtil_SequenceMixin
        --- @param startingSequence number|nil
        function o:CreateSequence(startingSequence)
            return self:K().Objects.SequenceMixin:New(startingSequence)
        end

        --- TODO: Update safecall to handle LoggerMixinV2
        --- @param libName Name
        --- @return Kapresoft_LibUtil_Safecall
        function o:CreateSafecall(libName)
            local logger = o.O.Logger:NewLogger(libName); return o.O.Safecall:New(logger)
        end

        --- @param moduleName string The module name, i.e. Logger
        --- @return string The complete module name, i.e. 'ActionbarPlus-Logger-1.0'
        function o:LibName(moduleName) return self.name .. '-' .. moduleName .. '-1.0' end

        --- @param name string The module name
        --- @param obj any The object to register
        function o:Register(name, obj)
            local nameAssertMsg = sformat('ns:Register(name, val): Library name is invalid. Expected type to be string but was: %s', type(name))
            assert(type(name) == 'string' , nameAssertMsg)

            local objAssertMsg = sformat('ns:Register(name, val): The library object value for [%s] is invalid. Expected table type but was [%s].',
                    tostring(name), type(obj))
            assert(type(obj) == 'table', objAssertMsg)

            ns.O[name] = obj
        end

        --- Plain old library
        --- @return any The newly created library
        function o:NewLibStd(libName, ...)
            assert(libName, "LibName is required")
            local newLib = {}
            local len = select("#", ...)
            if len > 0 then newLib = self:K():Mixin({}, ...) end
            newLib.mt = { __tostring = function() return libName  end }
            setmetatable(newLib, newLib.mt)
            self:Register(libName, newLib)
            return newLib
        end

        --- @param libName Name The library module name
        --- @return ModuleV2
        function o:NewLib(libName, ...) return self.O.ModuleV2Mixin:New(libName, ...) end

        --- @param libName Name The library module name
        --- @return ControllerV2
        function o:NewController(libName, ...) return self.O.ModuleV2Mixin:New(libName, self.O.ActionBarHandlerMixin, ...) end

    end; PropsAndMethods(ns)

    ns.LibStubAce = LibStub
    ns.LibStub = NewLocalLibStub(ns)

    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    --- print(ns.name .. '::Namespace:: pformat:', pformat)
    --- Global Function
    pformat = pformat or ns.pformat

    ABP_H = ns.H

    return ns
end

if kns.name then return end

--- @type Namespace
ABP_NS = CreateNamespace(...)

