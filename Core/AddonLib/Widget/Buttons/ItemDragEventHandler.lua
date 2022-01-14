local AssertNotNil, IsNil = Assert.AssertNotNil, Assert.IsNil
local WLIB, ItemAttributeSetter = WidgetLibFactory, ItemAttributeSetter
local ButtonAttributes, _API_Spell = ButtonAttributes, _API_Spell
local LOG = ABP_LogFactory

local P = WLIB:GetProfile()

local S = {}
LOG:EmbedLogger(S, 'ItemDragEventHandler')
ItemDragEventHandler = S

--- Item Cursor Info `{ type = cursorInfo.actionType, id=cursorInfo.info1, link=cursorInfo.info2 }`
---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
function S:Handle(btnUI, cursorInfo)
    if not self:IsValid(btnUI, cursorInfo) then return end
    local itemInfo = { type = cursorInfo.type,
                       id = cursorInfo.info1, link = cursorInfo.info2 }
    local itemName, itemLink,
        itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
        itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(itemInfo.id)
    local itemInfo = {
        id = itemInfo.id,
        name = itemName,
        icon = itemTexture,
        link = itemLink,
    }
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

function S:IsValid(btnUI, cursorInfo)
    if table.isEmpty(cursorInfo) then return false end
    if IsNil(cursorInfo.type) or IsNil(cursorInfo.info1) or IsNil(cursorInfo.info2) then
        return false
    end

    return true
end
