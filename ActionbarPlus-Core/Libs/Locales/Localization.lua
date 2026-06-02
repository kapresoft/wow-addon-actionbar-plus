--- @type Namespace_ABP_2_0
local ns = select(2, ...)

--- @type table<string, string>
local L = LibStub("AceLocale-3.0"):GetLocale(ns.name)

ABP_2_0_TITLE          = "ActionbarPlus"
ABP_2_0_CATEGORY       = ("%s/%s"):format(L['AddOns'], ABP_2_0_TITLE)
BINDING_HEADER_ABP_2_0 = ABP_2_0_TITLE
