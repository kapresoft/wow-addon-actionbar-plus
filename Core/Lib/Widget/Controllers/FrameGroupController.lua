--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG = GC.M
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'FrameGroupController'
--- @class FrameGroupController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o FrameGroupController | ControllerV2
local function PropsAndMethods(o)

    --- Fired by FrameHandle when dragging stopped
    --- Save Anchor/Position data
    --- @param frameIndex Index
    function o.OnDragStopFrameHandle(msg, src, frameIndex)
        p:f3(function() return 'OnDragStopFrameHandle() called: frameIndex=%s', frameIndex end)
        local frameWidget = o:GetFrameByIndex(frameIndex)
        frameWidget:UpdateAnchor()
    end

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:RegisterMessage(MSG.OnDragStopFrameHandle, o.OnDragStopFrameHandle)
    end

end; PropsAndMethods(L)

