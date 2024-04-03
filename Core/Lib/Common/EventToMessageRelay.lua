--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local GC, E = ns.GC, ns.GC.E
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
        })
    end

    --- @param frame Frame
    --- @param event string
    function o.OnMessageTransmitter(frame, event, ...)
        local a = {...}
        pt:t(function() return "Relaying event[%s] to message[%s] args=[%s]", event, GC.toMsg(event), a end)
        o:SendAddOnMessage(event, libName, ...)
    end

    ns.H.EventToMessageRelay_OnLoad = o.OnLoad

end; PropsAndMethods(L)


