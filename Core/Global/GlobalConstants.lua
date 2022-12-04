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
local addon, ns = ...
local LibSharedMedia = LibStub('LibSharedMedia-3.0')
local sformat = string.format
local ADDON_TEXTURES_DIR_FORMAT = 'interface/addons/actionbarplus/Core/Assets/Textures/%s'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class GlobalConstants
local L = {}


--[[-----------------------------------------------------------------------------
Methods: GlobalConstants
-------------------------------------------------------------------------------]]
---@param o GlobalConstants
local function GlobalConstantProperties(o)

    ---@class GlobalConstants_Default
    local Default = {
        FrameAnchor = {
            point = "CENTER", relativeTo = nil, relativePoint = 'CENTER', x = 0.0, y = 0.0
        }
    }

    ---@class GlobalAttributes
    local C = {
        ADDON_NAME = addon,
        DB_NAME = 'ABP_PLUS_DB',
        ABP_KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r',
        ABP_CHECK_VAR_SYNTAX_FORMAT = '|cfdeab676%s ::|r %s',
        -- The minimum size of a button before the texts are hidden (if configured)
        MIN_BUTTON_SIZE_FOR_HIDING_TEXTS = 35,
        ALT = 'ALT',
        ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT',
        ARTWORK_DRAW_LAYER = 'ARTWORK',
        BOTTOM = 'BOTTOM',
        BOTTOMLEFT = 'BOTTOMLEFT',
        BOTTOMRIGHT = 'BOTTOMRIGHT',
        CENTER = 'CENTER',
        Button5 = 'Button5',
        CLAMPTOBLACKADDITIVE = 'CLAMPTOBLACKADDITIVE',
        CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI',
        CTRL = 'CTRL',
        HIGHLIGHT_DRAW_LAYER = 'HIGHLIGHT',
        LeftButton = 'LeftButton',
        RightButton = 'RightButton',
        PICKUPACTION = 'PICKUPACTION',
        SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate',
        SHIFT = 'SHIFT',
        TOP = 'TOP',
        TOPLEFT = 'TOPLEFT',

    }

    ---@class Textures
    local Textures = {
        ---@type number|string
        DRUID_FORM_ACTIVE_ICON = 136116,
        ---@type number|string
        STEALTHED_ICON = sformat(ADDON_TEXTURES_DIR_FORMAT, 'spell_nature_invisibilty_active'),
        ---@type number|string
        PRIEST_SHADOWFORM_ACTIVE_ICON = sformat(ADDON_TEXTURES_DIR_FORMAT, 'spell_shadowform_active'),
        ---@type string
        TEXTURE_EMPTY = sformat(ADDON_TEXTURES_DIR_FORMAT, 'ui-button-empty'),
        ---@type string
        TEXTURE_EMPTY_GRID = sformat(ADDON_TEXTURES_DIR_FORMAT, 'ui-button-empty-grid'),
        ---@type string
        TEXTURE_EMPTY_BLIZZ_DIALOG_BACKGROUND = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background"),
        ---@type string
        TEXTURE_HIGHLIGHT = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background Gold"),
        ---@type string
        TEXTURE_HIGHLIGHT2 = [[Interface\Buttons\WHITE8X8]],
        ---@type string
        TEXTURE_HIGHLIGHT3A = [[Interface\Buttons\ButtonHilight-Square]],
        ---@type string
        TEXTURE_BUTTON_HILIGHT_SQUARE_BLUE = [[Interface\Buttons\ButtonHilight-Square]],
        TEXTURE_BUTTON_HILIGHT_SQUARE_YELLOW = [[Interface\Buttons\checkbuttonhilight]],
        ---@type string
        TEXTURE_HIGHLIGHT3B = [[Interface\Buttons\ButtonHilight-SquareQuickslot]],
        ---@type string
        TEXTURE_HIGHLIGHT4 = [[Interface\QuestFrame\UI-QuestTitleHighlight]],
        ---@type string
        TEXTURE_HIGHLIGHT_BUTTON_ROUND = [[Interface\Buttons\ButtonHilight-Round]],
        TEXTURE_HIGHLIGHT_BUTTON_OUTLINE = [[Interface\BUTTONS\UI-Button-Outline]],
        ---@type string
        TEXTURE_CASTING = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Rock"),
    }

    ---@class EventNames
    local E = {

        ---################################
        --- Addon Messages
        AddonMessage_OnAfterInitialize = 'AddonMessage_OnAfterInitialize',

        OnEnter = 'OnEnter',
        OnEvent = 'OnEvent',
        OnLeave = 'OnLeave',
        OnModifierStateChanged = 'OnModifierStateChanged',
        OnDragStart = 'OnDragStart',
        OnDragStop = 'OnDragStop',
        OnMouseUp = 'OnMouseUp',
        OnMouseDown = 'OnMouseDown',
        OnReceiveDrag = 'OnReceiveDrag',

        ---################################
        --- Custom Events
        OnCooldownTextSettingsChanged = 'OnCooldownTextSettingsChanged',
        OnTextSettingsChanged = 'OnTextSettingsChanged',
        OnMouseOverGlowSettingsChanged = 'OnMouseOverGlowSettingsChanged',
        OnButtonSizeChanged = 'OnButtonSizeChanged',
        OnButtonCountChanged = 'OnButtonCountChanged',
        OnAddonLoaded = 'OnAddonLoaded',
        OnActionbarFrameAlphaUpdated = 'OnActionbarFrameAlphaUpdated',
        OnActionbarShowGrid = 'OnActionbarShowGrid',
        OnActionbarHideGrid = 'OnActionbarHideGrid',
        OnActionbarShowGroup = 'OnActionbarShowGroup',
        OnActionbarHideGroup = 'OnActionbarHideGroup',
        OnFrameHandleMouseOverConfigChanged = 'OnFrameHandleMouseOverConfigChanged',
        OnFrameHandleAlphaConfigChanged = 'OnFrameHandleAlphaConfigChanged',
        OnActionbarShowEmptyButtonsUpdated = 'OnActionbarShowEmptyButtonsUpdated',
        OnPlayerLeaveCombat = 'OnPlayerLeaveCombat',
        OnUpdateItemStates = 'OnUpdateItemStates',

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

        ACTIONBAR_SHOWGRID = 'ACTIONBAR_SHOWGRID',
        ACTIONBAR_HIDEGRID = 'ACTIONBAR_HIDEGRID',

        BAG_UPDATE_DELAYED = 'BAG_UPDATE_DELAYED',
        CURSOR_CHANGED = 'CURSOR_CHANGED',
        COMBAT_LOG_EVENT_UNFILTERED = 'COMBAT_LOG_EVENT_UNFILTERED',
        MODIFIER_STATE_CHANGED = 'MODIFIER_STATE_CHANGED',

        PET_BATTLE_OPENING_START = 'PET_BATTLE_OPENING_START',
        PET_BATTLE_CLOSE = 'PET_BATTLE_CLOSE',

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
        --- It fires when:
        --- 1) A mage is casting a non-instant spell (i.e. teleport) and while still casting,
        ---     cast another instant spell (i.e., Arcane Intellect)
        --- 2) Usually a UI error display or an error bell sound
        UNIT_SPELLCAST_FAILED_QUIET = 'UNIT_SPELLCAST_FAILED_QUIET',
        UNIT_SPELLCAST_SENT = 'UNIT_SPELLCAST_SENT',
        -- Fired for Start of Non-Instant Spell Cast
        UNIT_SPELLCAST_START = 'UNIT_SPELLCAST_START',
        -- Fired for Stop of Non-Instant Spell Cast
        UNIT_SPELLCAST_STOP = 'UNIT_SPELLCAST_STOP',
        UNIT_SPELLCAST_SUCCEEDED = 'UNIT_SPELLCAST_SUCCEEDED',

        UPDATE_BINDINGS = 'UPDATE_BINDINGS',
        UPDATE_SHAPESHIFT_FORM = 'UPDATE_SHAPESHIFT_FORM',
        UPDATE_STEALTH = 'UPDATE_STEALTH',

        UNIT_ENTERED_VEHICLE = 'UNIT_ENTERED_VEHICLE',
        UNIT_EXITED_VEHICLE = 'UNIT_EXITED_VEHICLE',
    }

    ---@deprecated Use #UnitId
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
    ---@class Blizzard_UnitId
    local UnitId = {
        ["target"] = "target",
        ["player"] = "player",
        ["vehicle"] = "vehicle",
        ["pet"] = "pet",
        ["none"] = "none",
        ["focus"] = "focus",
        ["mouseover"] = "mouseover",
        ---@param raidIndex number
        ["partyN"] = function(raidIndex) return toSuffix("party", raidIndex) end,
        ["raidN"] = function(raidIndex) return toSuffix("raid", raidIndex) end,
    }

    ---@class WidgetAttributes
    local WidgetAttributes = {
        TYPE = 'type',
        UNIT = 'unit',
        SPELL = 'spell',
        ITEM = 'item',
        MOUNT = 'mount',
        COMPANION = 'companion',
        BATTLE_PET = 'battlepet',
        FLY_OUT = 'flyout',
        PET_ACTION = 'petaction',
        MACRO_TEXT = "macrotext",
        MACRO = "macro",
        DRUID = 'DRUID',
        SHAPESHIFT = 'shapeshift',
        SHADOWFORM = 'shadowform',
        STEALTH = 'stealth',
        PROWL = 'prowl',
    }

    ---@class ButtonAttributes
    local ButtonAttributes = {
        SPELL = WidgetAttributes.SPELL,
        UNIT = WidgetAttributes.UNIT,
        UNIT2 = format("*%s2", WidgetAttributes.UNIT),
        TYPE = WidgetAttributes.TYPE,
        MACRO = WidgetAttributes.MACRO,
        MOUNT = WidgetAttributes.MOUNT,
        BATTLE_PET = WidgetAttributes.BATTLE_PET,
        MACRO_TEXT = WidgetAttributes.MACRO_TEXT,
    }

    ---@class Profile_Config_Names
    local Profile_Config_Names = {
        ['bars'] = 'bars',
        ---@deprecated lock_actionbars is to be removed
        ['lock_actionbars'] = 'lock_actionbars',
        ['character_specific_anchors'] = 'character_specific_anchors',
        ['hide_when_taxi'] = 'hide_when_taxi',
        ['action_button_mouseover_glow'] = 'action_button_mouseover_glow',
        ['hide_text_on_small_buttons'] = 'hide_text_on_small_buttons',
        ['hide_countdown_numbers'] = 'hide_countdown_numbers',
        ['tooltip_visibility_key'] = 'tooltip_visibility_key',
        ['tooltip_visibility_combat_override_key'] = 'tooltip_visibility_combat_override_key',
        ['show_button_index'] = 'show_button_index',
        ['show_keybind_text'] = 'show_keybind_text',
    }

    ---@class Profile_Config_Widget_Names
    local Profile_Config_Widget_Names = {
        ['rowSize'] = 'rowSize',
        ['colSize'] = 'colSize',
        ['buttonSize'] = 'buttonSize',
        ['buttonAlpha'] = 'buttonAlpha',
        ['show_empty_buttons'] = 'show_empty_buttons',
        ['frame_handle_mouseover'] = 'frame_handle_mouseover',
        ['frame_handle_alpha'] = 'frame_handle_alpha',
    }

    ---@class Blizzard_DrawLayer : _DrawLayer
    local DrawLayer = {
        BACKGROUND = 'BACKGROUND',
        BORDER = 'BORDER',
        ARTWORK = 'ARTWORK',
        OVERLAY = 'OVERLAY',
        HIGHLIGHT = 'HIGHLIGHT',
    }

    ---Also known as AlphaMode
    ---@class Blizzard_BlendMode : _BlendMode
    local BlendMode = {
        DISABLE = 'DISABLE',
        BLEND = 'BLEND',
        ALPHAKEY = 'ALPHAKEY',
        ADD = 'ADD',
        MOD = 'MOD',
    }

    ---@param prefix string
    ---@param index number
    local function toSuffix(prefix, index) return prefix .. tostring(index) end

    o.Textures = Textures
    o.C = C
    o.E = E
    o.Default = Default
    o.Profile_Config_Names = Profile_Config_Names
    o.Profile_Config_Widget_Names = Profile_Config_Widget_Names
    o.ButtonAttributes = ButtonAttributes
    o.UnitIDAttributes = UnitIDAttributes
    o.WidgetAttributes = WidgetAttributes
    o.DrawLayer = DrawLayer
    o.BlendMode = BlendMode
    o.AlphaMode = BlendMode
    ---@type Blizzard_UnitId
    o.UnitId = UnitId
