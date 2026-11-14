--[[-----------------------------------------------------------------------------
TourList: ActionbarPlus's help tours.

Step keys are saved as seen: keep them unique and never rename one.
@see HelpTour.lua
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @see Core_Modules_ABP_2_0
local libName = ns.M.TourList()

--- @param barIndex Index
--- @return Button? @nil unless this bar's options dialog is open
local function SettingsIcon(barIndex)
  local dialog = ns:OptionsNS().O.BarOptionsDialog
  if not dialog:IsShownForBar(barIndex) then return nil end
  return dialog:GetFrame().settingsIconBtn
end

--- @return QuickKeybindModeDialog_ABP_2_0
local function QuickKeybindDialog() return ns:OptionsNS().O.QuickKeybindModeDialog end

--- @return boolean
local function InQuickKeybindMode() return QuickKeybindDialog():IsShown() end

--- @return Frame? @nil unless Quick Keybind Mode is open
local function QuickKeybindOkay()
  return InQuickKeybindMode() and QuickKeybindDialog():GetOkayButton() or nil
end

--- @param f BarFrame_ABP_2_0
--- @return Button? @nil before the bar's buttons are created
local function FirstButton(f) return f.widget.buttons and f.widget.buttons[1] end

--- @type LibHelpTour_Tour[]
local o = {
  {
    id = 'bars',
    targetId = 'Bar',
    steps = {
      {
        key = 'BarActionButton',
        textKey = 'Action Button::HelpTip',
        --- @param f BarFrame_ABP_2_0
        anchor = function(f) return not InQuickKeybindMode() and FirstButton(f) or nil end,
      },
      {
        key = 'BarMenu',
        textKey = 'Bar Menu::HelpTip',
        --- @param f BarFrame_ABP_2_0
        anchor = function(f) return not f.widget.dragHandleEnabled and f or nil end,
      },
      {
        key = 'BarSettings',
        textKey = 'Settings::HelpTip',
        --- @param f BarFrame_ABP_2_0
        anchor = function(f) return SettingsIcon(f.widget.index) end,
      },
      {
        key = 'QuickKeybindHover',
        textKey = 'Quick Keybind::HelpTip',
        --- @param f BarFrame_ABP_2_0
        anchor = function(f) return InQuickKeybindMode() and FirstButton(f) or nil end,
      },
      {
        key = 'QuickKeybindOkay',
        textKey = 'Quick Keybind Okay::HelpTip',
        anchor = QuickKeybindOkay,
      },
      {
        key = 'BarDragHandle',
        textKey = 'Drag Handle::HelpTip',
        --- @param f BarFrame_ABP_2_0
        anchor = function(f) return f.widget.dragHandleEnabled and f.widget.dragHandle or nil end,
      },
      {
        -- Shown to everyone once, installed or not
        key = 'BarAddOns',
        textKey = 'Add-Ons::HelpTip',
        --- @param f BarFrame_ABP_2_0
        anchor = function(f) return f end,
      },
    },
  },
}; ns:Register(libName, o)
