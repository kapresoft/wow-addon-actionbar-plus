--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local p, t = ns:log('Core')
local DatabaseMixin = ns.O.DatabaseMixin

--[[-------------------------------------------------------------------
AddOn: ActionbarPlus_Core
---------------------------------------------------------------------]]
--- @class ABP_Core_2_0 : AceAddon, AceEvent-3.0, AceBucket-3.0, AceConsole-3.0, Database_ABP_2_0
local o = ns:AceAddon():NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
ABP_Core_2_0 = o

----- Called once, after:
----- • SavedVariables are loaded
----- • All addon Lua/XML files are loaded
----- • Init default AceDB
function o:OnInitialize()
  DatabaseMixin:InitDb(self)
end
--
function o:OnEnable()
  --t('OnEnable', 'activeSpecIndex=', ns.O.UnitUtil:GetActiveSpecGroupIndex())
end

