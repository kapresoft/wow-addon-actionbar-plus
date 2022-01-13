local BATTR, RWAttr, WAttr, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT =
ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local LOG, AssertNotNil, format, IsNotBlank =
ABP_LogFactory, Assert.AssertNotNil, string.format, string.IsNotBlank
local GameTooltip = GameTooltip

local S = {}
MacrotextAttributeSetter = S
LOG:EmbedLogger(S, 'MacrotextAttributeSetter')

--- Macrotext Info:
--- `{
---
--- }`
function S:SetAttributes(btnUI, btnData)
    RWAttr(btnUI)

    local macroTextInfo = btnData[WAttr.MACRO_TEXT]
    if type(macroTextInfo) ~= 'table' then return end
    if not macroTextInfo.id then return end

    -- macro body

    AssertNotNil(macroTextInfo.id, 'btnData[item].macroInfo.id')

    local icon = TEXTURE_EMPTY
    if macroTextInfo.icon then icon = macroTextInfo.icon end
    btnUI:SetNormalTexture(icon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)

end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local macroTextInfo = btnData[WAttr.MACRO_TEXT]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(macroTextInfo.id)
end

S.mt.__call = S.SetAttributes