end

---@param o GlobalConstants
local function GlobalConstantMethods(o)

    function o:AddonName() return o.C.ADDON_NAME end
    function o:Constants() return o.C end
    function o:Events() return o.E end
    ---#### Example
    ---```
    ---local version, curseForge, issues, repo = GC:GetAddonInfo()
    ---```
    function o:GetAddonInfo()
        local addonName = o.C.ADDON_NAME
        local versionText
        --@non-debug@
        versionText = GetAddOnMetadata(addonName, 'Version')
        --@end-non-debug@
        --@debug@
        versionText = '1.0.x.dev'
        --@end-debug@
        return versionText, GetAddOnMetadata(addonName, 'X-CurseForge'),
        GetAddOnMetadata(addonName, 'X-Github-Issues'),
        GetAddOnMetadata(addonName, 'X-Github-Repo')
    end

    function o:GetLogLevel() return ABP_LOG_LEVEL end
    ---@param level number The log level between 1 and 100
    function o:SetLogLevel(level) ABP_LOG_LEVEL = level or 1 end
    ---@param level number
    function o:ShouldLog(level) return self:GetLogLevel() >= level end
    function o:IsVerboseLogging() return self:ShouldLog(20) end

end

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
local function Init()
    GlobalConstantProperties(L)
    GlobalConstantMethods(L)

    ---@type GlobalConstants
    ABP_GlobalConstants = L
    ns.O = ns.O or {}
    ns.O.GlobalConstants = L
end

Init()
