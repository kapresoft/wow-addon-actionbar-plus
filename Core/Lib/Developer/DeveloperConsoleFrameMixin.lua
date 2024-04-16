--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type string
local addon
--- @class BaseNamespace : Kapresoft_Base_Namespace
local ns
addon, ns = ...

local sformat, strlower = string.format, string.lower
local c1 = CreateColor(0.9, 0.2, 0.2, 1.0)
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'DeveloperConsoleFrameMixin'
local libShortName = 'DCFM'
--- @class DeveloperConsoleFrameMixin
local L = {}
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param name Name
function GetFrameByName(name)
    assert(type(name) == 'string', "ChatFrame string name is required")
    for i = 1, NUM_CHAT_WINDOWS do
        --- @type Frame
        local frame = _G["ChatFrame" .. i]
        if frame then
            --- @type Name
            local n = FCF_GetChatWindowInfo(i)
            if n and strlower(name) == strlower(n) then return frame end
        end
    end
end
--[[-----------------------------------------------------------------------------
Methods
/dump DEFAULT_CHAT_FRAME.name
/dump ChatFrame1.name
-------------------------------------------------------------------------------]]
--- @alias ChatLogFrame __ChatLogFrame | ScrollingMessageFrame

--- @class __ChatLogFrame
local ChatLogFrameMixin = {}
---@param o __ChatLogFrame
local function ChatLogFrameMixin_PropsAndMethods(o)

    --- @vararg
    function o:log(...)
        local args = {...}  -- Collect all arguments into a table
        local texts = {}
        for i, v in ipairs(args) do
            if type(v) == "table" then
                -- Assuming you want to print table addresses (customize as needed)
                texts[i] = tostring(v)
            else
                -- Convert non-tables to string
                texts[i] = tostring(v)
            end
        end
        -- Concatenate all items into a single string with spaces
        local message = table.concat(texts, " ")
        -- Output the message to the chat frame
        ns.chatFrame:AddMessage(message)
    end

end; ChatLogFrameMixin_PropsAndMethods(ChatLogFrameMixin)

--- @param o DeveloperConsoleFrameMixin
local function PropsAndMethods(o)

    local nameColor = c1:WrapTextInColorCode(addon)
    local libNameColor = YELLOW_FONT_COLOR:WrapTextInColorCode(libShortName)
    o.prefix = sformat('{{%s::%s}}:', nameColor, libNameColor)

    function o:GetChatFrameFn()
        if ns.printerFn then return ns.printerFn end

        --- @type ChatLogFrame
        local chatFrame = GetFrameByName(ns.debug.chatFrameName)
        if not chatFrame then
            print(o.prefix, addon, sformat('Could not find a chat frame named [%s].', ns.debug.chatFrameName))
            return nil
        end

        Mixin(chatFrame, ChatLogFrameMixin)

        local font, size, flags = ABP_Console_Mono:GetFont()
        chatFrame:SetFont(font, size, flags)
        ns.chatFrame = chatFrame

        local flag = ns.debug.flag
        if flag.logConsole == true and flag.debugging == true then
            ns.printerFn = function(...) ns.chatFrame:log(...) end
            FCF_SelectDockFrame(chatFrame)
        end
        chatFrame:log(o.prefix, 'Debug ChatFrame initialized. Log console enabled:', flag.logConsole)

        return ns.printerFn
    end

    o:GetChatFrameFn()

end; PropsAndMethods(L)
