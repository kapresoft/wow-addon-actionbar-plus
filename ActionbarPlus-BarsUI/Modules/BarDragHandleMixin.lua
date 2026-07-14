--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O, L = ns:cns()

--[[-----------------------------------------------------------------------------
New Instance
BarDragHandle: small square, drag target for moving the parent bar frame.
Shown only when the bar's backdrop theme is 'none' (no border/title to grab).
-------------------------------------------------------------------------------]]
local libName = 'BarDragHandleMixin_ABP_2_0'
--- @class BarDragHandleMixin_ABP_2_0 : Frame
--- @field barFrame BarFrame_ABP_2_0
local o = {}; BarDragHandleMixin_ABP_2_0 = o
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]

function o:OnLoad()
  self:RegisterForDrag('LeftButton')
end

function o:OnDragStart()
  if InCombatLockdown() then return end
  self.__dragging = true
  self.tex:Show()
  self.barFrame:OnDragStart()
end

function o:OnDragStop()
  if InCombatLockdown() then return end
  self.__dragging = false
  self.barFrame:OnDragStop()
  if not self:IsMouseOver() then self.barFrame.widget:HideDragHandle() end
end

--- Forwards to the bar frame's existing right-click handler since the handle
--- sits where the bar frame would otherwise catch the click (now click-through
--- when empty buttons are hidden).
function o:OnMouseUp(button)
  self.barFrame:OnMouseUp(button)
end

function o:OnEnter()
  if InCombatLockdown() then return end
  self.barFrame.widget:ShowDragHandle()
  self.barFrame:OnEnter()
end

function o:OnLeave()
  if InCombatLockdown() then return end
  self.barFrame:OnLeave()
  self.barFrame.widget:HideDragHandle()
end
