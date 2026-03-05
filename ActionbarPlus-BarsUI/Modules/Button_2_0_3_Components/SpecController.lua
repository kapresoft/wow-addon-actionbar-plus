--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local unit = cns.O.UnitUtil
local p, pd, t, tf = ns:log('SpecController')
-- todo: delete me
--[[-----------------------------------------------------------------------------
Module::SpecController
-------------------------------------------------------------------------------]]
--- @class SpecController_ABP_2_0 : AceEvent_3_0
local S = cns:NewAceEvent()

--[[-----------------------------------------------------------------------------
Module::SpecController (Methods)
-------------------------------------------------------------------------------]]
--- @type SpecController_ABP_2_0
local o = S

function o:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
  local activeSpecGroup = unit:GetActiveSpecGroupIndex()
  pd(event, 'activeSpecGroup=', activeSpecGroup, 'isLogin=', isLogin, 'isReload=', isReload)
end

--- ACTIVE_TALENT_GROUP_CHANGED: Fired when a player switches changes which talent group (dual specialization) is active.
--- currentIndex, prevIndex in retail always returns 1,1
--- [Doc:ACTIVE_TALENT_GROUP_CHANGED](https://warcraft.wiki.gg/wiki/ACTIVE_TALENT_GROUP_CHANGED)
--- Handles active spec-group changes by switching the profile partition
--- and rebuilding the current action bar module and its buttons.
function o:ACTIVE_TALENT_GROUP_CHANGED(event, ...)
  local currentIndex, prevIndex = ...
  local activeIndex = unit:GetActiveSpecGroupIndex()
  p('OnEvent::' .. event, 'from=', prevIndex, 'to=', currentIndex, 'activeIndex[detected]=', activeIndex)
  
  -- TBD: Implementation
end

--S:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
--S:RegisterEvent('PLAYER_ENTERING_WORLD')
