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
L['Disabled bars are hidden. Re-enable them here.'] = true
L['Drag the bar by hovering over its top-left corner (above the first button).'] = true
L['Edge Size']            = true
L['Enabled']              = true
L['General']              = true
L['Minimalist']           = true
L['Modern Dark']          = true
L['None']                 = true
L['Not Bound']            = true
L['Options']              = true
L['Padding']              = true
L['Reset']                = true
L['Rows']                 = true
L['Settings']             = true
L['Show Empty Buttons']   = true
L['Stone']                = true
L['Theme']                = true
L['Version']              = true

L['Re-enable from General Settings > General > Bars.'] = true
L['Reset to default theme settings.']                  = true
