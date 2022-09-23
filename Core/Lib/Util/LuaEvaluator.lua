--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, loadstring = string.format, loadstring

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local logPrefix = sformat(LibStub.logPrefix, '::' .. Core.M.LuaEvaluator) .. ':'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class LuaEvaluator
local L = LibStub:NewLibrary(Core.M.LuaEvaluator)

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

