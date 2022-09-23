--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
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
---@param btnData ProfileButton
function S:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes(btnUI)
    local itemData = btnData[WAttr.ITEM]
    if type(itemData) ~= 'table' then return end
    if not itemData.id then return end

    AssertNotNil(itemData.id, 'btnData[item].itemInfo.id')

    local icon = GC.Textures.TEXTURE_EMPTY
    if itemData.icon then icon = itemData.icon end

    btnUI.widget:SetIcon(icon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.ITEM)
    btnUI:SetAttribute(WAttr.ITEM, itemData.name)

    self:HandleGameTooltipCallbacks(btnUI)
end

---@param btnUI ButtonUI
function S:ShowTooltip(btnUI)
    if not btnUI then return end
    local w = btnUI.widget
    local btnData = w:GetConfig()
    if not btnData then return end
    if String.IsBlank(btnData.type) then return end

    ---@type ItemData
    GameTooltip:SetOwner(btnUI, GC.C.ANCHOR_TOPLEFT)
    local itemInfo = btnData[WAttr.ITEM]
    if itemInfo and itemInfo.id then
        GameTooltip:SetItemByID(itemInfo.id)
    end
end


S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes
