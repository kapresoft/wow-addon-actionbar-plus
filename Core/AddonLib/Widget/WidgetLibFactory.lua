local LibStub, format, unpack = LibStub, string.format, ABP_Table.unpackIt
local assert, type, tonumber, isTable = assert, type, tonumber, ABP_Table.isTable
local ACE_LIB, ADDON_LIB, Module = AceLibFactory, AceLibAddonFactory, Module
local VERSION_FORMAT = VERSION_FORMAT

local L = {}
WidgetLibFactory = L


-- Lazy Loaded libs
local logger = nil
local libButtonFactory = nil
local libProfile = nil

---@return Logger
function L:GetLogger()
    if not logger then logger = LibStub(format(VERSION_FORMAT, Module.Logger)) end
    return logger
end

--- Usage: local C, P, B, BF = unpack(LibFactory:GetAddonLibs())
function L:GetAddonStdLibs()
    local config = ADDON_LIB:LocalLibStub(Module.Config)
    local profile = self:GetProfile()
    local buttonUI = ADDON_LIB:LocalLibStub(Module.ButtonUI)
    local buttonFactory = self:GetButtonFactory()
    return { config, profile, buttonUI, buttonFactory }
end

-- Usage: P, SM = unpack(LibFactory:GetButtonFactoryLibs())
function L:GetButtonFactoryLibs()
    return self:GetProfile(), ACE_LIB:GetAceSharedMedia()
end

function L:GetConfigLibs()
    return { self:GetProfile(), self:GetButtonFactory() }
end

function L:GetProfile()
    if not libProfile then libProfile = ADDON_LIB:LocalLibStub(Module.Profile) end
    return libProfile
end

function L:GetButtonFactory()
    if not libButtonFactory then libButtonFactory = ADDON_LIB:LocalLibStub(Module.ButtonFactory) end
    return libButtonFactory
end
