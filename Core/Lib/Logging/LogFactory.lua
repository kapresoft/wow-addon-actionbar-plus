-- ## External -------------------------------------------------
local LibStub = __K_Core:LibPack()

-- ## Local ----------------------------------------------------

---@class LogFactory
local _L = LibStub:NewLibrary('LogFactory')
local logger = LibStub('Logger')

-- ## Functions ------------------------------------------------


-- ## Methods -------------------------------------------------

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


