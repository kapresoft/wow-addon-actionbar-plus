--- @diagnostic disable: inject-field

--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "enUS", true);
if not L then return end

L['ActionbarPlus']        = true
L['AddOns']               = true
L['Alpha']                = true
L['Bar']                  = true
L['Bound']                = true
L['Button']               = true
L['Button Size']          = true
L['Columns']              = true
L['Enabled']              = true
L['General']              = true
L['Not Bound']            = true
L['Options']              = true
L['Rows']                 = true
L['Settings']             = true
L['Show Empty Buttons']   = true
