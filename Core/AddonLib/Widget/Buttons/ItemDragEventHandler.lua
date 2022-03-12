-- ## External -------------------------------------------------
local GetItemInfo = GetItemInfo
local _, Table = ABP_LibGlobals:LibPackUtils()

-- ## Local ----------------------------------------------------
-- LocalLibStub, Module, Assert, Profile, LibSharedMedia, WidgetLibFactory, LibGlobals
local LibStub, M, Assert, P, LSM, W, CC = ABP_WidgetConstants:LibPack()

local AssertNotNil, IsNil = Assert.AssertNotNil, Assert.IsNil
local ItemAttributeSetter = W:ItemAttributeSetter()
local WAttr = CC.WidgetAttributes
local PH = ABP_PickupHandler

---@class ItemDragEventHandler
local _L = LibStub:NewLibrary(M.ItemDragEventHandler, 1)

-- ## Functions ------------------------------------------------
--- Item Cursor Info `{ type = cursorInfo.actionType, id=cursorInfo.info1, link=cursorInfo.info2 }`
---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
function _L:Handle(btnUI, cursorInfo)
    if not self:IsValid(btnUI, cursorInfo) then return end
    local item = self:GetItemDetails(cursorInfo.info1)
    local itemInfo = { id = item.id, name = item.name, icon = item.icon, link = item.link, }
    --self:logp('itemInfo', itemInfo)
    --ABP:DBG('ItemInfo', itemInfo)

    local actionbarInfo = btnUI.widget:GetActionbarInfo()
    --self:logp('ActionBar', actionbarInfo)
    local btnName = btnUI:GetName()
    local barData = P:GetBar(actionbarInfo.index)

    local btnData = barData.buttons[btnName] or P:GetTemplate().Button
    PH:PickupExisting(btnData)
    btnData.type = WAttr.ITEM
    btnData[WAttr.ITEM] = itemInfo

    ItemAttributeSetter(btnUI, btnData)
end

function _L:GetItemDetails(itemId)
    local itemName, itemLink,
    itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
    itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent = GetItemInfo(itemId)
    return { id = itemId, name = itemName, link = itemLink, icon = itemTexture }
end

function _L:IsValid(btnUI, cursorInfo)
    if Table.isEmpty(cursorInfo) then return false end
    if IsNil(cursorInfo.type) or IsNil(cursorInfo.info1) or IsNil(cursorInfo.info2) then
        return false
    end

    return true
end
