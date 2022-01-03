if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end
ADDON_NAME = 'ActionbarPlus'
ABP_PREFIX = '|cfdffffff{{|r|cfd2db9fbActionBarPlus|r|cfdfbeb2d%s|r|cfdffffff}}|r'
VERSION_FORMAT = 'ActionbarPlus-%s-1.0'

-- Usage
-- A,B = unpack(ABPGlobals)

local LibStub, format, unpack = LibStub, string.format, table.unpackIt
local function getLogger() return LibStub:GetLibrary(format(VERSION_FORMAT, 'Logger')) end

---@param optionalLogName string The optional log name
Embed_Logger = function(obj, optionalLogName)
    getLogger():Embed(obj, optionalLogName)
end

---@param libName string The library module name
ABP_VERSION = function(libName)
    local major, minor = format(VERSION_FORMAT, libName), tonumber(("$Revision: 1 $"):match("%d+"))
    return { major, minor }
end

ABP_Globals = function()
    local settings = LibStub:GetLibrary(format(VERSION_FORMAT, 'Settings'))
    local buttonUI = LibStub:GetLibrary(format(VERSION_FORMAT, 'ButtonUI'))
    local buttonFactory = LibStub:GetLibrary(format(VERSION_FORMAT, 'ButtonFactory'))
    return { settings, buttonUI, buttonFactory }
end

---@param localLibBaseName string The local library base name
ABP_GetLocalLib = function(localLibBaseName) return LibStub(format(VERSION_FORMAT, localLibBaseName)) end

---@param libName string The full Ace3 require library version string
ABP_GetLib = function(libName) return LibStub(libName) end

ABP_ACE = function()
    return {
        LibStub("AceDB-3.0"), LibStub("AceDBOptions-3.0"),
             LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")
    }
end

ABP_ACE_CONSOLE = function()
    return LibStub("AceConsole-3.0")
end

---@param major string Major version
---@param minor string Minor version
ABP_ACE_NEWLIB = function(libName)
    local version = ABP_VERSION(libName)
    local lib = LibStub:NewLibrary(unpack(version))
    function lib:GetVersion() return version end
    Embed_Logger(lib, libName)
end

ABP_ACE_NEWLIB_RAW = function(libName)
    local major, minor = unpack(ABP_VERSION(libName))
    return LibStub:NewLibrary(major, minor)
end




