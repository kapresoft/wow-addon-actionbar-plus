local _, NewLibrary = __K_Core:LibPack()
local LibStub = LibStub

local AceModule = {
    AceAddon = "AceAddon-3.0",
    AceConsole = 'AceConsole-3.0',
    AceConfig = 'AceConfig-3.0',
    AceConfigDialog = 'AceConfigDialog-3.0',
    AceDB = 'AceDB-3.0',
    AceDBOptions = 'AceDBOptions-3.0',
    AceEvent = 'AceEvent-3.0',
    AceHook = 'AceHook-3.0',
    AceGUI = 'AceGUI-3.0',
    AceLibSharedMedia = 'LibSharedMedia-3.0'
}

---@class AceLibFactory
local _L = NewLibrary('AceLibFactory', 1)

---@class AceConsole
local libAceConsole = LibStub(AceModule.AceConsole)
---@class LibSharedMedia
local libSharedMedia = LibStub(AceModule.AceLibSharedMedia)
---@class AceEvent
local libAceEvent = LibStub(AceModule.AceEvent)
---@class AceHook
local libAceHook = LibStub(AceModule.AceHook)
---@class AceDB
local libAceDB = LibStub(AceModule.AceDB)
---@class AceDBOptions
local libAceDBOptions = LibStub(AceModule.AceDBOptions)
---@class AceConfigDialog
local libAceConfigDialog = LibStub(AceModule.AceConfigDialog)
---@class AceConfig
local libAceConfig = LibStub(AceModule.AceConfig)
---@class AceGUI
local libAceGUI = LibStub(AceModule.AceGUI)

-- ############################################################
---@return
---@return AceConsole
function _L:GetAceConsole() return libAceConsole end
---@return AceEvent
function _L:GetAceEvent() return libAceEvent end
---@return LibSharedMedia
function _L:GetAceSharedMedia() return libSharedMedia end
---@return AceHook
function _L:GetAceHook() return libAceHook end
---@return AceDB
function _L:GetAceDB() return libAceDB end
---@return AceDBOptions
function _L:GetAceDBOptions() return libAceDBOptions end
---@return AceConfigDialog
function _L:GetAceConfig() return libAceConfig end
---@return AceConfigDialog
function _L:GetAceConfigDialog() return libAceConfigDialog end
---@return AceGUI
function _L:GetAceGUI() return libAceGUI end

