--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns, O = ns:cns()

local seedID = 4999
local hc = cns:ColorFn("539AFA")
local hct = cns:ColorFn("FFE680")
local hcd = cns:ColorFn("a9a9a9")

--[[-----------------------------------------------------------------------------
New Instance
BarFrame (secure)
    └── Handler (protected, hidden)
-------------------------------------------------------------------------------]]

local libName = 'BarFrameMixin_ABP_2_0_1'
--- @class BarFrameMixin_ABP_2_0_1 : Frame
--- @field widget BarFrameWidget_ABP_2_0
--- @field _originalLevel number
local o = {}; BarFrameMixin_ABP_2_0_1 = o
local p, t = ns:log(libName)

--- @return BarContextMenu_ABP_2_0
local function bcm() return ns.O.BarContextMenu end

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]

function o:OnLoad()
  --if not ns:IsV2() then self:UnregisterAllEvents(); self:Hide(); return; end
  self:RegisterForDrag("LeftButton")
end

function o:OnDragStart()
  if InCombatLockdown() then return end
  self._originalLevel = self:GetFrameLevel()
  self:StartMoving()
end
function o:OnDragStop()
  if InCombatLockdown() then return end
  self:StopMovingOrSizing()
  if self._originalLevel then
    self:SetFrameLevel(self._originalLevel)
    self._originalLevel = nil
  end
  ns:a():SendMessage(ns:msg('OnBarFrameDragStop'), self)
end
-- initially OnLoad() the self.widget is not defined
-- But this method will eventually be called once
-- BarFrame:SetSize(w, h) is called.
function o:OnMouseUp(button)
  if InCombatLockdown() then return end
  if button == 'RightButton' then bcm():Show(self) end
end

function o:OnSizeChanged()
  if not self.widget then return end
  self.widget:ApplyBackdrop()
end

function o:OnEnter()
  if not self.widget then return end
  local w = self.widget
  --todo: GameTooltip owner will be user configurable
  GameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
  GameTooltip:ClearAllPoints()
  GameTooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -10, 70)
  GameTooltip:ClearLines()
  GameTooltip:AddLine('ActionbarPlus — Bar ' .. w.index)
  if w.buttons then
    GameTooltip:AddLine(#w.buttons .. ' buttons', 0.8, 0.8, 0.8)
  end
  GameTooltip:AddLine(hc('\nAvailable Actions:'))
  GameTooltip:AddLine(hct('  • Right-Click ') .. hcd('to show options menu'))
  GameTooltip:AddLine(hct('  • Left-Drag ') .. hcd('to move to frame'))
  GameTooltip:Show()
end

function o:OnLeave() GameTooltip:Hide() end

