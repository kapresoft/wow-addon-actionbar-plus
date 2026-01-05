--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @type _GameTooltip
local GameTooltip, GetCursorInfo = GameTooltip, GetCursorInfo
local InCombatLockdown = InCombatLockdown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local WMX, String = O.WidgetMixin, ns:String()
local StartsWithIgnoreCase, EndsWithIgnoreCase = String.StartsWithIgnoreCase, String.EndsWithIgnoreCase
local PCN = GC.Profile_Config_Names

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
--- @class AttributeSetter : BaseLibraryObject
--- @field SetAttributes fun(self:AttributeSetter, btnUI:ButtonUI, btnData:Profile_Button)
--- @field OnAfterSetAttributes fun(self:AttributeSetter, btnUI:ButtonUI)
--- @field ShowTooltip fun(self:AttributeSetter, btnUI:ButtonUI)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class BaseAttributeSetter : AttributeSetter
local L = LibStub:NewLibrary(M.BaseAttributeSetter); if not L then return end
local p = ns:LC().BUTTON:NewLogger(M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
-- todo: delete PostCombat. This was for dragging buttons during combat. That is no longer allowed.
--- @param btn ButtonUI
local function AddPostCombat(btn)
    if not InCombatLockdown() then return end
    O.ActionBarFrameBuilder:AddPostCombatUpdate(btn.widget)
end
local function GetTooltipOwner(btnUI, anchorType)
    if StartsWithIgnoreCase(anchorType, 'cursor') then return btnUI end
    return _G[GC.C.TOOLTIP_ANCHOR_FRAME_NAME]
end

local function GetAnchorKeyword(anchorType)
    local points = { 'TOPLEFT', 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOMRIGHT' }
    for _,pt in ipairs(points) do
        if EndsWithIgnoreCase(anchorType, pt) then
            return 'ANCHOR_' .. pt
        end
    end
    return 'ANCHOR_TOPLEFT'
end
--- @param frame _Frame
local function isScreenFrame(frame)
    return 'function' == type(frame.GetName) and GC.C.TOOLTIP_ANCHOR_FRAME_NAME == frame:GetName()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param btn ButtonUI
function L:OnAfterSetAttributes(btn)
    -- todo: delete PostCombat. This was for dragging buttons during combat. That is no longer allowed.
    -- AddPostCombat(btn)
    self:HandleGameTooltipCallbacks(btn)
end

--- @param btn ButtonUI
function L:HandleGameTooltipCallbacks(btn)
    --- @param w ButtonUIWidget
    btn.widget:SetCallback(GC.E.OnEnter, function(w, event)
        if InCombatLockdown() then
            if not w:IsTooltipCombatModifierKeyDown() then return end
        elseif ABP.ActionbarEmptyGridShowing == true and btn.widget:IsEmpty() then
            w:SetHighlightEmptyButtonEnabled(true)
        else
            if not w:IsTooltipModifierKeyDown() then return end
        end
        local btnF = w.button()
        self:SetToolTipOwner(btnF)
        self:ShowTooltip(btnF)

        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(true)
    end)

    --- @param w ButtonUIWidget
    btn.widget:SetCallback("OnLeave", function(w, event)
        WMX:HideTooltipDelayed()

        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(false)
    end)
end

function L:GetTooltipAnchorType()
    local profile = ns.db.profile
    return profile[PCN.tooltip_anchor_type] or GC.TooltipAnchor.CURSOR_TOPRIGHT
end

--- @see TooltipAnchor
--- @param btnUI ButtonUI The UIFrame
function L:SetToolTipOwner(btnUI)
    local anchorType = self:GetTooltipAnchorType()
    local owner = GetTooltipOwner(btnUI, anchorType)
    local resolvedAnchor = GetAnchorKeyword(anchorType)
    --p:log('anchor: %s', tostring(resolvedAnchor))
    if isScreenFrame(owner) then resolvedAnchor = ns.GameTooltipAnchor end
    GameTooltip:SetOwner(owner, resolvedAnchor)
end
