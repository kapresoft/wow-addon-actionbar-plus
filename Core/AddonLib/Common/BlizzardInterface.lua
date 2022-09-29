-- Blizzard Interface Types for EmmyLua
-- This file does not need to be included in _Common.xml

---@class Blizzard_Region
local Blizzard_Region = {}

---@class Blizzard_Frame : Blizzard_Region
local Blizzard_Frame = {}
--[[-----------------------------------------------------------------------------
AnchorMixinInterface
-------------------------------------------------------------------------------]]
---@class Blizzard_AnchorMixin
---@see "Interface/SharedXML/AnchorUtil.lua"
local Blizzard_AnchorMixin = {
    point = '',
    relativeTo = nil,
    relativePoint = '',
    x = 0.0,
    y = 0.0,
};
---@param point string CENTER, TOPLEFT, etc..
---@param relativeTo Blizzard_Region
---@param relativePoint string CENTER, TOPLEFT, etc..
---@param x number
---@param y number
function Blizzard_AnchorMixin:Init(point, relativeTo, relativePoint, x, y) end
---@param point string CENTER, TOPLEFT, etc..
---@param relativeTo Blizzard_Region
---@param relativePoint string CENTER, TOPLEFT, etc..
---@param x number
---@param y number
function Blizzard_AnchorMixin:Set(point, relativeTo, relativePoint, x, y) end

---@param region Blizzard_Region
---@param pointIndex string CENTER, TOPLEFT, etc..
function Blizzard_AnchorMixin:SetFromPoint(region, pointIndex) end
function Blizzard_AnchorMixin:Get() end
---@param region Blizzard_Region
---@param clearAllPoints boolean
function Blizzard_AnchorMixin:SetPoint(region, clearAllPoints) end
---@param region Blizzard_Region
---@param clearAllPoints boolean
---@param extraOffsetX number
---@param extraOffsetY number
function Blizzard_AnchorMixin:SetPointWithExtraOffset(region, clearAllPoints, extraOffsetX, extraOffsetY) end

---@class Blizzard_AnchorUtil : Blizzard_AnchorMixin
local Blizzard_AnchorUtil = {}
---@param point string CENTER, TOPLEFT, etc..
---@param relativeTo Blizzard_Region
---@param relativePoint string CENTER, TOPLEFT, etc..
---@param x number
---@param y number
function Blizzard_AnchorUtil.CreateAnchor(point, relativeTo, relativePoint, x, y) end
---@param region Blizzard_Region
---@param pointIndex number
function Blizzard_AnchorUtil.CreateAnchorFromPoint(region, pointIndex) end

---@class Blizzard_RegionAnchor
local Blizzard_RegionAnchor = {
    point="CENTER", relativeTo=nil, relativePoint='CENTER', x=0.0, y=0.0
}
