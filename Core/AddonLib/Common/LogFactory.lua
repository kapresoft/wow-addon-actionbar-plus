local LibStub, VERSION_FORMAT, Module = LibStub, VERSION_FORMAT, Module
local format = string.format

F = {}
-- TODO: Deprecate LogFactory
LogFactory = F
ABP_LogFactory = F

local logger = nil

function F:GetLogger()
    if not logger then
        return LibStub(format(VERSION_FORMAT, Module.Logger))
    end
    return logger
end

function F:EmbedLogger(obj, optionalLogName)
    self:GetLogger():Embed(obj, optionalLogName)
end

function F:NewLogger(logName)
    local _logger = {}
    self:EmbedLogger(_logger, logName)
    return _logger
end

setmetatable(F, {
    __call = function (_, ...)
        return F:NewLogger(...)
    end
})