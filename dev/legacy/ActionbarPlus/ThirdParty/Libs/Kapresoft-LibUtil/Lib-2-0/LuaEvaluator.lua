--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-LuaEvaluator-2-0', 1

--- @class Kapresoft-LuaEvaluator-2-0
local o = LibStub:NewLibrary(MAJOR, MINOR); if not o then return end
local mt = { tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(o, mt)

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, loadstring = string.format, loadstring

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param literalVarName string
function o:Eval(literalVarName)
    if not literalVarName then return end

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
