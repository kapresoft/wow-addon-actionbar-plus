--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub

--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
--- @type string
local addonName
--- @type Kapresoft_Base_Namespace
local kns
addonName, kns = ...

local GC = kns.O.GlobalConstants; kns.GC = GC
local K = kns.Kapresoft_LibUtil
local KO = K.Objects

--[[-----------------------------------------------------------------------------
Global Variables: Replace with Addon-specific global vars
-------------------------------------------------------------------------------]]
---@param val EnabledInt|boolean|nil
---@param key string|nil Category name
---@return table<string, string>
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
--[[-----------------------------------------------------------------------------
Log Categories
-------------------------------------------------------------------------------]]
local LogCategories = {
    --- @type Kapresoft_LogCategory
    DEFAULT = 'DEFAULT',
    --- @type LogCategory
    ADDON = "AD",
    --- @type LogCategory
    API = "AP",
    --- @type LogCategory
    BAG = "BG",
    --- @type LogCategory
    BUTTON = "BN",
    --- @type LogCategory
    DEV = "DV",
    --- @type LogCategory
    DRAG_AND_DROP = "DD",
    --- @type LogCategory
    EVENT = "EV",
    --- @type LogCategory
    FRAME = "FR",
    --- @type LogCategory
    ITEM = "IT",
    --- @type LogCategory
    MESSAGE = "MS",
    --- @type LogCategory
    MOUNT = "MT",
    --- @type LogCategory
    PET = "PT",
    --- @type LogCategory
    PROFILE = "PR",
    --- @type LogCategory
    SPELL = "SP",
    --- @type LogCategory
    UNIT = "UN",
}

--[[-----------------------------------------------------------------------------
Type: LibPackMixin
-------------------------------------------------------------------------------]]
--- @class LibPackMixin
--- @field O GlobalObjects
--- @field name Name The addon name
local LibPackMixin = { };

---@param o LibPackMixin
local function LibPackMixinMethods(o)

    --- Create a new instance of AceEvent or embed to an obj if passed
    --- @return AceEvent
    --- @param obj|nil The object to embed or nil
    function o:AceEvent(obj) return self.O.AceLibrary.AceEvent:Embed(obj or {}) end

    --- Create a new instance of AceBucket or embed to an obj if passed
    --- @return AceBucket
    --- @param obj|nil The object to embed or nil
    function o:AceBucket(obj) return self.LibStubAce('AceBucket-3.0'):Embed(obj or {}) end

    function o:AceLocale() return LibStub("AceLocale-3.0"):GetLocale(self.name, true) end

end; LibPackMixinMethods(LibPackMixin)

--- @class __GameVersionMixin
local GameVersionMixin = {}

---@param o __GameVersionMixin | Namespace
---@param ns NameSpaceFn
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

--- @class __NamespaceLoggerMixin
local NamespaceLoggerMixin = {}
---@param o __NamespaceLoggerMixin
---@param ns NameSpaceFn
local function NamespaceLoggerMethods(o)

    local CategoryLogger = KO.CategoryMixin
    CategoryLogger:Configure(addonName, LogCategories, {
        consoleColors = GC.C.CONSOLE_COLORS,
        levelSupplierFn = function() return __logLevel() end,
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
        ---@param v boolean|nil
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

--- @param ns Namespace
--- @return LocalLibStub
local function NewLocalLibStub(ns)
    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = ns:K().Objects.LibStubMixin:New(ns.name, 1.0,
            function(name, newLibInstance) ns:Register(name, newLibInstance) end)
    return LocalLibStub
end

--- @class __NamespaceOther
--- @field gameVersion GameVersion

--- @alias GameVersion string | "'classic'" | "'tbc_classic'" | "'wotlk_classic'" | "'retail'"
--- @alias Namespace __Namespace | __NamespaceOther | __GameVersionMixin | __NamespaceLoggerMixin

--- @return Namespace
local function CreateNamespace(...)
    --- @type string
    local addon
    --- @class __Namespace : LibPackMixin
    --- @field gameVersion GameVersion
    --- @field GC GlobalConstants
    --- @field LibStub LocalLibStub
    --- @field LibStubAce LibStub
    --- @field O GlobalObjects
    local ns

    addon, ns = ...

    --- @return Kapresoft_LibUtil
    function ns:K() return ns.Kapresoft_LibUtil end

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

    ns:K():Mixin(ns, LibPackMixin, GameVersionMixin, NamespaceLoggerMixin)

    --- @param o __Namespace | Namespace
    local function Methods(o)

        --- @return Profile_Config
        function o.p() return ns.db.profile end

        ----- @return BooleanOptional
        --function o:IsLoggingEnabled() return true == ns.O.GlobalConstants.F.ENABLE_LOGGING end
        ----- @return BooleanOptional
        --function o:IsLoggingDisabled() return true ~= ns.O.GlobalConstants.F.ENABLE_LOGGING end

        --- @return CursorUtil
        ---@param cursorInfo CursorInfo Optional cursorInfo instance
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
        --- @param o any The object to register
        function o:Register(name, o)
            if not (name or o) then return end
            ns.O[name] = o
        end

    end; Methods(ns)

    ns.LibStubAce = LibStub
    ns.LibStub = NewLocalLibStub(ns)

    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    --- print(ns.name .. '::Namespace:: pformat:', pformat)
    --- Global Function
    pformat = pformat or ns.pformat

    return ns
end

if kns.name then return end

--- @type Namespace
ABP_NS = CreateNamespace(...)

