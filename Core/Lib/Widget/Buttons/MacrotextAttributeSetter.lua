--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local WAttr, Assert = GC.WidgetAttributes, O.Assert
local AssertNotNil = Assert.AssertNotNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacrotextAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(M.MacrotextAttributeSetter); if not S then return end
---@type BaseAttributeSetter
local BaseAttributeSetter = O.BaseAttributeSetter

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function S:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes(btnUI)

    local macroTextInfo = btnData[WAttr.MACRO_TEXT]
    if type(macroTextInfo) ~= 'table' then return end
    if not macroTextInfo.id then return end

    -- macro body

    AssertNotNil(macroTextInfo.id, 'btnData[item].macroInfo.id')

    local icon = GC.Textures.TEXTURE_EMPTY
    if macroTextInfo.icon then icon = macroTextInfo.icon end
    btnUI:SetNormalTexture(icon)
    btnUI:SetHighlightTexture(GC.Textures.TEXTURE_HIGHLIGHT)

    self:OnAfterSetAttributes(btnUI)
end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI)
    local bd = btnUI.widget:GetButtonData()
    if not bd:ConfigContainsValidActionType() then return end

    local btnData = btnUI.widget:GetConfig()
    local macroTextInfo = btnData[WAttr.MACRO_TEXT]

    GameTooltip:SetSpellByID(macroTextInfo.id)
end

S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes
