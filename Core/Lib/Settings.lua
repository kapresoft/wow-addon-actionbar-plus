local MAJOR, MINOR = "ActionbarPlus-Settings-1.0", tonumber(("$Revision: 1 $"):match("%d+"))
local S = LibStub:NewLibrary(MAJOR, MINOR)
if not S then return end
local format = string.format

function S:GetVersion()
    return MAJOR
end

function S:Initialized()
    print(format(ABP_PREFIX .. '%s.%s initialized', 'Settings', MAJOR, MINOR))
end

