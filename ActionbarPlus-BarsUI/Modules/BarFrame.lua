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
--- @field _originalLevel number
local S = {};
BarFrameMixin_ABP_2_0_1 = S
local p, pd, t, tf = ns:log(libName)

--- @type BarFrameMixin_ABP_2_0_1 | BarFrameObj_ABP_2_0
local o = S

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
end
-- initially OnLoad() the self.widget is not defined
-- But this method will eventually be called once
-- BarFrame:SetSize(w, h) is called.
function o:OnSizeChanged()
  if not self.widget then return end
  self.widget:ApplyBackdrop()
end

