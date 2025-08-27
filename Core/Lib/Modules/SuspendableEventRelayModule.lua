--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local K, O, GC = ns:K(), ns.O, ns.GC
local E, M = GC.E, GC.M
local StartsWith = ns:String().StartsWith
local AceEvent = ns:AceEvent()

local libName = 'SuspendableEventRelayModule'
local p = ns:LC().MOD_SERM:NewLogger(libName)

--- @type Frame
local driver

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- Player-only Events
local events = {
    [E.ACTIONBAR_UPDATE_COOLDOWN]    = true,
    [E.BAG_UPDATE]                   = true,
    [E.BAG_UPDATE_DELAYED]           = true,
    [E.CURSOR_CHANGED]               = true,
    [E.EQUIPMENT_SETS_CHANGED]       = true,
    [E.EQUIPMENT_SWAP_FINISHED]      = true,
    [E.PLAYER_ENTER_COMBAT]          = true,
    [E.PLAYER_EQUIPMENT_CHANGED]     = true,
    [E.PLAYER_LEAVE_COMBAT]          = true,
    [E.PLAYER_MOUNT_DISPLAY_CHANGED] = true,
    [E.PLAYER_STARTED_MOVING]        = true,
    [E.PLAYER_STOPPED_MOVING]        = true,
    [E.SPELL_UPDATE_COOLDOWN]        = true,
    [E.SPELL_UPDATE_USABLE]          = true,
    [E.START_AUTOREPEAT_SPELL]       = true,
    [E.STOP_AUTOREPEAT_SPELL]        = true,
    [E.UI_ERROR_MESSAGE]             = true,
    [E.UPDATE_MACROS]                = true,
    [E.UPDATE_MOUSEOVER_UNIT]        = true,
    [E.ZONE_CHANGED_NEW_AREA]        = true,
}

--- Unit Events (fires for all Units) But has a filter for 'player' only
local playerUnitEvents = {
    [E.UNIT_SPELLCAST_START]        = M.OnPlayerSpellCastStart,
    [E.UNIT_SPELLCAST_STOP]         = M.OnPlayerSpellCastStop,
    [E.UNIT_SPELLCAST_SUCCEEDED]    = M.OnPlayerSpellCastSucceeded,
    [E.UNIT_SPELLCAST_FAILED]       = M.OnPlayerSpellCastFailed,
    [E.UNIT_SPELLCAST_FAILED_QUIET] = M.OnPlayerSpellCastFailedQuiet,
}
local function toMessage(event)
    local val = events[event]
    if type(val) == "string" then return val end
    return GC.toMsg(event)
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class SuspendableEventRelayModule : AceModule
local L = ns:a():NewModule(libName, 'AceEvent-3.0'); if not L then return end

--- @type SuspendableEventRelayModule | AceEvent
local o = L

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function ns.xml:SuspendableEventRelayModule_OnLoad(frame)
    assert(frame, 'Frame is expected here.')
    driver = frame
end

function o:OnInitialize()
    AceEvent:RegisterMessage(M.OnPlayerIdle, o.OnPlayerIdle)
    AceEvent:RegisterMessage(M.OnPlayerActive, o.OnPlayerActive)
end

function o:OnEnable()
    if not driver then return end
    RegisterFrameForEvents(driver, GC.toArray(events))
    RegisterFrameForUnitEvents(driver, GC.toArray(playerUnitEvents), GC.UnitId.player)
    driver:SetScript(E.OnEvent, o.OnMessageTransmitter)
end

function o:OnDisable()
    if not driver then return end
    self:UnregisterAllEvents()
    driver:SetScript(E.OnEvent, nil)
end

local function logUnitEvents(event, msg, ...)
    local args = {...}
    p:f1(function() return "Relaying evt[%s] to msg[%s] args=[%s]", event, msg, args end)
end

--- @param frame Frame
--- @param event string
function o.OnMessageTransmitter(frame, event, ...)
    local msg = toMessage(event); logUnitEvents(event, msg, ...)
    if StartsWith(event, 'UNIT_') then
        return o.OnPlayerEvents(frame, event, ...)
    end
    o:SendMessage(msg, libName, ...)
end

function o.OnPlayerEvents(frame, event, ...)
    local msg = toMessage(event); logUnitEvents(event, msg, ...)
    o:SendMessage(msg, libName, ...)
end

function o.OnPlayerActive()
    o:Enable()
    o:LogEnabledState('active')
end
function o.OnPlayerIdle()
    o:Disable()
    o:LogEnabledState('idle')
end

--- @private
function o:LogEnabledState(stateName)
    local state = 'enabled'; if not o:IsEnabled() then state = 'disabled' end
    p:d(function() return 'Player %s; mod %s', stateName, state end)
end