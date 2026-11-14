--[[-----------------------------------------------------------------------------
HelpTour: ActionbarPlus's LibHelpTour controller.
@see TourList.lua
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)
local L = ns:GetLocale()
local TourList = ns.O.TourList
local HelpTourLib = LibStub('LibHelpTour-1.0')

local TARGET_ID = 'Bar'

--- @see Core_Modules_ABP_2_0
local libName = ns.M.HelpTour()
--- @class HelpTour_ABP_2_0
--- @field controller LibHelpTour_Controller
local o = {}; ns:Register(libName, o)

o.controller = HelpTourLib:New({
  tours = TourList,
  dismissed = function() return ns:g().helpTipsDismissed end,
  getBaseline = function() return ns:g().tourBaseline end,
  setBaseline = function(baseline) ns:g().tourBaseline = baseline end,
  text = function(textKey) return L[textKey] end,
  -- Above the options dialog, for its settings icon step
  tipStrata = 'TOOLTIP',
})

--- @type BarFrameWidget_ABP_2_0?
local glowingBar
local tipHideHooked = false

--- The drag handle glows while its tip points at it.
local function SyncHandleGlow()
  local showing = o.controller.showing
  local isHandleStep = showing and showing.step.key == 'BarDragHandle'
  local w = isHandleStep and showing.target.widget or nil
  if w == glowingBar then return end
  if glowingBar then glowingBar:StopHandleGlow() end
  glowingBar = w
  if w then w:StartHandleGlow() end
end

--- The tip is created on its first show.
local function HookTipHide()
  local tip = o.controller.tip
  if tipHideHooked or not tip then return end
  tip:HookScript('OnHide', SyncHandleGlow)
  tipHideHooked = true
end

--- @param barFrame BarFrame_ABP_2_0
function o:ShowOn(barFrame)
  self.controller:OnTargetShown(TARGET_ID, barFrame)
  HookTipHide()
  SyncHandleGlow()
end

--- For anchors just shown or moved: their position resolves
--- only after this frame's layout pass.
--- @param barFrame BarFrame_ABP_2_0
function o:ShowOnNextFrame(barFrame)
  C_Timer.After(0, function() self:ShowOn(barFrame) end)
end

--- @alias HelpTourStepKey_ABP_2_0
--- | 'BarActionButton'
--- | 'BarMenu'
--- | 'BarSettings'
--- | 'QuickKeybindHover'
--- | 'QuickKeybindOkay'
--- | 'BarDragHandle'
--- | 'BarAddOns'

--- @param key HelpTourStepKey_ABP_2_0
function o:Complete(key)
  self.controller:CompleteStep(key)
  SyncHandleGlow()
end
