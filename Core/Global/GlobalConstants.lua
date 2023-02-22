--[[-----------------------------------------------------------------------------
Global Variables Initialization
-------------------------------------------------------------------------------]]
-- log levels, 10, 20, (+10), 100
-- TODO NEXT: Move to player login event
if type(ABP_PLUS_DB) ~= "table" then ABP_PLUS_DB = {} end
if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata, GetBuildInfo, GetCVarBool = GetAddOnMetadata, GetBuildInfo, GetCVarBool
local date = date

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- Use the bare namespace here since this is the very first file to be loaded
local addon, ns = ...
local pformat = ns.pformat

local LibSharedMedia = LibStub('LibSharedMedia-3.0')
local ADDON_TEXTURES_DIR_FORMAT = 'interface/addons/actionbarplus/Core/Assets/Textures/%s'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class GlobalConstants
local L = {}


--[[-----------------------------------------------------------------------------
Methods: GlobalConstants
-------------------------------------------------------------------------------]]
--- @param o GlobalConstants
local function GlobalConstantProperties(o)

    local consoleCommandTextFormat = '|cfd2db9fb%s|r'
    local consoleKeyValueTextFormat = '|cfdfbeb2d%s|r: %s'

    --- @class GlobalConstants_Default
    local Default = {
        FrameAnchor = {
            point = "CENTER", relativeTo = nil, relativePoint = 'CENTER', x = 0.0, y = 0.0
        }
    }

    --- @class GlobalAttributes
    local C = {
        ADDON_NAME = addon,
        DB_NAME = 'ABP_PLUS_DB',
        BASE_FRAME_NAME = 'ActionbarPlusF',
        BUTTON_NAME_FORMAT = 'ActionbarPlusF%sButton%s',
        --- @see _ParentFrame.xml
        FRAME_TEMPLATE = 'ActionbarPlusFrameTemplate',
        SLASH_COMMAND_OPTIONS = "abp_options",
        ABP_KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r',
        ABP_CHECK_VAR_SYNTAX_FORMAT = '|cfdeab676%s ::|r %s',
        ABP_CONSOLE_HEADER_FORMAT = '|cfdeab676### %s ###|r',
        ABP_CONSOLE_OPTIONS_FORMAT = '  - %-8s|cfdeab676:: %s|r',
        ADDON_INFO_FMT = '%s|cfdeab676: %s|r',

        ABP_CONSOLE_COMMAND_TEXT_FORMAT = consoleCommandTextFormat,
        ABP_CONSOLE_KEY_VALUE_TEXT_FORMAT = consoleKeyValueTextFormat,

        ABP_COMMAND      = sformat(consoleCommandTextFormat, "/abp"),
        ABP_HELP_COMMAND = sformat(consoleCommandTextFormat, "/abp help"),

        -- The minimum size of a button before the texts are hidden (if configured)
        MIN_BUTTON_SIZE_FOR_HIDING_TEXTS = 35,
        ALT = 'ALT',
        ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT',
        ANCHOR_TOPRIGHT = 'ANCHOR_TOPRIGHT',
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
        TOOLTIP_ANCHOR_FRAME_NAME = 'ActionbarPlusTooltipAnchorFrame',

    }

    --- @class Textures
    local Textures = {
        --- @type number|string
        DRUID_FORM_ACTIVE_ICON = 136116,
        --- @type number|string
        STEALTHED_ICON = sformat(ADDON_TEXTURES_DIR_FORMAT, 'spell_nature_invisibilty_active'),
        --- @type number|string
        PRIEST_SHADOWFORM_ACTIVE_ICON = sformat(ADDON_TEXTURES_DIR_FORMAT, 'spell_shadowform_active'),
        --- @type string
        TEXTURE_EMPTY = sformat(ADDON_TEXTURES_DIR_FORMAT, 'ui-button-empty'),
        --- @type string
        TEXTURE_EMPTY_GRID = sformat(ADDON_TEXTURES_DIR_FORMAT, 'ui-button-empty-grid'),
        --- @type string
        TEXTURE_EMPTY_BLIZZ_DIALOG_BACKGROUND = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background"),
        --- @type string
        TEXTURE_HIGHLIGHT = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background Gold"),
        --- @type string
        TEXTURE_HIGHLIGHT2 = [[Interface\Buttons\WHITE8X8]],
        --- @type string
        TEXTURE_HIGHLIGHT3A = [[Interface\Buttons\ButtonHilight-Square]],
        --- @type string
        TEXTURE_BUTTON_HILIGHT_SQUARE_BLUE = [[Interface\Buttons\ButtonHilight-Square]],
        TEXTURE_BUTTON_HILIGHT_SQUARE_YELLOW = [[Interface\Buttons\checkbuttonhilight]],
        --- @type string
        TEXTURE_HIGHLIGHT3B = [[Interface\Buttons\ButtonHilight-SquareQuickslot]],
        --- @type string
        TEXTURE_HIGHLIGHT4 = [[Interface\QuestFrame\UI-QuestTitleHighlight]],
        --- @type string
        TEXTURE_HIGHLIGHT_BUTTON_ROUND = [[Interface\Buttons\ButtonHilight-Round]],
        TEXTURE_HIGHLIGHT_BUTTON_OUTLINE = [[Interface\BUTTONS\UI-Button-Outline]],
        --- @type string
        TEXTURE_CASTING = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Rock"),
    }

    --- @class EventNames
    local Events = {

        OnEnter = 'OnEnter',
        OnEvent = 'OnEvent',
        OnLeave = 'OnLeave',
        OnShow = 'OnShow',
        OnTooltipSetSpell = 'OnTooltipSetSpell',
        OnTooltipSetItem = 'OnTooltipSetItem',
        OnModifierStateChanged = 'OnModifierStateChanged',
        OnDragStart = 'OnDragStart',
        OnDragStop = 'OnDragStop',
        OnMouseUp = 'OnMouseUp',
        OnMouseDown = 'OnMouseDown',
        OnReceiveDrag = 'OnReceiveDrag',

        ---################################
        --- Custom Events
        OnActionbarFrameAlphaUpdated = 'OnActionbarFrameAlphaUpdated',
        OnActionbarHideGrid = 'OnActionbarHideGrid',
        OnActionbarHideGroup = 'OnActionbarHideGroup',
        OnActionbarShowEmptyButtonsUpdated = 'OnActionbarShowEmptyButtonsUpdated',
        OnActionbarShowGrid = 'OnActionbarShowGrid',
        OnActionbarShowGroup = 'OnActionbarShowGroup',
        OnButtonCountChanged = 'OnButtonCountChanged',
        OnButtonSizeChanged = 'OnButtonSizeChanged',
        OnCooldownTextSettingsChanged = 'OnCooldownTextSettingsChanged',
        OnFrameHandleAlphaConfigChanged = 'OnFrameHandleAlphaConfigChanged',
        OnFrameHandleMouseOverConfigChanged = 'OnFrameHandleMouseOverConfigChanged',
        OnHideWhenTaxiChanged = 'OnHideWhenTaxiChanged',
        OnMouseOverGlowSettingsChanged = 'OnMouseOverGlowSettingsChanged',
        OnPlayerLeaveCombat = 'OnPlayerLeaveCombat',
        OnTextSettingsChanged = 'OnTextSettingsChanged',
        OnUpdateItemStates = 'OnUpdateItemStates',

        -- ################################
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_ENTER = 'OnEnter',
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_EVENT = 'OnEvent',
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_LEAVE = 'OnLeave',
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_MODIFIER_STATE_CHANGED = 'OnModifierStateChanged',
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_RECEIVE_DRAG = 'OnReceiveDrag',
        -- ################################

        ACTIONBAR_UPDATE_COOLDOWN = 'ACTIONBAR_UPDATE_COOLDOWN',
        ACTIONBAR_UPDATE_STATE = 'ACTIONBAR_UPDATE_STATE',
        ACTIONBAR_UPDATE_USABLE = 'ACTIONBAR_UPDATE_USABLE',

        ACTIONBAR_SHOWGRID = 'ACTIONBAR_SHOWGRID',
        ACTIONBAR_HIDEGRID = 'ACTIONBAR_HIDEGRID',

        --- wow classic
        BAG_UPDATE = 'BAG_UPDATE',
        --- 5.0.4|Mist of Pandaria and above
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

    local function newMsg(msg) return sformat("%s::%s", addon, msg) end

    --- @class MessageNames
    local Messages = {
        OnAddOnInitialized    = newMsg('OnAddOnInitialized'),
        OnAddOnReady          = newMsg('OnAddOnReady'),
        OnBagUpdate           = newMsg('OnBagUpdate'),
        OnDBInitialized       = newMsg('OnDBInitialized'),
        OnConfigInitialized   = newMsg('OnConfigInitialized'),
        OnTooltipFrameUpdate  = newMsg('OnTooltipFrameUpdate'),
    }

    --- @class WidgetGlobals
    local Widgets = {
        BACKDROP_DIALOG_32_32 = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileEdge = true,
            tileSize = 32,
            edgeSize = 24,
            insets = { left = 6, right = 5, top = 5, bottom = 6 },
        },
        BACKDROP_CHARACTER_CREATE_TOOLTIP_32_32 = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
            tile = true,
            tileEdge = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 8, right = 4, top = 4, bottom = 8 },
        }
    }

    --- @deprecated Use #UnitId
    --- @class UnitIDAttributes
    local UnitIDAttributes = {
        FOCUS = 'focus',
        TARGET = 'target',
        MOUSEOVER = 'mouseover',
        NONE = 'none',
        PET = 'pet',
        PLAYER = 'player',
        VEHICLE = 'vehicle',
    }
    --- @class Blizzard_UnitId
    local UnitId = {
        ["target"] = "target",
        ["player"] = "player",
        ["vehicle"] = "vehicle",
        ["pet"] = "pet",
        ["none"] = "none",
        ["focus"] = "focus",
        ["mouseover"] = "mouseover",
        --- @param raidIndex number
        ["partyN"] = function(raidIndex) return toSuffix("party", raidIndex) end,
        ["raidN"] = function(raidIndex) return toSuffix("raid", raidIndex) end,
    }
    local UnitClass = {
        DRUID = 'DRUID',
        PRIEST = 'PRIEST',
        ROGUE = 'ROGUE'
    }

    --- @class WidgetAttributes
    local WidgetAttributes = {
        TYPE = 'type',
        UNIT = 'unit',
        SPELL = 'spell',
        ITEM = 'item',
        MOUNT = 'mount',
        COMPANION = 'companion',
        BATTLE_PET = 'battlepet',
        EQUIPMENT_SET = 'equipmentset',
        FLY_OUT = 'flyout',
        PET_ACTION = 'petaction',
        MACRO_TEXT = "macrotext",
        MACRO = "macro",
        DRUID = 'DRUID',
        SHAPESHIFT = 'shapeshift',
        SHADOWFORM = 'shadowform',
        MOONKIN_FORM = 'moonkin form',
        STEALTH = 'stealth',
        PROWL = 'prowl',
        --- equipmentset
        NAME = 'name',
    }

    --- @class ButtonAttributes
    local ButtonAttributes = {
        SPELL = WidgetAttributes.SPELL,
        NAME = WidgetAttributes.NAME,
        UNIT = WidgetAttributes.UNIT,
        UNIT2 = format("*%s2", WidgetAttributes.UNIT),
        TYPE = WidgetAttributes.TYPE,
        MACRO = WidgetAttributes.MACRO,
        MOUNT = WidgetAttributes.MOUNT,
        BATTLE_PET = WidgetAttributes.BATTLE_PET,
        MACRO_TEXT = WidgetAttributes.MACRO_TEXT,
    }

    --- Flat view of all known config names
    --- Use this for strongly-typed configs
    --- @class Profile_Config_Names
    local Profile_Config_Names = {
        ['enabled'] = 'enabled',
        --- @see Profile_Bar
        ['bars'] = 'bars',
        --- @see Profile_Bar_Widget Contains widget settings, i.e. colsize, etc
        ['widget'] = 'widget',
        --- @see _RegionAnchor
        ['anchor'] = 'anchor',
        ['locked'] = 'locked',
        --- type is table<number, Profile_Button>
        ['buttons'] = 'buttons',
        ['rowSize'] = 'rowSize',
        ['colSize'] = 'colSize',
        ['buttonSize'] = 'buttonSize',
        ['character_specific_anchors'] = 'character_specific_anchors',
        ['hide_when_taxi'] = 'hide_when_taxi',
        ['action_button_mouseover_glow'] = 'action_button_mouseover_glow',
        ['hide_text_on_small_buttons'] = 'hide_text_on_small_buttons',
        ['hide_countdown_numbers'] = 'hide_countdown_numbers',
        ['tooltip_visibility_key'] = 'tooltip_visibility_key',
        ['tooltip_visibility_combat_override_key'] = 'tooltip_visibility_combat_override_key',
        ['show_button_index'] = 'show_button_index',
        ['show_keybind_text'] = 'show_keybind_text',
        ['tooltip_anchor_type'] = 'tooltip_anchor_type',
        ['show_empty_buttons'] = 'show_empty_buttons',
        ['frame_handle_mouseover'] = 'frame_handle_mouseover',
        ['frame_handle_alpha'] = 'frame_handle_alpha',
        ['alpha'] = 'alpha',
    }

    --- @class Profile_Config_Widget_Names
    local Profile_Config_Widget_Names = {
        ['rowSize'] = 'rowSize',
        ['colSize'] = 'colSize',
        ['buttonSize'] = 'buttonSize',
        ['buttonAlpha'] = 'buttonAlpha',
        ['show_empty_buttons'] = 'show_empty_buttons',
        ['frame_handle_mouseover'] = 'frame_handle_mouseover',
        ['frame_handle_alpha'] = 'frame_handle_alpha',
    }

    --- @class Blizzard_DrawLayer : _DrawLayer
    local DrawLayer = {
        BACKGROUND = 'BACKGROUND',
        BORDER = 'BORDER',
        ARTWORK = 'ARTWORK',
        OVERLAY = 'OVERLAY',
        HIGHLIGHT = 'HIGHLIGHT',
    }

    ---Also known as AlphaMode
    --- @class Blizzard_BlendMode : _BlendMode
    local BlendMode = {
        DISABLE = 'DISABLE',
        BLEND = 'BLEND',
        ALPHAKEY = 'ALPHAKEY',
        ADD = 'ADD',
        MOD = 'MOD',
    }

    --- @class TooltipAnchor
    local TooltipAnchor = {
        CURSOR_TOPLEFT = 'CURSOR_TOPLEFT',
        CURSOR_TOPRIGHT = 'CURSOR_TOPRIGHT',
        CURSOR_BOTTOMLEFT = 'CURSOR_BOTTOMLEFT',
        CURSOR_BOTTOMRIGHT = 'CURSOR_BOTTOMRIGHT',

        SCREEN_TOPLEFT = 'SCREEN_TOPLEFT',
        SCREEN_TOPRIGHT = 'SCREEN_TOPRIGHT',
        SCREEN_BOTTOMLEFT = 'SCREEN_BOTTOMLEFT',
        SCREEN_BOTTOMRIGHT = 'SCREEN_BOTTOMRIGHT',
    }

    --- @param prefix string
    --- @param index number
    local function toSuffix(prefix, index) return prefix .. tostring(index) end

    o.Textures = Textures
    o.C = C
    o.E = Events
    o.M = Messages
    o.W = Widgets
    o.Default = Default
    o.Profile_Config_Names = Profile_Config_Names
    o.Profile_Config_Widget_Names = Profile_Config_Widget_Names
    o.ButtonAttributes = ButtonAttributes
    o.UnitIDAttributes = UnitIDAttributes
    o.WidgetAttributes = WidgetAttributes
    o.DrawLayer = DrawLayer
    o.BlendMode = BlendMode
    o.AlphaMode = BlendMode
    o.TooltipAnchor = TooltipAnchor
    --- @type Blizzard_UnitId
    o.UnitId = UnitId
    o.UnitClass = UnitClass
