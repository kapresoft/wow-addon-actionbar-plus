if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end

ABP_PREFIX = '{{|cfd2db9fbActionBarPlus|r|cfdfbeb2d::%s|r}} '
local settings = LibStub:GetLibrary("ActionbarPlus-Settings-1.0")
local buttonsUI = LibStub:GetLibrary("ActionbarPlus-ButtonUI-1.0")

local function initGlobals()
    local C = function()
        return "hellox"
    end
    return { settings, buttonsUI, C }
end

ABP_Globals = initGlobals()

-- Usage
-- A,B = unpack(ABPGlobals)