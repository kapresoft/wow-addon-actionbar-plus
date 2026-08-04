--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, loadstring = string.format, loadstring

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub
local MAJOR_VERSION = 'Kapresoft-LuaEvaluator-1.0'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class Kapresoft_LuaEvaluator
local L = LibStub:NewLibrary(MAJOR_VERSION, 2); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param literalVarName string
function L:Eval(literalVarName)
    if not literalVarName then return end
    --print(logPrefix, 'eval:', literalVarName)

    local scriptToEval = sformat([[ return %s]], literalVarName)
    local func, errorMessage = loadstring(scriptToEval, "Eval-Variable")
    if errorMessage then print(logPrefix, 'Error:', pformat(errorMessage)) end

    local val = func()
    if type(val) == 'function' then
        local status, pcallError = pcall(function() val = val() end)
        if not status then
            val = nil
        end
        if pcallError then print(logPrefix, 'Error:', pformat(pcallError)) end
    end
    return val
end
