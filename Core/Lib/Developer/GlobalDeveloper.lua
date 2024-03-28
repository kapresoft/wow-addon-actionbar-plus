--- @type string
local addon
--- @type Namespace | Kapresoft_Base_Namespace
local ns
addon, ns = ...
local sformat = string.format
local c1 = PURE_RED_COLOR
local c2 = WHITE_FONT_COLOR

local prefix = sformat('{{%s::%s}}::', c1:WrapTextInColorCode(addon), c2:WrapTextInColorCode('GlobalDeveloper'))
--[[-----------------------------------------------------------------------------
Main Code
-------------------------------------------------------------------------------]]

ns.enableEventTrace = true
print(prefix, 'ns.enableEventTrace:', ns.enableEventTrace)
