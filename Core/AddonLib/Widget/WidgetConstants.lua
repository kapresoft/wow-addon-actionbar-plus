--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core = __K_Core:LibPack_GlobalObjects()
local G = O.LibGlobals
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@type AceLibFactory
local LibSharedMedia, LogFactory = O.AceLibFactory:GetAceSharedMedia(), O.LogFactory
local p = LogFactory(Core.M.WidgetConstants)

-- #########################################################

---Only put Widget Constants here
---@class WidgetConstantsConstants : GlobalConstants
local C = {
    mt = { __index = G.C },
    TEXTURE_EMPTY = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background"),
    TEXTURE_HIGHLIGHT = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Dialog Background Gold"),
    TEXTURE_HIGHLIGHT2 = [[Interface\Buttons\WHITE8X8]],
    TEXTURE_HIGHLIGHT3 = [[Interface\Buttons\ButtonHilight-Square]],
    TEXTURE_HIGHLIGHT4 = [[Interface\QuestFrame\UI-QuestTitleHighlight]],
    TEXTURE_CASTING = LibSharedMedia:Fetch(LibSharedMedia.MediaType.BACKGROUND, "Blizzard Rock"),
}
setmetatable(C, C.mt)

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

---@class WidgetConstants
local _L = {}
_L.C = C
_L.E = E

Core:Register(Core.M.WidgetConstants, _L)
