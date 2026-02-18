--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local p, pd, t, tf = ns:log()
local AceAddon, DatabaseMixin = ns.O.AceAddon, ns.O.DatabaseMixin

--[[-------------------------------------------------------------------
AddOn: ActionbarPlus_Core
---------------------------------------------------------------------]]
--- @alias ABP_Core_2_0 AceAddon_3_0 | AceEvent_3_0 | AceBucket_3_0 | AceConsole_3_0
--
--
------ @class ABP_Core_2_0_Impl : AceAddonObj
local A = AceAddon:NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")
ABP_Core_2_0 = A
--
--- @type ABP_Core_2_0_Impl | ABP_Core_2_0
local o = A

--- Called once, after:
--- • SavedVariables are loaded
--- • All addon Lua/XML files are loaded
--- • Init default AceDB
function o:OnInitialize()
  DatabaseMixin:InitDb(self)
end

function o:OnEnable()
  t('OnEnable::', 'specID=', ns.O.Compat:GetSpecializationID())
  self:RegisterEvent('SPELLS_CHANGED')
end

function o:SPELLS_CHANGED()
  self:UnregisterEvent("SPELLS_CHANGED")
  p('xx SPELLS_CHANGED...')
  self:SendMessage('ABP_2_0::SPELLS_CHANGED')
end
