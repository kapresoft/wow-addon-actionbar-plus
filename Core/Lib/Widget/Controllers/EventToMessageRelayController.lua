--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, MSG, E = ns.O, ns.GC, ns.M, ns.GC.M, ns.GC.E
local libName = ns.M.EventToMessageRelayController
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class EventToMessageRelayController
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
--- @param o EventToMessageRelayController | ModuleV2
local function PropsAndMethods(o)

    function o:OnLoad(frame, event, ...)
        p:f3('OnLoad called...')
        frame:SetScript(E.OnEvent, function(self, evt, ...) L:OnMessageTransmitter(evt, ...) end)

        --- @see GlobalConstants#M (Messages)
        RegisterFrameForEvents(frame, {
            E.PLAYER_ENTERING_WORLD,
            E.EQUIPMENT_SETS_CHANGED, E.EQUIPMENT_SWAP_FINISHED, E.PLAYER_EQUIPMENT_CHANGED,
            E.PLAYER_MOUNT_DISPLAY_CHANGED, E.ZONE_CHANGED_NEW_AREA,
            E.BAG_UPDATE, E.BAG_UPDATE_DELAYED,
            E.MODIFIER_STATE_CHANGED,
            E.CVAR_UPDATE,
        })
    end

    --- @param event string
    function o:OnMessageTransmitter(event, ...)
        pt:t(function() return "Relaying event[%s] to message[%s]", event, GC.toMsg(event) end)
        self:SendAddOnMessage(event, ns.name, ...)
    end

end; PropsAndMethods(L)

--[[-----------------------------------------------------------------------------
Frame Event Handlers: ABP_EventToMessageRelayControllerFrame
-------------------------------------------------------------------------------]]
--- @param frame Frame
function ns.H.EventToMessageRelayController_OnLoad(frame) L:OnLoad(frame) end

