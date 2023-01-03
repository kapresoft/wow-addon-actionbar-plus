--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local GC = O.GlobalConstants
local Assert, String, WAttr = O.Assert, O.String, GC.WidgetAttributes
local AssertNotNil = Assert.AssertNotNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ItemAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(Core.M.ItemAttributeSetter)
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(Core.M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@param btnUI ButtonUI
---@param btnData Profile_Button
function S:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes(btnUI)
    local itemData = btnData[WAttr.ITEM]
    if type(itemData) ~= 'table' then return end
    if not itemData.id then return end

    AssertNotNil(itemData.id, 'btnData[item].itemInfo.id')

    btnUI.widget:SetIcon(itemData.icon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.ITEM)
    btnUI:SetAttribute(WAttr.ITEM, itemData.name)

    self:OnAfterSetAttributes(btnUI)
end

---@param btnUI ButtonUI
function S:ShowTooltip(btnUI)
    local bd = btnUI.widget:GetButtonData()
    if not bd:ConfigContainsValidActionType() then return end

    local btnData = btnUI.widget:GetConfig()
    local itemInfo = btnData[WAttr.ITEM]
    if itemInfo and itemInfo.id then GameTooltip:SetItemByID(itemInfo.id) end
end


S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes
