-- ## External -------------------------------------------------
local GameTooltip = GameTooltip

-- ## Local ----------------------------------------------------
local LibStub, M, A, P, LSM, W = ABP_WidgetConstants:LibPack()
local PrettyPrint = ABP_LibGlobals:LibPackUtils()
local pformat = PrettyPrint.pformat
local BATTR, WAttr, RWAttr = W:LibPack_WidgetAttributes()
local TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT = TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT

---@class MacrotextAttributeSetter
local S = LibStub:NewLibrary(M.MacrotextAttributeSetter)

-- ## Functions ------------------------------------------------

--- Macrotext Info:
--- `{
---
--- }`
function S:SetAttributes(btnUI, btnData)
    W:ResetWidgetAttributes(btnUI)

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