end

--- @param o GlobalConstants
local function GlobalConstantMethods(o)

    function o:AddonName() return o.C.ADDON_NAME end
    ---@param frameIndex number
    function o:GetFrameName(frameIndex)
        assert(frameIndex, "frameIndex is required on GC:GetFrameName(frameIndex)")
        assert(frameIndex > 0, "frameIndex should be > 0 on GC:GetFrameName(frameIndex)")
        return self.C.BASE_FRAME_NAME .. frameIndex
    end
    function o:Constants() return o.C end
    function o:Events() return o.E end
    ---#### Example
    ---```
    ---local version, curseForge, issues, repo, lastUpdate, useKeyDown, wowInterfaceVersion = GC:GetAddonInfo()
    ---```
    --- @return string, string, string, string, string, string, string
    function o:GetAddonInfo()
        local addonName = o.C.ADDON_NAME
        local versionText, lastUpdate
        --@non-debug@
        versionText = GetAddOnMetadata(addonName, 'Version')
        lastUpdate = GetAddOnMetadata(ns.name, 'X-Github-Project-Last-Changed-Date')
        --@end-non-debug@
        --@debug@
        versionText = '1.0.x.dev'
        lastUpdate = date("%m/%d/%y %H:%M:%S")
        --@end-debug@

        local useKeyDown = GetCVarBool("ActionButtonUseKeyDown")
        local wowInterfaceVersion = select(4, GetBuildInfo())

        return versionText, GetAddOnMetadata(addonName, 'X-CurseForge'), GetAddOnMetadata(addonName, 'X-Github-Issues'),
                    GetAddOnMetadata(addonName, 'X-Github-Repo'), lastUpdate, useKeyDown, wowInterfaceVersion
    end

    --- @return string
    function o:GetAddonInfoFormatted()
        local version, curseForge, issues, repo, lastUpdate, useKeyDown, wowInterfaceVersion = self:GetAddonInfo()
        local fmt = self.C.ADDON_INFO_FMT
        return sformat("Addon Info:\n%s\n%s\n%s\n%s\n%s\n%s\n%s",
                sformat(fmt, ABP_VERSION_TEXT, version),
                sformat(fmt, 'Curse-Forge', curseForge),
                sformat(fmt, ABP_BUGS_TEXT, issues),
                sformat(fmt, ABP_REPO_TEXT, repo),
                sformat(fmt, ABP_LAST_UPDATE_TEXT, lastUpdate),
                sformat(fmt, 'Use-KeyDown(cvar ActionButtonUseKeyDown)', tostring(useKeyDown)),
                sformat(fmt, ABP_INTERFACE_VERSION_TEXT, wowInterfaceVersion)
        )
    end

    function o:GetLogLevel() return ABP_LOG_LEVEL end
    --- @param level number The log level between 1 and 100
    function o:SetLogLevel(level) ABP_LOG_LEVEL = level or 1 end
    --- @param level number
    function o:ShouldLog(level) return self:GetLogLevel() >= level end
    function o:IsVerboseLogging() return self:ShouldLog(20) end

    --- @param frameIndex number
    --- @param btnIndex number
    function o:ButtonName(frameIndex, btnIndex)
        return sformat(self.C.BUTTON_NAME_FORMAT, tostring(frameIndex), tostring(btnIndex))
    end
end

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
local function Init()
    GlobalConstantProperties(L)
    GlobalConstantMethods(L)

    --- @type GlobalConstants
    ABP_GlobalConstants = L
    ns.O = ns.O or {}
    ns.O.GlobalConstants = L
end

Init()
