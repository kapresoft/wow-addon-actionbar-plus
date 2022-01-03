if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end

ABP_PREFIX_ADDON = '{{|cfd2db9fbActionBar|r}} '
ABP_PREFIX = '{{|cfd2db9fbActionBar|r|cfdfbeb2dPlus::%s|r}} '
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