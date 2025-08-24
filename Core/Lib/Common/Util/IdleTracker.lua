--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local K, O, GC = ns:K(), ns.O, ns.GC
local MSG, E = GC.M, GC.E
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

local libName = ns.M.IdleTracker
--- @class IdleTracker
--- @field private IDLE_MINUTES number
--- @field private lastActivityTime TimeInMilli
--- @field private isIdle boolean
local S = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @type IdleTracker | ModuleV2
local o = S

-- Change this number to configure IDLE_MINUTES
o.IDLE_MINUTES = 0.5
o.lastActivityTime = GetTime()
o.isIdle = false

-- Public API
function o:IsIdle() return self.isIdle end
function o:GetIdleTime() return (GetTime() - self.lastActivityTime) end
function o:ResetIdleTimer()
    self.lastActivityTime = GetTime()
    if self.isIdle then
        self.isIdle = false
        o:SendMessage(MSG.OnPlayerActive, libName)
    end
end
--[[-----------------------------------------------------------------------------
Global Function
-------------------------------------------------------------------------------]]
--- @param elapsed TimeInMilli
--- @param f Frame
function ns.xml:IdleTracker_OnLoad(f, elapsed)
    -- this events determines the active state of a player
    f:RegisterEvent(E.PLAYER_STARTED_MOVING)
    f:RegisterEvent(E.PLAYER_ENTERING_WORLD)
    f:RegisterEvent(E.SPELL_UPDATE_COOLDOWN)
    -- catches clicks/keys that trigger errors (optional)
    f:RegisterEvent(E.UI_ERROR_MESSAGE)
    -- optional, cross-version safe
    pcall(f.RegisterEvent, f, "GLOBAL_MOUSE_DOWN")
    pcall(f.RegisterEvent, f, "GLOBAL_MOUSE_UP")
    f:Show()
end

--- @param event Name
--- @param f Frame
function ns.xml:IdleTracker_OnEvent(f, event)
    o:ResetIdleTimer()
end

--- @param elapsed TimeInMilli
function ns.xml:IdleTracker_OnUpdate(_, elapsed)
    local idleLimit = o.IDLE_MINUTES * 60
    if o.isIdle or (GetTime() - o.lastActivityTime) < idleLimit then return end

    o.isIdle = true
    -- Optional: fire a callback/event when idle detected
    p:vv("Player has been idle for " .. o.IDLE_MINUTES .. " minutes.")
    o:SendMessage(MSG.OnPlayerIdle, libName)
end