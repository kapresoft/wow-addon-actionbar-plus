local BATTR, RWAttr, WAttr, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT =
ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local LOG, AssertNotNil, format, IsNotBlank =
LogFactory, Assert.AssertNotNil, string.format, string.IsNotBlank
local GameTooltip = GameTooltip

local S = {}
MacroAttributeSetter = S
LOG:EmbedLogger(S, 'Widget::Buttons::MacroAttributeSetter')

--- Macro Info:
--- `{
--- }`
function S:SetAttributes(btnUI, btnData)
    RWAttr(btnUI)

    local macroInfo = btnData[WAttr.MACRO]
    if type(macroInfo) ~= 'table' then return end
    if not macroInfo.id then return end

    AssertNotNil(macroInfo.id, 'btnData[item].macroInfo.id')

    local icon = TEXTURE_EMPTY
    if macroInfo.icon then icon = macroInfo.icon end
    btnUI:SetNormalTexture(icon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)

end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local macroInfo = btnData[WAttr.MACRO]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:AddSpellByID(macroInfo.id)
end

setmetatable(S, {
    __call = function (_, ...)
        return S:SetAttributes(...)
    end
})