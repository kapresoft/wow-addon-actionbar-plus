local ReloadUI = ReloadUI

local LibStub, M, G = ABP_LibGlobals:LibPack()
---@type AceLibFactory
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
TEXTURE_CASTING = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Rock")

---@class WidgetConstants
local _L = {}
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

--local function logger()
--    if _logger == nil then
--        _logger = LogFactory('WidgetConstants')
--    end
--    return _logger
--end

--- TODO: Move to LibGlobals
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

---@return ButtonUI
function _L:LibPack_ButtonUI() return LibStub(M.ButtonUI) end
