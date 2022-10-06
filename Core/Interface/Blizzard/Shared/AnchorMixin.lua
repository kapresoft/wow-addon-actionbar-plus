-- Blizzard Interface Types for EmmyLua
-- This file does not need to be included in _Common.xml

--[[-----------------------------------------------------------------------------
AnchorMixinInterface
-------------------------------------------------------------------------------]]
---@class _AnchorMixin
---@see "Interface/SharedXML/AnchorUtil.lua"
local _AnchorMixin = {
    point = '',
    relativeTo = nil,
    relativePoint = '',
    x = 0.0,
    y = 0.0,
};
---@param point string CENTER, TOPLEFT, etc..
---@param relativeTo _Region
---@param relativePoint string CENTER, TOPLEFT, etc..
---@param x number
---@param y number
function _AnchorMixin:Init(point, relativeTo, relativePoint, x, y) end
---@param point string CENTER, TOPLEFT, etc..
---@param relativeTo _Region
---@param relativePoint string CENTER, TOPLEFT, etc..
---@param x number
---@param y number
function _AnchorMixin:Set(point, relativeTo, relativePoint, x, y) end

---@param region _Region
---@param pointIndex string CENTER, TOPLEFT, etc..
function _AnchorMixin:SetFromPoint(region, pointIndex) end
function _AnchorMixin:Get() end
---@param region _Region
---@param clearAllPoints boolean
function _AnchorMixin:SetPoint(region, clearAllPoints) end
---@param region _Region
---@param clearAllPoints boolean
---@param extraOffsetX number
---@param extraOffsetY number
function _AnchorMixin:SetPointWithExtraOffset(region, clearAllPoints, extraOffsetX, extraOffsetY) end

---@class _AnchorUtil : _AnchorMixin
local _AnchorUtil = {}
---@param point string CENTER, TOPLEFT, etc..
---@param relativeTo _Region
---@param relativePoint string CENTER, TOPLEFT, etc..
---@param x number
---@param y number
function _AnchorUtil.CreateAnchor(point, relativeTo, relativePoint, x, y) end
---@param region _Region
---@param pointIndex number
function _AnchorUtil.CreateAnchorFromPoint(region, pointIndex) end
