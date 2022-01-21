-- ## External -------------------------------------------------
local LibStub = LibStub
local logger = __K_Core:GetLogger()

-- ## Local ----------------------------------------------------

---@class LogFactory
local major, minor = __K_Core:GetLibVersion('LogFactory', 1)
local _L = LibStub:NewLibrary(major, minor)


-- ## Functions ------------------------------------------------

---@return LogFactory
function _L:GetLogger() return logger end
function _L:EmbedLogger(obj, optionalLogName) self:GetLogger():Embed(obj, optionalLogName) end

---```
---local newLib = LogFactory:GetLogger('Assert', LibStub:NewLibrary(MINOR, MAJOR))
---```
---@return table A generic object with embedded AceConsole and Logger
function _L:NewLogger(logName, optionalObj)
    local o = {}
    if type(optionalObj) == 'table' then
        o = optionalObj
    end
    self:EmbedLogger(o, logName)
    return o
end

if type(_L.mt) ~= 'table' then _L.mt = {} end
_L.mt.__call = _L.NewLogger
setmetatable(_L, _L.mt)


