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
        ADDON_NAME = 'ActionbarPlus',
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
        ---@type string
        TEXTURE_EMPTY = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background"),
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

        OnEnter = 'OnEnter',
        OnEvent = 'OnEvent',
        OnLeave = 'OnLeave',
        OnModifierStateChanged = 'OnModifierStateChanged',
        OnDragStart = 'OnDragStart',
        OnDragStop = 'OnDragStop',
        OnMouseUp = 'OnMouseUp',
        OnMouseDown = 'OnMouseDown',
        OnReceiveDrag = 'OnReceiveDrag',

        -- ################################
        ---Custom Events
        OnCooldownTextSettingsChanged = 'OnCooldownTextSettingsChanged',
        OnTextSettingsChanged = 'OnTextSettingsChanged',
        OnMouseOverGlowSettingsChanged = 'OnMouseOverGlowSettingsChanged',
        OnButtonSizeChanged = 'OnButtonSizeChanged',
        OnAddonLoaded = 'OnAddonLoaded',
        OnActionbarFrameAlphaUpdated = 'OnActionbarFrameAlphaUpdated',
        OnActionbarShowGrid = 'OnActionbarShowGrid',
        OnActionbarHideGrid = 'OnActionbarHideGrid',
        OnFrameHandleMouseOverConfigChanged = 'OnFrameHandleMouseOverConfigChanged',
        OnFrameHandleAlphaConfigChanged = 'OnFrameHandleAlphaConfigChanged',

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

    function o:GetAddonInfo()
        local addonName = o.C.ADDON_NAME
        local versionText
        --@non-debug@
        versionText = GetAddOnMetadata(addonName, 'X-Github-Project-Version')
        --@end-non-debug@
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
end

Init()

