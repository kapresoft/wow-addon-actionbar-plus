--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetItemInfo = GetItemInfo

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local E, MSG = GC.E, GC.M

local P, Assert, Table, PH = O.Profile, ns:Assert(), ns:Table(), O.PickupHandler
local WAttr = ns.GC.WidgetAttributes
local IsNil, AssertNotNil = Assert.IsNil, Assert.AssertNotNil
local API, TT = O.API, O.TooltipUtil
local AceEvent = ns:AceLibrary().AceEvent

--[[-----------------------------------------------------------------------------
New Instance: ItemDragEventHandler
-------------------------------------------------------------------------------]]
---@class ItemDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(M.ItemDragEventHandler); if not L then return end
local p = ns:LC().ITEM:NewLogger(M.ItemDragEventHandler)

--[[-----------------------------------------------------------------------------
New Instance: ItemAttributeSetter
-------------------------------------------------------------------------------]]
---@class ItemAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(M.ItemAttributeSetter); if not S then return end
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods: ItemDragEventHandler
-------------------------------------------------------------------------------]]
---@param e ItemDragEventHandler
local function eventHandlerMethods(e)

    --- Item Cursor Info `{ type = cursorInfo.actionType, id=cursorInfo.info1, link=cursorInfo.info2 }`
    ---@param btnUI ButtonUI
    ---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
    function e:Handle(btnUI, cursorInfo)
        if not self:IsValid(btnUI, cursorInfo) then
            return
        end

        local itemID = cursorInfo.info1
        --- @type ItemInfoDetails
        local itemInfo = API:GetItemInfo(itemID)
        local itemData = { id = itemID, name = itemInfo.name, icon = itemInfo.icon,
                           link = itemInfo.link, count = itemInfo.count, stackCount = itemInfo.stackCount }

        local btnData = btnUI.widget:conf()
        PH:PickupExisting(btnUI.widget)
        btnData.type = WAttr.ITEM
        btnData[WAttr.ITEM] = itemData

        S(btnUI, btnData)
        btnUI.widget:UpdateItemState()

        AceEvent:SendMessage(MSG.OnUpdateItemState,
                             M.ItemDragEventHandler, btnUI.widget)
    end

    function e:GetItemDetails(itemId)
        local itemName, itemLink,
        itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
        itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(itemId)
        return { id = itemId, name = itemName, link = itemLink, icon = itemTexture }
    end

    function e:IsValid(btnUI, cursorInfo)
        if Table.isEmpty(cursorInfo) then
            return false
        end
        if IsNil(cursorInfo.type) or IsNil(cursorInfo.info1) or IsNil(cursorInfo.info2) then
            return false
        end

        return true
    end
end

--[[-----------------------------------------------------------------------------
Methods: ItemAttributeSetter
-------------------------------------------------------------------------------]]
---@param a ItemAttributeSetter
local function attributeSetterMethods(a)

    ---@param btnUI ButtonUI
    function a:SetAttributes(btnUI)
        local w = btnUI.widget
        w:ResetWidgetAttributes(btnUI)
        local itemData = w:GetItemData()
        if w:IsInvalidItem(itemData) then
            return
        end

        AssertNotNil(itemData.id, 'btnData[item].itemInfo.id')

        btnUI.widget:SetIcon(itemData.icon)
        btnUI:SetAttribute(WAttr.TYPE, WAttr.ITEM)
        btnUI:SetAttribute(WAttr.ITEM, 'item:' .. itemData.id)

        self:OnAfterSetAttributes(btnUI)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI) TT:ShowTooltip_Item(GameTooltip, btnUI.widget) end
end

--[[-----------------------------------------------------------------------------
Init
-------------------------------------------------------------------------------]]
local function Init()
    eventHandlerMethods(L)
    attributeSetterMethods(S)

    S.mt.__index = BaseAttributeSetter
    S.mt.__call = S.SetAttributes
end

Init()
