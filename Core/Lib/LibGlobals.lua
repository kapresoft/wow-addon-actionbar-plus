-- log levels, 10, 20, (+10), 100
if type(ABP_PLUS_DB) ~= "table" then ABP_PLUS_DB = {} end
if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, unpack = string.format, unpack

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

-- ## Start Here ---
local Core = __K_Core
local LibStub = Core:LibPack()

-- ABP_LOG_LEVEL is also in use here
local ABP_PLUS_DB_NAME = 'ABP_PLUS_DB'
local addonName, versionFormat, logPrefix = Core:GetAddonInfo()

---@class Module
local M = {
    -- Libraries
    Logger = 'Logger',
    LogFactory = 'LogFactory',
    PrettyPrint = 'PrettyPrint',
    Table = 'Table',
    String = 'String',
    Assert = 'Assert',
    AceLibFactory = 'AceLibFactory',
    -- Constants
    CommonConstants = 'CommonConstants',
    -- Mixins
    Mixin = 'Mixin',
    ButtonMixin = 'ButtonMixin',
    ButtonProfileMixin = 'ButtonProfileMixin',
    -- Addons
    BaseAttributeSetter = 'BaseAttributeSetter',
    ButtonDataBuilder = 'ButtonDataBuilder',
    ButtonFactory = 'ButtonFactory',
    ButtonFrameFactory = 'ButtonFrameFactory',
    ButtonUI = 'ButtonUI',
    ButtonUIWidgetBuilder = 'ButtonUIWidgetBuilder',
    Config = 'Config',
    ItemAttributeSetter = 'ItemAttributeSetter',
    ItemDragEventHandler = 'ItemDragEventHandler',
    MacroAttributeSetter = 'MacroAttributeSetter',
    MacroDragEventHandler = 'MacroDragEventHandler',
    MacroEventsHandler = 'MacroEventsHandler',
    MacrotextAttributeSetter = 'MacrotextAttributeSetter',
    MacroTextureDialog = 'MacroTextureDialog',
    PickupHandler = 'PickupHandler',
    Profile = 'Profile',
    ProfileInitializer = 'ProfileInitializer',
    ReceiveDragEventHandler = 'ReceiveDragEventHandler',
    SpellAttributeSetter = 'SpellAttributeSetter',
    SpellDragEventHandler = 'SpellDragEventHandler',
    WidgetConstants = 'WidgetConstants',
    WidgetLibFactory = 'WidgetLibFactory',
    WidgetMixin = 'WidgetMixin',
}

---@class GlobalObjects
local GlobalObjectsTemplate = {
    ---@type AceLibFactory
    AceLibFactory = {},
    ---@type Assert
    Assert = {},
    ---@type BaseAttributeSetter
    BaseAttributeSetter = {},
    ---@type ButtonDataBuilder
    ButtonDataBuilder = {},
    ---@type ButtonFactory
    ButtonFactory = {},
    ---@type ButtonFrameFactory
    ButtonFrameFactory = {},
    ---@type ButtonMixin
    ButtonMixin = {},
    ---@type ButtonProfileMixin
    ButtonProfileMixin = {},
    ---@type ButtonUI
    ButtonUI = {},
    ---@type ButtonUIWidgetBuilder
    ButtonUIWidgetBuilder = {},
    ---@type CommonConstants
    CommonConstants = {},
    ---@type Config
    Config = {},
    ---@type ItemAttributeSetter
    ItemAttributeSetter = {},
    ---@type ItemDragEventHandler
    ItemDragEventHandler = {},
    ---@type LogFactory
    LogFactory = {},
    ---@type Logger
    Logger = {},
    ---@type MacroAttributeSetter
    MacroAttributeSetter = {},
    ---@type MacroDragEventHandler
    MacroDragEventHandler = {},
    ---@type MacroEventsHandler
    MacroEventsHandler = {},
    ---@type MacroTextureDialog
    MacroTextureDialog = {},
    ---@type MacrotextAttributeSetter
    MacrotextAttributeSetter = {},
    ---@type Mixin
    Mixin = {},
    ---@type PickupHandler
    PickupHandler = {},
    ---@type Profile
    Profile = {},
    ---@type ProfileInitializer
    ProfileInitializer = {},
    ---@type ReceiveDragEventHandler
    ReceiveDragEventHandler = {},
    ---@type SpellAttributeSetter
    SpellAttributeSetter = {},
    ---@type SpellDragEventHandler
    SpellDragEventHandler = {},
    ---@type String
    String = {},
    ---@type Table
    Table = {},
    ---@type WidgetConstants
    WidgetConstants = {},
    ---@type WidgetLibFactory
    WidgetLibFactory = {},
    ---@type WidgetMixin
    WidgetMixin = {},
}

