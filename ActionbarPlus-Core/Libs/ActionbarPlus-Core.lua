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
  C_Timer.After(0.2, function()
      self:SendMessage('ABP_2_0::SPELLS_CHANGED')
  end)
end

function o:PLAYER_ENTERING_WORLD(evt, isInitialLogin, isReloadingUi)
  ns.lockActionBars = Settings.GetValue("lockActionBars")
  local delay = 1
  if isReloadingUi then delay = 0.01 end
  self:SendMessage('ABP_2_0::PLAYER_ENTERING_WORLD', isInitialLogin, isReloadingUi)
  C_Timer.After(delay, function()
    p('XXX delay=', delay, 'isInitialLogin=', isInitialLogin, 'isReloadingUi=', isReloadingUi)
    --self:SendMessage('ABP_2_0::PLAYER_ENTERING_WORLD', isInitialLogin, isReloadingUi)
  end)
end
o:RegisterEvent('PLAYER_ENTERING_WORLD')

