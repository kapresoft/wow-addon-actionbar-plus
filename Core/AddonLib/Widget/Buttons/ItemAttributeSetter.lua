-- ## External -------------------------------------------------
local GameTooltip = GameTooltip
local format = string.format

-- ## Local ----------------------------------------------------

-- LocalLibStub, Module, Assert, Profile, LibSharedMedia, WidgetLibFactory, LibGlobals
local LibStub, M, Assert, P, LSM, W = ABP_WidgetConstants:LibPack()
local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
local BATTR, WAttr = W:LibPack_WidgetAttributes()

local TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT = TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local AssertNotNil, IsNotBlank = Assert.AssertNotNil, String.IsNotBlank

-- ## Functions ------------------------------------------------

---@class ItemAttributeSetter
local _L = LibStub:NewLibrary(M.ItemAttributeSetter, 1)

--- Item Info:
--- `{
---   id = 20857,
---   name = 'Honey Bread',
---   icon = 133964,
---   link = '[Honey Bread]',
--- }`
function _L:SetAttributes(btnUI, btnData)
    W:ResetWidgetAttributes(btnUI)

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

function _L:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local itemInfo = btnData[WAttr.ITEM]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    GameTooltip:SetItemByID(itemInfo.id)

end

_L.mt.__call = _L.SetAttributes
