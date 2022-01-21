-- ## External -------------------------------------------------
local format = string.format
---@class LibStub Ace3 LibStub
local LibStub = LibStub

-- ## Local ----------------------------------------------------

local pkg = 'ActionbarPlus'
local versionFormat = pkg .. '-%s-1.0'

-- ## ----------------------------------------------------------
-- ## LocalLibStub ---------------------------------------------
-- ## ----------------------------------------------------------

---Version Format: ActionbarPlus-[LibName]-1.0, Example: LibStub('ActionbarPlus-Logger-1.0')
---@class LocalLibStub
local _S = {
    package = pkg,
    logPrefix = '|cfdffffff{{|r|cfd2db9fb' .. pkg .. '|r|cfdfbeb2d%s|r|cfdffffff}}|r',
    versionFormat = versionFormat
}

--- Get a local or acelibrary
---```
---// Local Lib
---local logger = LocalLibStub('Logger')
---// Ace3 Lib
---local console = LocalLibStub('Ace-Console-1.0', true)
---// OR
---local console = LocalLibStub:GetLibrary('Ace-Console-1.0', true)
---```
---@param isAceLib boolean if true, then calls Ace3 LibStub directly
function _S:GetLibrary(libName, isAceLib)
    if isAceLib then return LibStub(libName) end
    return LibStub(_S:GetLibVersionUnpacked(libName))
end

function _S:NewLibrary(libName)
    local major, minor = _S:GetLibVersionUnpacked(libName)
    local obj = LibStub:NewLibrary(major, minor)
    if type(obj.mt) ~= 'table' then obj.mt = {} end
    obj.mt = { __tostring = function() return major  end }
    setmetatable(obj, obj.mt)

    _S:Embed(obj, libName, major, minor)
    return obj
end

function _S:NewAddon(addonName)
    return LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
end

function _S:GetMajorVersion(libName)
    return format(self.versionFormat, libName)
end

---@param revisionNumber number The revision number.  This should be a positive number.
function _S:GetLibVersionUnpacked(libName, revisionNumber)
    local revNumber = revisionNumber or 1
    local revisionString = format("$Revision: %s $", revNumber)
    return self:GetMajorVersion(libName), tonumber((revisionString):match("%d+"))
end

function _S:Embed(o, name, major, minor)
    ---@return string
    function o:GetModuleName() return name end
    ---@return string, string major and minor versions
    function o:GetVersionUnpacked() return major, minor end
    ---@return table<string, string>  major:string, minor:string
    function o:GetVersion() return { major = major, minor = minor } end

    ---@return void
    function o:OnAddonLoaded()
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
    ---@return void
    function o:OnInitialize(context)
        --assert(isTable(context), 'The passed context is not a table')
        self.addon = context.handler
        self.profile = context.profile
        if type(self.OnAfterInitialize) == 'function' then self:OnAfterInitialize() end
    end
    self:EmbedLoggerIfAvailable(o)
end

function _S:EmbedLoggerIfAvailable(o)
    local logger = self:GetLogger()
    if not logger then return end
    logger:Embed(o, o:GetModuleName())
end

---@return Logger
function _S:GetLogger()
    local loggerName = self:GetMajorVersion('Logger')
    return LibStub(loggerName, true)
end

_S.mt = { __call = function (_, ...) return _S:GetLibrary(...) end }
setmetatable(_S, _S.mt)

-- ## ----------------------------------------------------------
-- ## Core -----------------------------------------------------
-- ## ----------------------------------------------------------

---@class Core
local _L = {}

-- ## Functions ------------------------------------------------

local function _SetGlobal(obj, packageName, moduleName)
    assert(obj ~= nil,
            'Object to be globally defined is required. Got: ' .. type(obj))
    assert(type(packageName) == 'string',
            'Package-Name is a required string. Got: ' .. type(packageName))
    assert(type(moduleName) == 'string',
            'Module-Name is a required string. Got: ' .. type(moduleName))

    local varName = format('%s_%s__', packageName, moduleName)
    --print('Global var:', varName)
    _G[varName] = obj
end


---Library creation and retrieval functions
---### New Library
---```
---local LibPack = Core:LibPack()
---local newAssertLib = LibPack:NewLibrary('Assert')
---```
---### Get Library
---```
---local Assert = LibPack('Assert')
---```
---### New Addon
---```
---local MyAddon = LibPack:NewAddon('Assert')
---```
---@return LocalLibStub, (fun(libName:string):table), (fun(addonName:string):table)
function _L:LibPack()
    local function NewLibrary(libName) return _S.NewLibrary(_S, libName) end
    local function NewAddon(addonName) return _S.NewAddon(_S, addonName) end
    return _S, NewLibrary, NewAddon
end

---@return LocalLibStub
function _L:LibStub() return _S end


---Package is also know as the "Addon Name"
---```
---local package, versionFormat, logPrefix = Core:GetAddonInfo()
---```
---@return string, string, string
function _L:GetAddonInfo()
    return _S.package, _S.versionFormat, _S.logPrefix
end

---Expects the following object structure
---```
---local package = {
---    __info = { name = 'Logging', package = { name='ActionbarPlus', shortName='ABP' }, }
---}
---// Call
---SetGlobal(package)
---```
function _L:SetGlobal(obj)
    local pkgInfo = obj.__pkg
    assert(type(pkgInfo) == 'table',
            'Object info __pkg field must be defined. Got: ' .. type(pkgInfo))
    _SetGlobal(obj, pkgInfo.package.shortName, pkgInfo.name)
end

---@type Core
__K_Core = _L
