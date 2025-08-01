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
local ActionButtonUseKeyDown_Cvar = 'ActionButtonUseKeyDown'
local ABP_M6_COMPATIBLE_VERSION_DATE = 'X-ActionbarPlus-M6-Compatible-Version-Date'

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetBuildInfo, GetCVarBool = GetBuildInfo, GetCVarBool
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub

--- @type CoreNamespace
local kns = select(2, ...)
local addon = kns.addon

--- @type Kapresoft_LibUtil_ConsoleHelper
local kch = kns.Kapresoft_LibUtil.CH
--- @type Kapresoft_LibUtil
local K = kns.Kapresoft_LibUtil
--- @type Kapresoft_LibUtil_Modules
local KO = K.Objects
--- @type Kapresoft_LibUtil_TimeUtil

local TimeUtil = KO.TimeUtil
local String = KO.String
local IsBlank, IsNotBlank, EqualsIgnoreCase = String.IsBlank, String.IsNotBlank, String.EqualsIgnoreCase

local LibSharedMedia = LibStub('LibSharedMedia-3.0')
local ADDON_TEXTURES_DIR_FORMAT = 'interface/addons/actionbarplus/Core/Assets/Textures/%s'

local consoleCommand = "actionbarplus"
local consoleCommandShort = "abp"
local consoleCommandOptions = consoleCommandShort .. '-options'
local globalVarName = "ABP"
local globalVarPrefix = globalVarName .. "_"
local dbName = globalVarPrefix .. 'PLUS_DB'


