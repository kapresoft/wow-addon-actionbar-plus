local LibStub, VERSION_FORMAT, Module = LibStub, VERSION_FORMAT, Module
local format = string.format

F = {}
LogFactory = F

local logger = nil

function F:GetLogger()
    if not logger then
        return LibStub(format(VERSION_FORMAT, Module.Logger))
    end
    return logger
end

function F:EmbedLogger(obj)
    self:GetLogger():Embed(obj)
end