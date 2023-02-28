--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local Assert, String, WAttr = O.Assert, O.String, GC.WidgetAttributes
local AssertNotNil = Assert.AssertNotNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ItemAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(M.ItemAttributeSetter); if not S then return end
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@param btnUI ButtonUI
function S:SetAttributes(btnUI)
    local w = btnUI.widget
    w:ResetWidgetAttributes(btnUI)
    local itemData = w:GetItemData()
    if w:IsInvalidItem(itemData) then return end

    AssertNotNil(itemData.id, 'btnData[item].itemInfo.id')

    btnUI.widget:SetIcon(itemData.icon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.ITEM)
    btnUI:SetAttribute(WAttr.ITEM, itemData.name)

    self:OnAfterSetAttributes(btnUI)
end

---@param btnUI ButtonUI
function S:ShowTooltip(btnUI)
    local w = btnUI.widget
    if not w:ConfigContainsValidActionType() then return end

    local itemInfo = w:GetItemData()
    if w:IsInvalidItem(itemInfo) then return end

    if itemInfo and itemInfo.id then GameTooltip:SetItemByID(itemInfo.id) end
end


S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes
