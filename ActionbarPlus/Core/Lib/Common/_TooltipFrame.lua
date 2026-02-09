--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, MSG = ns.O, ns.GC, ns.GC.M
local TA =  GC.TooltipAnchor

--[[-----------------------------------------------------------------------------
Type: ActionbarPlusTooltipAnchorFrame
-------------------------------------------------------------------------------]]
--- @alias ActionbarPlusTooltipAnchorFrame _Frame

--[[-----------------------------------------------------------------------------
Type: TooltipFrameHandlerWidget
-------------------------------------------------------------------------------]]
--- @class TooltipFrameHandlerWidget
--- @field frame ActionbarPlusTooltipAnchorFrame | _Frame

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'TooltipFrameHandler'
--- @class TooltipFrameHandler
--- @field widget TooltipFrameHandlerWidget
local L = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)
local pm = ns:LC().MESSAGE:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param evt string The event name
--- @param handler TooltipFrameHandler
--- @vararg any
local function OnTooltipFrameUpdate(evt, handler, ...)
    local position, val = ...
    pm:d(function() return 'MSG::R: %s %s=%s', evt, tostring(position), tostring(val) end)
    if not val then return end
    handler:UpdateTooltipAnchor(val)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o TooltipFrameHandler | ModuleV2
local function MethodsAndProperties(o)

    --- @see Config
    o:RegisterMessage(MSG.OnTooltipFrameUpdate, function(msg, source, ...)
        OnTooltipFrameUpdate(msg, o, ...)
    end)

    o.widget = {}

    function o:OnShow(frame)
        self.widget.frame = frame
        if not self.widget.frame then return end
        self.widget.frame:SetSize(1, 1)

        self:RegisterMessage(MSG.OnAddOnEnabled, function(msg, source, ...)
            local names = GC.Profile_Config_Names
            local anchorType = ns.db.profile[names.tooltip_anchor_type] or GC.TooltipAnchor.CURSOR_TOPLEFT
            self:UpdateTooltipAnchor(anchorType)
        end)

    end

    --- @param anchorType string
    function o:IsCursorAnchorType(anchorType) return ns:String().StartsWithIgnoreCase(anchorType, 'cursor_') end

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
end; MethodsAndProperties(L)

--- @see TooltipUtil.lua
--- @see _TooltipFrame.xml
--- @param frame _Frame
function ns.xml:TooltipFrame_OnLoad(frame)
    ns.O.TooltipUtil:OnLoad_InitButtonGameTooltipHooks()
end

--- @see _TooltipFrame.xml
--- @param frame _Frame
function ns.xml:TooltipFrame_OnShow(frame)
    L:OnShow(frame)
end
