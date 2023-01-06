--[[
    ActionbarPlus Addon
--]]

local sformat = string.format

local ns = ABP_Namespace(...)
local LocUtil = ns.O.LocalizationUtil

---@type AceLocale
local L = LibStub("AceLocale-3.0"):GetLocale(ns.name)
if not L then return end

-- General
ABP_TITLE                                    = "ActionbarPlus"
ABP_CATEGORY                                 = "AddOns/" .. ABP_TITLE

-- Key binding localization text
BINDING_HEADER_ABP                           = ABP_TITLE
BINDING_HEADER_ABP_CATEGORY                  = ABP_CATEGORY

--[[-----------------------------------------------------------------------------
Localization
-------------------------------------------------------------------------------]]

ABP_ACTIONBAR_BASE_NAME                      = L['ABP_ACTIONBAR_BASE_NAME']
ABP_BUTTON_BASE_NAME                         = L['ABP_BUTTON_BASE_NAME']

LocUtil:MapBindingsXMLNames(L, ABP_ACTIONBAR_BASE_NAME, ABP_TITLE)

ABP_SETTINGS_BASE_NAME                                          = L['ABP_SETTINGS_BASE_NAME']
ABP_ENABLE_BASE_NAME                                            = L['ABP_ENABLE_BASE_NAME']

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
ABP_BAR_CONFIG_COMMON_TEXT_NO                                   = L['ABP_BAR_CONFIG_COMMON_TEXT_NO']
ABP_BAR_CONFIG_COMMON_TEXT_ALWAYS                               = L['ABP_BAR_CONFIG_COMMON_TEXT_ALWAYS']
ABP_BAR_CONFIG_COMMON_TEXT_IN_COMBAT                            = L['ABP_BAR_CONFIG_COMMON_TEXT_IN_COMBAT']

ABP_TOOLTIP_RIGHT_CLICK_TO_OPEN_CONFIG_TEXT                     = L['ABP_TOOLTIP_RIGHT_CLICK_TO_OPEN_CONFIG_TEXT']

ABP_GENERAL_CONFIG_HEADER                                       = L['ABP_GENERAL_CONFIG_HEADER']
ABP_GENERAL_TOOLTIP_OPTIONS_HEADER                              = L['ABP_GENERAL_TOOLTIP_OPTIONS_HEADER']

ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME                        = L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME']
ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC                        = L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC']

ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME              = L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME']
ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC              = L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC']
ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME               = L['ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME']
ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC               = L['ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC']

ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME                  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME']
ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC                  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC']
ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_NAME  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_NAME']
ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_DESC  = L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_DESC']
ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME     = L['ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME']
ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC     = L['ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC']
ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME          = L['ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME']
ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC          = L['ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC']
ABP_GENERAL_CONFIG_NAME                                         = L['ABP_GENERAL_CONFIG_NAME']
ABP_GENERAL_CONFIG_DESC                                         = L['ABP_GENERAL_CONFIG_DESC']
ABP_GENERAL_CONFIG_TOOLTIP_NAME                                 = L['ABP_GENERAL_CONFIG_TOOLTIP_NAME']
ABP_GENERAL_CONFIG_TOOLTIP_DESC                                 = L['ABP_GENERAL_CONFIG_TOOLTIP_DESC']
ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_NAME      = L['ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_NAME']
ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_DESC      = L['ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_DESC']

ABP_DEBUGGING_NAME                                              = L['ABP_DEBUGGING_NAME']
ABP_DEBUGGING_DESC                                              = L['ABP_DEBUGGING_DESC']
ABP_DEBUGGING_CONFIGURATION_HEADER                              = L['ABP_DEBUGGING_CONFIGURATION_HEADER']
ABP_DEBUGGING_LOG_LEVEL_NAME                                    = L['ABP_DEBUGGING_LOG_LEVEL_NAME']
ABP_DEBUGGING_LOG_LEVEL_DESC                                    = L['ABP_DEBUGGING_LOG_LEVEL_DESC']

ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_DESC                         = L['ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_DESC']
ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_LABEL                        = L['ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_LABEL']

ABP_BAR_CONFIG_SHOW_EMPTY_BUTTONS_NAME                          = L['ABP_BAR_CONFIG_SHOW_EMPTY_BUTTONS_NAME']
ABP_BAR_CONFIG_SHOW_EMPTY_BUTTONS_DESC                          = L['ABP_BAR_CONFIG_SHOW_EMPTY_BUTTONS_DESC']
ABP_BAR_CONFIG_SHOW_BUTTON_NUMBERS_NAME                         = L['ABP_BAR_CONFIG_SHOW_BUTTON_NUMBERS_NAME']
ABP_BAR_CONFIG_SHOW_BUTTON_NUMBERS_DESC                         = L['ABP_BAR_CONFIG_SHOW_BUTTON_NUMBERS_DESC']
ABP_BAR_CONFIG_SHOW_KEYBIND_TEXT_NAME                           = L['ABP_BAR_CONFIG_SHOW_KEYBIND_TEXT_NAME']
ABP_BAR_CONFIG_SHOW_KEYBIND_TEXT_DESC                           = L['ABP_BAR_CONFIG_SHOW_KEYBIND_TEXT_DESC']
ABP_BAR_CONFIG_ALPHA_NAME                                       = L['ABP_BAR_CONFIG_ALPHA_NAME']
ABP_BAR_CONFIG_ALPHA_DESC                                       = L['ABP_BAR_CONFIG_ALPHA_DESC']
ABP_BAR_CONFIG_SIZE_NAME                                        = L['ABP_BAR_CONFIG_SIZE_NAME']
ABP_BAR_CONFIG_SIZE_DESC                                        = L['ABP_BAR_CONFIG_SIZE_DESC']
ABP_BAR_CONFIG_ROWS_NAME                                        = L['ABP_BAR_CONFIG_ROWS_NAME']
ABP_BAR_CONFIG_ROWS_DESC                                        = L['ABP_BAR_CONFIG_ROWS_DESC']
ABP_BAR_CONFIG_COLS_NAME                                        = L['ABP_BAR_CONFIG_COLS_NAME']
ABP_BAR_CONFIG_COLS_DESC                                        = L['ABP_BAR_CONFIG_COLS_DESC']
ABP_BAR_CONFIG_LOCK_NAME                                        = L['ABP_BAR_CONFIG_LOCK_NAME']
ABP_BAR_CONFIG_LOCK_DESC                                        = L['ABP_BAR_CONFIG_LOCK_DESC']
ABP_BAR_CONFIG_MOUSEOVER_NAME                                   = L['ABP_BAR_CONFIG_MOUSEOVER_NAME']
ABP_BAR_CONFIG_MOUSEOVER_DESC                                   = L['ABP_BAR_CONFIG_MOUSEOVER_DESC']
ABP_BAR_CONFIG_FRAME_HANDLE_SETTINGS_HEADER                     = L['ABP_BAR_CONFIG_FRAME_HANDLE_SETTINGS_HEADER']
ABP_BAR_CONFIG_FRAME_HANDLE_OPACITY_NAME                        = L['ABP_BAR_CONFIG_FRAME_HANDLE_OPACITY_NAME']
ABP_BAR_CONFIG_FRAME_HANDLE_OPACITY_DESC                        = L['ABP_BAR_CONFIG_FRAME_HANDLE_OPACITY_DESC']
