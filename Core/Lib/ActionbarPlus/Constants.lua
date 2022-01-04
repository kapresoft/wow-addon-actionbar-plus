if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end
ADDON_NAME = 'ActionbarPlus'
ABP_PREFIX = '|cfdffffff{{|r|cfd2db9fbActionBarPlus|r|cfdfbeb2d%s|r|cfdffffff}}|r'
VERSION_FORMAT = 'ActionbarPlus-%s-1.0'
SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate'
TOPLEFT = 'TOPLEFT'
ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT'
CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI'

-- Usage
-- A,B = unpack(ABPGlobals)

local LibStub, format, unpack = LibStub, string.format, table.unpackIt
local Module = {
    Logger = 'Logger',
    Config = 'Config',
    Profile = 'Profile',
    ButtonUI = 'ButtonUI',
    ButtonFactory = 'ButtonFactory'
}
local AceModule = {
    AceConsole = 'AceConsole-3.0',
    AceDB = 'AceDB-3.0',
    AceDBOptions = 'AceDBOptions-3.0',
    AceConfig = 'AceConfig-3.0',
    AceConfigDialog = 'AceConfigDialog-3.0',
    LibSharedMedia = 'LibSharedMedia-3.0'
}

---@return Logger
local function getLogger() return LibStub(format(VERSION_FORMAT, Module.Logger)) end
---@param localLibBaseName string The local library base name
local LocalLibStub = function(localLibBaseName) return LibStub(format(VERSION_FORMAT, localLibBaseName)) end

ABP_ACE_CONSOLE = function() return LibStub(AceModule.AceConsole) end
ABP_SHARED_MEDIA = function() return LibStub(AceModule.LibSharedMedia) end
ABP_BUTTON_FACTORY = function() return LocalLibStub(Module.Profile), ABP_SHARED_MEDIA() end
ABP_PROFILE = function () return LocalLibStub(Module.Profile) end

ABP_GLOBALS = function()
    local config = LocalLibStub(Module.Config)
    local profile = LocalLibStub(Module.Profile)
    local buttonUI = LocalLibStub(Module.ButtonUI)
    local buttonFactory = LocalLibStub(Module.ButtonFactory)
    return { config, profile, buttonUI, buttonFactory }
end

ABP_ACE = function()
    return {
        LibStub(AceModule.AceDB), LibStub(AceModule.AceDBOptions),
        LibStub(AceModule.AceConfig), LibStub(AceModule.AceConfigDialog)
    }
end

---@param libName string The library name
ABP_ACE_NEWLIB = function(libName)
    local version = ABP_VERSION(libName)
    local lib = LibStub:NewLibrary(unpack(version))
    function lib:GetVersion() return version end
    EMBED_LOGGER(lib, libName)
    return lib
end

---@param libName string The library name
ABP_ACE_NEWLIB_RAW = function(libName)
    local version = ABP_VERSION(libName)
    local lib = LibStub:NewLibrary(unpack(version))
    function lib:GetVersion() return version end
    return lib
end

---@param optionalLogName string The optional log name
EMBED_LOGGER = function(obj, optionalLogName)
    getLogger():Embed(obj, optionalLogName)
end

---@param libName string The library module name
ABP_VERSION = function(libName)
    local major, minor = format(VERSION_FORMAT, libName), tonumber(("$Revision: 1 $"):match("%d+"))
    return { major, minor }
end