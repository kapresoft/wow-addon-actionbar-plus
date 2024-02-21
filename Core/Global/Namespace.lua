--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
local _addon, _ns = ...
local LibStub = LibStub

---This absolutely does NOTHING but make EmmyLua work better in IDEs for code
---completions.
--- @param o Namespace
local function Define_InterfaceMethods(o)

    --- @see CursorMixin.lua
    --- @return CursorUtil
    --function o:CreateCursorUtil() end

    --- @see UtilWrapper.lua
    --- @param start number
    --- @param increment number
    --- @return Kapresoft_Incrementer
    function o:CreateIncrementer(start, increment) end

end

Define_InterfaceMethods(_ns)

--- @type LibPackMixin
local LibPackMixin = {}
--- @return GlobalObjects, LocalLibStub
function LibPackMixin:LibPack() return self.O, self.O.LibStub end
--- @return GlobalObjects, GlobalConstants
function LibPackMixin:LibPack2() return self.O, self.O.GlobalConstants end
--- @generic A : AceEvent
--- @return A
function LibPackMixin:AceEvent() return self.O.AceLibrary.AceEvent:Embed({}) end
function LibPackMixin:AceEventEmbed(obj) return self.O.AceLibrary.AceEvent:Embed(obj) end
--- @return AceBucket
function LibPackMixin:AceBucket() return self.LibStubAce('AceBucket-3.0'):Embed({}) end

--- @return AceBucket
--- @param obj table
function LibPackMixin:AceBucketEmbed(obj)
    local AceBucket = self.LibStubAce('AceBucket-3.0'); if obj then AceBucket:Embed(obj) end
    return AceBucket
end
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
    local function LoggerMixin() return ns().O.LoggerMixinV2 end

    --- @return BooleanOptional
    function o:IsLoggingEnabled() return true == ns().O.GlobalConstants.F.ENABLE_LOGGING end
    --- @return BooleanOptional
    function o:IsLoggingDisabled() return true ~= ns().O.GlobalConstants.F.ENABLE_LOGGING end

    function o:CreateDefaultLogger(moduleName)
        return LoggerMixin():New(moduleName)
    end
    function o:CreateAddonLogger()
        return LoggerMixin():New(ns().name, 'addon', 'ad')
    end
    function o:CreateSpellLogger(moduleName)
        return LoggerMixin():New(moduleName, 'spell', 'sp')
    end
    function o:CreateFrameLogger(moduleName)
        return LoggerMixin():New(moduleName, 'frame', 'fr')
    end
    function o:CreateButtonLogger(moduleName)
        return LoggerMixin():New(moduleName, 'button', 'bn')
    end
    function o:CreateDragAndDropLogger(moduleName)
        return LoggerMixin():New(moduleName, 'drag_and_drop', 'dd')
    end
    function o:CreateItemLogger(moduleName)
        return LoggerMixin():New(moduleName, 'item', 'it')
    end
    function o:CreateBagLogger(moduleName)
        return LoggerMixin():New(moduleName, 'bag', 'bg')
    end
    function o:CreateMountLogger(moduleName)
        return LoggerMixin():New(moduleName, 'mount', 'mt')
    end
    function o:CreatePetLogger(moduleName)
        return LoggerMixin():New(moduleName, 'pet', 'pt')
    end
    function o:CreateUnitLogger(moduleName)
        return LoggerMixin():New(moduleName, 'unit', 'ua')
    end
    function o:CreateProfileLogger(moduleName)
        return LoggerMixin():New(moduleName, 'profile', 'pr')
    end
    function o:CreateEventLogger(moduleName)
        return LoggerMixin():New(moduleName, 'event', 'ev')
    end
    function o:CreateMessageLogger(moduleName)
        return LoggerMixin():New(moduleName, 'message', 'ms')
    end
end; NamespaceLoggerMethods(NamespaceLoggerMixin, nsfn)

--- @param ns Namespace
--- @return LocalLibStub
local function NewLocalLibStub(ns)
    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = ns:K().Objects.LibStubMixin:New(ns.name, 1.0,
            function(name, newLibInstance)
                --- @type Logger
                local loggerLib = LibStub(ns:LibName(ns.M.Logger))
                if loggerLib then
                    newLibInstance.logger = loggerLib:NewLogger(name)
                    newLibInstance.logger:log(30, 'New Lib: %s', newLibInstance.major)
                    function newLibInstance:GetLogger() return self.logger end
                end
                ns:Register(name, newLibInstance)
            end)
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
