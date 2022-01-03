local format = string.format
local NAME = 'ButtonUI'
local MAJOR, MINOR = format("ActionbarPlus-%s-1.0", NAME), tonumber(("$Revision: 1 $"):match("%d+"))

local B = LibStub:NewLibrary(MAJOR, MINOR)
if not B then return end
local format = string.format

function B:GetVersion()
    return MAJOR
end

function B:Initialized()
    print(format(ABP_PREFIX .. '%s.%s initialized', NAME, MAJOR, MINOR))
end