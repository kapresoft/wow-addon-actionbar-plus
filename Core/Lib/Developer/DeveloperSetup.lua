--- @type string
local addon
--- @type CoreNamespace
local ns
addon, ns = ...

--[[-----------------------------------------------------------------------------
Debugger Vars
--- @see Interface/SharedXML/Dump.lua
-------------------------------------------------------------------------------]]

-- DEVTOOLS_MAX_ENTRY_CUTOFF = 100       -- Maximum table entries shown (default: 30)
-- DEVTOOLS_LONG_STRING_CUTOFF = 200; -- Maximum string size shown
-- DEVTOOLS_DEPTH_CUTOFF = 3;           -- Maximum table depth (default: 10)
--DEVTOOLS_USE_TABLE_CACHE = true;   -- Look up table names
--DEVTOOLS_USE_FUNCTION_CACHE = true;-- Look up function names
--DEVTOOLS_USE_USERDATA_CACHE = true;-- Look up userdata names
--DEVTOOLS_INDENT='  ';              -- Indentation string

--[[-----------------------------------------------------------------------------
Debug Flags
-------------------------------------------------------------------------------]]
local d                  = ns.debug
local flag               = d.flag
flag.developer           = true
flag.enableLogConsole    = false
flag.selectLogConsoleTab = true
flag.eventTrace          = true

--- @class DeveloperSetup
local _d = {}

local K         = ns:K()
local logp      = ns.logp
local sformat   = string.format
local c1, c2    = K:cf(DULL_RED_FONT_COLOR), K:cf(YELLOW_FONT_COLOR)
local c3, c4    = K:cf(ADVENTURES_COMBAT_LOG_BLUE), K:cf(FACTION_GREEN_COLOR)
local c5        = K:cf(LIGHTGRAY_FONT_COLOR)
local libName   = c2('DeveloperSetup')


--[[-----------------------------------------------------------------------------
Main Code
Available Fonts:
 ConsoleMonoCondensedSemiBold
 ConsoleMonoCondensedSemiBoldOutline
 ConsoleMonoSemiCondensedBlack
 ConsoleMedium
 ConsoleMediumOutline
 SystemFont_Outline_Small
-------------------------------------------------------------------------------]]
if not d:IsEnableLogConsole() then return end
if not c then c = ns.print end

--- /dump LoadAddOn('DebugChatFrame')
--- /dump IsAddOnLoaded('DebugChatFrame')
-- /run FCF_OpenTemporaryWindow('SAY', 'Padrepio', ChatFrame1, true)
local pre = sformat('{{%s::%s}}', c1(ns.addon), libName)

local function LoadDebugChatFrame()
    local addonName = 'DebugChatFrame'
    local U = ns:KO().AddonUtil
    U:LoadOnDemand(addonName, function(loadSuccess)
        print(pre, addonName, 'Loaded OnDemand:', loadSuccess)
    end)
end; LoadDebugChatFrame()
if not DebugChatFrame then return print(pre, 'DebugChatFrame is not available') end


--- @type DebugChatFrameInterface
local devConsole = DebugChatFrame

--- @type DebugChatFrameOptionsInterface
local opt = {
    addon = 'ABP',
    chatFrameTabName = 'abp',
    font = DCF_ConsoleMonoCondensedSemiBoldOutline,
    fontSize = 16,
    windowAlpha = 0.5,
    maxLines = 200,
}

--C_Timer.After(0.1, function()
ns.chatFrame = devConsole:New(opt, function(chatFrame)
    chatFrame:SetAlpha(1.0)
    local windowColor = ns:ColorUtil():NewColorFromHex('343434fc')
    FCF_SetWindowColor(chatFrame, windowColor:GetRGBA())
    FCF_SetWindowAlpha(chatFrame, opt.windowAlpha)
end);

--- @type ChatLogFrameInterface
local cf = ns.chatFrame

cf:InitialTabSelection(d:IsSelectLogConsoleTab())

logp(libName, c5('-------------------------------------------'))
logp(libName, 'Debug ChatFrame initialized.')
logp(libName,
     'Developer:', c3(d:IsDeveloper()),
     'SelectLogConsoleTab:', c3(d:IsSelectLogConsoleTab()))
logp(libName,
     'ConsoleEnabled:', c3(d:IsEnableLogConsole()),
     'EventTrace:', c3(flag.eventTrace))
logp(libName, 'GameVersion:', c4(ns.gameVersion))

local font, size, flags = cf:GetFont()
logp(libName, 'Size:', c3(size), 'Flags:', c3(flags), 'Font:', c5(font))

logp(libName, 'chatFrame:',
  c3(cf:GetName()), c3(sformat('(%s)', opt.chatFrameTabName)), 'selected:', c3(cf:IsSelected()))
logp(libName, 'Usage:', c3('/run c("hello", "there")'))
logp(libName, c5('-------------------------------------------'), '\n\n')
--end)