--[[-----------------------------------------------------------------------------
Console Colors
-------------------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil_ColorDefinition
local consoleColors = kns.consoleColors
local command = kch:FormatColor(consoleColors.primary, '/' .. consoleCommand)
local commandShort = kch:FormatColor(consoleColors.primary, '/' .. consoleCommandShort)

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

    --- @Class AddonFeatures
    local FEATURES = {
        ENABLE_LOGGING = true,
        ENABLE_RANGE_INDICATOR_UPDATE_ON_SPELLCAST = true,
        ENABLE_MULTI_SPEC = true,
        ENABLE_EXTERNAL_API = false,
    }

    --- @class GlobalAttributes
    local C = {
        ADDON_NAME = addon,
        VAR_NAME = globalVarName,
        CONSOLE_COMMAND_NAME = consoleCommand,
        CONSOLE_COMMAND_SHORT = consoleCommandShort,
        CONSOLE_COMMAND_OPTIONS = consoleCommandOptions,
        CONSOLE_COLORS = consoleColors,
        DB_NAME = dbName,
        BUTTON_NAME_FORMAT = 'ActionbarPlusF%sButton%s',
        BUTTON_NAME_SHORT_FORMAT = 'F%s-B%s',
        --- @see _ParentFrame.xml
        FRAME_TEMPLATE = 'ActionbarPlusFrameTemplate',
        ABP_KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r',
        ABP_CHECK_VAR_SYNTAX_FORMAT = '|cfdeab676%s ::|r %s',
        ABP_CONSOLE_HEADER_FORMAT = '|cfdeab676### %s ###|r',
        ABP_CONSOLE_OPTIONS_FORMAT = '  - %-8s|cfdeab676:: %s|r',
        ADDON_INFO_FMT = '%s|cfdeab676: %s|r',
        ADDON_INFO_FEATURE_FMT = '%s|cfd7c9cfb=%s|r',

        ABP_CONSOLE_COMMAND_TEXT_FORMAT = consoleCommandTextFormat,
        ABP_CONSOLE_KEY_VALUE_TEXT_FORMAT = consoleKeyValueTextFormat,

        ABP_COMMAND      = sformat(consoleCommandTextFormat, "/abp"),
        ABP_HELP_COMMAND = sformat(consoleCommandTextFormat, "/abp help"),

        -- The minimum size of a button before the texts are hidden (if configured)
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
        MIN_BUTTON_SIZE_FOR_HIDING_TEXTS = 35,
        MOUNT_ACTIVE_TEXTURE = 136116,
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
        GHOST_WOLF_FORM_ACTIVE_ICON = 136116,
        --- @type number|string
        STEALTHED_ICON = sformat(ADDON_TEXTURES_DIR_FORMAT, 'spell_nature_invisibilty_active'),
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

        ---################################
        --- Custom Events
        OnActionbarHideGrid = 'OnActionbarHideGrid',
        OnActionbarShowGrid = 'OnActionbarShowGrid',
        OnCooldownTextSettingsChanged = 'OnCooldownTextSettingsChanged',

        -- ################################
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_ENTER = 'OnEnter',
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_EVENT = 'OnEvent',
        --- @deprecated DEPRECATED: Use the camel cased version
        ON_LEAVE = 'OnLeave',
        -- ################################

        ADDON_LOADED = 'ADDON_LOADED',
        ACTIONBAR_UPDATE_COOLDOWN = 'ACTIONBAR_UPDATE_COOLDOWN',
        ACTIONBAR_UPDATE_STATE = 'ACTIONBAR_UPDATE_STATE',
        ACTIONBAR_UPDATE_USABLE = 'ACTIONBAR_UPDATE_USABLE',

        ACTIONBAR_SHOWGRID = 'ACTIONBAR_SHOWGRID',
        ACTIONBAR_HIDEGRID = 'ACTIONBAR_HIDEGRID',

        -- Classic
        ACTIVE_TALENT_GROUP_CHANGED          = 'ACTIVE_TALENT_GROUP_CHANGED',
        -- Retail
        ACTIVE_PLAYER_SPECIALIZATION_CHANGED = 'ACTIVE_PLAYER_SPECIALIZATION_CHANGED',
        -- MoP
        PLAYER_SPECIALIZATION_CHANGED        = 'PLAYER_SPECIALIZATION_CHANGED',

        PET_BAR_SHOWGRID   = 'PET_BAR_SHOWGRID',
        PET_BAR_HIDEGRID   = 'PET_BAR_HIDEGRID',

        --- wow classic
        BAG_UPDATE = 'BAG_UPDATE',
        --- 5.0.4|Mist of Pandaria and above
        BAG_UPDATE_DELAYED = 'BAG_UPDATE_DELAYED',
        CURSOR_CHANGED = 'CURSOR_CHANGED',
        COMBAT_LOG_EVENT_UNFILTERED = 'COMBAT_LOG_EVENT_UNFILTERED',
        COMPANION_UPDATE = 'COMPANION_UPDATE',
        CVAR_UPDATE = 'CVAR_UPDATE',
        --- This event fires whenever there's a change to the player's equipment sets. This includes creating, modifying, or deleting an equipment set.
        EQUIPMENT_SETS_CHANGED = 'EQUIPMENT_SETS_CHANGED',
        --- Triggered after an equipment set swap has been completed. This event helps addons and scripts determine when the gear change process has ended, allowing them to update or react accordingly.
        --- Event Params: result, setID
        EQUIPMENT_SWAP_FINISHED = 'EQUIPMENT_SWAP_FINISHED',
        MODIFIER_STATE_CHANGED = 'MODIFIER_STATE_CHANGED',
        UPDATE_MOUSEOVER_UNIT = 'UPDATE_MOUSEOVER_UNIT',

        --- This event is fired when the players gear changes. Example, a chest is changed to another chest piece.
        ---
        --- #### Event Params:<br/>
        ---  - equipmentSlot number - InventorySlotId
        ---  - hasCurrent boolean - True when a slot becomes empty, false when filled.
        PLAYER_EQUIPMENT_CHANGED = 'PLAYER_EQUIPMENT_CHANGED',

        PLAYER_CONTROL_GAINED = 'PLAYER_CONTROL_GAINED',
        PLAYER_CONTROL_LOST = 'PLAYER_CONTROL_LOST',
        PLAYER_MOUNT_DISPLAY_CHANGED = 'PLAYER_MOUNT_DISPLAY_CHANGED',
        PLAYER_ENTERING_WORLD = 'PLAYER_ENTERING_WORLD',
        --- This event fires when the player's currently equipped items change. It provides specifics about which slot had an item change, making it useful for tracking equipped items in real-time.
        PLAYER_REGEN_DISABLED = 'PLAYER_REGEN_DISABLED',
        PLAYER_REGEN_ENABLED = 'PLAYER_REGEN_ENABLED',
        PLAYER_STARTED_MOVING = 'PLAYER_STARTED_MOVING',
        PLAYER_STOPPED_MOVING = 'PLAYER_STOPPED_MOVING',
        PLAYER_TARGET_CHANGED = 'PLAYER_TARGET_CHANGED',
        PLAYER_TARGET_SET_ATTACKING = 'PLAYER_TARGET_SET_ATTACKING',

        SPELL_UPDATE_COOLDOWN  = 'SPELL_UPDATE_COOLDOWN',
        SPELL_UPDATE_USABLE    = 'SPELL_UPDATE_USABLE',
        START_AUTOREPEAT_SPELL = 'START_AUTOREPEAT_SPELL',
        STOP_AUTOREPEAT_SPELL  = 'STOP_AUTOREPEAT_SPELL',
        PLAYER_ENTER_COMBAT    = 'PLAYER_ENTER_COMBAT',
        PLAYER_LEAVE_COMBAT    = 'PLAYER_LEAVE_COMBAT',

        UI_ERROR_MESSAGE = 'UI_ERROR_MESSAGE',
        UNIT_AURA = 'UNIT_AURA',
        UNIT_HEALTH = 'UNIT_HEALTH',
        UNIT_POWER_FREQUENT = 'UNIT_POWER_FREQUENT',
        --- It fires when:
        --- 1) A mage is casting a non-instant spell (i.e. teleport) and while still casting,
        ---     cast another instant spell (i.e., Arcane Intellect)
        --- 2) Usually a UI error display or an error bell sound
        UNIT_SPELLCAST_FAILED_QUIET = 'UNIT_SPELLCAST_FAILED_QUIET',
        UNIT_SPELLCAST_FAILED = 'UNIT_SPELLCAST_FAILED',
        --- This applies to all players
        --- In classic, this is not a real event, but shows up on etrace
        UNIT_SPELLCAST_SENT = 'UNIT_SPELLCAST_SENT',
        -- Fired for Start of Non-Instant Spell Cast
        UNIT_SPELLCAST_START = 'UNIT_SPELLCAST_START',
        -- Fired for Stop of Non-Instant Spell Cast
        UNIT_SPELLCAST_STOP = 'UNIT_SPELLCAST_STOP',
        UNIT_SPELLCAST_SUCCEEDED = 'UNIT_SPELLCAST_SUCCEEDED',

        UNIT_SPELLCAST_EMPOWER_START = 'UNIT_SPELLCAST_EMPOWER_START',
        UNIT_SPELLCAST_EMPOWER_STOP = 'UNIT_SPELLCAST_EMPOWER_STOP',

        UPDATE_BINDINGS = 'UPDATE_BINDINGS',
        UPDATE_SHAPESHIFT_FORM = 'UPDATE_SHAPESHIFT_FORM',
        UPDATE_STEALTH = 'UPDATE_STEALTH',

        UNIT_ENTERED_VEHICLE = 'UNIT_ENTERED_VEHICLE',
        UNIT_EXITED_VEHICLE = 'UNIT_EXITED_VEHICLE',

        UPDATE_MACROS = 'UPDATE_MACROS',
        ZONE_CHANGED = 'ZONE_CHANGED',
        ZONE_CHANGED_NEW_AREA = 'ZONE_CHANGED_NEW_AREA',
    }

    ---@param msg string Message name
    local function newMsg(msg) return sformat("%s::%s", addon, msg) end
    ---@param event string Event name
    local function toMsg(event) return newMsg(event) end

    --- @class MessageNames
    local Messages = {
        OnEnter                             = newMsg('OnEnter'),
        OnLeave                             = newMsg('OnLeave'),
        OnActionbarFrameAlphaUpdated        = newMsg('OnActionbarFrameAlphaUpdated'),
        OnActionBarShowGroup                = newMsg('OnActionBarShowGroup'),
        OnActionBarHideGroup                = newMsg('OnActionBarHideGroup'),
        OnActionButtonShowGrid              = newMsg('OnActionButtonShowGrid'),
        OnActionButtonHideGrid              = newMsg('OnActionButtonHideGrid'),
        OnAddOnInitialized                  = newMsg('OnAddOnInitialized'),
        OnAddOnEnabled                      = newMsg('OnAddOnEnabled'),
        OnAddOnEnabledV2                    = newMsg('OnAddOnEnabledV2'),
        OnAddOnInitializedV2                = newMsg('OnAddOnInitializedV2'),
        OnAddOnReady                        = newMsg('OnAddOnReady'),
        OnAfterReceiveDrag                  = newMsg('OnAfterReceiveDrag'),
        OnAfterDragStart                    = newMsg('OnAfterDragStart'),
        OnBagUpdate                         = newMsg('OnBagUpdate'),
        OnButtonBeforePreClick              = newMsg('OnButtonBeforePreClick'),
        OnButtonAfterPreClick               = newMsg('OnButtonAfterPreClick'),
        OnButtonBeforePostClick             = newMsg('OnButtonBeforePostClick'),
        OnButtonAfterPostClick              = newMsg('OnButtonAfterPostClick'),
        OnButtonClickBattlePet              = newMsg('OnButtonClickBattlePet'),
        OnButtonClickEquipmentSet           = newMsg('OnButtonClickEquipmentSet'),
        OnButtonClickCompanion              = newMsg('OnButtonClickCompanion'),
        OnButtonClickLeatherworking         = newMsg('OnButtonClickLeatherworking'),
        OnButtonCountChanged                = newMsg('OnButtonCountChanged'),
        OnButtonSizeChanged                 = newMsg('OnButtonSizeChanged'),
        OnConfigInitialized                 = newMsg('OnConfigInitialized'),
        OnCooldownTextSettingsChanged       = newMsg('OnCooldownTextSettingsChanged'),
        OnDBInitialized                     = newMsg('OnDBInitialized'),
        OnDragStopFrameHandle               = newMsg('OnDragStopFrameHandle'),
        OnEquipmentSetDragComplete          = newMsg('OnEquipmentSetDragComplete'),
        OnFrameHandleAlphaConfigChanged     = newMsg('OnFrameHandleAlphaConfigChanged'),
        OnHideWhenTaxiSettingsChanged       = newMsg('OnHideWhenTaxiSettingsChanged'),
        OnShowKeybindTextSettingsUpdated    = newMsg('OnShowKeybindTextSettingsUpdated'),
        OnMacroAttributesSet                = newMsg('OnMacroAttributesSet'),
        OnMouseOverGlowSettingsChanged      = newMsg('OnMouseOverGlowSettingsChanged'),
        OnMouseOverFrameHandleConfigChanged = newMsg('OnMouseOverFrameHandleConfigChanged'),
        OnUpdateMacroState                  = newMsg('OnUpdateMacroState'),
        OnUpdateItemState                   = newMsg('OnUpdateItemState'),
        OnPostUpdateSpellUsable             = newMsg('OnPostUpdateSpellUsable'),
        OnShowEmptyButtons                  = newMsg('OnShowEmptyButtons'),
        OnSpellCastSucceeded                = newMsg('OnSpellCastSucceeded'),
        OnTextSettingsChanged               = newMsg('OnTextSettingsChanged'),
        OnTooltipFrameUpdate                = newMsg('OnTooltipFrameUpdate'),
        MacroAttributeSetter_OnSetIcon      = newMsg('MacroAttributeSetter:OnSetIcon'),
        MacroAttributeSetter_OnShowTooltip  = newMsg('MacroAttributeSetter:OnShowTooltip'),
        -- External Add-On Integration
        OnBagUpdateExt                      = newMsg('OnBagUpdateExt'),
        OnButtonPostClickExt                = newMsg('OnButtonPostClickExt'),
        OnPlayerEnterCombat                 = newMsg('OnPlayerEnterCombat'),
        OnPlayerLeaveCombat                 = newMsg('OnPlayerLeaveCombat'),

        -- Relayed from UNIT_SPELLCAST_[SENT|FAILED|SUCCEEDED]
        OnPlayerSpellCastStart              = newMsg('OnPlayerSpellCastStart'),
        OnPlayerSpellCastStop               = newMsg('OnPlayerSpellCastStop'),
        OnPlayerSpellCastSucceeded          = newMsg('OnPlayerSpellCastSucceeded'),
        OnPlayerSpellCastFailed             = newMsg('OnPlayerSpellCastFailed'),
        OnPlayerSpellCastFailedQuiet        = newMsg('OnPlayerSpellCastFailedQuiet'),

        OnSpellCastStartExt                 = newMsg('OnSpellCastStartExt'),
        OnSpellCastSentExt                  = newMsg('OnSpellCastSentExt'),
        OnSpellCastStopExt                  = newMsg('OnSpellCastStopExt'),
        OnSpellCastFailedExt                = newMsg('OnSpellCastFailedExt'),

        --- Relayed Events
        PLAYER_ENTERING_WORLD               = newMsg(Events.PLAYER_ENTERING_WORLD),
        EQUIPMENT_SETS_CHANGED              = newMsg(Events.EQUIPMENT_SETS_CHANGED),
        EQUIPMENT_SWAP_FINISHED             = newMsg(Events.EQUIPMENT_SWAP_FINISHED),
        PLAYER_MOUNT_DISPLAY_CHANGED        = newMsg(Events.PLAYER_MOUNT_DISPLAY_CHANGED),
        ZONE_CHANGED_NEW_AREA               = newMsg(Events.ZONE_CHANGED_NEW_AREA),
        MODIFIER_STATE_CHANGED              = newMsg(Events.MODIFIER_STATE_CHANGED),
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

    -- Note: Monk class was added in Mists of Pandaria.
    -- Note: Demon Hunter class was added in Legion.
    local UnitClass = {
        WARRIOR = "WARRIOR",
        PALADIN = "PALADIN",
        HUNTER = "HUNTER",
        ROGUE = "ROGUE",
        PRIEST = "PRIEST",
        DEATHKNIGHT = "DEATHKNIGHT",
        SHAMAN = "SHAMAN",
        MAGE = "MAGE",
        WARLOCK = "WARLOCK",
        MONK = "MONK",
        DRUID = "DRUID",
        DEMONHUNTER = "DEMONHUNTER"
    }

    local UnitClassID = {
        WARRIOR = 1,
        PALADIN = 2,
        HUNTER = 3,
        ROGUE = 4,
        PRIEST = 5,
        DEATHKNIGHT = 6,
        SHAMAN = 7,
        MAGE = 8,
        WARLOCK = 9,
        MONK = 10,      -- Note: Monk class was added in Mists of Pandaria
        DRUID = 11,
        DEMONHUNTER = 12 -- Note: Demon Hunter class was added in Legion
    }

    local UnitClasses = {
        WARRIOR = { id = UnitClassID.WARRIOR, name = UnitClass.WARRIOR },
        PALADIN = { id = UnitClassID.PALADIN, name = UnitClass.PALADIN },
        HUNTER = { id = UnitClassID.HUNTER, name = UnitClass.HUNTER },
        ROGUE = { id = UnitClassID.ROGUE, name = UnitClass.ROGUE },
        PRIEST = { id = UnitClassID.PRIEST, name = UnitClass.PRIEST },
        DEATHKNIGHT = { id = UnitClassID.DEATHKNIGHT, name = UnitClass.DEATHKNIGHT },
        SHAMAN = { id = UnitClassID.SHAMAN, name = UnitClass.SHAMAN },
        MAGE = { id = UnitClassID.MAGE, name = UnitClass.MAGE },
        WARLOCK = { id = UnitClassID.WARLOCK, name = UnitClass.WARLOCK },
        MONK = { id = UnitClassID.MONK, name = UnitClass.MONK },
        DRUID = { id = UnitClassID.DRUID, name = UnitClass.DRUID },
        DEMONHUNTER = { id = UnitClassID.DEMONHUNTER, name = UnitClass.DEMONHUNTER },
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
        MACRO_SUBTYPE_M6 = "m6",
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
        ['equipmentset_open_character_frame'] = 'equipmentset_open_character_frame',
        ['equipmentset_open_equipment_manager'] = 'equipmentset_open_equipment_manager',
        ['equipmentset_show_glow_when_active'] = 'equipmentset_show_glow_when_active',
        ['spec2_init'] = 'spec2_init',
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

    --- @class TooltipKeyName
    local TooltipKeyName = {
        ['SHOW'] = '',
        ['ALT'] = 'alt',
        ['CTRL'] = 'ctrl',
        ['SHIFT'] = 'shift',
        ['HIDE'] = 'hide',
    }

    --- @param prefix string
    --- @param index number
    local function toSuffix(prefix, index) return prefix .. tostring(index) end

    o.F = FEATURES
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
    o.TooltipKeyName = TooltipKeyName
    --- @type Blizzard_UnitId
    o.UnitId = UnitId
    o.UnitClass = UnitClass
    o.UnitClasses = UnitClasses

    o.ch = kch
    o.newMsg = newMsg
    o.toMsg = toMsg
end

--- @param o GlobalConstants
local function GlobalConstantMethods(o)

    --- @return boolean
    local function IsDev()
        local _isDev = kns:IsDev()
        --@do-not-package@
        _isDev = true
        --@end-do-not-package@
        return _isDev
    end

    --- Checks if the first argument matches any of the subsequent arguments.
    --- @param toMatch number The value to match against the varargs.
    --- @param ... any The list of values to check for a match.
    --- @return boolean True if `toMatch` is found in the varargs, false otherwise.
    function o:IsAnyOfNumber(toMatch, ...)
        if toMatch == nil then return false end
        for i = 1, select('#', ...) do
            local val = select(i, ...)
            if toMatch == val then return true end
        end
        return false
    end

    --- @return string
    function o:AddonName() return o.C.ADDON_NAME end
    function o:GetAceLocale()
        --return LibStub("AceLocale-3.0"):GetLocale(addon, true)
        return KO.AceLocaleUtil:GetLocale(addon, not IsDev())
    end

    function o:AIU()
        if o.AddonUtil then return o.AddonUtil end
        o.AddonUtil = kns:AddonInfoUtil():New(addon, kns.consoleColors, IsDev())
        return o.AddonUtil
    end

    --- @return string The ActionbarPlus version string. Example: 2024.3.1
    function o:GetVersion() return self:AIU():GetVersion() end

    --- @return string The time in ISO Date Format. Example: 2024-03-22T17:34:00Z
    function o:GetLastUpdate() return self:AIU():GetLastUpdate() end

    --- The date represents compatible version update date.
    --- between ActionbarPlus-M6 and ActionbarPlus. Any dates lower than this
    --- will prompt the user of ActionbarPlus-M6 addon to update to the latest
    --- ActionbarPlus. Example: 2024-03-22T17:34:00Z
    function o:GetActionbarPlusM6CompatibleVersionDate()
        local lastCompatibleDate
        lastCompatibleDate = GetAddOnMetadata(addon, ABP_M6_COMPATIBLE_VERSION_DATE)

        --@do-not-package@
        if kns:IsDev() then
            -- Add time to simulate expired ActionbarPlus-M6 in dev environment. Example: time() + 1000
            -- if "lastUpdate" is older than "lastCompatibleDate", then ActionbarPlus-M6 will notify user.
            -- lastCompatibleDate = ns.TimeUtil:TimeToISODate(time() - 10)
            lastCompatibleDate = lastCompatibleDate or TimeUtil:TimeToISODate(time() - 10)
        end
        --@end-do-not-package@

        return lastCompatibleDate
    end

    --- @return string
    function o:GetAddonInfoFormatted()
        local a = self:AIU()

        local kvFormat = a:infoKvFn()
        local kvSubFormat = a:infoKvSubFn()

        local function AdditionalInfo()
            local C = self:GetAceLocale()
            local s = ''
            local useKeyDown = GetCVarBool(ActionButtonUseKeyDown_Cvar)

            s = s .. kvFormat(C['Use-KeyDown(cvar ActionButtonUseKeyDown)'], tostring(useKeyDown))
            s = s .. kvFormat(C['Features'], ' ')
            s = s .. kvSubFormat('v2-enabled', tostring(kns.features.enableV2))
            return s
        end

        return self:AIU():GetInfoSlashCommandText() .. AdditionalInfo()
    end

    function o:GetMessageLoadedText()
        return self:AIU():GetMessageLoadedText(command, commandShort)
    end

    --- @param frameIndex number
    --- @param btnIndex number
    function o:ButtonName(frameIndex, btnIndex)
        return sformat(self.C.BUTTON_NAME_FORMAT, tostring(frameIndex), tostring(btnIndex))
    end

    --- todo next: merge with IsM6Macro
    --- @param macroName string The macro name i.e '_M6+s01'
    --- @return boolean Returns true if the macro name has the format '_M6+<slotID>', i.e. '_M6+s01'
    function o:IsM6Macro(macroName)
        if IsBlank(macroName) then return nil end
        local _, slotID = macroName:gmatch("(%w+)%+(%w+)")()
        return IsNotBlank(slotID)
    end
end

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
local function Init()
    GlobalConstantProperties(L)
    GlobalConstantMethods(L)
    kns.GC = L
end

Init()
