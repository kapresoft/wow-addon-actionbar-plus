-- Addon Interface Types for EmmyLua
-- This file does not need to be included in _Common.xml
--[[-----------------------------------------------------------------------------
ActionbarPlus_AceDB
-------------------------------------------------------------------------------]]
--- @class ActionbarPlus_AceDB
local _db = {
    --- @type Profile_Global_Config
    global = {},
    ----- @type Profile_Config
    profile = {},
}

--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @class LibPackMixin
local LibPackMixin = {
    --- @type GlobalObjects
    O = {}
}

--- @class Namespace : LibPackMixin
local Namespace = {
    --- @type string
    name = "",
    --- @type GlobalObjects
    O = {},
    --- @type ActionbarPlus_AceDB,
    db = {},
    --- @type Module
    M = {},

    --- @type Kapresoft_LibUtil
    Kapresoft_LibUtil = {},

    --- @type fun(): Kapresoft_LibUtil
    K = {},

    --- @type LocalLibStub
    LibStub = {},

    --- Used in TooltipFrame and BaseAttributeSetter to coordinate the GameTooltip Anchor
    --- @see TooltipAnchor#SCREEN_* vars
    --- @type string
    GameTooltipAnchor = "",
    --- @type fun(o:any, ...) : void
    pformat = {}
}

--- @class CursorUtil : CursorMixin
local CursorUtil = {}

--[[-----------------------------------------------------------------------------
ActionbarPlus
-------------------------------------------------------------------------------]]
--- @class ActionbarPlusProperties
local ActionbarPlusProperties = { }
ActionbarPlusProperties.db = _db


--[[-----------------------------------------------------------------------------
Profile
-------------------------------------------------------------------------------]]
--- @class Profile_Spell
local Profile_Spell = {
    ["minRange"] = 0,
    ["id"] = 8232,
    ["label"] = "Windfury Weapon |c00747474(Rank 1)|r",
    ["name"] = "Windfury Weapon",
    ["castTime"] = 0,
    ["link"] = "|cff71d5ff|Hspell:8232:0|h[Windfury Weapon]|h|r",
    ["maxRange"] = 0,
    ["icon"] = 136018,
    ["rank"] = "Rank 1"
}
--- @class Profile_Item
local Profile_Item = {
    ["name"] = "Arcane Powder",
    ["link"] = "|cffffffff|Hitem:17020::::::::70:::::::::|h[Arcane Powder]|h|r",
    ["id"] = 17020,
    ["stackCount"] = 20,
    ["icon"] = 133848,
    ["count"] = 40,
}
--- @class Profile_Macro
local Profile_Macro = {
    ["type"] = "macro",
    ["index"] = 41,
    ["name"] = "z#LOL",
    ["icon"] = 132093,
    ["body"] = "/lol\n",
}
--- @class Profile_Mount_Spell
local Profile_Mount_Spell = { id = 1, icon = 123 }
--- @class Profile_Mount
local Profile_Mount = {
    type = 'mount',
    id = -1,
    index = -1,
    name = 'Reawakened Phase Hunter',
    spell = Profile_Mount_Spell,
}
--- @class Profile_Companion_Spell
local Profile_Companion_Spell = { id = 1, icon = 123 }
--- @class Profile_Companion
local Profile_Companion = {
    type = 'companion',
    petType = 'critter',
    mountType = 0x1,
    id = -1,
    index = -1,
    name = 'Black Kingsnake',
    spell = Profile_Companion_Spell,
}
--- @class Profile_BattlePet
local Profile_BattlePet = {
    type='battlepet',
    petType = -1,
    ['guid'] = 'BattlePet-0-000008C13591',
    ['speciesID'] = speciesID,
    ['creatureID'] = 157969,
    ['name'] = 'Anima Wyrmling',
    ['icon'] = 3038273,
}

--- @class Profile_Button
local Profile_Button = {
    ['type'] = 'spell',
    ["spell"] = Profile_Spell,
    ["item"] = Profile_Item,
    ["macro"] = Profile_Macro,
    ["mount"] = Profile_Mount,
    ["companion"] = Profile_Companion,
}

