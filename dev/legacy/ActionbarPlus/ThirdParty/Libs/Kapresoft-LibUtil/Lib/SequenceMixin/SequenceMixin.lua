--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub
local KC = K_Constants
local MAJOR, MINOR = 'Kapresoft-SequenceMixin-1.0', 1

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class Kapresoft_SequenceMixin
local L = LibStub:NewLibrary(MAJOR, MINOR); if not L then return end
L.mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR]  end }
setmetatable(L, L.mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o Kapresoft_SequenceMixin
local function PropsAndMethods(o)

    --- @param startingIndex number|nil Optional starting positive index
    function o:Init(startingIndex) self.order = startingIndex or 1 end

    --- @param startingIndex number|nil Optional starting positive index
    --- @return Kapresoft_SequenceMixin
    function o:New(startingIndex) return KC:CreateAndInitFromMixin(o, startingIndex) end

    function o:get() return self.order end

    --- @param incr number An optional increment amount
    function o:next(incr)
        self.order = self.order + (incr or 1)
        return self.order
    end

    function o:reset()
        local lastCount = self.order + 1
        self.order = 1
        return lastCount
    end

end;
PropsAndMethods(L)

