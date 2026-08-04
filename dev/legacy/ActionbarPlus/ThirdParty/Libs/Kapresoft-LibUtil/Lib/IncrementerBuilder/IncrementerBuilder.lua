--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub
local MAJOR_VERSION = 'Kapresoft-IncrementerBuilder-1.0'

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param o Kapresoft_Incrementer
local function IncrementerMethods(o)
    --- @param customIncrement number
    --- @return number
    function o:next(customIncrement)
        self.n = self.n + (customIncrement or  self.increment)
        return self.n
    end
    --- @return number
    function o:get() return self.n end
    --- @return number
    function o:reset() self.n = self.startIndex; return self:get() end
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Kapresoft_IncrementerBuilder
local L = LibStub:NewLibrary(MAJOR_VERSION, 1); if not L then return end
L.mt = { __tostring = function() return MAJOR_VERSION .. '.' .. LibStub.minors[MAJOR_VERSION]  end }
setmetatable(L, L.mt)


--- @return Kapresoft_Incrementer
function L:New(start, increment)

    --- @class Kapresoft_Incrementer
    local o = {
        startIndex = start,
        n = start,
        increment = increment
    }
    IncrementerMethods(o)
    return o
end
