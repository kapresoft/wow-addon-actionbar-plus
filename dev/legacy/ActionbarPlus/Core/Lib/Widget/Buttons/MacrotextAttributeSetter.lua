--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local WAttr, Assert = GC.WidgetAttributes, ns:Assert()
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
---@param btnUI ButtonUI
function S:ShowTooltip(btnUI)
    local w = btnUI.widget
    if not w:ConfigContainsValidActionType() then return end

    local macroTextInfo = w:GetMacroTextData()
    --- add if w:IsInvalidMacroTextData() then return end
    GameTooltip:SetSpellByID(macroTextInfo.id)
end

S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes
