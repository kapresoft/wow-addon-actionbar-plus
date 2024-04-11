--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local GC, E, M = ns.GC, ns.GC.E, ns.GC.M
local libName = 'EventToMessageRelay'
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

        --- @see GlobalConstants#M (Messages)
        RegisterFrameForEvents(frame, {
            E.PLAYER_ENTERING_WORLD,
            E.EQUIPMENT_SETS_CHANGED, E.EQUIPMENT_SWAP_FINISHED, E.PLAYER_EQUIPMENT_CHANGED,
            E.PLAYER_MOUNT_DISPLAY_CHANGED, E.ZONE_CHANGED_NEW_AREA,
            E.BAG_UPDATE, E.BAG_UPDATE_DELAYED,
            E.ACTIONBAR_SHOWGRID, E.ACTIONBAR_HIDEGRID,
            E.CURSOR_CHANGED,
            E.MODIFIER_STATE_CHANGED,

            E.PLAYER_REGEN_ENABLED, E.PLAYER_REGEN_DISABLED,
            E.PLAYER_CONTROL_LOST, E.PLAYER_CONTROL_GAINED,
        })

    end

    local transformations = {
        [E.PLAYER_REGEN_DISABLED] = M.OnPlayerEnterCombat,
        [E.PLAYER_REGEN_ENABLED] = M.OnPlayerLeaveCombat,
    }

    --- @param frame Frame
    --- @param event string
    function o.OnMessageTransmitter(frame, event, ...)
        local a = {...}
        local msg = transformations[event] or GC.toMsg(event)
        pt:i(function() return "Relaying event[%s] to message[%s] args=[%s]", event, msg, a end)
        o:SendMessage(msg, libName, ...)
    end

    ns.H.EventToMessageRelay_OnLoad = o.OnLoad

end; PropsAndMethods(L)


