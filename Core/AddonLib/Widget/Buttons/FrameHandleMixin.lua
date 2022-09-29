--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, BackdropTemplateMixin = CreateFrame, BackdropTemplateMixin
---@type Blizzard_AnchorUtil
local AnchorUtil = AnchorUtil
local GameTooltip, StaticPopup_Show, ReloadUI = GameTooltip, StaticPopup_Show, ReloadUI
local C_Timer, IsShiftKeyDown = C_Timer, IsShiftKeyDown
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format, strlower = string.format, string.lower

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local Mixin, LSM = O.Mixin, O.AceLibFactory:A().AceLibSharedMedia
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
---@class FrameHandleMixin
local L = LibStub:NewLibrary(Core.M.FrameHandleMixin)
--Events
L.E = {
    OnDragStop_FrameHandle = 'OnDragStop_FrameHandle'
}
---@return LoggerTemplate
local p = L:GetLogger()
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

---@param frame Frame
local function ShowConfigTooltip(frame)
    local widget = frame.widget
    GameTooltip:SetOwner(frame, C.ANCHOR_TOPLEFT)
    GameTooltip:AddLine(format('Actionbar #%s: Right-click to open config UI', widget.index, 1, 1, 1))
    GameTooltip:Show()
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function OnLeave(_) GameTooltip:Hide() end

local function OnEnter(frame)
    ShowConfigTooltip(frame)
    C_Timer.After(3, function() GameTooltip:Hide() end)
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

---@return FrameHandle
function L:Constructor()
    ---@class FrameHandle
    local fh = CreateFrame("Frame", nil, self.widget.frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    self.widget.frameHandle = fh
    fh.widget = self.widget

    --TODO: NEXT: Customizable backdrop in settings
    fh:RegisterForDrag(C.LeftButton, C.RightButton);
    fh:SetBackdrop(FrameHandleBackdrop)
    fh:ApplyBackdrop()
    fh:SetBackdropColor(235/255, 152/255, 45/255, 1)
    fh:EnableMouse(true)
    fh:SetMovable(true)
    fh:SetResizable(true)
    fh:SetHeight(self.widget.frameHandleHeight)
    fh:SetFrameStrata(self.widget.frameStrata)
    fh:SetPoint(C.BOTTOM, self.frame, C.TOP, 0, 1)

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
    local mixin = Mixin:MixinAndInit(L, widget)
    return mixin:Constructor()
end

