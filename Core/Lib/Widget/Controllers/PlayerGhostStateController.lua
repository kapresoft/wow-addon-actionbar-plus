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
--C_Timer.After(1, function()
--    print('xx loaded...')
--end)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o PlayerGhostStateController | ControllerV2
local function PropsAndMethods(o)

  --- Automatically called
  --- @see ModuleV2Mixin#Init
  --- @private
  function o:OnAddOnReady()
    -- todo: need user settings per bar, hide_when_ghost_form, default: true
    -- todo: don't check-in yet, we may need a general 'visibility' field
    -- todo: meant for: Story: Option to Hide Actionbars when Dead #457
    --       but will be solved by #5 Use State Driver for Visibility State

    self:RegisterAddOnMessage(E.PLAYER_ALIVE, o.OnPlayerAlive)
    self:RegisterAddOnMessage(E.PLAYER_UNGHOST, o.OnPlayerUnghost)
  end

  --- Fired when the player releases from death to a graveyard;
  --- or accepts a resurrect before releasing their spirit.
  function o.OnPlayerAlive()
    local isGhost = UnitIsGhost('player')
    p:vv(function() return 'xxx OnPlayerAlive() unitIsGhost=%s', isGhost end)
    if not isGhost then return end
    C_Timer.After(0.2, function() o:HideAll() end)
  end

  --- Fired when the player is alive after being a ghost.
  function o.OnPlayerUnghost()
    p:vv(function() return 'xxx OnPlayerUnghost() called... end)' end)
    C_Timer.After(0.2, function() o:ShowAll() end)
  end

end;
PropsAndMethods(L)

