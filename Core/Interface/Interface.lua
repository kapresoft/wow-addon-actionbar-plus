--[[-----------------------------------------------------------------------------
Note:
Addon Interface Types for EmmyLua.
This file does not need to be included in _Common.xml
-------------------------------------------------------------------------------]]
--
--
--[[-----------------------------------------------------------------------------
Global Vars
-------------------------------------------------------------------------------]]
--- @type fun(fmt:string, ...)|fun(val:string)
pformat = {}
--[[-----------------------------------------------------------------------------
Aliases
-------------------------------------------------------------------------------]]
--- @alias LayoutStrategyFn fun(index:number, barConf:Profile_Bar, context:LayoutStrategyContext)

--- @alias PLAYER_EQUIPMENT_CHANGED_CallbackFn fun(InventorySlotId:Identifier, hasCurrent:boolean) | "function(invSlotID, hasCurrent) end"
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Type: ActionbarPlus_AceDB
-------------------------------------------------------------------------------]]
--- @class ActionbarPlus_AceDB Represents an AceDB instance for ActionbarPlus.
--- @field global Profile_Global_Config The global configuration profile.
--- @field profile Profile_Config The configuration profile.
--- @type ActionbarPlus_AceDB

--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @class SpellInfoShort
--- @field id SpellID The unique identifier for the class.
--- @field name SpellName The name of the class.

--- @class CursorUtil : CursorMixin
local CursorUtil = {}

--[[-----------------------------------------------------------------------------
Profile
-------------------------------------------------------------------------------]]
--- @class Profile_Spell
--- @field public id SpellID The spell ID
--- @field public name SpellName The spell Name
--- @field public icon Icon The icon ID
--- @field public rank string The rank label number, i.e. "Rank 1"
--- @field public runeSpell RuneSpellInfo The actual spell that the run is casting
local Profile_Spell = { }

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
    -- This macro is used by third-party plugins
    ["icon2"] = 132093,
    ["body"] = "/lol\n",
}
--- @class Profile_MacroText
local Profile_MacroText = {
    ["type"] = "macrotext",
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
    --- for C_PetJournal Pet Identifier
    petID = 'pet guid',
    id = -1,
    index = -1,
    name = 'Black Kingsnake',
    spell = Profile_Companion_Spell,
}
--- @class Profile_BattlePet
local Profile_BattlePet = {
    ['type'] = 'battlepet',
    ['petType'] = -1,
    ['guid'] = 'BattlePet-0-000008C13591',
    ['speciesID'] = speciesID,
    ['creatureID'] = 157969,
    ['name'] = 'Anima Wyrmling',
    ['icon'] = 3038273,
}

--- @class Profile_EquipmentSet
local Profile_EquipmentSet = {
    ['type'] ='equipmentset',
    ['name'] = '<name of equipment>',
    --- The Equipment setID
    ['id'] = 1,
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
    ["equipmentset"] = Profile_EquipmentSet,
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
    --- show/hide the actionbar frame
    ["enabled"] = false,
    --- allowed values: {"", "always", "in-combat"}
    ["locked"] = "",
    --- shows the button index
    ["show_button_index"] = true,
    --TODO next: show_keybind_text should be in Profile_Bar_Widget properties
    --- shows the keybind text TOP
    ["show_keybind_text"] = true,
    ["widget"] = Profile_Bar_Widget,
    --- @see _RegionAnchor
    ["anchor"] = { point="CENTER", relativeTo=nil, relativePoint='CENTER', x=0.0, y=0.0 },
    --- @type table<number, Profile_Button>
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
    --- Spec 2 Initialized Flag, 1=initialized, otherwise, not initialized
    ["spec2_init"] = 1,
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
    ["equipmentset_open_character_frame"] = true,
    ["equipmentset_open_equipment_manager"] = true,
    ["equipmentset_show_glow_when_active"] = true,
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
Type: ActionbarInitialSettings
-------------------------------------------------------------------------------]]
--- @class ActionbarInitialSettings Initial configuration settings for action bar layouts and behaviors.
--- @field public rowSize Index Initial row size setting.
--- @field public colSize Index Initial column size setting.
--- @field public enable boolean Whether the action bar is enabled by default.
--- @field public frame_handle_mouseover boolean Determines if the frame handles mouseover events.
--- @field public spec2Init BooleanInt Spec 2 Initialized Flag. Default is 0

