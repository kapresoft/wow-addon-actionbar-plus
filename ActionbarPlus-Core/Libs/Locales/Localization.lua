--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type table<string, string>
local L = LibStub("AceLocale-3.0"):GetLocale(ns.name)

ABP_2_0_TITLE          = "ActionbarPlus"
ABP_2_0_CATEGORY       = ("%s/%s"):format(L['AddOns'], ABP_2_0_TITLE)
BINDING_HEADER_ABP_2_0 = ABP_2_0_TITLE

RESET_THEME_TOOLTIP      = L['Reset to default theme settings.']
GENERAL_SETTINGS_TOOLTIP = L['Open General Settings for all bars and profiles.']
BACKDROP_SETTINGS_TOOLTIP = L['Open Backdrop Settings for the current bar.']
