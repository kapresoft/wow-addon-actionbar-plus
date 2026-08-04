--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-SequenceMixin-2-0', 1

--- @class Kapresoft-SequenceMixin-2-0
--- @field order number
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
S.mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, S.mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

--- @param startingIndex number|nil Optional starting positive index
function o:Init(startingIndex) self.order = startingIndex or 1 end

--- @param startingIndex number|nil Optional starting positive index
--- @return Kapresoft-SequenceMixin-2-0
function o.New(startingIndex)
  return CreateAndInitFromMixin(o, startingIndex)
end

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
