--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
--- treat this as a base generic namespace (not the Namespace type)
local _ns = select(2, ...)
--- @type LibStub
local LibStub = LibStub
--[[-----------------------------------------------------------------------------
Type: LibPackMixin
-------------------------------------------------------------------------------]]
--- @class LibPackMixin
--- @field O GlobalObjects
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
end; LibPackMixinMethods(LibPackMixin)

--- @alias NameSpaceFn fun() : Namespace
--- @return Namespace
local function nsfn() return ABP_NS end

--- @class __GameVersionMixin
local GameVersionMixin = {}

---@param o __GameVersionMixin
---@param ns NameSpaceFn
local function GameVersionMethods(o, ns)
    --- @return GameVersion
    function o:IsVanilla() return ns().gameVersion == 'classic' end
    --- @return GameVersion
    function o:IsTBC() return ns().gameVersion == 'tbc_classic' end
    --- @return GameVersion
    function o:IsWOTLK() return ns() == 'wotlk_classic' end
    --- @return GameVersion
    function o:IsRetail() return ns().gameVersion == 'retail' end
end; GameVersionMethods(GameVersionMixin, nsfn)

--- @class __NamespaceLoggerMixin
local NamespaceLoggerMixin = {}
---@param o __NamespaceLoggerMixin
---@param ns NameSpaceFn
local function NamespaceLoggerMethods(o, ns)
    ABP_DEBUG_ENABLED_CATEGORIES = ABP_DEBUG_ENABLED_CATEGORIES or {}

    local function LoggerMixin() return ns().O.LoggerMixinV2 end

    --- @return BooleanOptional
    function o:IsLoggingEnabled() return true == ns().O.GlobalConstants.F.ENABLE_LOGGING end
    --- @return BooleanOptional
    function o:IsLoggingDisabled() return true ~= ns().O.GlobalConstants.F.ENABLE_LOGGING end

    --- @param name string | "'ADDON'" | "'BAG'" | "'BUTTON'" | "'DRAG_AND_DROP'" | "'EVENT'" | "'FRAME'" | "'ITEM'" | "'MESSAGE'" | "'MOUNT'" | "'PET'" | "'PROFILE'" | "'SPELL'"
    --- @param v boolean|number | "1" | "0" | "true" | "false"
    function o:SetLogCategory(name, val)
        assert(name, 'Debug category name is missing.')
        ---@param v boolean|nil
        local function normalizeVal(v) if v == 1 or v == true then return 1 end; return 0 end
        ABP_DEBUG_ENABLED_CATEGORIES[name] = normalizeVal(val)
    end
    function o:IsLogCategoryEnabled(name)
        assert(name, 'Debug category name is missing.')
        local val = ABP_DEBUG_ENABLED_CATEGORIES[name]
        return val == 1 or val == true
    end
    function o.LogCategory() return LoggerMixin().Category end
    function o.LogCategories() return o.LogCategory():GetCategories() end
    function o:CreateDefaultLogger(moduleName) return LoggerMixin():New(moduleName) end

end; NamespaceLoggerMethods(NamespaceLoggerMixin, nsfn)

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
    --- @field O GlobalObjects
    local ns

    addon, ns = ...

    --- @return Kapresoft_LibUtil
    function ns:K() return ns.Kapresoft_LibUtil end

    --- this is in case we are testing outside of World of Warcraft
    addon = addon or ABP_GlobalConstants.C.ADDON_NAME

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- The AddOn Name, i.e. "ActionbarPlus"
    --- @type string
    ns.name = addon
    --- @type ActionbarPlus_AceDB
    ns.db = ns.db or {}

    --- @type Module
    ns.M = ns.M or {}

    ns.pformat = ns:K().pformat:B()

    ns:K():Mixin(ns, LibPackMixin, GameVersionMixin, NamespaceLoggerMixin)

    ns.features = {
        enableV2 = false,
    }
    ns.playerBuffs = ns.playerBuffs or {}

    --- script handlers
    ns.xml = {}

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

        --- ### Namespace Helper Function
        --- ```
        --- local ns, O, GC, M, LibStub = ABP_NS:ns(...)
        --- ```
        --- @return Namespace, GlobalObjects, GlobalConstants, Module, LocalLibStub
        function o:namespace(...)
            --- @type Namespace
            local _, n = ...; return n, n.O, n.O.GlobalConstants, n.M, n.O.LibStub
        end

    end; Methods(ns)

    ns.LibStubAce = LibStub
    ns.LibStub = NewLocalLibStub(ns)
    ns.O.LibStub = ns.LibStub

    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    return ns
end

if _ns.name then return end

--- @type Namespace
ABP_NS = CreateNamespace(...)

--- @return Namespace
function abp_ns(...) local _, namespace = ...; return namespace end
