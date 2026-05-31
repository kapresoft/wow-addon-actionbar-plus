--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()
local comp = O.Compat

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = 'BarVisibilityController'

--- @class BarVisibilityController_ABP_2_0 : AceEvent-3.0
local o = cns:NewAceEvent(); ns:Register(libName, o)
local p, t = ns:log(libName)

function o.OnBarsReady(evt, ...)
  o:Init()
end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
function o:Init()
  self:RegisterEvent("PLAYER_CONTROL_LOST")
  self:RegisterEvent("PLAYER_CONTROL_GAINED")
  self:RegisterEvent("PLAYER_ALIVE")
  self:RegisterEvent("PLAYER_UNGHOST")

  if comp:IsPlayerGhost() then
    self:PLAYER_ALIVE()
  elseif comp:IsPlayerOnTaxi() then
    self:__OnPlayerControlLost(0.01)
  end
end

function o:PLAYER_ALIVE()
  if not (cns:p().hideWhenGhost and comp:IsPlayerGhost()) then return end
  self:DisableBars()
end

function o:PLAYER_UNGHOST() self:EnableBars() end
function o:PLAYER_CONTROL_LOST() self:__OnPlayerControlLost(0.1) end
function o:PLAYER_CONTROL_GAINED() self:EnableBars() end

function o:EnableBars() C_Timer.After(0.2, function() ns:a():Enable() end) end
function o:DisableBars() C_Timer.After(0.2, function() ns:a():Disable() end) end

--- todo: this could also be stunned, etc
--- @private
--- @param delay number @Default is 0.5
function o:__OnPlayerControlLost(delay)
  C_Timer.After(delay or 0.3, function()
    if not (cns:p().hideWhenTaxi and comp:IsPlayerOnTaxi()) then return end
    self:DisableBars()
  end)
end

--[[-----------------------------------------------------------------------------
Register Messages
-------------------------------------------------------------------------------]]
o:RegisterMessage(ns:msg('OnBarsReady'), o.OnBarsReady)
