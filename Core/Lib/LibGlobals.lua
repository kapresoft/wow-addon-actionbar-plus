-- log levels, 10, 20, (+10), 100
if type(ABP_PLUS_DB) ~= "table" then ABP_PLUS_DB = {} end
if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

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
local Module = {
    -- Libraries
    Logger = 'Logger',
    LogFactory = 'LogFactory',
    PrettyPrint = 'PrettyPrint',
    Table = 'Table',
    String = 'String',
    Assert = 'Assert',
    AceLibFactory = 'AceLibFactory',
    -- Addons
    Config = 'Config',
    Profile = 'Profile',
    ButtonUI = 'ButtonUI',
    ButtonDataBuilder = 'ButtonDataBuilder',
    ButtonFactory = 'ButtonFactory',
    ButtonFrameFactory = 'ButtonFrameFactory',
    MacroTextureDialog = 'MacroTextureDialog',
    ProfileInitializer = 'ProfileInitializer',
    ReceiveDragEventHandler = 'ReceiveDragEventHandler',
    SpellDragEventHandler = 'SpellDragEventHandler',
    SpellAttributeSetter = 'SpellAttributeSetter',
    ItemDragEventHandler = 'ItemDragEventHandler',
    MacroDragEventHandler = 'MacroDragEventHandler',
    ItemAttributeSetter = 'ItemAttributeSetter',
    WidgetLibFactory = 'WidgetLibFactory',
    MacroAttributeSetter = 'MacroAttributeSetter',
    MacrotextAttributeSetter = 'MacrotextAttributeSetter',
    MacroEventsHandler = 'MacroEventsHandler'
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
    Module = Module,
}
---@type LibGlobals
ABP_LibGlobals = _L

---@return AceLibFactory
local function GetAceLibFactory() return _L:Get(Module.AceLibFactory)  end

---```
---Example:
---local LocalLibPack, Module = Core:LibPack()
---```
---@return LocalLibStub, Module, LibGlobals
function _L:LibPack() return LibStub, Module, _L end

---### Usage:
---```
---local AceDB, AceDBOptions, AceConfig, AceConfigDialog = AceLibFactory:GetAddonAceLibs()
---```
---@return AceDB, AceDBOptions, AceConfig, AceConfigDialog
function _L:LibPack_AceAddonLibs()
    local alf = GetAceLibFactory()
    return alf:GetAceDB(), alf:GetAceDBOptions(), alf:GetAceConfig(), alf:GetAceConfigDialog()
end

---### Get New Addon LibPack
---```
---local LibStub, Module, AceLibFactory, WidgetLibFactory, ProfileInitializer, LibGlobals = LibGlobals:LibPack_NewAddon()
---```
---@return LocalLibStub, Module, AceLibFactory, WidgetLibFactory, ProfileInitializer, LibGlobals
function _L:LibPack_NewAddon()
    local AceLibFactory, WidgetLibFactory, ProfileInitializer = self:Get(
            Module.AceLibFactory, Module.WidgetLibFactory, Module.ProfileInitializer)
    return LibStub, Module, AceLibFactory, WidgetLibFactory, ProfileInitializer, _L
end
---### Usage
---```
---local LibStub, M, P, LogFactory = ABP_LibGlobals:LibPack_NewLibrary()
---```
---@return LocalLibStub, Module, Profile, LogFactory
function _L:LibPack_NewLibrary()
    local Profile, LogFactory = self:Get(Module.Profile, Module.LogFactory)
    return LibStub, Module, Profile, LogFactory
end

---### Example
---```
---local AceEvent, AceGUI, AceHook = G:LibPack_AceLibrary()
---```
---@return AceEvent, AceGUI, AceHook
function _L:LibPack_AceLibrary()
    ---@type AceLibFactory
    local AceLibFactory = self:Get(Module.AceLibFactory)
    return AceLibFactory:GetAceEvent(), AceLibFactory:GetAceGUI(), AceLibFactory:GetAceHook()
end

---### Usage:
---```
---local pformat, ToStringSorted = ABP_LibGlobals:LibPackPrettyPrint()
---```
---@return pformat, function
function _L:LibPackPrettyPrint()
    local PrettyPrint, Table = self:Get(Module.PrettyPrint, Module.Table)
    return PrettyPrint.pformat, Table.ToStringSorted
end

--- ### Usage
---```
---local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
---```
---@return PrettyPrint, Table, String, LogFactory
function _L:LibPackUtils()
    local PrettyPrint, Table, String, LogFactory = self:Get(
            Module.PrettyPrint, Module.Table, Module.String, Module.LogFactory)
    return PrettyPrint, Table, String, LogFactory
end

---@return Table, String
function _L:LibPack_CommonUtils()
    local Table, String = self:Get(Module.Table, Module.String)
    return Table, String
end

---@return ButtonDataBuilder
function _L:LibPack_ButtonDataBuilder()
    return self:Get(Module.ButtonDataBuilder)
end

function _L:GetLogLevel() return ABP_LOG_LEVEL end
---@param level number The log level between 1 and 100
function _L:SetLogLevel(level) ABP_LOG_LEVEL = level or 1 end

---@return WidgetLibFactory
function _L:GetWidgetLibFactory() return self:Get(Module.WidgetLibFactory) end
---@return MacroEventsHandler
function _L:GetMacroEventsHandler() return self:Get(Module.MacroEventsHandler) end

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
