--- @class GlobalDeveloper

--- @type string
local addon
--- @type CoreNamespace
local ns
addon, ns = ...
local sformat = string.format
local KO = ns.Kapresoft_LibUtil.Objects
local ch = KO.ColorUtil

local c1 = ch:NewFormatterFromColor(DULL_RED_FONT_COLOR)
local c2 = ch:NewFormatterFromColor(WHITE_FONT_COLOR)
local c3 = ch:NewFormatterFromColor(BLUE_FONT_COLOR)

local prefix = sformat('{{%s::%s}}:', c1(addon), c2('GlobalDeveloper'))
local function log(...) print(prefix, ...) end

--[[-----------------------------------------------------------------------------
Main Code
-------------------------------------------------------------------------------]]
local flag             = ns.debug.flag
flag.logConsole        = true
flag.developer         = true
flag.eventTrace        = true
ns.debug.chatFrameName = 'dev'

--[[
ConsoleMonoCondensedSemiBold
ConsoleMonoCondensedSemiBoldOutline
ConsoleMonoSemiCondensedBlack
ConsoleMedium
ConsoleMediumOutline
]]

ns.DEV_CONSOLE_FONT     = ConsoleMonoCondensedSemiBoldOutline
log('developer:', c3(ns.debug:IsDeveloper()))
log('logConsole:', c3(flag.logConsole))
log('eventTrace:', c3(flag.eventTrace))