---TODO: Add all constants here
---@class GlobalConstants
local C = {

    ALT = 'ALT',
    CTRL = 'CTRL',
    SHIFT = 'SHIFT',
    PICKUPACTION = 'PICKUPACTION',

    BOTTOMLEFT = 'BOTTOMLEFT',
    BOTTOMRIGHT = 'BOTTOMRIGHT',
    TOPLEFT = 'TOPLEFT',
    ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT',

    CLAMPTOBLACKADDITIVE = 'CLAMPTOBLACKADDITIVE',
    CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI',
    SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate',

    HIGHLIGHT_DRAW_LAYER = 'HIGHLIGHT',
    ARTWORK_DRAW_LAYER = 'ARTWORK',
    ABP_KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r',

}

---@class LibGlobals
local _L = {
    -- use whole number if no longer in beta
    name = addonName,
    addonName = addonName,
    version = GetAddOnMetadata(addonName, 'Version'),
    versionText = GetAddOnMetadata(addonName, 'X-Github-Project-Version'),
    dbName = ABP_PLUS_DB_NAME,
    versionFormat = versionFormat,
    logPrefix = logPrefix,
    C = C,
    M = M,
    ---@deprecated Use 'M'
    Module = M,
    mt = {
        __tostring = function() return addonName .. "::LibGlobals" end,
        __call = function (_, ...)
            --local libNames = {...}
            --print("G|libNames:", pformat(libNames))
            return __K_Core:Lib(...)
        end
    }
}
setmetatable(_L, _L.mt)

---@type LibGlobals
ABP_LibGlobals = _L

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function _pack(...) return { len = select("#", ...), ... } end
-----@xreturn GlobalObjects
--local function XCreateGlobalObjects()
--    local o = {}
--    for k,v in pairs(M) do o[k] = Core:Get(v) end
--    return o
--end

---@return GlobalObjects
local function CreateGlobalObjects(...)
    local a = {...}
    local o = {}
    if #a <= 0 then
        for k,v in pairs(M) do o[k] = Core:Get(v) end
    else
        for k,v in pairs(a) do o[v] = Core:Get(v) end
    end
    return o
end
_L.O = CreateGlobalObjects

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---local LibStub, M, G = ABP_LibGlobals:LibPack()
---@return LocalLibStub, Module, LibGlobals
function _L:LibPack() return LibStub, M, _L end

---### Get New Addon LibPack
---```
---local LibStub, Module, AceLibFactory, WidgetLibFactory, ProfileInitializer, LibGlobals = LibGlobals:LibPack_NewAddon()
---```
---@return LocalLibStub, Module, AceLibFactory, WidgetLibFactory, ProfileInitializer, LibGlobals
function _L:LibPack_NewAddon()
    local AceLibFactory, WidgetLibFactory, ProfileInitializer = self:Get(
            M.AceLibFactory, M.WidgetLibFactory, M.ProfileInitializer)
    return LibStub, M, AceLibFactory, WidgetLibFactory, ProfileInitializer, _L
end
---### Usage
---```
---local LibStub, M, P, LogFactory = ABP_LibGlobals:LibPack_NewLibrary()
---```
---@return LocalLibStub, Module, Profile, LogFactory
function _L:LibPack_NewLibrary()
    local Profile, LogFactory = self:Get(M.Profile, M.LogFactory)
    return LibStub, M, Profile, LogFactory
end

---### Example:
---local LibStub, Module, LogFactory, LibGlobals = LibGlobals:LibPack()
---@return LocalLibStub, Module, LogFactory, LibGlobals
function _L:LibPack_UI() return LibStub, M, self:Get(M.LogFactory), _L end

---```
---Example:
---local LibStub, Module, Core, LibGlobals = LibGlobals:LibPack_NewMixin()
---```
---@return LocalLibStub, Module, Core, LibGlobals
function _L:LibPack_NewMixin() return LibStub, M, Core, _L end

---@return AceLibFactory
function _L:LibPack_AceLibFactory() return _L:Get(M.AceLibFactory)  end

---### Usage:
---```
---local AceDB, AceDBOptions, AceConfig, AceConfigDialog = AceLibFactory:GetAddonAceLibs()
---```
---@return AceDB, AceDBOptions, AceConfig, AceConfigDialog
function _L:LibPack_AceAddonLibs()
    local alf = self:LibPack_AceLibFactory()
    return alf:GetAceDB(), alf:GetAceDBOptions(), alf:GetAceConfig(), alf:GetAceConfigDialog()
