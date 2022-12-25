--[[
    ActionbarPlus Addon
--]]

local sformat = string.format

---@type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("ActionbarPlus")

-- General
ABP_TITLE                                    = "ActionbarPlus"
ABP_CATEGORY                                 = "AddOns/" .. ABP_TITLE

-- Key binding localization text
BINDING_HEADER_ABP                           = ABP_TITLE
BINDING_HEADER_ABP_CATEGORY                  = ABP_CATEGORY

--[[-----------------------------------------------------------------------------
Localization
-------------------------------------------------------------------------------]]

ABP_GENERAL_BAR_HEADER_FORMAT                = L['ABP_BAR_HEADER_FORMAT']

-- bar max: 8, button max 50
for bar = 1,8,1
do
    local headerVar = string.format('BINDING_HEADER_ABP_HEADER_ACTIONBAR%s', bar)
    local headerVarValue = string.format(ABP_GENERAL_BAR_HEADER_FORMAT, ABP_TITLE, bar)
    _G[headerVar] = headerVarValue

    for button = 1,50,1
    do
        -- Example: _G["BINDING_NAME_CLICK ActionbarPlusF1Button1:LeftButton"]  = L["BINDING_NAME_ABP_ACTIONBAR1_BUTTON1"]
        local left = string.format('BINDING_NAME_CLICK ActionbarPlusF%sButton%s:LeftButton', bar, button)
        local right = string.format('BINDING_NAME_ABP_ACTIONBAR%s_BUTTON%s', bar, button)
        _G[left] = L[right]
    end
end

ABP_CURSE_FORGE                                                 = 'Curse Forge'
ABP_CONSOLE_COMMAND_TEXT                                        = L['ABP_CONSOLE_COMMAND_TEXT']
ABP_CONSOLE_HELP_COMMAND_TEXT                                   = L['ABP_CONSOLE_HELP_COMMAND_TEXT']
ABP_BUGS_TEXT                                                   = L['ABP_BUGS_TEXT']
ABP_VERSION_TEXT                                                = L['ABP_VERSION_TEXT']
ABP_REPO_TEXT                                                   = L['ABP_REPO_TEXT']
ABP_LAST_UPDATE_TEXT                                            = L['ABP_LAST_UPDATE_TEXT']
ABP_INTERFACE_VERSION_TEXT                                      = L['ABP_INTERFACE_VERSION_TEXT']
ABP_INITIALIZED_TEXT                                            = L['ABP_INITIALIZED_TEXT']
ABP_COMMAND_CONFIG_TEXT                                         = L['ABP_COMMAND_CONFIG_TEXT']
ABP_COMMAND_INFO_TEXT                                           = L['ABP_COMMAND_INFO_TEXT']
ABP_COMMAND_HELP_TEXT                                           = L['ABP_COMMAND_HELP_TEXT']
ABP_AVAILABLE_CONSOLE_COMMANDS_TEXT                             = L['ABP_AVAILABLE_CONSOLE_COMMANDS_TEXT']
ABP_OPTIONS_LABEL                                               = L['ABP_OPTIONS_LABEL'] .. ':'
ABP_USAGE_LABEL                                                 = L['ABP_USAGE_LABEL'] .. sformat(': /abp [%s]', L['ABP_OPTIONS_LABEL'])

ABP_SHOW                                                        = L['ABP_SHOW']
ABP_HIDE                                                        = L['ABP_HIDE']
ABP_ALT                                                         = L['ABP_ALT']
ABP_CTRL                                                        = L['ABP_CTRL']
ABP_SHIFT                                                       = L['ABP_SHIFT']

ABP_GENERAL_CONFIG_HEADER                                       = L['ABP_GENERAL_CONFIG_HEADER']
ABP_GENERAL_TOOLTIP_OPTIONS_HEADER                              = L['ABP_GENERAL_TOOLTIP_OPTIONS_HEADER']

ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME                        = L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME']
ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC                        = L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC']

ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME              = L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME']
ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC              = L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC']
ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME               = L['ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME']
ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC               = L['ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC']

ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME     = L['ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME']
ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC     = L['ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC']
ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME          = L['ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME']
ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC          = L['ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC']
ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME                  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME']
ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC                  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC']
ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_NAME  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_NAME']
ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_DESC  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_DESC']

ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_NAME      = L['ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_NAME']
ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_DESC      = L['ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_DESC']

ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_DESC                         = L['ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_DESC']
ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_LABEL                        = L['ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_LABEL']
