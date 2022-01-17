local ACE_LIB = AceLibFactory
local ReloadUI = ReloadUI
local SHARED_MEDIA = ACE_LIB:GetAceSharedMedia()
local BATTR = ButtonAttributes
local LOG = ABP_LogFactory
local l = LOG('WidgetConstants')

-- #########################################################

ADDON_NAME = 'ActionbarPlus'
SECURE_ACTION_BUTTON_TEMPLATE = 'SecureActionButtonTemplate'
TOPLEFT = 'TOPLEFT'
BOTTOMLEFT = 'BOTTOMLEFT'
ANCHOR_TOPLEFT = 'ANCHOR_TOPLEFT'
CONFIRM_RELOAD_UI = 'CONFIRM_RELOAD_UI'
TEXTURE_EMPTY = SHARED_MEDIA:Fetch(SHARED_MEDIA.MediaType.BACKGROUND, "Blizzard Dialog Background")
TEXTURE_HIGHLIGHT = SHARED_MEDIA:Fetch(SHARED_MEDIA.MediaType.BACKGROUND, "Blizzard Dialog Background Gold")

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

function ResetWidgetAttributes(btnUI)
    for _,v in pairs(BATTR) do
        l:log(50, 'Resetting Attribute: %s', v)
        btnUI:SetAttribute(v, nil)
    end
end