end

---### Example
---```
---local AceEvent, AceGUI, AceHook = G:LibPack_AceLibrary()
---```
---@return AceEvent, AceGUI, AceHook
function _L:LibPack_AceLibrary()
    ---@type AceLibFactory
    local AceLibFactory = self:Get(M.AceLibFactory)
    return AceLibFactory:GetAceEvent(), AceLibFactory:GetAceGUI(), AceLibFactory:GetAceHook()
end

---@param object any The target object
---@return any The mixed-in object
function _L:Mixin(object, ...) return self:LibPack_Mixin():Mixin(object, ...) end

---@return Mixin
function _L:LibPack_Mixin() return self:Get(M.Mixin) end
---@return ButtonProfileMixin
function _L:LibPack_ButtonProfileMixin() return self:Get(M.ButtonProfileMixin) end
---@return ButtonMixin
function _L:LibPack_ButtonMixin() return self:Get(M.ButtonMixin) end

---### Usage:
---```
---local pformat, ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()
---```
---@return pformat, function
function _L:LibPackPrettyPrint()
    local PrettyPrint, Table = self:Get(M.PrettyPrint, M.Table)
    return PrettyPrint.pformat, Table.ToStringSorted
end

--- ### Usage
---```
---local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
---```
---@return PrettyPrint, Table, String, LogFactory
function _L:LibPackUtils()
    local PrettyPrint, Table, String, LogFactory = self:Get(
            M.PrettyPrint, M.Table, M.String, M.LogFactory)
    return PrettyPrint, Table, String, LogFactory
end

---@return Table, String
function _L:LibPack_CommonUtils()
    local Table, String = self:Get(M.Table, M.String)
    return Table, String
end
---@return ButtonDataBuilder
function _L:LibPack_ButtonDataBuilder() return self:Get(M.ButtonDataBuilder) end

function _L:GetLogLevel() return ABP_LOG_LEVEL end
---@param level number The log level between 1 and 100
function _L:SetLogLevel(level) ABP_LOG_LEVEL = level or 1 end

---@return WidgetLibFactory
function _L:GetWidgetLibFactory() return self:Get(M.WidgetLibFactory) end
---@return MacroEventsHandler
function _L:GetMacroEventsHandler() return self:Get(M.MacroEventsHandler) end

---@type CommonConstants
function _L:LibPack_CommonConstants() return self:Get(M.CommonConstants) end

---@return WidgetMixin
function _L:Lib_WidgetMixin() return self:Get(M.WidgetMixin) end

---@return string, string, string The spell, item, macro attribute values
function _L:SpellItemMacroAttributes()
    local Attr = self:LibPack_CommonConstants().WidgetAttributes
    return Attr.SPELL, Attr.ITEM, Attr.MACRO
end

---@return UnitIDAttributes
function _L:UnitIdAttributes()
    ---@class UnitIDAttributes
    local unitIDAttributes = {
        focus = 'focus',
        target = 'target',
        mouseover = 'mouseover',
        none = 'none',
        pet = 'pet',
        player = 'player',
        vehicle = 'vehicle',
    }
    return unitIDAttributes
end

function _L:Get(...)
    local libNames = {...}
    local libs = {}
    for _, lib in ipairs(libNames) do
        local o = LibStub(lib)
        --assert(o ~= nil, 'Lib not found: ' .. lib)
        table.insert(libs, o)
    end
    return unpack(libs)
end

function _L:GetLogPrefix() return self.logPrefix end

---### Addon Version Info
---```Example:
---local version, major = G:GetVersionInfo()
---```
---@return string, string The version text, major version of the addon.
function _L:GetVersionInfo() return self.versionText, self.version end

---### Addon URL Info
---```Example:
---local versionText, curseForge, githubIssues, githubRepo = G:GetAddonInfo()
---```
---@return string, string, string The version and URL info for curse forge, github issues, github repo
function _L:GetAddonInfo()
    local versionText = self.versionText
    --@debug@
    if versionText == '1.0.0.10-beta' then versionText = addonName .. '-' .. self.version .. '.dev' end
    --@end-debug@
    return versionText, GetAddOnMetadata(addonName, 'X-CurseForge'), GetAddOnMetadata(addonName, 'X-Github-Issues'),
                GetAddOnMetadata(addonName, 'X-Github-Repo')
end
