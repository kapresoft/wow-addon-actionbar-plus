--- @class GlobalDeveloper

--- @type string
local addon
--- @type Namespace | Kapresoft_Base_Namespace
local kns
addon, kns = ...
local sformat = string.format
local c1 = CreateColor(0.9, 0.2, 0.2, 1.0)
local c2 = WHITE_FONT_COLOR

local prefix = sformat('{{%s::%s}}:', c1:WrapTextInColorCode(addon), c2:WrapTextInColorCode('GlobalDeveloper'))

local function log(...) print(prefix, ...) end

--[[-----------------------------------------------------------------------------
Main Code
-------------------------------------------------------------------------------]]
local flag = kns.debug.flag
flag.developer = true
flag.debugging = true
flag.eventTrace = true

log('debug.flag.developer:', flag.developer)
log('debug.flag.debugging:', flag.debugging)
log('debug.flag.eventTrace:', flag.eventTrace)
