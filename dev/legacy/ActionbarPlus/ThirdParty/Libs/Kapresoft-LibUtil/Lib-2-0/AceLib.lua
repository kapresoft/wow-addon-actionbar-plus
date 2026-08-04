--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-- 2: EmmyLua2 update
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-AceLib-2-0', 2

--- @class Kapresoft-AceLib-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

function o:AceAddon() return LibStub('AceAddon-3.0') end
function o:AceBucket() return LibStub('AceBucket-3.0') end
function o:AceConfig() return LibStub('AceConfig-3.0') end
function o:AceConfigDialog() return LibStub('AceConfigDialog-3.0') end
function o:AceConfigRegistry() return LibStub('AceConfigRegistry-3.0') end
function o:AceConsole() return LibStub('AceConsole-3.0') end
function o:AceDB() return LibStub('AceDB-3.0') end
function o:AceDBOptions() return LibStub('AceDBOptions-3.0') end
function o:AceEvent() return LibStub('AceEvent-3.0') end
function o:AceGUI() return LibStub('AceGUI-3.0') end
function o:AceHook() return LibStub('AceHook-3.0') end
function o:AceLocale() return LibStub('AceLocale-3.0') end

--- @param obj? any The target object
--- @param ... string The Ace3 Library names, i.e. 'AceEvent-3.0', 'AceBucket-3.0'
function o:AceEmbed(obj, ...)
  assert(type(obj) == 'table', 'Expected {obj} to be of type table.')
  local inst = obj or {}
  local aceLib
  for i = 1, select("#", ...) do
    aceLib = select(i, ...)
    if type(aceLib) == 'string' then
      local name = aceLib
      aceLib = LibStub(name)
      assert(type(aceLib) == 'table', 'Ace3 lib not found: ' .. name)
    end
    if type(aceLib) == 'table' and aceLib.Embed then
      aceLib:Embed(inst)
    end
  end
  return inst
end

--- Create a new instance of AceEvent or embed to an obj if passed
--- @param obj table? The object to embed or nil
--- @return AceEvent-3.0
function o:NewAceEvent(obj) return self:AceEvent():Embed(obj or {}) end

--- Create a new instance of AceBucket or embed to an obj if passed
--- @param obj table? The object to embed or nil
--- @return AceBucket-3.0
function o:NewAceBucket(obj) return self:AceBucket():Embed(obj or {}) end

--- @param obj table? The object to embed or nil
--- @return 'AceHook-3.0'
function o:NewAceHook(obj) return self:AceHook():Embed(obj or {}) end

--- @param addon string
--- @param silent boolean?
--- @return table<string, string>
function o:GetLocale(addon, silent) return self:AceLocale():GetLocale(addon, true) end