--[[-----------------------------------------------------------------------------
Type: LayoutStrategyContext
-------------------------------------------------------------------------------]]
--- @class LayoutStrategyContext Represents a context for layout strategies.
--- @field xIncr Kapresoft_Incrementer The incrementer for the x-axis.
--- @field yIncr Kapresoft_Incrementer The incrementer for the y-axis.

--[[-----------------------------------------------------------------------------
Type: EquipmentSetInfo
-------------------------------------------------------------------------------]]
--- @class EquipmentSetInfo Represents information about an equipment set.
--- @field name string The name of the equipment set.
--- @field id number The ID of the equipment set.
--- @field index number The button index order.
--- @field setID number The ID of the equipment set.
--- @field icon number The icon ID of the equipment set.
--- @field isEquipped boolean Whether the equipment set is currently equipped.
--- @field numItems number The total number of items in the equipment set.
--- @field numEquipped number The number of items currently equipped from the equipment set.
--- @field numInInventory number The number of items from the equipment set currently in the player's inventory.
--- @field numLost number The number of items from the equipment set that are lost.
--- @field numIgnored number The number of items from the equipment set that are ignored.

--[[-----------------------------------------------------------------------------
Type: CooldownInfo
-------------------------------------------------------------------------------]]
--- @class CooldownInfo Represents information about a cooldown.
--- @field type CooldownType "The type of the cooldown (e.g., 'spell', 'item')."
--- @field start StartTime|nil The start time of the cooldown (in seconds since epoch), or nil if not started.
--- @field duration Duration|nil | "1.0" | "The duration of the cooldown (in seconds), or nil if not applicable."
--- @field enabled EnabledInt "Indicates whether the cooldown is enabled (0 for disabled, 1 for enabled)."
--- @field details SpellCooldown|ItemCooldown The details of the cooldown, which can be of type SpellCooldown or ItemCooldown.

--[[-----------------------------------------------------------------------------
Type: SpellCooldown_Spell
-------------------------------------------------------------------------------]]
--- @class SpellCooldown_Spell Represents information about a spell cooldown.
--- @field name SpellName The name of the spell.
--- @field id SpellID The ID of the spell.
--- @field icon Icon The icon ID of the spell.

--[[-----------------------------------------------------------------------------
Type: SpellCooldown
-------------------------------------------------------------------------------]]
--- @class SpellCooldown : Cooldown Represents information about a spell cooldown extending Cooldown.
--- @field spell SpellCooldown_Spell The details of the spell cooldown.

--[[-----------------------------------------------------------------------------
Type: ItemCooldown
-------------------------------------------------------------------------------]]
--- @class ItemCooldown : Cooldown Represents information about an item cooldown extending Cooldown.
--- @field item ItemInfo The details of the item.

--[[-----------------------------------------------------------------------------
Type: SpellInfoBasic
-------------------------------------------------------------------------------]]
--- @class SpellInfoBasic
--- @field public id SpellID The spell ID
--- @field public name SpellName The spell Name
--- @field public icon Icon The icon ID
--- @field public empowered BooleanOptional

--[[-----------------------------------------------------------------------------
Type: AutoRepeatSpellData
-------------------------------------------------------------------------------]]
--- @class AutoRepeatSpellData
--- @field public flashing BooleanInt
--- @field public flashTime TimeInMilli
--- @field public wasAuto boolean
--- @field _checkAutoRepeatTime TimeInMilli
