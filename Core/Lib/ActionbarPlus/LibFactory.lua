local LibStub, format, unpack = LibStub, string.format, table.unpackIt
local assert, type, tonumber, isTable = assert, type, tonumber, table.isTable

local L = {}
LibFactory = L

local VERSION_FORMAT = 'ActionbarPlus-%s-1.0'
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
    AceHook = 'AceHook-3.0',
    AceLibSharedMedia = 'LibSharedMedia-3.0'
}

-- Lazy Loaded libs
local logger = nil
local libAceConsole = nil
local libSharedMedia = nil
local libProfile = nil
local libAceHook = nil

---@return Logger
function L:GetLogger()
    if not logger then logger = LibStub(format(VERSION_FORMAT, Module.Logger)) end
    return logger
end

function L:EmbedLogger(libObj, optionalLogName) return self:GetLogger():Embed(libObj, optionalLogName) end

function L:GetAceLibVersionFormat() return VERSION_FORMAT end
function L:LocalLibStub(localLibName) return LibStub(format(VERSION_FORMAT, localLibName)) end

function L:GetAceLibVersion(libName)
    local major, minor = format(VERSION_FORMAT, libName), tonumber(("$Revision: 1 $"):match("%d+"))
    return { major, minor }
end

local function Embed(libName, lib, version)
    L:EmbedLogger(lib, libName)

    function lib:GetVersion() return version end

    function lib:OnAddonLoaded()
        local major, minor = unpack(version)
        self:log(10, '%s.%s initialized', major, minor)
        --self:log(1, 'Profile: %s', type(self.profile))
        if type(self.OnAfterAddonLoaded) == 'function' then self:OnAfterAddonLoaded() end
    end

    ---
    --- `lib:OnInitialized{ addon=<handler>, profile=<profiledb> }`
    ---@vararg context table A vararg parameter
    ---
    --- Example:
    ---
    ---`{ addon=<handler>, profile=<profiledb> }`
    ---
    function lib:OnInitialize(context)
        assert(isTable(context), 'The passed context is not a table')
        self.addon = context.handler
        self.profile = context.profile
        if type(self.OnAfterInitialize) == 'function' then self:OnAfterInitialize() end
    end
end

---@return A library instance with embedded methods
---@param libName string The library name
function L:NewAceLib(libName)
    local version = self:GetAceLibVersion(libName)
    local newLib = LibStub:NewLibrary(unpack(version))
    newLib.__name = libName
    Embed(libName, newLib, version)
    return newLib
end

---@return Library without the embedded module methods
function L:NewPlainAceLib(libName)
    local version = self:GetAceLibVersion(libName)
    local newLib = LibStub:NewLibrary(unpack(version))
    newLib.__name = libName
    return newLib
end

--- Usage: local C, P, B, BF = unpack(LibFactory:GetAddonLibs())
function L:GetAddonStdLibs()
    local config = self:LocalLibStub(Module.Config)
    local profile = self:LocalLibStub(Module.Profile)
    local buttonUI = self:LocalLibStub(Module.ButtonUI)
    local buttonFactory = self:LocalLibStub(Module.ButtonFactory)
    return { config, profile, buttonUI, buttonFactory }
end

function L:GetAddonAceLibs()
    return {
        LibStub(AceModule.AceDB), LibStub(AceModule.AceDBOptions),
        LibStub(AceModule.AceConfig), LibStub(AceModule.AceConfigDialog)
    }
end

function L:GetAceConsole()
    if not libAceConsole then libAceConsole = LibStub(AceModule.AceConsole) end
    return libAceConsole
end

function L:GetAceSharedMedia()
    if not libSharedMedia then libSharedMedia =  LibStub(AceModule.AceLibSharedMedia) end
    return libSharedMedia
end

function L:GetAceHook()
    if not libAceHook then libAceHook =  LibStub(AceModule.AceHook) end
    return libAceHook
end

function L:GetProfile()
    if not libProfile then
        libProfile = self:LocalLibStub(Module.Profile)
    end
    return libProfile
end

-- Usage: P, SM = unpack(LibFactory:GetButtonFactoryLibs())
function L:GetButtonFactoryLibs()
    return self:GetProfile(), self:GetAceSharedMedia()
end



