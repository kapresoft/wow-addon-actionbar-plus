--- @type string
local addon
--- @type CoreNamespace
local ns
addon, ns = ...
--[[-----------------------------------------------------------------------------
Debug Flags
-------------------------------------------------------------------------------]]
local flag             = ns.debug.flag
flag.logConsole        = true
flag.developer         = true
flag.eventTrace        = true

--- @class DeveloperSetup
local _d = {}

local libName = 'DeveloperSetup'

local sformat = string.format
local ch = ns:ColorUtil()

local c1     = ch:NewFormatterFromColor(DULL_RED_FONT_COLOR)
local c2     = ch:NewFormatterFromColor(BLUE_FONT_COLOR)
local c3     = ch:NewFormatterFromColor(WHITE_FONT_COLOR)
local c4     = ch:NewFormatterFromColor(FACTION_GREEN_COLOR)

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
if flag.logConsole ~= true then return end

--- @class _ChatLogFrame
--- @field log fun(self:ChatLogFrame, ...:any) : void
--- @field logp fun(self:ChatLogFrame, module:Name, ...:any) : void

--- /dump LoadAddOn('DebugChatFrame')
--- /dump IsAddOnLoaded('DebugChatFrame')
-- /run FCF_OpenTemporaryWindow('SAY', 'Padrepio', ChatFrame1, true)
local pre = '{{' .. c1(addon .. '::') .. c2(libName) .. '}}:'

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
    addon = addon,
    chatFrameTabName = 'abp',
    font = DCF_ConsoleMonoCondensedSemiBold,
    fontSize = 16,
    windowAlpha = 0.5,
    maxLines = 200,
}

C_Timer.After(0.1, function()
    ns.chatFrame = devConsole:New(opt, function(chatFrame)
        chatFrame:SetAlpha(1.0)
        local windowColor = ch:NewColorFromHex('343434fc')
        FCF_SetWindowColor(chatFrame, windowColor:GetRGBA())
        FCF_SetWindowAlpha(chatFrame, opt.windowAlpha)
    end);

    local logp = ns.logp

    --- @type ChatLogFrameInterface
    local cf = ns.chatFrame

    if flag.logConsole == true and ns.debug:IsDeveloper() then cf:SelectInDock() end

    logp(libName, 'Debug ChatFrame initialized.')
    logp(libName, sformat('gameVersion=%s console-enabled=%s',
                      c4(ns.gameVersion), c2(flag.logConsole)))

    local font, size, flags = cf:GetFont()
    logp(libName, sformat('Size=%s', c2(size)),
      sformat('Flags=%s', c2(flags)),
      sformat('Font=%s', c3(font)))

    logp(libName, 'chatFrame:',
      c2(cf:GetName()), c2(sformat('(%s)', opt.chatFrameTabName)), 'selected:', c2(cf:IsSelected()))
    logp(libName, 'developer:', c2(ns.debug:IsDeveloper()), 'eventTrace:', c2(flag.eventTrace))
    logp(libName, 'Usage:', c2('/run c("hello", "there") or /c hello there'), '\n\n')
end)
