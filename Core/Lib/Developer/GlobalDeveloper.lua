--- @class GlobalDeveloper

--- @type string
local addon
--- @type BaseNamespace
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
flag.logConsole = true
flag.eventTrace = true

kns.debug.chatFrameName = 'debug'

log('developer:', flag.developer)
log('debugging:', flag.debugging)
log('logConsole:', flag.logConsole)
log('eventTrace:', flag.eventTrace)
log('chatFrameName:', kns.debug.chatFrameName)
