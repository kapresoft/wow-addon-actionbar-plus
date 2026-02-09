--[[-------------------------------------------------------------------
Blizzard Vars
---------------------------------------------------------------------]]
local C_Timer = C_Timer
local UnitIsGhost = UnitIsGhost

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local E = ns.GC.E

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'PlayerGhostStateController'
--- @class PlayerGhostStateController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @type PlayerGhostStateController | ControllerV2
local o = L

--- Automatically called
--- @see ModuleV2Mixin#Init
--- @private
function o:OnAddOnReady()
  self:RegisterAddOnMessage(E.PLAYER_ALIVE, o.OnPlayerAlive)
  self:RegisterAddOnMessage(E.PLAYER_UNGHOST, o.OnPlayerUnghost)
end

--- Fired when the player releases from death to a graveyard;
--- or accepts a resurrect before releasing their spirit.
function o.OnPlayerAlive()
  local isGhost = UnitIsGhost('player')
  if not isGhost then return end
  C_Timer.After(0.2, function() o:HideAll() end)
end

--- Fired when the player is alive after being a ghost.
function o.OnPlayerUnghost()
  C_Timer.After(0.2, function() o:ShowAll() end)
end
