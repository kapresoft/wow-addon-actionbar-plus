---@param LIB table LibStub
---@param VF table VERSION_FORMAT
---@param M table Module
local __def = function(LIB, VF, M, isNotTable)

    local format = string.format

    local F = {}

    local logger = nil

    function F:GetLogger()
        if not logger then
            return LIB(format(VF, M.Logger))
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

    if isNotTable(F.mt) then F.mt = {} end
    F.mt.__call = F.NewLogger
    setmetatable(F, F.mt)

    return F
end

ABP_LogFactory = __def(LibStub, VERSION_FORMAT, Module, ABP_Table.isNotTable)