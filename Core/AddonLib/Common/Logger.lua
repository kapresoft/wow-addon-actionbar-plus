local ABP_PREFIX, LOG_LEVEL = ABP_PREFIX, ABP_LOG_LEVEL
local format, pack, unpack, sliceAndPack = string.format, ABP_Table.pack, ABP_Table.unpackIt, ABP_Table.sliceAndPack
local type, select, tostring, error = type, select, tostring, error
local pformat = PrettyPrint.pformat
local isNotTable, isTable, tableToString = ABP_Table.isNotTable, ABP_Table.isTable, ABP_Table.toString
local ACE_LIB, ADDON_LIB = AceLibFactory, AceLibAddonFactory
local AceUtil = ABP_AceUtil

local c = AceUtil:GetAceConsole()
local L = AceUtil:NewPlainAceLib('Logger')
if not L then return end

---@param obj table
---@param optionalLogName string The optional logger name
local function _EmbedLogger(obj, optionalLogName)
    local prefix = ''
    if type(optionalLogName) == 'string' then prefix = '::' .. optionalLogName end
    if type(obj.mt) ~= 'table' then obj.mt = {} end
    obj.mt = { __tostring = function() return format(ABP_PREFIX, prefix)  end }
    setmetatable(obj, obj.mt)

    function obj:log(...)
        local args = pack(...)
        if args.len == 1 then
            self:Print(self:ArgToString(args[1]))
            return
        end
        local level = 1
        local startIndex = 1
        if type(args[1]) == 'number' then
            level = args[1]
            startIndex = 2
        end
        if type(args[startIndex]) ~= 'string' then
            error(format('Argument #%s requires a string.format text', startIndex))
        end
        if LOG_LEVEL < level then return end
        --print(format('startIndex: %s level: %s', startIndex, level))
        args = sliceAndPack({...}, startIndex)
        local newArgs = {}
        for i=1,args.len do
            newArgs[i] = self:ArgToString(args[i])
        end
        --c:Print(prefix, format(unpack(newArgs)))
        self:Printf(format(unpack(newArgs)))
    end

    function obj:logn(...)
        local args = pack(...)
        local level = 1
        local startIndex = 1
        if type(args[1]) == 'number' then
            level = args[1]
            startIndex = 2
        end
        if type(args[startIndex]) ~= 'string' then
            error(format('Argument #%s requires a string.format text', startIndex))
        end
        if LOG_LEVEL < level then return end
        --print(format('startIndex: %s level: %s', startIndex, level))
        args = sliceAndPack({...}, startIndex)
        local newArgs = {}
        for i=1,args.len do
            local nl = '\n   '
            if i == 1 then nl = '' end
            local el = args[i]
            if type(el) == 'table' then newArgs[i] = nl .. tableToString(el)
            else newArgs[i] = nl .. tostring(el) end
        end
        self:Print(format(unpack(newArgs)))
    end

    -- Log a Pretty Formatted Object
    -- self:logp(itemInfo)
    -- self:logp("itemInfo", itemInfo)
    function obj:logp(...)
        local count = select('#', ...)
        if count == 1 then
            self:log(pformat(select(1, ...)))
            return
        end
        local label, obj = select(1, ...)
        self:log(label .. ': %s', pformat(obj))
    end

    function obj:printf(...)
        local args = pack(...)
        if args.len <= 0 then error('No arguments passed') end
        local formatText = args[1]
        if type(formatText) ~= 'string' then error('First argument must be a string.format string') end
        local newArgs = {}
        for i=1,args.len do
            local el = args[i]
            newArgs[i] = self:ArgToString(el)
        end
        self:Print(format(unpack(newArgs)))
    end

    function obj:ArgToString(any)
        if type(any) == 'table' then return tableToString(any)
        else
            return tostring(any)
        end
    end

end

---@class Logger
---@param obj table
---@param optionalLogName string The optional log name
function L:Embed(obj, optionalLogName)
    c:Embed(obj)
    _EmbedLogger(obj, optionalLogName)
end


