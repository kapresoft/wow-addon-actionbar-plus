local format = string.format
local NAME = 'Settings'
local MAJOR, MINOR = format("ActionbarPlus-%s-1.0", NAME), tonumber(("$Revision: 1 $"):match("%d+"))
local S = LibStub:NewLibrary(MAJOR, MINOR)
if not S then return end
local format = string.format

function S:GetVersion()
    return MAJOR
end

function S:Initialized()
    print(format(ABP_PREFIX .. '%s.%s initialized', NAME, MAJOR, MINOR))
end

