--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI_2_0
local ns = select(2, ...)
local cns = ns:cns()

--[[-----------------------------------------------------------------------------
DragStateController: Suspends and Restores action during drag operations
-------------------------------------------------------------------------------]]
--- @see BarsUI_Modules_ABP_2_0
local libName = 'DragStateController'

local MODIFIER_STATE_CHANGED = 'MODIFIER_STATE_CHANGED'

--- @class DragStateController_ABP_2_0
local o = ns:Register(libName, cns:NewAceEvent())
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

-- Prepares the button for a drag operation.
-- Suspends the button action and registers MODIFIER_STATE_CHANGED.
--- @param self Button_ABP_2_0_X
function o.Btn_PrepareForDrag(self)
  self:SetChecked(false)
  self.widget:SuspendAction()
  self:RegisterEvent(MODIFIER_STATE_CHANGED, o.OnModifierStateChanged, self)
end

-- Called when a drag operation has started
-- Unregisters MODIFIER_STATE_CHANGED
--- @param self Button_ABP_2_0_X
function o.Btn_OnDragStart(self)
  self:UnregisterEvent(MODIFIER_STATE_CHANGED)
end

-- Called when a modifier key state changes.
-- Restores the suspended action unless in combat lockdown.
--- @param self Button_ABP_2_0_X
function o.OnModifierStateChanged(self)
  self:UnregisterEvent(MODIFIER_STATE_CHANGED)
  if InCombatLockdown() then return end
  self.widget:RestoreAction()
end
