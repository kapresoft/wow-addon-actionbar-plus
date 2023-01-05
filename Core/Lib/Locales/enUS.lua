--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format
local addon = ...

---@class Localization
local L = LibStub("AceLocale-3.0"):NewLocale(addon, "enUS", true);
if not L then return end

--[[-----------------------------------------------------------------------------
Keybinding Localization
-------------------------------------------------------------------------------]]
ABP_BUTTON_NAME_TEXT_FORMAT_DEFAULT         = 'Action Bar #%s Button %s'

for bar = 1,8,1
do
    for button = 1,50,1
    do
        -- Example: L["BINDING_NAME_ABP_ACTIONBAR1_BUTTON1"]  = 'Bar #1 Action Button 1'
        local left = sformat('BINDING_NAME_ABP_ACTIONBAR%s_BUTTON%s', bar, button)
        local right = sformat(ABP_BUTTON_NAME_TEXT_FORMAT_DEFAULT, bar, button)
        L[left] = right
    end
end

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local GCC = ABP_GlobalConstants.C

--[[-----------------------------------------------------------------------------
Defaults
-------------------------------------------------------------------------------]]
ABP_BAR_HEADER_FORMAT_DEFAULT               = '%s Bar #%s'

L['ABP_INITIALIZED_TEXT']                                = sformat('Initialized.  Type %s on the console for available commands.', GCC.ABP_COMMAND)
L['ABP_CONSOLE_HELP_COMMAND_TEXT']                       = sformat('Type %s on the console to see additional commands', GCC.ABP_HELP_COMMAND)
L['ABP_CONSOLE_COMMAND_TEXT']                            = sformat('Type %s on the console to open config dialog or right-click on drag frame located at the top of the actionbar.', GCC.ABP_COMMAND)
L['ABP_VERSION_TEXT']                                    = 'Version'
L['ABP_BUGS_TEXT']                                       = 'Bugs'
L['ABP_REPO_TEXT']                                       = 'Repo'
L['ABP_LAST_UPDATE_TEXT']                                = 'Last Update'
L['ABP_INTERFACE_VERSION_TEXT']                          = 'Interface Version'
L['ABP_COMMAND_CONFIG_TEXT']                             = 'Shows the config UI (default)'
L['ABP_COMMAND_INFO_TEXT']                               = 'Prints additional information about the addon on this console'
L['ABP_COMMAND_HELP_TEXT']                               = 'Shows this help'
L['ABP_AVAILABLE_CONSOLE_COMMANDS_TEXT']                 = 'Available console commands'
L['ABP_USAGE_LABEL']                                     = 'usage'
L['ABP_OPTIONS_LABEL']                                   = 'options'

L['ABP_SHOW']                                            = 'Show'
L['ABP_HIDE']                                            = 'Hide'
L['ABP_ALT']                                             = 'ALT'
L['ABP_CTRL']                                            = 'CTRL'
L['ABP_SHIFT']                                           = 'SHIFT'

L['ABP_BAR_CONFIG_COMMON_TEXT_NO'] = 'No'
L['ABP_BAR_CONFIG_COMMON_TEXT_ALWAYS'] = 'Always'
L['ABP_BAR_CONFIG_COMMON_TEXT_IN_COMBAT'] = 'In-Combat'

L['ABP_BUTTON_NAME_TEXT_FORMAT']                         = ABP_BUTTON_NAME_TEXT_FORMAT_DEFAULT
L['ABP_BAR_HEADER_FORMAT']                               = ABP_BAR_HEADER_FORMAT_DEFAULT
L['ABP_GENERAL_CONFIG_HEADER']                           = 'General Configuration'
L['ABP_GENERAL_TOOLTIP_OPTIONS_HEADER']                  = 'Tooltip Options'
L['ABP_GENERAL_CONFIG_NAME']                              = 'General'
L['ABP_GENERAL_CONFIG_DESC']                              = 'General Configuration'
L['ABP_GENERAL_CONFIG_TOOLTIP_NAME']                      = 'Tooltip Anchor'
L['ABP_GENERAL_CONFIG_TOOLTIP_DESC']                      = 'Select how and where the game tooltip should be displayed when hovering over an action button'
L['ABP_DEBUGGING_NAME']                                   = 'Debugging'
L['ABP_DEBUGGING_DESC']                                   = 'Debug Settings for troubleshooting'
L['ABP_DEBUGGING_CONFIGURATION_HEADER']                   = 'Debugging Configuration'
L['ABP_DEBUGGING_LOG_LEVEL_NAME']                         = 'Log Level'
L['ABP_DEBUGGING_LOG_LEVEL_DESC']                         = 'Higher log levels generate more logs'

L['ABP_ACTIONBAR_BASE_NAME']                             = 'Action Bar'
L['ABP_SETTINGS_BASE_NAME']                              = 'Settings'
L['ABP_ENABLE_BASE_NAME']                                = 'Enable'

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
