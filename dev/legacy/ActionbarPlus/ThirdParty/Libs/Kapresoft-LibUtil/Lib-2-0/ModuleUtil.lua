--[[-----------------------------------------------------------------------------
Usage:

local M = {
   --- @type MyObj1
   MyObj1 = {},

   --- @type MyObj2
   MyObj2 = {},
}

local moduleUtil = LibStub('Kapresoft-ModuleUtil-2-0')
moduleUtil:EnrichModules(M)

--- @type string returns the string name
local libName = MyObj1()

-------------------------------------------------------------------------------]]
--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
  - 1: Initial version
  - 2: Init() method update
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-ModuleUtil-2-0', 3

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Kapresoft-ModuleUtil-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
S.mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, S.mt)

--[[-----------------------------------------------------------------------------
Methods
------------------------------------------------------------------------------]]
--- @param val any
--- @param valType string | "'string'", "'table'", "'number'", "'etc...'"
--- @param methodLabel string
local function assertType(val, valType, methodLabel)
  local t = type(val)
  local msg = ('%s:: Expected value should be a [%s] but was: %s')
          :format(tostring(methodLabel), tostring(valType), t)
  assert(t == valType, msg)
end

local o = S

--- @param moduleName Name
function o:Init(moduleName)
  local t = type(moduleName)
  assert(t == 'string', 'Init(moduleName): The moduleName should be a string but was:' .. t)
  
  self._name = moduleName
  local me = self
  self.mt = {
    --- @param m Kapresoft_LibUtil_Module
    __tostring = function() return 'Module: ' .. me._name end,
    --- @param m Kapresoft_LibUtil_Module
    __call     = function(m, ...) return me._name end
  }
  setmetatable(self, self.mt)
end

--- @class Kapresoft-ModuleUtil-EnrichedModuleMixin-2-0
--- @field name string The module name
local EnrichedModuleMixin = {}
--
--- @class Kapresoft-ModuleUtil-EnrichedModule-2-0 : Kapresoft-ModuleUtil-EnrichedModuleMixin-2-0
--
--
function EnrichedModuleMixin:GetName() return self.name end

local EnrichedModuleMT = {
  __index = EnrichedModuleMixin,
  --- @param m Kapresoft-ModuleUtil-EnrichedModule-2-0
  __tostring = function(m) return 'Module: ' .. m.name end,
  --- @param m Kapresoft-ModuleUtil-EnrichedModule-2-0
  __call     = function(m, ...) return m.name end
}

--- @param moduleName Name The module name
--- @return Kapresoft-ModuleUtil-EnrichedModule-2-0
function o:New(moduleName)
  assertType(moduleName, 'string', 'Init(moduleName)')
  local module = { name = moduleName }
  return setmetatable(module, EnrichedModuleMT)
end

--- @param modules table
function o:EnrichModules(modules)
  assertType(modules, 'table', 'EnrichModules(modules)')
  --- @param name Name
  for name in pairs(modules) do modules[name] = self:New(name) end
end
