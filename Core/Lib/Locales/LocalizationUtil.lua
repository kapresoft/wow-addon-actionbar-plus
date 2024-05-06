--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local c1 = ns:K():cf(LIGHTBLUE_FONT_COLOR)

local bindingGlobalVarFormat = 'BINDING_NAME_ABP_ACTIONBAR%s_BUTTON%s'
local MAX_BARS = 8
local MAX_BUTTONS = 50

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class LocalizationUtil : BaseLibraryObject
local L = ns.LibStub:NewLibrary(ns.M.LocalizationUtil); if not L then return end
local p = ns:CreateDefaultLogger(ns.M.LocalizationUtil)

L.MAX_BARS = MAX_BARS
L.MAX_BUTTONS = MAX_BUTTONS

---@param o LocalizationUtil
local function Methods(o)

    --- Map the binding names in Bindings.xml to the localized values
    --- @param localizedBarText string The locale transaction of "Bar"
    --- @param addonTitle string More like will stay static as "ActionBar"
    --- @param aceLocale AceLocale
    function o:MapBindingsXMLNames(aceLocale, localizedBarText, addonTitle)
        --- ActionbarPlus Bar #1
        local headerFormat = '%s %s #%s'

        for bar = 1, MAX_BARS, 1
        do
            local headerVar = string.format('BINDING_HEADER_ABP_HEADER_ACTIONBAR%s', bar)
            local headerVarValue = string.format(headerFormat, addonTitle, localizedBarText, bar)
            _G[headerVar] = headerVarValue

            for button = 1, MAX_BUTTONS, 1
            do
                -- Example: _G["BINDING_NAME_CLICK ActionbarPlusF1Button1:LeftButton"]  = L["BINDING_NAME_ABP_ACTIONBAR1_BUTTON1"]
                local left = string.format('BINDING_NAME_CLICK ActionbarPlusF%sButton%s:LeftButton', bar, button)
                local right = string.format('BINDING_NAME_ABP_ACTIONBAR%s_BUTTON%s', bar, button)
                _G[left] = aceLocale[right]
            end
        end
    end

    --- @param localizedActionBarText string The localized "Action Bar" text
    --- @param localizedButtonBarText string The localized "Button" text
    --- @param aceLocale AceLocale
    function o:SetupKeybindNames(aceLocale, localizedActionBarText, localizedButtonBarText)
        assert(aceLocale, "AceLocale is required")
        -- Example: L["BINDING_NAME_ABP_ACTIONBAR1_BUTTON1"]  = 'Bar #1 Action Button 1'
        local bindingNameFormat = localizedActionBarText ..' %s %s %s ' .. c1('(ABP)')
        for bar = 1, MAX_BARS, 1
        do
            for button = 1, MAX_BUTTONS, 1
            do
                local left = sformat(bindingGlobalVarFormat, bar, button)
                local right = sformat(bindingNameFormat, bar, localizedButtonBarText, button)
                aceLocale[left] = right
            end
        end

    end

end

Methods(L)

