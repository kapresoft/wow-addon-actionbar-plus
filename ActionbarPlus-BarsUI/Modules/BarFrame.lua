--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)

local seedID = 4999

--[[-----------------------------------------------------------------------------
New Instance
BarFrame (secure)
    └── Handler (protected, hidden)
-------------------------------------------------------------------------------]]
--
--
local libName = 'BarFrameMixin_ABP_2_0_1'
--- @class BarFrameMixin_ABP_2_0_1 : Frame
--- @field widget BarFrameWidget_ABP_2_0
--- @field _originalLevel number
local o = {}; BarFrameMixin_ABP_2_0_1 = o
local p, t = ns:log(libName)

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
function o:OnSizeChanged()
  if not self.widget then return end
  self.widget:ApplyBackdrop()
end

