--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @type _GameTooltip
local GameTooltip, GetCursorInfo = GameTooltip, GetCursorInfo
local InCombatLockdown = InCombatLockdown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, ns = ABP_LibPack(...)
local GC, WMX, String, Profile = O.GlobalConstants, O.WidgetMixin, O.String, O.Profile
local StartsWithIgnoreCase, EndsWithIgnoreCase = String.StartsWithIgnoreCase, String.EndsWithIgnoreCase
local PCN = GC.Profile_Config_Names

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
--- @class AttributeSetter : BaseLibraryObject
local AttributeSetter = {
    --- @param self AttributeSetter
    --- @param btnUI ButtonUI
    --- @param btnData Profile_Button
    ['SetAttributes'] = function(self, btnUI, btnData) end,
    --- @param self AttributeSetter
    --- @param btnUI ButtonUI
    ['OnAfterSetAttributes'] = function(self, btnUI) end,
    --- @param self AttributeSetter
    --- @param btnUI ButtonUI
    ['ShowTooltip'] = function(self, btnUI) end
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class BaseAttributeSetter : AttributeSetter
local _L = LibStub:NewLibrary(ns.M.BaseAttributeSetter)
local p = _L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param btnUI ButtonUI
local function AddPostCombat(btn)
    if not InCombatLockdown() then return end
    O.ButtonFrameFactory:AddPostCombatUpdate(btn.widget)
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
function _L:OnAfterSetAttributes(btn)
    AddPostCombat(btn)
    self:HandleGameTooltipCallbacks(btn)
end

--- @param btn ButtonUI
function _L:HandleGameTooltipCallbacks(btn)
    --- @param w ButtonUIWidget
    btn.widget:SetCallback(GC.E.OnEnter, function(w, event)
        if InCombatLockdown() then
            if not w:IsTooltipCombatModifierKeyDown() then return end
        elseif ABP.ActionbarEmptyGridShowing == true and btn.widget:IsEmpty() then
            w:SetHighlightEmptyButtonEnabled(true)
        else
            if not w:IsTooltipModifierKeyDown() then return end
        end

        self:SetToolTipOwner(w.button)
        self:ShowTooltip(w.button)

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

function _L:GetTooltipAnchorType()
    local profile = ns.db.profile
    return profile[PCN.tooltip_anchor_type] or GC.TooltipAnchor.CURSOR_TOPRIGHT
end

--- @see TooltipAnchor
--- @param btnUI ButtonUI The UIFrame
function _L:SetToolTipOwner(btnUI)
    local anchorType = self:GetTooltipAnchorType()
    local owner = GetTooltipOwner(btnUI, anchorType)
    local resolvedAnchor = GetAnchorKeyword(anchorType)
    --p:log('anchor: %s', tostring(resolvedAnchor))
    if isScreenFrame(owner) then resolvedAnchor = ns.GameTooltipAnchor end
    GameTooltip:SetOwner(owner, resolvedAnchor)
end
