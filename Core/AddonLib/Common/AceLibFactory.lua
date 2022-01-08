local LibStub, format, unpack = LibStub, string.format, table.unpackIt
local assert, type, tonumber, isTable = assert, type, tonumber, table.isTable
local VERSION_FORMAT = VERSION_FORMAT

local A = {}
AceLibFactory = A

local logger = nil
local libAceConsole = nil
local libSharedMedia = nil
local libAceHook = nil
local libAceDB = nil
local libAceDBOptions = nil
local libAceConfigDialog = nil
local libAceConfig = nil
local libAceGUI = nil

---- TODO: Rename to AddonAceLib
-----@return table A library instance with embedded methods
-----@param libName string The library name
--function A:NewAceLib(libName)
--    local version = self:GetAceLibVersion(libName)
--    local newLib = LibStub:NewLibrary(unpack(version))
--    newLib.__name = libName
--    Embed(libName, newLib, version)
--    return newLib
--end
--
-----@return table Library without the embedded module methods
--function A:NewPlainAceLib(libName)
--    local version = self:GetAceLibVersion(libName)
--    local newLib = LibStub:NewLibrary(unpack(version))
--    newLib.__name = libName
--    return newLib
--end
--
---- TODO: Rename to GetAddonAceLibVersion()
--function A:GetAceLibVersion(libName)
--    local major, minor = format(VERSION_FORMAT, libName), tonumber(("$Revision: 1 $"):match("%d+"))
--    return { major, minor }
--end

---- TODO: Rename to GetAddonAceLibVersionFormat()
--function A:GetAceLibVersionFormat() return VERSION_FORMAT end

function A:LazyGetAceLib(libObj, libName)
    if not libObj then return LibStub(libName) end
    return libObj
end

--function A:AddonLibStub(localLibName) return LibStub(format(VERSION_FORMAT, localLibName)) end

--function A:LazyGetLocalAceLib(libObj, localLibName)
--    if not libObj then return self:AddonLibStub(localLibName) end
--    return libObj
--end

-- ############################################################

function A:GetAceConsole()
    libAceConsole = self:LazyGetAceLib(libAceConsole, AceModule.AceConsole)
    return libAceConsole
end

function A:GetAceSharedMedia()
    libSharedMedia = self:LazyGetAceLib(libSharedMedia, AceModule.AceLibSharedMedia)
    return libSharedMedia
end

function A:GetAceHook()
    libAceHook = self:LazyGetAceLib(libAceHook, AceModule.AceHook)
    return libAceHook
end

function A:GetAceDB()
    libAceDB = self:LazyGetAceLib(libAceDB, AceModule.AceDB)
    return libAceDB
end

function A:GetAceDBOptions()
    libAceDBOptions = self:LazyGetAceLib(libAceDBOptions, AceModule.AceDBOptions)
    return libAceDBOptions
end

function A:GetAceConfig()
    libAceConfig = self:LazyGetAceLib(libAceConfig, AceModule.AceConfig)
    return libAceConfig
end

function A:GetAceConfigDialog()
    libAceConfigDialog = self:LazyGetAceLib(libAceConfigDialog, AceModule.AceConfigDialog)
    return libAceConfigDialog
end
function A:GetAceGUI()
    libAceGUI = self:LazyGetAceLib(libAceGUI, AceModule.AceGUI)
    return libAceGUI
end

function A:GetAddonAceLibs()
    return { self:GetAceDB(), self:GetAceDBOptions(), self:GetAceConfig(), self:GetAceConfigDialog() }
end

