--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local AceLocale = LibStub('AceLocale-3.0')

--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-AceLocaleUtil-2-0', 2

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]
--- @class Kapresoft-AceLocaleUtil-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

--- ### Example
--- ```
---  local L = LibStub('Kapresoft-AceLocaleUtil-2-0'):GetLocale(addon, not IsDev())
--- ```
--- @param addonName Name
--- @param silent boolean|nil Defaults to false
--- @return table<string, string>|nil
function o:GetLocale(addonName, silent)
  assert(type(addonName) == 'string', 'GetLocale(addonName):: addonName is required.')
  silent = silent == true
  local loc = AceLocale:GetLocale(addonName, true); if not loc then return nil end
  if silent ~= true then return loc end
  
  -- Override index so we don't get an error for non-existing keys
  local meta = getmetatable(loc)
  meta.__index = function(self, key)
    rawset(loc, key, key)
    return key
  end
  return loc
end
