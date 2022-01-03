local format = string.format
local NAME = 'ButtonFactory'
local MAJOR, MINOR = format("ActionbarPlus-%s-1.0", NAME), tonumber(("$Revision: 1 $"):match("%d+"))

local BF = LibStub:NewLibrary(MAJOR, MINOR)
if not BF then return end

function BF:GetVersion()
    return MAJOR
end

function BF:Initialized()
    print(format(ABP_PREFIX .. '%s.%s initialized', NAME, MAJOR, MINOR))
end