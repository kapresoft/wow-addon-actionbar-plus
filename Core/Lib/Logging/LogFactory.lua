-- ## External -------------------------------------------------
local LibStub = LibStub
local logger = __K_Core:_LoggerImpl()

-- ## Local ----------------------------------------------------
local Core = __K_Core
local major, minor = Core:GetLibVersion(Core.M.LogFactory)
---@type LogFactory
local _L = LibStub:NewLibrary(major, minor)
Core:Register(Core.M.LogFactory, _L)

-- ## Functions ------------------------------------------------

function _L:EmbedLogger(obj, optionalLogName) logger:Embed(obj, optionalLogName) end

---@class LoggerTemplate
local LoggerTemplate = {}
---@param format string The string format. Example: logger:log('hello: %s', 'world')
function LoggerTemplate:log(format, ...)  end

---```
---local newLib = LogFactory:GetLogger('Assert', LibStub:NewLibrary(MINOR, MAJOR))
---```
---@return LogFactory A generic object with embedded AceConsole and Logger
function _L:NewLogger(logName, optionalObj)
    ---@class LogFactory : LoggerTemplate
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
