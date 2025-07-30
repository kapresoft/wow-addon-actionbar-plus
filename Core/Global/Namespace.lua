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
--- @type CoreNamespace
local kns
addonName, kns = ...

local GC = kns.GC
local KO = kns:KO()

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
--- @class LogCategories
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
    MACRO = "MA",
    --- @type Kapresoft_LogCategory
    MESSAGE = "MS",
    --- @type Kapresoft_LogCategory
    MESSAGE_TRACE = "MT",
    --- @type Kapresoft_LogCategory
    MOUNT = "MN",
    --- @type Kapresoft_LogCategory
    PET = "PT",
    --- @type Kapresoft_LogCategory
    PROFILE = "PR",
    --- @type Kapresoft_LogCategory
    SPELL = "SP",
    --- @type Kapresoft_LogCategory
    TALENT = "TA",
    --- @type Kapresoft_LogCategory
    SPELL_AUTO_REPEAT = "SPA",
    --- @type Kapresoft_LogCategory
    SPELL_USABLE = "SPU",
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

--[[-----------------------------------------------------------------------------
Namespace: Create
-------------------------------------------------------------------------------]]

--- @alias Namespace __Namespace | AceEventWithTraceMixin | CategoryLoggerMixin | Kapresoft_LibUtil_NamespaceAceLibraryMixin

--- @return Namespace
local function CreateNamespace(...)
    --- @type string
    local addon

    --- @class __Namespace : CoreNamespace
    --- @field debug DebugSettings
    --- @field LibStub LocalLibStub
    --- @field LibStubAce LibStub
    --- @field O GlobalObjects
    --- @field barBindings table<string, BindingInfo>
    --- @field CategoryLoggerMixin CategoryLoggerMixin
    --- @field ConfigDialogControllerEventFrame ConfigDialogControllerEventFrame
    --- @field uie fun(self:__Namespace) : UIError
    local ns = select(2, ...)

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

    ns:K():MixinWithDefExc(ns, ns.O.AceEventWithTraceMixin)
    ns.CategoryLoggerMixin:Configure(ns, LogCategories)

    --- @param o __Namespace | Namespace
    local function PropsAndMethods(o)

        o.sformat = string.format

        --- Used in XML files to hook frame events: OnLoad and OnEvent
        --- Example: <OnLoad>ABP_NS.H.[TypeName]_OnLoad(self)</OnLoad>
        o.H = {}

        o.barBindings = nil

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
            local logger = o.O.Logger:NewLogger(libName); return ns:Safecall():New(logger)
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
        --- @return any The newly created library object
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

        --- Use this for plain old mixins
        --- @param libName Name The library module name
        --- @return any The newly created mixin library object
        function o:NewMixin(libName, ...) return self:NewLibStd(libName, ...) end

        --- Use this for library modules that require addon event hooks
        --- @param libName Name The library module name
        --- @return ModuleV2
        function o:NewLib(libName, ...) return self.O.ModuleV2Mixin:New(libName, ...) end

        --- @param libName Name The library module name
        --- @return ControllerV2
        function o:NewController(libName, ...) return self.O.ModuleV2Mixin:New(libName, self.O.ActionBarHandlerMixin, ...) end

        --- @param btnIndex Index
        --- @param activeSpec number Example values: 1=primary, 2=secondary
        --- @return string The secondary spec button name (i.e. b1_2 for button 1)
        function o:GetSpecConfigName(btnIndex, activeSpec)
            return sformat('b%s_%s', btnIndex, activeSpec or 1)
        end

        --- @param btnName Name
        --- @return string
        function o:GetPrimarySpecButtonConfigName(btnName) return btnName end

        --- @param btnIndex Index
        --- @return string The secondary spec button name (i.e. b1_2 for button 1)
        function o:GetSecondarySpecConfigName(btnIndex)
            return self:GetSpecConfigName(btnIndex, 2)
        end

        --- @param btnName Name
        --- @param btnIndex Index
        --- @return string
        function o:ButtonConfigName(btnName, btnIndex)
            local c     = self.O.Compat
            local bName = btnName
            if not c:IsMultiSpecEnabled() or c:IsPrimarySpec() then return bName end
            assert(btnIndex, 'Namespace:: Unexpected error retrieving button index number.')

            local activeSpec = c:GetSpecializationID()
            bName = self:GetSpecConfigName(btnIndex, activeSpec)
            return bName
        end

        --- @return table<string, BindingInfo>
        function o:RetrieveKeyBindingsMap()
            self.barBindings = self.O.WidgetMixin:GetBarBindingsMap()
            return self.barBindings
        end

        --- @param buttonUIName string This is the global UI name of the actionbar, i.e. ActionbarPlusF1Button1
        --- @return BindingInfo
        function o:Button_GetBindings(buttonUIName)
            assert(type(buttonUIName) == 'string', 'ButtonUIName is required.')

            if not self.barBindings then self:RetrieveKeyBindingsMap() end
            return type(self.barBindings) == 'table' and self.barBindings[buttonUIName]
        end

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
--- @type Namespace
ABP_NS = CreateNamespace(...)
