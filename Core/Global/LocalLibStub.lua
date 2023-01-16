--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

--- @type LibStub
local LibStub = LibStub

--- The major version format, i.e. 'ActionbarPlus-<Module>-1.0'
local versionFormat = ns.name .. '-%s-1.0'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- Version Format: ActionbarPlus-[LibName]-1.0, Example: LibStub('ActionbarPlus-Logger-1.0')
--- @class LocalLibStub
local S = LibStub:NewLibrary(ns:LibName(ns.M.LibStub), 1); if not S then return end
ns:Register(ns.M.LibStub, S)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return Logger
local function CreateLogger() return LibStub(ns:LibName(ns.M.Logger), true) end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- Get a local or acelibrary
---```
---// Local Lib
---local logger = LocalLibStub('Logger')
---// Ace3 Lib
---local console = LocalLibStub('Ace-Console-1.0', true)
---// OR
---local console = LocalLibStub:GetLibrary('Ace-Console-1.0', true)
---```
--- @param isAceLib boolean if true, then calls Ace3 LibStub directly
function S:GetLibrary(libName, isAceLib)
    if isAceLib then return LibStub(libName) end
    return LibStub(S:GetLibVersionUnpacked(libName))
end

--- @return BaseLibraryObject
function S:NewLibrary(libName)
    local major, minor = S:GetLibVersionUnpacked(libName)
    --- @type BaseLibraryObject
    local obj = LibStub:NewLibrary(major, minor)
    obj.name = libName
    obj.major = major
    obj.minor = minor

    if type(obj.mt) ~= 'table' then obj.mt = {} end
    obj.mt = { __tostring = function() return self.major  end }
    setmetatable(obj, obj.mt)

    --- @param o BaseLibraryObject
    local function BaseMethods(o)
        --- @return string
        function o:GetModuleName() return self.name end
        --- @return string, string major and minor versions
        function o:GetVersionUnpacked() return self.major, self.minor end
        --- @return table<string, string>  major:string, minor:string
        function o:GetVersion() return { major = self.major, minor = self.minor } end

        --- @return Logger
        function o:GetLogger() return ns.O.LogFactory(self:GetModuleName()) end

        --- @param o BaseLibraryObject
        local function EmbedLoggerIfAvailable(o)
            local logger = CreateLogger()
            if not logger then return end
            logger:EmbedModule(o)
        end
        EmbedLoggerIfAvailable(o)
    end
    BaseMethods(obj)
    ns:Register(libName, obj)

    if verboseLogging then
        print(sformat('LocalLibStub::Registered:%s major=%s minor=%s', self.name, self.major, self.minor))
    end

    return obj
end

function S:NewAddon(addonName)
    return LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
end

--- @param major string The major version ~ AceGUI-3.0
--- @param silent boolean set to true for verbose
function S:LibStubAce(major, silent) return LibStub(major, silent) end

--- @param libName string
--- @return string The major version, i.e. 'ActionbarPlus-<Module>-1.0'
function S:GetMajorVersion(libName) return sformat(versionFormat, libName) end

---### Usage:
---```
---local major, minor = Core:GetLibVersionUnpacked('Logger', 1)
---```
--- @param libName string The library name -- i.e. 'Logger', 'Assert', etc...
--- @param revisionNumber number The revision number.  This should be a positive number.
--- @return string, number The major, minor version info. Example: ```ActionbarPlus-Logger-1.0, 1```
function S:GetLibVersionUnpacked(libName, revisionNumber)
    local revNumber = revisionNumber or 1
    local revisionString = sformat("$Revision: %s $", revNumber)
    return self:GetMajorVersion(libName), tonumber((revisionString):match("%d+"))
end

--- @return LoggerTemplate
--- @param libObj table Any library created by "NewLibrary"
function S:GetLogger(libObj) return libObj:GetLogger() end

S.mt = { __call = function (_, ...) return S:GetLibrary(...) end }
setmetatable(S, S.mt)
