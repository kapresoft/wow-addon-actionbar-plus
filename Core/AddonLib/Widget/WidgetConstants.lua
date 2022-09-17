local ReloadUI = ReloadUI
local Core = __K_Core
local LibStub, M, G = ABP_LibGlobals:LibPack()

---@type AceLibFactory
local CC = ABP_CommonConstants
local AceLibFactory = LibStub('AceLibFactory')
local LibSharedMedia = AceLibFactory:GetAceSharedMedia()
local LogFactory = LibStub(M.LogFactory)
local p = LogFactory('WidgetConstants')

-- #########################################################

ADDON_NAME = 'ActionbarPlus'
SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate'
TOPLEFT = 'TOPLEFT'
BOTTOMLEFT = 'BOTTOMLEFT'
BOTTOMRIGHT = 'BOTTOMRIGHT'
CLAMPTOBLACKADDITIVE = 'CLAMPTOBLACKADDITIVE'
ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT'
CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI'
TEXTURE_EMPTY = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background")
TEXTURE_HIGHLIGHT = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background Gold")
TEXTURE_HIGHLIGHT2 = [[Interface\Buttons\WHITE8X8]]
TEXTURE_HIGHLIGHT3 = [[Interface\Buttons\ButtonHilight-Square]]
TEXTURE_HIGHLIGHT4 = [[Interface\QuestFrame\UI-QuestTitleHighlight]]
TEXTURE_CASTING = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Rock")

--ALT = 'ALT'
--CTRL = 'CTRL'
--SHIFT = 'SHIFT'
--PICKUPACTION = 'PICKUPACTION'

---@class WidgetConstantsConstants
local C = {

    PLAYER_REGEN_ENABLED = 'PLAYER_REGEN_ENABLED',
    PLAYER_REGEN_DISABLED = 'PLAYER_REGEN_DISABLED',

}

---@class WidgetConstantsEventNames
local E = {

    ON_LEAVE = 'OnLeave',
    ON_ENTER = 'OnEnter',
    ON_RECEIVE_DRAG = 'OnReceiveDrag',
    ON_MODIFIER_STATE_CHANGED = 'OnModifierStateChanged',

    ACTIONBAR_UPDATE_COOLDOWN = 'ACTIONBAR_UPDATE_COOLDOWN',
    ACTIONBAR_UPDATE_STATE = 'ACTIONBAR_UPDATE_STATE',
    ACTIONBAR_UPDATE_USABLE = 'ACTIONBAR_UPDATE_USABLE',

    BAG_UPDATE_DELAYED = 'BAG_UPDATE_DELAYED',
    COMBAT_LOG_EVENT_UNFILTERED = 'COMBAT_LOG_EVENT_UNFILTERED',
    MODIFIER_STATE_CHANGED = 'MODIFIER_STATE_CHANGED',

    PLAYER_CONTROL_GAINED = 'PLAYER_CONTROL_GAINED',
    PLAYER_CONTROL_LOST = 'PLAYER_CONTROL_LOST',
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

HIGHLIGHT_DRAW_LAYER = 'HIGHLIGHT'
ARTWORK_DRAW_LAYER = 'ARTWORK'

---@class WidgetConstants
local _L = {}
_L.C = C
_L.E = E

---@type WidgetConstants
ABP_WidgetConstants = _L
Core:Register(M.WidgetConstants, _L)

StaticPopupDialogs[CONFIRM_RELOAD_UI] = {
    text = "Reload UI?", button1 = "Yes", button2 = "No",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function() ReloadUI() end,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

--_G[TEXTURE_DIALOG_GLOBAL_FRAME_NAME] = frame.frame
--table.insert(UISpecialFrames, TEXTURE_DIALOG_GLOBAL_FRAME_NAME)
function ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    table.insert(UISpecialFrames, frameName)
end

function ShowReloadUIConfirmation()
    StaticPopup_Show(CONFIRM_RELOAD_UI)
end

--- ### Example
---```
---local LibStub, M, A, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
---```
---@return LocalLibStub, Module, Assert, Profile, LibSharedMedia, WidgetLibFactory, CommonConstants, LibGlobals
function _L:LibPack()
    local WidgetLibFactory, Assert, Profile = G:Get(M.WidgetLibFactory, M.Assert, M.Profile)
    return LibStub, M, Assert, Profile, LibSharedMedia, WidgetLibFactory, ABP_CommonConstants, G
end

---@return string, string TEXTURE_EMPTY and TEXTURE_HIGHLIGHT
function _L:GetButtonTextures()
    return TEXTURE_EMPTY, TEXTURE_HIGHLIGHT, TEXTURE_CASTING
end

---@return AceLibFactory
function _L:LibPack_AceLibFactory() return AceLibFactory end

---@return WidgetLibFactory
function _L:LibPack_WidgetFactory() return LibStub(M.WidgetLibFactory) end

---@return ButtonUILib
function _L:LibPack_ButtonUI() return LibStub(M.ButtonUI) end

---### Example
---local SPELL, ITEM, MACRO = ABP_WidgetConstants:LibPack_SpellItemMacro()
---@return string, string, string
function _L:LibPack_SpellItemMacro() return 'spell','item','macro' end