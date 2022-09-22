--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local GC = O.GlobalConstants
local WAttr, Assert = GC.WidgetAttributes, O.Assert
local AssertNotNil = Assert.AssertNotNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacrotextAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(Core.M.MacrotextAttributeSetter)
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

end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local macroTextInfo = btnData[WAttr.MACRO_TEXT]
    GameTooltip:SetOwner(btnUI, GC.C.ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(macroTextInfo.id)
end

S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes
