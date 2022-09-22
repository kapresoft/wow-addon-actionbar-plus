-- ## External -------------------------------------------------
local format = string.format
---@class LibStub Ace3 LibStub
local LibStub = LibStub

-- ## Local ----------------------------------------------------

local _G = _G
local pkg = 'ActionbarPlus'
local shortName = 'ABP'
local globalVarPrefix = shortName .. '_'
local versionFormat = pkg .. '-%s-1.0'
local Modules = ABP_Modules

-- ## ----------------------------------------------------------
-- ## LocalLibStub ---------------------------------------------
-- ## ----------------------------------------------------------

local __Internal = {}

---Version Format: ActionbarPlus-[LibName]-1.0, Example: LibStub('ActionbarPlus-Logger-1.0')
---@class LocalLibStub
local _S = {
    package = pkg,
    shortName = shortName,
    globalVarPrefix = globalVarPrefix,
    logPrefix = '|cfdffffff{{|r|cfd2db9fb' .. pkg .. '|r|cfdfbeb2d%s|r|cfdffffff}}|r',
    versionFormat = versionFormat,
    M = Modules.M,
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
    --if true == global then
    --    obj:log('Setting global var: %s', __K_Core:GetGlobalVarName(libName))
    --    __K_Core:SetGlobal(libName, obj)
    --end
    __K_Core:Register(libName, obj)
    --print('Registered:', libName)
    return obj
end

function _S:NewAddon(addonName)
    return LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
end

---@param major string The major version ~ AceGUI-3.0
---@param silent boolean set to true for verbose
function _S:LibStubAce(major, silent) return LibStub(major, silent) end

function _S:GetMajorVersion(libName)
    return format(self.versionFormat, libName)
end

---### Usage:
---```
---local major, minor = Core:GetLibVersionUnpacked('Logger', 1)
---```
---@param libName string The library name -- i.e. 'Logger', 'Assert', etc...
---@param revisionNumber number The revision number.  This should be a positive number.
---@return string, number The major, minor version info. Example: ```ActionbarPlus-Logger-1.0, 1```
---@see Core#GetLibVersion
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
        --self:log(20, '%s.%s loaded', major, minor)
        --self:log(1, 'Profile: %s', type(self.profile))
        if type(self.OnAfterAddonLoaded) == 'function' then self:OnAfterAddonLoaded() end
    end

    function o:GetLogger() return __K_Core:O().LogFactory(self:GetModuleName()) end

    ---
    ---AceAddon lifecycle template method
    ---### Example Call:
    ---```[Addon]:OnInitialized{ addon=ABP }```
    ---@param context @vararg table A vararg parameter. ```{ addon=addon }```
    ---@return void
    function o:OnInitialize(context)
        self.addon = context.addon
        self.profile = context.addon.profile
        if type(self.OnAfterInitialize) == 'function' then self:OnAfterInitialize() end
    end
    self:EmbedLoggerIfAvailable(o)
end

function _S:EmbedLoggerIfAvailable(o)
    local logger = self:GetLogger()
    if not logger then return end
    logger:EmbedModule(o)
end

---@return Logger
---@see Core#GetLogger
function _S:GetLogger() return LibStub(self:GetMajorVersion('Logger'), true) end

_S.mt = { __call = function (_, ...) return _S:GetLibrary(...) end }
setmetatable(_S, _S.mt)

-- ## ----------------------------------------------------------
-- ## Core -----------------------------------------------------
-- ## ----------------------------------------------------------

---@class Core
local _L = {
    addonName = _S.package,
    M = Modules.M
}

-- ## Functions ------------------------------------------------

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
---### Others
---local LibStub, NewLibrary = __K_Core:LibPack()
---local LibStub, Core = __K_Core:LibPack()
---local AceGUI = LibStub:LibStubAce('AceGUI-3.0')
---```
---@return LocalLibStub, Core, GlobalObjects
function _L:LibPack() return _S, self, self:O() end

---local O, Core, LocalLibStub = __K_Core:LibPack_GlobalObjects()
---@return GlobalObjects, Core, LocalLibStub
function _L:LibPack_GlobalObjects() return self:O(), self, _S  end

---@return Mixin
function _L:LibPack_Mixin() return _S:GetLibrary('Mixin') end

---@return LibGlobals
function _L:LibPack_Globals() return _G['ABP_LibGlobals'] end

---@return LocalLibStub
function _L:LibStub() return _S end

---@see LogFactory
---@return LoggerTemplate
function _L:NewLogger(logName) return _S:GetLibrary('LogFactory'):NewLogger(logName) end

---Package is also know as the "Addon Name"
---```
---local package, versionFormat, logPrefix = Core:GetAddonInfo()
---```
---@return string, string, string
function _L:GetAddonInfo()
    return _S.package, _S.versionFormat, _S.logPrefix
end

---### Usage:
---```
---local major, minor = Core:GetLibVersion('Logger', 1)
---```
---@param libName string The library name -- i.e. 'Logger', 'Assert', etc...
---@param revisionNumber number The revision number.  This should be a positive number.
---@return string, number, string The major, minor, logPrefix. Example: ```ActionbarPlus-Logger-1.0, 1, <log-prefix>```
---@see LocalLibStub#GetLibVersionUnpacked
function _L:GetLibVersion(libName, revisionNumber)
    local major, minor = _S:GetLibVersionUnpacked(libName, revisionNumber)
    return major, minor, _S.logPrefix
end

---@return Logger
function _L:GetLogger() return _S:GetLogger() end

---Sets the global var name with the Addon short-name prefix
---```
---Example: This sets an ABP_MyVar
---Core:SetGlobal('MyVar', 'This is my var')
---```
function _L:SetGlobal(varName, obj)
    _G[self:GetGlobalVarName(varName)] = obj
    return obj
end

function _L:GetGlobalVarName(varName)
    return _S.globalVarPrefix .. varName
end

---### Syntax:
---```
--- // Default Setup without functions being shown
--- local str = pformat(obj)
--- local str = pformat:Default()(obj)
--- // Shows functions, etc.
--- local str = pformat:A():pformat(obj)
---```
function _L:InitPrettyPrint()

    ---@type PrettyPrint
    local pprint = LibStub(_S:GetMajorVersion('PrettyPrint'))
    ---@class pformat
    local o = { wrapped = pprint }
    ---@type pformat
    pformat = o

    ---@return pformat
    function o:Default()
        pprint.setup({ wrap_string = false, indent_size=4, sort_keys=true, level_width=120, depth_limit = true,
                   show_all=false, show_function = false })
        return self;
    end

    ---Configured to show all
    ---@return pformat
    function o:A()
        pprint.setup({ wrap_string = false, indent_size=4, sort_keys=true, level_width=120,
                   show_all=true, show_function = true, depth_limit = true })
        return self;
    end

    ---@return string
    function o:pformat(obj, option, printer)
        local str = pprint.pformat(obj, option, printer)
        o:Default(o)
        return str
    end
    o.mt = { __call = function (_, ...) return o.pformat(o, ...) end }
    setmetatable(o, o.mt)

    self:SetGlobal('PrettyPrint', pformat)
end

--function _L:GetNamespaceObject()
--    return self
--end

---@param name string The module name
---@param o table The object
function _L:Register(name, o)
    if not (name or o) then return end
    --local n = {
    --    mt = {
    --        __tostring = function() return name  end,
    --        __call = function() return o  end
    --    }
    --}
    --setmetatable(n, n.mt)
    __Internal[name] = o
end
---@return GlobalObjects
function _L:O() return __Internal end

function _L:Init() self:InitPrettyPrint() end
_L:Init()

local _LIB = {}
function _LIB:GetLibraries(...)
    local libNames = {...}
    --print("libNames:", pformat(libNames))
    local libs = {}
    for _, lib in ipairs(libNames) do
        local o = _S:GetLibrary(lib)
        table.insert(libs, o)
    end
    return unpack(libs)
end
_LIB.mt = {
    __tostring = function() return "Core::Lib"  end,
    __call = function (_, ...) return _LIB.GetLibraries(...) end
}
setmetatable(_LIB, _LIB.mt)
_L.Lib = _LIB

---@type Core
__K_Core = _L

--Define Globals here
if ABP_GlobalConstants then _L:Register('GlobalConstants', ABP_GlobalConstants) end
if ABP_Modules then _L:Register('Modules', ABP_Modules) end