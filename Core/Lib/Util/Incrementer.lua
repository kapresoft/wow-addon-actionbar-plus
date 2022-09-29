--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local L = LibStub:NewLibrary(Core.M.Incrementer)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o Incrementer
local function IncrementerMethods(o)

    ---@param customIncrement number
    ---@return number
    function o:next(customIncrement)
        self.n = self.n + (customIncrement or  self.increment)
        return self.n
    end
    ---@return number
    function o:get() return self.n end
    ---@return number
    function o:reset() self.n = self.startIndex; return self:get() end

end

---@param start number
---@param increment number
---@return Incrementer
function ABP_CreateIncrementer(start, increment)
    ---@class Incrementer
    local o = {
        startIndex = start,
        n = start,
        increment = increment
    }
    IncrementerMethods(o)
    return o
end
