--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, BackdropTemplateMixin = CreateFrame, BackdropTemplateMixin
local GameTooltip, StaticPopup_Show, ReloadUI = GameTooltip, StaticPopup_Show, ReloadUI
local C_Timer, IsShiftKeyDown = C_Timer, IsShiftKeyDown
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, strlower = string.format, string.lower

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub = ns:LibPack()

local LSM = O.AceLibFactory:A().AceLibSharedMedia
local E = O.GlobalConstants.E
local C = O.GlobalConstants.C

local FrameHandleBackdrop = {
    ---@see LibSharedMedia
    bgFile = LSM:Fetch(LSM.MediaType.BACKGROUND, "Solid"),
    --bgFile = BACKDROP_TUTORIAL_16_16.bgFile,
    tile = false, tileSize = 26, edgeSize = 0,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class FrameHandleMixin : BaseLibraryObject
local L = LibStub:NewLibrary(ns.M.FrameHandleMixin); if not L then return end
local p = L:GetLogger()

--Events
L.E = {
    OnDragStop_FrameHandle = 'OnDragStop_FrameHandle'
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@class MouseButtonMixin
local MouseButtonUtil = {}
---@param mouseButton string
---@return boolean
function MouseButtonUtil:IsLeftButton(mouseButton) return C.LeftButton == mouseButton end
---@param mouseButton string
---@return boolean
function MouseButtonUtil:IsRightButton(mouseButton) return C.RightButton == mouseButton end
---@param mouseButton string
---@return boolean
function MouseButtonUtil:IsButton5(mouseButton) return C.Button5 == mouseButton end
local MBU = MouseButtonUtil

---@param frame FrameHandle
local function ShowConfigTooltip(frame)
    GameTooltip:SetOwner(frame, C.ANCHOR_TOPLEFT)
    --  Shift + Left-Click to ReloadUI (on debug only)
    GameTooltip:AddLine(frame.OnMouseOverTooltipText)
    GameTooltip:Show()
end

---@param frame FrameHandle
local function OnLeave(frame)
    GameTooltip:Hide()

    if not frame:IsMouseOverEnabled() then return end
    frame:HideBackdrop()
end

---@param frame FrameHandle
local function OnEnter(frame)
    ShowConfigTooltip(frame)
    C_Timer.After(3, function() GameTooltip:Hide() end)

    if not frame:IsMouseOverEnabled() then return end
    frame:ShowBackdrop()
end

local function OnMouseDown(frameHandle, mouseButton)
    --p:log(20, 'Clicked: %s', mouseButton or '')
    GameTooltip:Hide()
    if IsShiftKeyDown() and MBU:IsLeftButton(mouseButton) then
        ReloadUI()
    elseif MBU:IsRightButton(mouseButton) then
        ABP:OpenConfig(frameHandle.widget)
    elseif MBU:IsButton5(mouseButton) then
        StaticPopup_Show(C.CONFIRM_RELOAD_UI)
    end
end

---@param f FrameHandle
local function OnDragStart(f)
    f.widget.frame:StartMoving()
end

---@param f FrameHandle
local function OnDragStop(f)
    f.widget.frame:StopMovingOrSizing()
    f.widget:Fire(L.E.OnDragStop_FrameHandle)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param widget FrameWidget
function L:Init(widget)
    self.widget = widget
    self.frame = widget.frame
end

---@param f FrameHandle
local function PropertiesAndMethods(f)

    f.OnMouseOverTooltipText = format('%s #%s: %s', ABP_ACTIONBAR_BASE_NAME,
            f.widget.index, ABP_TOOLTIP_RIGHT_CLICK_TO_OPEN_CONFIG_TEXT)

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
end


---@return FrameHandle
function L:Constructor()
    ---@class FrameHandle : _Frame
    local fh = CreateFrame("Frame", nil, self.widget.frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    self.widget.frameHandle = fh
    fh.widget = self.widget

    ---Ignore parent alpha so the handle frame doesn't get affected when we hide the
    --- main actionbar frame
    fh:SetIgnoreParentAlpha(true)
    fh:RegisterForDrag(C.LeftButton, C.RightButton);
    fh:EnableMouse(true)
    fh:SetMovable(true)
    fh:SetResizable(true)
    --todo next: review height settings
    --fh:SetHeight(self.widget.frameHandleHeight)
    fh:SetFrameStrata(self.widget.frameStrata)
    --todo next: move alpha to settings
    fh:SetAlpha(0.5)
    fh:SetPoint(C.BOTTOM, self.frame, C.TOP, 0, 1)

    PropertiesAndMethods(fh)

    fh:ShowBackdrop()
    self:RegisterScripts(fh)



    return fh
end


---@param fh FrameHandle
function L:RegisterScripts(fh)
    fh:SetScript(E.OnMouseDown, OnMouseDown)
    fh:SetScript(E.OnDragStart, OnDragStart)
    fh:SetScript(E.OnDragStop, OnDragStop)
    fh:SetScript(E.OnEnter, OnEnter)
    fh:SetScript(E.OnLeave, OnLeave)
end

---@return FrameHandle
---@param widget FrameWidget
function ABP_CreateFrameHandle(widget)
    assert(widget, "FrameWidget is required.")
    ---@class FrameHandleMixinInstance : FrameHandleMixin
    local mixin = ns:K():CreateAndInitFromMixin(L, widget)
    return mixin:Constructor()
end
