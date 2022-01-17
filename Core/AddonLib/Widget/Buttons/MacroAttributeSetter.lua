local BATTR, RWAttr, WAttr, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT =
ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local LOG, AssertNotNil, format, IsNotBlank =
ABP_LogFactory, Assert.AssertNotNil, string.format, string.IsNotBlank
local GameTooltip = GameTooltip

local S = {}
MacroAttributeSetter = S
LOG:EmbedLogger(S, 'MacroAttributeSetter')

--- Macro Info:
--- {
---     body = '/run message(GetXPExhaustion())\n',
---     icon = 132096,
---     macroIndex = 1,
---     name = '#GetRestedXP',
---     type = 'macro'
--- }
function S:SetAttributes(btnUI, btnData)
    RWAttr(btnUI)

    local macroInfo = btnData[WAttr.MACRO]
    local icon = TEXTURE_EMPTY
    if macroInfo.icon then icon = macroInfo.icon end
    btnUI:SetAttribute(WAttr.TYPE, WAttr.MACRO)
    btnUI:SetAttribute(WAttr.MACRO, macroInfo.name)
    btnUI:SetNormalTexture(icon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI, btnData)  end)
end

---@param link table The blizzard `GameTooltip` link
function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local macroInfo = btnData[WAttr.MACRO]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    ABP_PREFIX = '|cfdffffff{{|r|cfd2db9fbActionBarPlus|r|cfdfbeb2d%s|r|cfdffffff}}|r'

    local macroLabel = ' |cfd5a5a5a(Macro)|r'
    GameTooltip:SetText(macroInfo.name .. macroLabel)
end

S.mt.__call = S.SetAttributes
