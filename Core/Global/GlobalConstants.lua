--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibSharedMedia = LibStub('LibSharedMedia-3.0')


--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class GlobalConstants
local L = {}

---@class GlobalAttributes
local C = {

    ABP_KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r',
    ALT = 'ALT',
    ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT',
    ARTWORK_DRAW_LAYER = 'ARTWORK',
    BOTTOMLEFT = 'BOTTOMLEFT',
    BOTTOMRIGHT = 'BOTTOMRIGHT',
    CLAMPTOBLACKADDITIVE = 'CLAMPTOBLACKADDITIVE',
    CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI',
    CTRL = 'CTRL',
    HIGHLIGHT_DRAW_LAYER = 'HIGHLIGHT',
    PICKUPACTION = 'PICKUPACTION',
    SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate',
    SHIFT = 'SHIFT',
    TOPLEFT = 'TOPLEFT',

}

---@class Textures
local Textures = {
    TEXTURE_EMPTY = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background"),
    TEXTURE_HIGHLIGHT = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background Gold"),
    TEXTURE_HIGHLIGHT2 = [[Interface\Buttons\WHITE8X8]],
    TEXTURE_HIGHLIGHT3 = [[Interface\Buttons\ButtonHilight-Square]],
    TEXTURE_HIGHLIGHT4 = [[Interface\QuestFrame\UI-QuestTitleHighlight]],
    TEXTURE_CASTING = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Rock"),
}

---@class UnitIDAttributes
local UnitIDAttributes = {
    FOCUS = 'focus',
    TARGET = 'target',
    MOUSEOVER = 'mouseover',
    NONE = 'none',
    PET = 'pet',
    PLAYER = 'player',
    VEHICLE = 'vehicle',
}

---@class WidgetAttributes
local WidgetAttributes = {
    TYPE = 'type',
    UNIT = 'unit',
    SPELL = 'spell',
    ITEM = 'item',
    MOUNT = 'mount',
    FLY_OUT = 'flyout',
    PET_ACTION = 'petaction',
    MACRO_TEXT = "macrotext",
    MACRO = "macro",
}

---@class ButtonAttributes
local ButtonAttributes = {
    SPELL = WidgetAttributes.SPELL,
    UNIT = WidgetAttributes.UNIT,
    UNIT2 = format("*%s2", WidgetAttributes.UNIT),
    TYPE = WidgetAttributes.TYPE,
    MACRO = WidgetAttributes.MACRO,
    MOUNT = WidgetAttributes.MOUNT,
    MACRO_TEXT = WidgetAttributes.MACRO_TEXT,
}

local function Init()
    L.WidgetAttributes = WidgetAttributes
    L.ButtonAttributes = ButtonAttributes
    L.UnitIDAttributes = UnitIDAttributes
    L.Textures = Textures
    L.C = C

    ---@tpe GlobalConstants
    ABP_GlobalConstants = L
end

Init()

