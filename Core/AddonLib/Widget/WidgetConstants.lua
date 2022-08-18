local ReloadUI = ReloadUI

local LibStub, M, G = ABP_LibGlobals:LibPack()

---@type AceLibFactory
local CC = ABP_CommonConstants
local AceLibFactory = LibStub('AceLibFactory')
local LibSharedMedia = AceLibFactory:GetAceSharedMedia()
local LogFactory = LibStub(M.LogFactory)
local l = LogFactory('WidgetConstants')

-- #########################################################

ADDON_NAME = 'ActionbarPlus'
SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate'
TOPLEFT = 'TOPLEFT'
BOTTOMLEFT = 'BOTTOMLEFT'
ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT'
CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI'
TEXTURE_EMPTY = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background")
TEXTURE_HIGHLIGHT = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background Gold")
TEXTURE_HIGHLIGHT2 = [[Interface\Buttons\WHITE8X8]]
TEXTURE_HIGHLIGHT3 = [[Interface\Buttons\ButtonHilight-Square]]
TEXTURE_HIGHLIGHT4 = [[Interface\QuestFrame\UI-QuestTitleHighlight]]
TEXTURE_CASTING = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Rock")
ACTIONBAR_UPDATE_COOLDOWN = 'ACTIONBAR_UPDATE_COOLDOWN'
ACTIONBAR_UPDATE_USABLE = 'ACTIONBAR_UPDATE_USABLE'
ACTIONBAR_UPDATE_STATE = 'ACTIONBAR_UPDATE_STATE'
BAG_UPDATE_DELAYED = 'BAG_UPDATE_DELAYED'
UNIT_SPELLCAST_START = 'UNIT_SPELLCAST_START'
UNIT_SPELLCAST_STOP = 'UNIT_SPELLCAST_STOP'
UNIT_SPELLCAST_SUCCEEDED = 'UNIT_SPELLCAST_SUCCEEDED'
UPDATE_BINDINGS = 'UPDATE_BINDINGS'
PLAYER_CONTROL_LOST = 'PLAYER_CONTROL_LOST'
PLAYER_CONTROL_GAINED = 'PLAYER_CONTROL_GAINED'

local C = {

    PLAYER_REGEN_ENABLED = 'PLAYER_REGEN_ENABLED',
    PLAYER_REGEN_DISABLED = 'PLAYER_REGEN_DISABLED'

}

HIGHLIGHT_DRAW_LAYER = 'HIGHLIGHT'
ARTWORK_DRAW_LAYER = 'ARTWORK'

---@class WidgetConstants
local _L = {}
_L.C = C
---@type WidgetConstants
ABP_WidgetConstants = _L


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

---@return WidgetLibFactory
function _L:LibPack_WidgetFactory() return LibStub(M.WidgetLibFactory) end

---@return ButtonUILib
function _L:LibPack_ButtonUI() return LibStub(M.ButtonUI) end
