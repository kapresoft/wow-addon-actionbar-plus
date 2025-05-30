--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local GC, E, M, KO = ns.GC, ns.GC.E, ns.GC.M, ns:KO()
local StartsWith = KO.String.StartsWith
local libName = 'EventToMessageRelay'

local tinsert = table.insert
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class EventToMessageRelay
local L = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)
local pm = ns:LC().MESSAGE:NewLogger(libName)
local pt = ns:LC().MESSAGE_TRACE:NewLogger(libName)
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o EventToMessageRelay | ModuleV2
local function PropsAndMethods(o)

    ---@param frame Frame
    function o.OnLoad(frame)
        p:f3(function() return 'OnLoad called... frame=%s', frame:GetParentKey() end)
        frame:SetScript(E.OnEvent, o.OnMessageTransmitter)

        local events = {
            E.PLAYER_ENTERING_WORLD,
            E.EQUIPMENT_SETS_CHANGED, E.EQUIPMENT_SWAP_FINISHED, E.PLAYER_EQUIPMENT_CHANGED,
            E.PLAYER_MOUNT_DISPLAY_CHANGED, E.ZONE_CHANGED_NEW_AREA,
            E.BAG_UPDATE, E.BAG_UPDATE_DELAYED,
            E.ACTIONBAR_SHOWGRID, E.ACTIONBAR_HIDEGRID,
            E.PET_BAR_SHOWGRID, E.PET_BAR_HIDEGRID,
            E.CURSOR_CHANGED,
            E.MODIFIER_STATE_CHANGED,
            E.PLAYER_REGEN_ENABLED, E.PLAYER_REGEN_DISABLED,
            E.PLAYER_CONTROL_LOST, E.PLAYER_CONTROL_GAINED,
            E.UI_ERROR_MESSAGE
        }
        if not ns:IsRetail() then
            tinsert(events, E.ACTIVE_TALENT_GROUP_CHANGED)
            tinsert(events, E.PLAYER_TARGET_SET_ATTACKING)
        else
            tinsert(events, E.ACTIVE_PLAYER_SPECIALIZATION_CHANGED)
        end

        local playerEvents = {
            E.UNIT_SPELLCAST_START,
            E.UNIT_SPELLCAST_STOP,
            E.UNIT_SPELLCAST_SUCCEEDED,
            E.UNIT_SPELLCAST_FAILED,
            E.UNIT_SPELLCAST_FAILED_QUIET,
        }

        --- @see GlobalConstants#M (Messages)
        RegisterFrameForEvents(frame, events)
        RegisterFrameForUnitEvents(frame, playerEvents, 'player')

    end

    local transformations = {
        [E.PLAYER_REGEN_DISABLED]       = M.OnPlayerEnterCombat,
        [E.PLAYER_REGEN_ENABLED]        = M.OnPlayerLeaveCombat,
    }
    local unitTransformations = {
        [E.UNIT_SPELLCAST_START]        = M.OnPlayerSpellCastStart,
        [E.UNIT_SPELLCAST_STOP]         = M.OnPlayerSpellCastStop,
        [E.UNIT_SPELLCAST_SUCCEEDED]    = M.OnPlayerSpellCastSucceeded,
        [E.UNIT_SPELLCAST_FAILED]       = M.OnPlayerSpellCastFailed,
        [E.UNIT_SPELLCAST_FAILED_QUIET] = M.OnPlayerSpellCastFailedQuiet,
    }

    --- @param frame Frame
    --- @param event string
    function o.OnMessageTransmitter(frame, event, ...)
        local a = {...}
        if StartsWith(event, 'UNIT_') then
            local unitName = a[1]
            return unitName == GC.UnitId.player and o.OnPlayerEvents(frame, event, ...)
        end

        local msg = transformations[event] or GC.toMsg(event)
        pt:f3(function() return "OnMessageTransmitter::Relaying evt[%s] to msg[%s] args=[%s]", event, msg, a end)
        o:SendMessage(msg, libName, ...)
    end

    function o.OnPlayerEvents(frame, event, ...)
        local a = {...}
        local msg = unitTransformations[event] or GC.toMsg(event)
        pt:f3(function() return "OnPlayerEvents::Relaying evt[%s] to msg[%s] args=[%s]", event, msg, a end)
    end

    ns.H.EventToMessageRelay_OnLoad = o.OnLoad

end; PropsAndMethods(L)


