if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end

local BUI = LibStub:GetLibrary("ActionbarPlus-ButtonUI-1.0")

local function initGlobals()
    local C = function()
        return "hello"
    end
    return { BUI, C }
end

ABP_Globals = initGlobals()

-- Usage
-- A,B = unpack(ABPGlobals)