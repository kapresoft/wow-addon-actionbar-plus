local format, unpack, pack = string.format, table.unpackIt, table.pack
local ABP_ACE_NEWLIB = ABP_ACE_NEWLIB
local S = ABP_ACE_NEWLIB('Settings')
if not S then return end

---- ## Start Here ----

local SPELL = { id = nil, name = nil, icon = nil, label = nil }
local ITEM = { id = nil, name = nil, icon = nil, label = nil }
local MACRO = { index = nil, name = nil, icon = nil }
local MACROTEXT = { name = nil, icon = nil, body = nil }
local DETAILS = { spell = SPELL, item = ITEM, macro = MACRO, macrotext = MACROTEXT }
local TOOLTIP = { text = nil, link = nil }
local BUTTON = { type = nil, name = nil, icon = nil, macrotext = nil, tooltip = TOOLTIP, details = DETAILS }

local ButtonType = {
    SPELL = "spell",
    ITEM = "item",
    MACRO = "macro",
    MACROTEXT = "macrotext",
}

local ButtonTypeCode = {
    ["spell"] = 1,
    ["item"] = 2,
    ["macro"] = 3,
    ["macrotext"] = 4
}



function S:CreateButtonSettingsTemplate()
    return BUTTON
end