--- @class Profile_Bar_Widget
local Profile_Bar_Widget = {
    ["rowSize"] = 1,
    ["colSize"] = 1,
    ["buttonSize"] = 11,
    ["buttonAlpha"] = 0.1,
    ["frame_handle_mouseover"] = false,
    ["frame_handle_alpha"] = 1.0,
    ["show_empty_buttons"] = true
}


--- @class Profile_Bar
local Profile_Bar = {
    -- show/hide the actionbar frame
    ["enabled"] = false,
    -- allowed values: {"", "always", "in-combat"}
    ["locked"] = "",
    -- shows the button index
    ["show_button_index"] = true,
    -- shows the keybind text TOP
    --TODO next: show_keybind_text should be in Profile_Bar_Widget properties
    ["show_keybind_text"] = true,
    ["widget"] = Profile_Bar_Widget,
    --- @see _RegionAnchor
    ["anchor"] = { point="CENTER", relativeTo=nil, relativePoint='CENTER', x=0.0, y=0.0 },
    ["buttons"] = {
        ['ActionbarPlusF1Button1'] = Profile_Button
    }
}

--- @class Global_Profile_Bar
local Global_Profile_Bar = {
    --- @type _RegionAnchor
    ["anchor"] = { point="CENTER", relativeTo=nil, relativePoint='CENTER', x=0.0, y=0.0 },
}

--- @class Profile_Global_Config
local Profile_Global_Config = {
    ["bars"] = {
        ["ActionbarPlusF1"] = Global_Profile_Bar,
        ["ActionbarPlusF2"] = Global_Profile_Bar,
        ["ActionbarPlusF3"] = Global_Profile_Bar,
        ["ActionbarPlusF4"] = Global_Profile_Bar,
        ["ActionbarPlusF5"] = Global_Profile_Bar,
        ["ActionbarPlusF6"] = Global_Profile_Bar,
        ["ActionbarPlusF7"] = Global_Profile_Bar,
        ["ActionbarPlusF8"] = Global_Profile_Bar,
    }
}

--- @class Profile_Config
local Profile_Config = {
    ["hide_when_taxi"] = true,
    --- Toggle action button mouseover glow
    ["action_button_mouseover_glow"] = true,
    --- Hide keybindText and indexText for smaller buttons
    ["hide_text_on_small_buttons"] = true,
    --- Hide cooldown countdown numbers
    ["hide_countdown_numbers"] = true,
    ["tooltip_visibility_key"] = '',
    ["tooltip_visibility_combat_override_key"] = '',
    --- @see TooltipAnchor
    ["tooltip_anchor_type"] = '',
    --- @type table<string, Profile_Bar>
    ["bars"] = {
        ["ActionbarPlusF1"] = Profile_Bar,
        ["ActionbarPlusF2"] = Profile_Bar,
        ["ActionbarPlusF3"] = Profile_Bar,
        ["ActionbarPlusF4"] = Profile_Bar,
        ["ActionbarPlusF5"] = Profile_Bar,
        ["ActionbarPlusF6"] = Profile_Bar,
        ["ActionbarPlusF7"] = Profile_Bar,
        ["ActionbarPlusF8"] = Profile_Bar,
    }
}

--- @class Spellcast_Event_Data
local SpellcastSent_Data = {
    unit='unit', target='target', castGUID='castGUID', spellID=12345
}

--[[-----------------------------------------------------------------------------
Config
-------------------------------------------------------------------------------]]
--- @class Config : BaseLibraryObject_Initialized_WithAceEvent
local Config = {
    --- @type ActionbarPlus
    addon = {},
    --- @type Profile
    profile = {},
    --- @type ConfigEventHandlerMixin
    eventHandler = {},
}

--- @class ActionbarInitialSettings
local ActionbarInitialSettings = {
    ['rowSize'] = 1,
    ['colSize'] = 1,
    ['enable'] = false,
    ['frame_handle_mouseover'] = true
}

--- @class LayoutStrategyContext
local LayoutStrategyContext = {
    --- @type Kapresoft_LibUtil_Incrementer
    xIncr = {},
    --- @type Kapresoft_LibUtil_Incrementer
    yIncr = {},
}
--- @alias LayoutStrategyFn fun(index:number, barConf:Profile_Bar, context:LayoutStrategyContext)
