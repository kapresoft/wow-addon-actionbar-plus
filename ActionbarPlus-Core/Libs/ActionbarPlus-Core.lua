--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local p, pd, t, tf = ns:log('Core')
local AceAddon, DatabaseMixin = ns.O.AceAddon, ns.O.DatabaseMixin

--[[-------------------------------------------------------------------
AddOn: ActionbarPlus_Core
---------------------------------------------------------------------]]
--- @alias ABP_Core_2_0 AceAddon_3_0 | AceEvent_3_0 | AceBucket_3_0 | AceConsole_3_0 | Database_ABP_2_0
--
--
--- @class ABP_Core_2_0_Impl : AceAddonObj
local A = AceAddon:NewAddon(ns.name, "AceEvent-3.0", "AceBucket-3.0", "AceConsole-3.0")

--
--- @type ABP_Core_2_0_Impl | ABP_Core_2_0
local o = A; ABP_Core_2_0 = o

--- Called once, after:
--- • SavedVariables are loaded
--- • All addon Lua/XML files are loaded
--- • Init default AceDB
function o:OnInitialize()
  DatabaseMixin:InitDb(self)
end

function o:OnEnable()
  C_Timer.After(0.1, function()
    t('OnEnable', 'activeSpecIndex=', ns.O.UnitUtil:GetActiveSpecGroupIndex())
  end)
end

function o:OnCoreReady(evt, isInitialLogin, isReloadingUi)
  ns.lockActionBars = Settings.GetValue("lockActionBars")
  ns:InitTracer()
  t('OnCoreReady', 'isInitialLogin=', isInitialLogin, 'isReloadingUi=', isReloadingUi)
  self:SendMessage('ABP_2_0::CORE_READY', isInitialLogin, isReloadingUi)
end; o:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnCoreReady')

