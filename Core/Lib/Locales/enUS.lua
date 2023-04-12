-- SEE: https://github.com/BigWigsMods/packager/wiki/Localization-Substitution
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local LocUtil = ns.O.LocalizationUtil

---@type AceLocale
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "enUS", true);
if not L then return end

--[[-----------------------------------------------------------------------------
Localization Keys That need to be defined for Bindings.xml
-------------------------------------------------------------------------------]]
local actionBarText = 'Action Bar'
local buttonBarText = 'Button'

L['ABP_ACTIONBAR_BASE_NAME']                             = actionBarText
L['ABP_BUTTON_BASE_NAME']                                = buttonBarText

LocUtil:SetupKeybindNames(L, actionBarText, buttonBarText)

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local GCC = ABP_GlobalConstants.C

--[[-----------------------------------------------------------------------------
No Translations
-------------------------------------------------------------------------------]]
L['Version']                                    = true
L['Curse-Forge']                                = true
L['Bugs']                                       = true
L['Repo']                                       = true
L['Last-Update']                                = true
L['Interface-Version']                          = true
L['Locale']                                     = true
L['Use-KeyDown(cvar ActionButtonUseKeyDown)']   = true

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['Addon Info']                                          = 'Addon Info'
L['Addon Initialized Text Format']                       = '%s Initialized.  Type %s on the console for available commands.'
L['ALT']                                                 = true
L['Available console commands']                          = true
L['CTRL']                                                = true
L['Enable']                                              = true
L['General']                                             = true
L['Hide']                                                = true
L['Info Console Command Text']                           = 'Prints additional info about the addon on this console'
L['Options Dialog']                                      = true
L['options']                                             = true
L['Settings']                                            = true
L['SHIFT']                                               = true
L['Show']                                                = true
L['Shows the config UI (default)']                       = true
L['Shows this help']                                     = true
L['usage']                                               = true
L['No']                                                  = true
L['Always']                                              = true
L['In-Combat']                                           = true
L['Right-click to open config UI']                       = true
L['General']                                             = true
L['General Configuration']                               = true
L['Tooltip Options']                                     = true
L['Tooltip Anchor']                                      = true
L['Tooltip Anchor Description']                          = 'Select how and where the game tooltip should be displayed when hovering over an action button'
L['Debugging']                                           = true
L['Debugging Description']                               = 'Debug Settings for troubleshooting'
L['Debugging Configuration']                             = true
L['Log Level']                                           = true
L['Log Level Description']                               = 'Higher log levels generate more logs'

--[[-----------------------------------------------------------------------------
TODO: Need to refactor (Below)
-------------------------------------------------------------------------------]]
L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_NAME']            = 'Lock Actionbars with SHIFT key'
L['ABP_GENERAL_CONFIG_LOCK_ACTION_BARS_DESC']            = 'Prevents user from picking up or dragging spells, items, or macros from the ActionbarPlus bars.'
L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_NAME']  = 'Hide during taxi'
L['ABP_GENERAL_CONFIG_HIDE_WHEN_TAXI_ACTION_BARS_DESC']  = 'Hides the action bars while the player is in taxi; flying from one point to another.'
L['ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_NAME']   = 'Mouseover Glow'
L['ABP_GENERAL_CONFIG_ENABLE_ACTION_BUTTON_GLOW_DESC']   = 'Enables action button mouseover glow'
L['ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_NAME']         = 'Hide text for smaller buttons'
L['ABP_GENERAL_CONFIG_HIDE_TEXTS_FOR_SMALLER_BUTTONS_DESC']         = 'When checked, this option hides item count, keybind and index text when buttons are smaller than 35 in size'
L['ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_NAME']    = 'Hide countdown numbers on cooldowns'
L['ABP_GENERAL_CONFIG_HIDE_COUNTDOWN_NUMBERS_ON_COOLDOWNS_DESC']    = 'When checked, this option hides countdown numbers from a spell, item, macro, etc'

