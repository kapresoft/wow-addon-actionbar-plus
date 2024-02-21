--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC = ns.O, ns.O.GlobalConstants

local AceEvent, M, TA =  O.AceLibrary.AceEvent, GC.M, GC.TooltipAnchor

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ActionbarPlusTooltipAnchorFrame : _Frame
local _ActionbarPlusTooltipAnchorFrame = {}

--- @class TooltipFrameHandlerWidget
local _TooltipFrameHandlerWidget = {
    --- @type ActionbarPlusTooltipAnchorFrame
    frame = {}
}

--- @class TooltipFrameHandler : BaseLibraryObject_WithAceEvent
local L = ns:AceEvent()
local libName = 'TooltipFrameHandler'
local p = ns:CreateDefaultLogger(libName)
local pm = ns:CreateMessageLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param evt string The event name
--- @param handler TooltipFrameHandler
local OnTooltipFrameUpdate = function(evt, handler, ...)
    local position, val = ...
    pm:d(function() return 'MSG::R: %s %s=%s', evt, tostring(position), tostring(val) end)
    if not val then return end
    handler:UpdateTooltipAnchor(val)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o TooltipFrameHandler
local function MethodsAndProperties(o)

    --- @see Config
    o:RegisterMessage(M.OnTooltipFrameUpdate, function(msg, ...)
        OnTooltipFrameUpdate(msg, o, ...)
    end)

    --- @type TooltipFrameHandlerWidget
    o.widget = {}

    function o:OnShow(frame)
        self.widget.frame = frame
        if not self.widget.frame then return end
        self.widget.frame:SetSize(1, 1)

        self:RegisterMessage(GC.M.OnAddOnEnabled, function(msg, ...)
            pm:d(function() return 'MSG::R: %s', msg end)
            local names = GC.Profile_Config_Names
            local anchorType = ns.db.profile[names.tooltip_anchor_type] or GC.TooltipAnchor.CURSOR_TOPLEFT
            self:UpdateTooltipAnchor(anchorType)
        end)

    end

    function o:IsCursorAnchorType(anchorType) return O.String.StartsWithIgnoreCase(anchorType, 'cursor_') end

    --- @see TooltipAnchor
    --- @param anchorType string
    function o:UpdateTooltipAnchor(anchorType)
        if not anchorType or self:IsCursorAnchorType(anchorType) then return end

        local f = self.widget.frame
        local padX = 50
        local padY = 50

        f:ClearAllPoints()
        if TA.SCREEN_TOPLEFT == anchorType then
            ns.GameTooltipAnchor = 'ANCHOR_BOTTOMRIGHT'
            f:SetPoint('TOPLEFT', nil, 'TOPLEFT', padX, -(padY))
        elseif TA.SCREEN_TOPRIGHT == anchorType then
            ns.GameTooltipAnchor = 'ANCHOR_BOTTOMLEFT'
            f:SetPoint('TOPRIGHT', nil, 'TOPRIGHT', -(padX), -(padY))
        elseif TA.SCREEN_BOTTOMRIGHT == anchorType then
            ns.GameTooltipAnchor = 'ANCHOR_TOPRIGHT'
            f:SetPoint('BOTTOMRIGHT', nil, 'BOTTOMRIGHT', -(padX), padY)
        elseif TA.SCREEN_BOTTOMLEFT == anchorType then
            ns.GameTooltipAnchor = 'ANCHOR_TOPLEFT'
            f:SetPoint('BOTTOMLEFT', nil, 'BOTTOMLEFT', padX, padY)
        end
    end
end

MethodsAndProperties(L)
--- @see _TooltipFrame.xml
function ABP_NS.xml:TooltipFrame_OnShow(frame)
    L:OnShow(frame)
end
