--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetItemInfo = GetItemInfo

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, LibStub, ns = ABP_LibPack()

local P, Assert, Table, PH = O.Profile, O.Assert, O.Table, O.PickupHandler
local ItemAttributeSetter, WAttr = O.ItemAttributeSetter, O.GlobalConstants.WidgetAttributes
local IsNil = Assert.IsNil
local API = O.API

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ItemDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(ns.M.ItemDragEventHandler); if not L then return end

-- ## Functions ------------------------------------------------
--- Item Cursor Info `{ type = cursorInfo.actionType, id=cursorInfo.info1, link=cursorInfo.info2 }`
---@param btnUI ButtonUI
---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
function L:Handle(btnUI, cursorInfo)
    if not self:IsValid(btnUI, cursorInfo) then return end

    local itemID = cursorInfo.info1
    ---@type ItemInfo
    local itemInfo = API:GetItemInfo(itemID)
    local itemData = { id = itemID, name = itemInfo.name, icon = itemInfo.icon,
                       link = itemInfo.link, count = itemInfo.count, stackCount=itemInfo.stackCount }
    local actionbarInfo = btnUI.widget:GetActionbarInfo()

    local btnName = btnUI:GetName()
    local barData = P:GetBar(actionbarInfo.index)

    local btnData = barData.buttons[btnName]
    PH:PickupExisting(btnUI.widget)
    btnData.type = WAttr.ITEM
    btnData[WAttr.ITEM] = itemData

    ItemAttributeSetter(btnUI, btnData)
    btnUI.widget:UpdateItemState()
end

function L:GetItemDetails(itemId)
    local itemName, itemLink,
    itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
    itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent = GetItemInfo(itemId)
    return { id = itemId, name = itemName, link = itemLink, icon = itemTexture }
end

function L:IsValid(btnUI, cursorInfo)
    if Table.isEmpty(cursorInfo) then return false end
    if IsNil(cursorInfo.type) or IsNil(cursorInfo.info1) or IsNil(cursorInfo.info2) then
        return false
    end

    return true
end
