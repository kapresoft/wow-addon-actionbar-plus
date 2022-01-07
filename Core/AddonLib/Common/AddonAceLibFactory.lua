local LibStub, format, unpack = LibStub, string.format, table.unpackIt
local assert, type, tonumber, isTable = assert, type, tonumber, table.isTable
local VERSION_FORMAT = VERSION_FORMAT
local LOGF = LogFactory

local F = {}
AddonAceLibFactory = F

function F:GetAceLibVersionFormat() return VERSION_FORMAT end
function F:LocalLibStub(localLibName) return LibStub(format(VERSION_FORMAT, localLibName)) end

function F:GetAceLibVersion(libName)
    local major, minor = format(VERSION_FORMAT, libName), tonumber(("$Revision: 1 $"):match("%d+"))
    return { major, minor }
end

local function Embed(libName, lib, version)
    LOGF:GetLogger():Embed(lib, libName)

    function lib:GetVersion() return version end

    function lib:OnAddonLoaded()
        local major, minor = unpack(version)
        self:log(10, '%s.%s initialized', major, minor)
        --self:log(1, 'Profile: %s', type(self.profile))
        if type(self.OnAfterAddonLoaded) == 'function' then self:OnAfterAddonLoaded() end
    end

    ---
    --- `lib:OnInitialized{ addon=<handler>, profile=<profiledb> }`
    --- @param context @vararg table A vararg parameter
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

---@return table A library instance with embedded methods
---@param libName string The library name
function F:NewAceLib(libName)
    local version = self:GetAceLibVersion(libName)
    local newLib = LibStub:NewLibrary(unpack(version))
    newLib.__name = libName
    Embed(libName, newLib, version)
    return newLib
end

---@return table Library without the embedded module methods
function F:NewPlainAceLib(libName)
    local version = self:GetAceLibVersion(libName)
    local newLib = LibStub:NewLibrary(unpack(version))
    newLib.__name = libName
    return newLib
end

function F:AddonLibStub(localLibName) return LibStub(format(VERSION_FORMAT, localLibName)) end

function F:LazyGetLocalAceLib(libObj, localLibName)
    if not libObj then return self:AddonLibStub(localLibName) end
    return libObj
end