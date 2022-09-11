-- ## External -------------------------------------------------
local GameTooltip = GameTooltip

-- ## Local ----------------------------------------------------

-- LocalLibStub, Module, Assert, Profile, LibSharedMedia, WidgetLibFactory, LibGlobals
local LibStub, M, Assert, _, _, W = ABP_WidgetConstants:LibPack()
local _, _, String, _ = ABP_LibGlobals:LibPackUtils()
local _, WAttr = W:LibPack_WidgetAttributes()
local WU = ABP_LibGlobals:LibPack_WidgetUtil()

local _, TEXTURE_EMPTY, ANCHOR_TOPLEFT = TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local AssertNotNil, _ = Assert.AssertNotNil, String.IsNotBlank

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ItemAttributeSetter : BaseAttributeSetter
local _L = LibStub:NewLibrary(M.ItemAttributeSetter, 1)
---@type BaseAttributeSetter
local Base = LibStub(M.BaseAttributeSetter)
_L.mt.__index = Base

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@param btnUI ButtonUI
---@param btnData ProfileButton
function _L:SetAttributes(btnUI, btnData)
    W:ResetWidgetAttributes(btnUI)
    local itemData = btnData[WAttr.ITEM]
    if type(itemData) ~= 'table' then return end
    if not itemData.id then return end

    AssertNotNil(itemData.id, 'btnData[item].itemInfo.id')

    local icon = TEXTURE_EMPTY
    if itemData.icon then icon = itemData.icon end

    btnUI.widget:SetIcon(icon)
    btnUI:SetAttribute(WAttr.TYPE, WAttr.ITEM)
    btnUI:SetAttribute(WAttr.ITEM, itemData.name)

    self:HandleGameTooltipCallbacks(btnUI)
end

---@param btnUI ButtonUI
function _L:ShowTooltip(btnUI)
    if not btnUI then return end
    local w = btnUI.widget
    local btnData = w:GetConfig()
    if not btnData then return end
    if String.IsBlank(btnData.type) then return end

    ---@type ItemData
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    local itemInfo = btnData[WAttr.ITEM]
    if itemInfo and itemInfo.id then
        GameTooltip:SetItemByID(itemInfo.id)
    end
end

--[[-----------------------------------------------------------------------------
Constructor Setup
-------------------------------------------------------------------------------]]
_L.mt.__call = _L.SetAttributes

