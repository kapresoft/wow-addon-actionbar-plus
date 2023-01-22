-- TODO NEXT: Use Kapresoft_LibUtil_AceLibrary()

--- Examle Usage:
---```
---A = O.AceLibFactory:A()
---AceConsole = A.AceConsole
---AceConfig = A.AceConfig
--- ```

--- @type Namespace
local _, ns = ...
local M, LibStub = ns.M, ns.O.LibStub

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
--- @class AceObjects
local AceObjectsTemplate = {

    --- @type AceAddon
    AceAddon = {},
    --- @type AceConsole
    AceConsole = {},
    --- @type AceConfig
    AceConfig = {},
    --- @type AceConfigDialog
    AceConfigDialog = {},
    --- @type AceDB
    AceDB = {},
    --- @type AceDBOptions
    AceDBOptions = {},
    --- @type AceEvent
    AceEvent = {},
    --- @type AceHook
    AceHook = {},
    --- @type AceGUI
    AceGUI = {},
    --- @type AceLibSharedMedia
    AceLibSharedMedia = {},

}

local __Internal = {}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class AceLibFactory
local _L = LibStub:NewLibrary(M.AceLibFactory)
_L.mt.__call = function (_, ...) return _L:Constructor(...) end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param aceLib string
local function LocalLibAce(name, aceLib)
    local o = LibStub.LibStubAce(aceLib)
    __Internal[name] = o
    return o
end

local function Init()
    --- @type AceAddon
    LocalLibAce('AceAddon', AceModule.AceAddon)
    --- @type AceConsole
    LocalLibAce('AceConsole', AceModule.AceConsole)
    --- @type AceConfig
    LocalLibAce('AceConfig', AceModule.AceConfig)
    --- @type AceConfigDialog
    LocalLibAce('AceConfigDialog', AceModule.AceConfigDialog)
    --- @type AceDB
    LocalLibAce('AceDB', AceModule.AceDB)
    --- @type AceDBOptions
    LocalLibAce('AceDBOptions', AceModule.AceDBOptions)
    --- @type AceEvent
    LocalLibAce('AceEvent', AceModule.AceEvent)
    --- @type AceHook
    LocalLibAce('AceHook', AceModule.AceHook)
    --- @type AceGUI
    LocalLibAce('AceGUI', AceModule.AceGUI)
    --- @type AceLibSharedMedia
    LocalLibAce('AceLibSharedMedia', AceModule.AceLibSharedMedia)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @return AceObjects
function _L:A() return __Internal end

function _L:Constructor(...)
    return self:Get(...)
end

function _L:Get(...)
    local libNames = {...}
    local libs = {}
    for _, lib in ipairs(libNames) do
        local o = LibStub.LibStubAce(lib)
        table.insert(libs, o)
    end
    return unpack(libs)
end

--[[-----------------------------------------------------------------------------
Initialize
-------------------------------------------------------------------------------]]
Init()
