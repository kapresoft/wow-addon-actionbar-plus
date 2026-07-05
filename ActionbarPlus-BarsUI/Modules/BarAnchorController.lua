--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = 'BarAnchorController'

--- @class BarAnchorController_ABP_2_0 : AceEvent-3.0
local o = cns:NewAceEvent(); ns:Register(libName, o)
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @param barIndex Index
--- @return Anchor
local function GetAnchorConfig(barIndex)
  if cns:p().characterSpecificAnchors then
    return cns:bar(barIndex).anchor
  end
  return cns:barGlobal(barIndex).anchor
end

--- @param barFrame BarFrame_ABP_2_0
local function SaveAnchor(barFrame)
  assert(type(barFrame) == 'table', "SaveAnchor(barFrame): {barFrame} is missing")
  --- @type RegionAnchor
  local barIndex = barFrame.widget.index
  local point, relativeTo, relativePoint, x, y = barFrame:GetPoint(1)
  local anchor = GetAnchorConfig(barIndex)
  anchor.point         = point
  anchor.relativePoint = relativePoint
  anchor.x             = x
  anchor.y             = y
  anchor.relativeTo    = relativeTo and relativeTo:GetName() or nil
end

--- @param barFrame BarFrame_ABP_2_0
local function RestoreAnchor(barFrame)
  local barIndex = barFrame.widget.index
  local anchor = GetAnchorConfig(barIndex)
  if not (anchor and anchor.point) then return end
  barFrame:ClearAllPoints()
  barFrame:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.x, anchor.y)
end

--- @param msg string @The message name
--- @param barFrame BarFrame_ABP_2_0
function o.OnBarFrameDragStop(msg, barFrame) SaveAnchor(barFrame) end

--- Called from BarModuleFactory after bar frame is created
--- @param barFrame BarFrame_ABP_2_0
function o.ApplyAnchor(barFrame) RestoreAnchor(barFrame) end

--- Seeds the anchor store from the bar's current screen position.
--- @param barFrame BarFrame_ABP_2_0
function o.SeedAnchor(barFrame) SaveAnchor(barFrame) end

--[[-----------------------------------------------------------------------------
Register Messages
-------------------------------------------------------------------------------]]
o:RegisterMessage(ns:msg('OnEnable'), function()
  o:RegisterMessage(ns:msg('OnBarFrameDragStop'), o.OnBarFrameDragStop)
end)
