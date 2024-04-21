--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, BackdropTemplateMixin = CreateFrame, BackdropTemplateMixin
local GameTooltip, StaticPopup_Show, ReloadUI = GameTooltip, StaticPopup_Show, ReloadUI
local C_Timer, IsShiftKeyDown = C_Timer, IsShiftKeyDown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, MSG, LibStub = ns.O, ns.GC, ns.M, ns.GC.M, ns.LibStub

local LSM = ns:AceLibrary().AceLibSharedMedia
local E, GCC, C = GC.E, GC.C, GC:GetAceLocale()
local AceEvent = ns:AceEvent()

local FrameHandleBackdrop = {
    --- @see LibSharedMedia
    bgFile = LSM:Fetch(LSM.MediaType.BACKGROUND, "Solid"),
    tile = false, tileSize = 26, edgeSize = 0,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local BAR_NAME_COLOR = BLUE_FONT_COLOR

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.FrameHandleBuilderMixin
--- @class FrameHandleBuilderMixin : BaseLibraryObject
local L = LibStub:NewLibrary(libName); if not L then return end
local p = ns:LC().FRAME:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @class MouseButtonMixin
local MouseButtonUtil = {}
--- @param mouseButton string
--- @return boolean
function MouseButtonUtil:IsLeftButton(mouseButton) return GCC.LeftButton == mouseButton end
--- @param mouseButton string
--- @return boolean
function MouseButtonUtil:IsRightButton(mouseButton) return GCC.RightButton == mouseButton end
--- @param mouseButton string
--- @return boolean
function MouseButtonUtil:IsButton5(mouseButton) return GCC.Button5 == mouseButton end
local MBU = MouseButtonUtil

--- @param frame FrameHandle
local function ShowConfigTooltip(frame)
    GameTooltip:SetOwner(frame, GCC.ANCHOR_TOPLEFT)
    --  Shift + Left-Click to ReloadUI (on debug only)
    GameTooltip:AddLine(frame:GetMouseOverTooltipText())
    GameTooltip:Show()
end

--- @param self FrameHandle
local function OnLeave(self)
    GameTooltip:Hide()
    if not self:IsMouseOverEnabled() then return end

    self:HideBackdrop()
end

--- @param self FrameHandle
local function OnEnter(self)
    ShowConfigTooltip(self)
    C_Timer.After(3, function() GameTooltip:Hide() end)

    if not self:IsMouseOverEnabled() then return end
    self:ShowBackdrop()
end

---@param self FrameHandle
local function OnMouseDown(self, mouseButton)
    GameTooltip:Hide()
    if ns.debug.flag.developer == true and IsShiftKeyDown() and MBU:IsLeftButton(mouseButton) then
        return ReloadUI()
    end

    if MBU:IsRightButton(mouseButton) then
        ns:a():OpenConfig(self.widget)
    elseif MBU:IsButton5(mouseButton) then
        StaticPopup_Show(GCC.CONFIRM_RELOAD_UI)
    end
end

--- @param self FrameHandle
local function OnDragStart(self) self.widget.frame:StartMoving() end

--- @param self FrameHandle
local function OnDragStop(self)
    local fw = self.widget
    fw.frame:StopMovingOrSizing()
    AceEvent:SendMessage(MSG.OnDragStopFrameHandle, libName, self.widget.index)
end

--[[-----------------------------------------------------------------------------
Methods: FrameHandle
-------------------------------------------------------------------------------]]
--- @param f FrameHandle
local function FrameHandle_PropsAndMethods(f)

    function f:GetMouseOverTooltipText()
        local dev = ''
        if ns.debug.flag.developer == true then
            dev = '\n• Shift-click to ReloadUI'
        end
        return ns.sformat('%s• %s.\n• %s.%s', self.prettyName,
                C['Click and drag to move the action bar'],
                C['Right-click to open the settings dialog'],
                dev
        )
    end

    function f:UpdateBackdropState()
        if self:IsMouseOverEnabled() then
            self:HideBackdrop()
            return
        end
        self:ShowBackdrop()
    end

    function f:ShowBackdrop()
        self:SetBackdrop(FrameHandleBackdrop)
        self:ApplyBackdrop()
        self:SetBackdropColor(235/255, 152/255, 45/255, 1)
    end

    function f:HideBackdrop()
        self:ClearBackdrop()
    end

    function f:IsMouseOverEnabled()
        local barConf = self.widget:GetConfig()
        return true == barConf.widget.frame_handle_mouseover
    end

    function f:RegisterScripts()
        self:SetScript(E.OnMouseDown, OnMouseDown)
        self:SetScript(E.OnDragStart, OnDragStart)
        self:SetScript(E.OnDragStop, OnDragStop)
        self:SetScript(E.OnEnter, OnEnter)
        self:SetScript(E.OnLeave, OnLeave)
    end

end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o FrameHandleBuilderMixin
local function PropsAndMethods(o)

    --- Automatically called by Mixin and Init
    --- @private
    --- @param widget FrameWidget
    function o:Init(widget)
        assert(type(widget) == 'table', 'Expected widget to be a FrameWidget object but was: ' .. type(widget))
        self.widget = widget
        self.frame = widget.frame
    end

    --- @param widget FrameWidget
    --- @return FrameHandle
    function o:New(widget)
        return ns:K():CreateAndInitFromMixin(o, widget):CreateFrameHandle()
    end

    --- @return FrameHandle
    function o:CreateFrameHandle()
        --- @class FrameHandle : Frame
        local fh = CreateFrame("Frame", nil, self.widget.frame,
                BackdropTemplateMixin and "BackdropTemplate" or nil)

        self.widget.frameHandle = fh
        fh.widget = self.widget
        fh.prettyName = BAR_NAME_COLOR:WrapTextInColorCode(ns.sformat('%s #%s:\n',
                ABP_ACTIONBAR_BASE_NAME, self.widget.index))

        FrameHandle_PropsAndMethods(fh)

        -- Ignore parent alpha so the handle frame doesn't get affected when we hide the
        --- main actionbar frame
        fh:SetIgnoreParentAlpha(true)
        fh:RegisterForDrag(GCC.LeftButton, GCC.RightButton);
        fh:EnableMouse(true)
        fh:SetMovable(true)
        fh:SetResizable(true)
        --todo next: review height settings
        --fh:SetHeight(self.widget.frameHandleHeight)
        fh:SetFrameStrata(self.widget.frameStrata)
        fh:SetPoint(GCC.BOTTOM, self.frame, GCC.TOP, 0, 1)
        fh:ShowBackdrop()
        fh:RegisterScripts()

        --- Prelim alpha; this is configured on
        --- @see PlayerSettingsController#OnAddOnReady()
        fh:SetAlpha(1.0)

        return fh
    end

end; PropsAndMethods(L)
