local MAJOR, MINOR = "ActionbarPlus-ButtonUI-1.0", tonumber(("$Revision: 1 $"):match("%d+"))
local B = LibStub:NewLibrary(MAJOR, MINOR)
if not B then return end

function B:GetVersion()
    return MAJOR
end

