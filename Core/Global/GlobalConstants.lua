--[[-----------------------------------------------------------------------------
Global Variables Initialization
-------------------------------------------------------------------------------]]
-- log levels, 10, 20, (+10), 100
if type(ABP_PLUS_DB) ~= "table" then ABP_PLUS_DB = {} end
if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata

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
    ADDON_NAME = 'ActionbarPlus',
    DB_NAME = 'ABP_PLUS_DB',
    ABP_KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r',
    ABP_CHECK_VAR_SYNTAX_FORMAT = '|cfdeab676%s ::|r %s',
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
    ---@type string
    TEXTURE_EMPTY = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background"),
    ---@type string
    TEXTURE_HIGHLIGHT = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background Gold"),
    ---@type string
    TEXTURE_HIGHLIGHT2 = [[Interface\Buttons\WHITE8X8]],
    ---@type string
    TEXTURE_HIGHLIGHT3 = [[Interface\Buttons\ButtonHilight-Square]],
    ---@type string
    TEXTURE_HIGHLIGHT4 = [[Interface\QuestFrame\UI-QuestTitleHighlight]],
    ---@type string
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

---@class EventNames
local E = {

    OnEnter = 'OnEnter',
    OnEvent = 'OnEvent',
    OnLeave = 'OnLeave',
    OnModifierStateChanged = 'OnModifierStateChanged',
    OnReceiveDrag = 'OnReceiveDrag',

    -- ################################
    ---@deprecated DEPRECATED: Use the camel cased version
    ON_ENTER = 'OnEnter',
    ---@deprecated DEPRECATED: Use the camel cased version
    ON_EVENT = 'OnEvent',
    ---@deprecated DEPRECATED: Use the camel cased version
    ON_LEAVE = 'OnLeave',
    ---@deprecated DEPRECATED: Use the camel cased version
    ON_MODIFIER_STATE_CHANGED = 'OnModifierStateChanged',
    ---@deprecated DEPRECATED: Use the camel cased version
    ON_RECEIVE_DRAG = 'OnReceiveDrag',
    -- ################################

    ACTIONBAR_UPDATE_COOLDOWN = 'ACTIONBAR_UPDATE_COOLDOWN',
    ACTIONBAR_UPDATE_STATE = 'ACTIONBAR_UPDATE_STATE',
    ACTIONBAR_UPDATE_USABLE = 'ACTIONBAR_UPDATE_USABLE',

    BAG_UPDATE_DELAYED = 'BAG_UPDATE_DELAYED',
    COMBAT_LOG_EVENT_UNFILTERED = 'COMBAT_LOG_EVENT_UNFILTERED',
    MODIFIER_STATE_CHANGED = 'MODIFIER_STATE_CHANGED',

    PLAYER_CONTROL_GAINED = 'PLAYER_CONTROL_GAINED',
    PLAYER_CONTROL_LOST = 'PLAYER_CONTROL_LOST',
    PLAYER_ENTERING_WORLD = 'PLAYER_ENTERING_WORLD',
    PLAYER_REGEN_DISABLED = 'PLAYER_REGEN_DISABLED',
    PLAYER_REGEN_ENABLED = 'PLAYER_REGEN_ENABLED',
    PLAYER_STARTED_MOVING = 'PLAYER_STARTED_MOVING',
    PLAYER_STOPPED_MOVING = 'PLAYER_STOPPED_MOVING',
    PLAYER_TARGET_CHANGED = 'PLAYER_TARGET_CHANGED',

    SPELL_UPDATE_COOLDOWN = 'SPELL_UPDATE_COOLDOWN',
    SPELL_UPDATE_USABLE = 'SPELL_UPDATE_USABLE',

    UNIT_HEALTH = 'UNIT_HEALTH',
    UNIT_SPELLCAST_FAILED_QUIET = 'UNIT_SPELLCAST_FAILED_QUIET',
    UNIT_SPELLCAST_SENT = 'UNIT_SPELLCAST_SENT',
    UNIT_SPELLCAST_START = 'UNIT_SPELLCAST_START',
    UNIT_SPELLCAST_STOP = 'UNIT_SPELLCAST_STOP',
    UNIT_SPELLCAST_SUCCEEDED = 'UNIT_SPELLCAST_SUCCEEDED',

    UPDATE_BINDINGS = 'UPDATE_BINDINGS',

}

--[[-----------------------------------------------------------------------------
Methods: GlobalConstants
-------------------------------------------------------------------------------]]
---@param o GlobalConstants
local function methods(o)
    function o:GetAddonInfo()
        local addonName = C.ADDON_NAME
        local versionText = self.versionText
        --@debug@
        versionText = '1.0.dev'
        --@end-debug@

        return versionText, GetAddOnMetadata(addonName, 'X-CurseForge'),
                            GetAddOnMetadata(addonName, 'X-Github-Issues'),
                            GetAddOnMetadata(addonName, 'X-Github-Repo')
    end
    function o:GetLogLevel() return ABP_LOG_LEVEL end
    ---@param level number The log level between 1 and 100
    function o:SetLogLevel(level) ABP_LOG_LEVEL = level or 1 end
end



--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
local function Init()
    L.WidgetAttributes = WidgetAttributes
    L.ButtonAttributes = ButtonAttributes
    L.UnitIDAttributes = UnitIDAttributes
    L.Textures = Textures
    L.C = C
    L.E = E
    methods(L)

    ---@tpe GlobalConstants
    ABP_GlobalConstants = L
end

Init()
