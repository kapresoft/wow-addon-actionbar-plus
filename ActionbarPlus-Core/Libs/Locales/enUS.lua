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
L['Extra Button Size']    = true
L['Extra Button Columns'] = true
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
L['Disabled bars are hidden. Re-enable them here.'] = true
L['Drag the bar by hovering over the handle at the selected location.'] = true

L['Re-enable from General Settings > General > Bars.'] = true
L['At least one bar must remain enabled.']             = true
L['Profiles']                                         = true
L['Extra Buttons Tooltip'] = 'A single row of buttons placed outside the bar border. Useful for consumables, trinkets, or situational items you want nearby but separate from your main bar.'
L['Reset to default theme settings.']                  = true
L['Open General Settings for all bars and profiles.']  = true
L['Open Backdrop Settings for the current bar.']  = true
