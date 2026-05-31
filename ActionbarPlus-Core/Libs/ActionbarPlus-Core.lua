--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local O = ns.O

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local p, t = ns:log('Core')
local DatabaseMixin, PickupHooks = O.DatabaseMixin, O.PickupHooks

--[[-------------------------------------------------------------------
AddOn: ActionbarPlus_Core
---------------------------------------------------------------------]]
--- @class ABP_Core_2_0 : AceAddon, AceEvent-3.0, AceBucket-3.0, AceConsole-3.0, Database_ABP_2_0
local o = ns:AceAddon():NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
ABP_Core_2_0 = o

--- Called once, after:
--- - SavedVariables are loaded
--- - All addon Lua/XML files are loaded
--- - AceDB initialized
function o:OnInitialize()
  DatabaseMixin:InitDb(self)
  self:SendMessage(ns:msg('OnAddOnInitialized'))
end
--
function o:OnEnable()
  --t('OnEnable', 'activeSpecIndex=', ns.O.UnitUtil:GetActiveSpecGroupIndex())
  PickupHooks:Init()
end

