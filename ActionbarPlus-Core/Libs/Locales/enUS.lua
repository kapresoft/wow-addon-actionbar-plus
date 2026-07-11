--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "enUS", true);
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']               = true
L['Alpha']                = true
L['Backdrop']             = true
L['Background Color']     = true
L['Bar']                  = true
L['Bars']                 = true
L['Border Color']         = true
L['Bound']                = true
L['Button']               = true
L['Button Size']          = true
L['Columns']              = true
L['Border Size']          = true
L['Enabled']              = true
L['General']              = true
L['Keybind']              = true
L['Masque Settings']      = true
L['Not Bound']            = true
L['Options']              = true
L['Padding']              = true
L['Reset']                = true
L['Rows']                 = true
L['Settings']             = true
L['Show Empty Buttons']   = true
L['Drag Handle Location'] = true
L['Thickness']            = true
L['Extra Buttons']        = true
L['Button Count']         = true
L['Toggle Bars']                 = true
L['Reset to Default']            = true
L['Copy Backdrop from Bar']      = true
L['Apply Backdrop to All Bars']  = true
L['Right-click for more options.'] = true
L['Mouseover Glow']         = true
L['Mouseover Glow Tooltip'] = 'When enabled, buttons glow when the mouse hovers over them.'
L['Gap']                  = true
L['Gap Tooltip']          = 'Spacing between the bar border and the extra button row.'
L['Global']               = true
L['Character Specific Frame Positions'] = true
L['Character Specific Frame Positions Tooltip'] = 'When enabled, each character saves its own bar positions. When disabled, bar positions are shared across all characters using this profile.'
L['Anchor']               = true
L['Top']                  = true
L['Top Left']             = true
L['Top Right']            = true
L['Bottom']               = true
L['Bottom Left']          = true
L['Bottom Right']         = true
L['Stone']                = true
L['Theme']                = true
L['Version']              = true

-- Theme Names
L['None']                 = true
L['Minimalist']           = true
L['Modern Dark']          = true
L['Abyss']                = true
L['Glow']                 = true
L['Shadowmoon']           = true
L['Dark Knight']          = true
L['Modern']               = true
-- /Theme Names


-- Long texts
L['Drag the bar by hovering over the handle at the selected location.'] = true
L['At least one bar must remain enabled.']                       = true
L['Toggle bar visibility from the right-click context menu.']    = true
L['Profiles']                                           = true
L['Extra Buttons Tooltip'] = 'A single row of buttons placed outside the bar border. Useful for consumables, trinkets, or situational items you want nearby but separate from your main bar.'
L['Reset to default theme settings.']                   = true
L['Open General Settings for all bars and profiles.']   = true
L['Open Backdrop Settings for the current bar.']        = true

L['Right-Click'] = true
L['Left-Click and Drag'] = true
L['to show options menu'] = true
L['bar frame or drag frame'] = true
L['to move the bar'] = true

L['Really switch to general key bindings?'] = true
L['All key bindings specific to this character will be permanently deleted.'] = true

L['ESC'] = true
L['press the desired key'] = true
L['You are in Quick Keybind Mode']                      = true
L['Mouse over a button and %s to set its binding']      = true
L['or press %s to clear it']                            = true
L['Canceling will remove you from Quick Keybind Mode']  = true
