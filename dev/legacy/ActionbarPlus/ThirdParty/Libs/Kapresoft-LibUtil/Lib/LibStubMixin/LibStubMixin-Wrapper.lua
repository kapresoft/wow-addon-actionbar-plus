--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub
local prefix = '{{Kapresoft::LibStubMixin-Wrapper}}'

local function CreateLibWrapper(moduleName, moduleRevision)
    local majorVersion = string.format('Kapresoft-LibUtil-%s-1.0', moduleName)
    local standAloneMajorVersion = string.format('Kapresoft-%s-1.0', moduleName)
    local W = LibStub:NewLibrary(majorVersion, moduleRevision); if not W then return end
    local L = LibStub(standAloneMajorVersion); if not L then return end

    W.mt = {
        __index = L,
        __tostring = function()
            local minorVersion = LibStub.minors[majorVersion]
            if minorVersion then
                majorVersion =  majorVersion .. '.' .. minorVersion
            end
            return majorVersion
        end
    }
    setmetatable(W, W.mt)

    if (Kapresoft_LibUtil_LogLevel_LibStub or 0) > 10 then
        print(prefix, moduleName .. ':', '{ lib=' .. tostring(L), 'wrapper=' .. tostring(W) .. '}')
    end

    return W
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_LibStubMixin : Kapresoft_LibStubMixin
local W = CreateLibWrapper('LibStubMixin', 5)

