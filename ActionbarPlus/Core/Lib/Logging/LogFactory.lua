--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

--- @type LibStub
local LibStub = LibStub
local logger = LibStub(ns:LibName(ns.M.Logger))

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
local major, minor, moduleName = ns:LibName(ns.M.LogFactory), 1, ns.M.LogFactory

--- @type LogFactory
local L = LibStub:NewLibrary(major, minor); if not L then return end
ns:Register(moduleName, L)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function L:EmbedLogger(obj, optionalLogName) logger:Embed(obj, optionalLogName) end

---```
---local newLib = LogFactory:GetLogger('Assert', LibStub:NewLibrary(MINOR, MAJOR))
---```
--- @return Logger A generic object with embedded AceConsole and Logger
function L:NewLogger(logName, optionalObj)
    --- @class LogFactory : Logger
    local o = {}
    if type(optionalObj) == 'table' then
        o = optionalObj
    end
    self:EmbedLogger(o, logName)
    return o
end

if type(L.mt) ~= 'table' then L.mt = {} end
L.mt.__call = L.NewLogger
setmetatable(L, L.mt)
