--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

local band = bit and bit.band -- WoW Lua 5.1 bitlib

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see Core_Modules_ABP_2_0
local libName = ns.M.HashUtil()
---@class HashUtil_ABP_2_0
local o = ns:Register(libName, {})
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @param str string
function o.string(str)
  if not str or str == '' then return nil end
  local hash = 5381
  for i = 1, #str do
    hash = band((hash * 33) + str:byte(i), 0xFFFFFFFF)
  end
  return hash
end
