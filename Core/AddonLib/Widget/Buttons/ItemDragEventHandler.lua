-- ## External -------------------------------------------------
local GetItemInfo = GetItemInfo

-- ## Local ----------------------------------------------------
-- LocalLibStub, Module, Assert, Profile, LibSharedMedia, WidgetLibFactory, LibGlobals
local LibStub, M, Assert, P, LSM, W, CC = ABP_WidgetConstants:LibPack()

local AssertNotNil, IsNil = Assert.AssertNotNil, Assert.IsNil
local ItemAttributeSetter = W:ItemAttributeSetter()
local WidgetAttributes = CC.WidgetAttributes

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

    local actionbarInfo = btnUI:GetActionbarInfo()
    --self:logp('ActionBar', actionbarInfo)
    local btnName = btnUI:GetName()
    local barData = P:GetBar(actionbarInfo.index)

    local btnData = barData.buttons[btnName] or P:GetTemplate().Button
    btnData.type = WidgetAttributes.ITEM
    btnData[btnData.type] = itemInfo
    barData.buttons[btnName] = btnData
    --ABP:DBG('btnData', btnData)

    ItemAttributeSetter(btnUI, btnData)
end

function _L:GetItemDetails(itemId)
    local itemName, itemLink,
    itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
    itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent = GetItemInfo(itemCursor.id)
    return { id = itemId, name = itemName, link = itemLink, icon = itemTexture }
end

function _L:IsValid(btnUI, cursorInfo)
    if table.isEmpty(cursorInfo) then return false end
    if IsNil(cursorInfo.type) or IsNil(cursorInfo.info1) or IsNil(cursorInfo.info2) then
        return false
    end

    return true
end
