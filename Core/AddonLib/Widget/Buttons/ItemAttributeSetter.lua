local BATTR, RWAttr, WAttr, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT =
ButtonAttributes, ResetWidgetAttributes, WidgetAttributes, TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local LOG, AssertNotNil, format, IsNotBlank =
LogFactory, Assert.AssertNotNil, string.format, string.IsNotBlank
local GameTooltip = GameTooltip

local S = {}
ItemAttributeSetter = S
LOG:EmbedLogger(S, 'ItemAttributeSetter')

--- Item Info:
--- `{
---   id = 20857,
---   name = 'Honey Bread',
---   icon = 133964,
---   link = '[Honey Bread]',
--- }`
function S:SetAttributes(btnUI, btnData)
    RWAttr(btnUI)

    local itemInfo = btnData[WAttr.ITEM]
    if type(itemInfo) ~= 'table' then return end
    if not itemInfo.id then return end

    AssertNotNil(itemInfo.id, 'btnData[item].itemInfo.id')

    local icon = TEXTURE_EMPTY
    if itemInfo.icon then icon = itemInfo.icon end
    btnUI:SetNormalTexture(icon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)

    btnUI:SetAttribute(WAttr.TYPE, WAttr.ITEM)
    btnUI:SetAttribute(WAttr.ITEM, itemInfo.name)
    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI, btnData)  end)
end

function S:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local itemInfo = btnData[WAttr.ITEM]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:SetItemByID(itemInfo.id)

end

S.mt.__call = S.SetAttributes
