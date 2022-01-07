local LibStub, format, unpack = LibStub, string.format, table.unpackIt
local assert, type, tonumber, isTable = assert, type, tonumber, table.isTable
local ACELIB, ALIB, LF, Module = AceLibFactory, AceLibAddonFactory, ABPLogFactory, Module
local L = {}
LibFactory = L


-- Lazy Loaded libs
local libButtonFactory = nil
local libProfile = nil

---@return Logger
function L:GetLogger()
    if not logger then logger = LibStub(format(VERSION_FORMAT, Module.Logger)) end
    return logger
end

--- Usage: local C, P, B, BF = unpack(LibFactory:GetAddonLibs())
function L:GetAddonStdLibs()
    local config = ALIB:LocalLibStub(Module.Config)
    local profile = self:GetProfile()
    local buttonUI = ALIB:LocalLibStub(Module.ButtonUI)
    local buttonFactory = self:GetButtonFactory()
    return { config, profile, buttonUI, buttonFactory }
end

-- Usage: P, SM = unpack(LibFactory:GetButtonFactoryLibs())
function L:GetButtonFactoryLibs()
    return self:GetProfile(), ACELIB:GetAceSharedMedia()
end

function L:GetConfigLibs()
    return { self:GetProfile(), self:GetButtonFactory() }
end

function L:GetProfile()
    if not libProfile then libProfile = ALIB:LocalLibStub(Module.Profile) end
    return libProfile
end

function L:GetButtonFactory()
    if not libButtonFactory then libButtonFactory = ALIB:LocalLibStub(Module.ButtonFactory) end
    return libButtonFactory
end
