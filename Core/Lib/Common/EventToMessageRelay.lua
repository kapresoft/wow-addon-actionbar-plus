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
local GC, E, M, KO = ns.GC, ns.GC.E, ns.GC.M, ns:KO()
local libName = 'EventToMessageRelay'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class EventToMessageRelay
local L = ns:NewLib(libName); if not L then return end
local p = ns:CreateDefaultLogger(libName)
local pm = ns:LC().MESSAGE:NewLogger(libName)
local pt = ns:LC().MESSAGE_TRACE:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o EventToMessageRelay | ModuleV2
local function PropsAndMethods(o)

    --- Player-only Events
    --- value of true means there is no transformation
    local events = {
        [E.ACTIONBAR_SHOWGRID]     = true,
        [E.ACTIONBAR_HIDEGRID]     = true,
        [E.MODIFIER_STATE_CHANGED] = true,
        [E.PLAYER_ENTERING_WORLD]  = true,
        [E.PLAYER_CONTROL_GAINED]  = true,
        [E.PLAYER_CONTROL_LOST]    = true,
        [E.PLAYER_TARGET_CHANGED]  = true,
        [E.PLAYER_REGEN_ENABLED]   = true,
        [E.PLAYER_REGEN_DISABLED]  = true,
        [E.PET_BAR_SHOWGRID]       = true,
        [E.PET_BAR_HIDEGRID]       = true,
        [E.UPDATE_BINDINGS]        = true,
        [E.PLAYER_REGEN_DISABLED]  = M.OnPlayerEnterCombat,
        [E.PLAYER_REGEN_ENABLED]   = M.OnPlayerLeaveCombat,
    }

    --- @param frame Frame
    function ns.xml:EventToMessageRelay_OnLoad(frame)
        p:f3(function() return 'OnLoad called... frame=%s', frame:GetParentKey() end)
        frame:SetScript(E.OnEvent, o.OnMessageTransmitter)

        --- @see EquipmentSetController
        if ns:IsRetail() then
            events[E.ACTIVE_PLAYER_SPECIALIZATION_CHANGED] = true
        elseif ns:IsMoP() then
            events[E.PLAYER_SPECIALIZATION_CHANGED] = true
        else
            events[E.ACTIVE_TALENT_GROUP_CHANGED] = true
        end

        --- @see GlobalConstants#M (Messages)
        RegisterFrameForEvents(frame, GC.toArray(events))
    end

    local function toMessage(event)
        local val = events[event]
        if type(val) == "string" then return val end
        return GC.toMsg(event)
    end

    local function logUnitEvents(event, msg, ...)
        local args = {...}
        pt:t(function() return "OnPlayerEvents::Relaying evt[%s] to msg[%s] args=[%s]", event, msg, args end)
    end

    --- @param frame Frame
    --- @param event string
    function o.OnMessageTransmitter(frame, event, ...)
        local msg = toMessage(event); logUnitEvents(event, msg, ...)
        o:SendMessage(msg, libName, ...)
    end

end; PropsAndMethods(L)
