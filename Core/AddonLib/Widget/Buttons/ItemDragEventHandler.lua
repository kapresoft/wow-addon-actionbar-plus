-- ## External -------------------------------------------------
local GetItemInfo = GetItemInfo
local _, Table = ABP_LibGlobals:LibPackUtils()

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local P, Assert, PH = O.Profile, O.Assert, O.PickupHandler
local ItemAttributeSetter, WAttr = O.ItemAttributeSetter, O.CommonConstants.WidgetAttributes
local IsNil = Assert.IsNil

--TODO: NEXT: Add _API to GlobalObjects
local _API = _API

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ItemDragEventHandler
local _L = LibStub:NewLibrary(Core.M.ItemDragEventHandler)

-- ## Functions ------------------------------------------------
--- Item Cursor Info `{ type = cursorInfo.actionType, id=cursorInfo.info1, link=cursorInfo.info2 }`
---@param btnUI ButtonUI
---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
function _L:Handle(btnUI, cursorInfo)
    if not self:IsValid(btnUI, cursorInfo) then return end
    --local item = self:GetItemDetails(cursorInfo.info1)
    local itemID = cursorInfo.info1
    ---@type ItemInfo
    local itemInfo = _API:GetItemInfo(itemID)
    local itemData = { id = itemID, name = itemInfo.name, icon = itemInfo.icon,
                       link = itemInfo.link, count = itemInfo.count, stackCount=itemInfo.stackCount }
    --self:log('itemInfo: %s', itemInfo)
    --ABP:DBG({info=itemInfo, data=itemData})

    local actionbarInfo = btnUI.widget:GetActionbarInfo()
    --self:logp('ActionBar', actionbarInfo)
    local btnName = btnUI:GetName()
    local barData = P:GetBar(actionbarInfo.index)

    local btnData = barData.buttons[btnName] or P:GetTemplate().Button
    PH:PickupExisting(btnData)
    btnData.type = WAttr.ITEM
    btnData[WAttr.ITEM] = itemData

    ItemAttributeSetter(btnUI, btnData)
    btnUI.widget:UpdateItemState()
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