L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_NAME']                 = 'Tooltip Visibility'
L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_KEY_DESC']                 = 'Choose when you want the tooltip to show when not in combat. If a modifier is chosen, then you need to hold that modifier down to show the tooltip.'
L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_NAME'] = 'Combat Override Key'
L['ABP_GENERAL_CONFIG_TOOLTIP_VISIBILITY_COMBAT_OVERRIDE_KEY_DESC'] = 'Choose when you want the tooltip to show during combat. If a modifier is chosen, then you need to hold that modifier down to show the tooltip.'
L['ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_NAME']     = 'Character Specific Frame Positions'
L['ABP_GENERAL_CONFIG_CHARACTER_SPECIFIC_FRAME_POSITIONS_DESC']     = 'By default, all frame positions (or anchors) are global across characters. If checked, the frame positions are saved at the character level.'

L['ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_LABEL']                       = 'Reset Anchor'
L['ABP_BAR_CONFIG_RESET_ANCHOR_BUTTON_DESC']                        = 'Resets the anchor (position) of the action bar group to the center of the screen.  This can be useful when the actionbar drag frame goes off screen.'

--L['ABP_BAR_CONFIG_'] = ''
L['ABP_BAR_CONFIG_SHOW_EMPTY_BUTTONS_NAME']                         = 'Show empty buttons'
L['ABP_BAR_CONFIG_SHOW_EMPTY_BUTTONS_DESC']                         = 'Check this option to always show the buttons on the action bar, even when they are empty.'
L['ABP_BAR_CONFIG_SHOW_BUTTON_NUMBERS_NAME']                        = 'Show Button Numbers'
L['ABP_BAR_CONFIG_SHOW_BUTTON_NUMBERS_DESC']                        = 'Show each button index on'
L['ABP_BAR_CONFIG_SHOW_KEYBIND_TEXT_NAME']                          = 'Show Keybind Text'
L['ABP_BAR_CONFIG_SHOW_KEYBIND_TEXT_DESC']                          = 'Show each button keybind text on'

L['ABP_BAR_CONFIG_ALPHA_NAME']                                      = 'Alpha'
L['ABP_BAR_CONFIG_ALPHA_DESC']                                      = 'Set the opacity of the actionbar'
L['ABP_BAR_CONFIG_SIZE_NAME']                                       = 'Size (Width & Height)'
L['ABP_BAR_CONFIG_SIZE_DESC']                                       = 'The width and height of a buttons'
L['ABP_BAR_CONFIG_ROWS_NAME']                                       = 'Rows'
L['ABP_BAR_CONFIG_ROWS_DESC']                                       = 'The number of rows for the buttons'
L['ABP_BAR_CONFIG_COLS_NAME']                                       = 'Columns'
L['ABP_BAR_CONFIG_COLS_DESC']                                       = 'The number of columns for the buttons'

L['ABP_BAR_CONFIG_LOCK_NAME']                                       = 'Lock Actionbar?'
L['ABP_BAR_CONFIG_LOCK_DESC']                                       = 'Lock'
L['ABP_BAR_CONFIG_LOCK_NAME']                                       = 'Lock Actionbar?'
L['ABP_BAR_CONFIG_MOUSEOVER_NAME']                                  = 'Mouseover'
L['ABP_BAR_CONFIG_MOUSEOVER_DESC']                                  = 'Hide the frame mover at the top of the actionbar by default.  Mouseover to make it visible for moving the frame.'
L['ABP_BAR_CONFIG_FRAME_HANDLE_SETTINGS_HEADER']                    = 'Frame Handle Settings'
L['ABP_BAR_CONFIG_FRAME_HANDLE_OPACITY_NAME']                       = 'Alpha'
L['ABP_BAR_CONFIG_FRAME_HANDLE_OPACITY_DESC']                       = 'Set the opacity of the frame handle.'
