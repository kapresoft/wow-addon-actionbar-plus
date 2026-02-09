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
L['%s version %s by %s is loaded.'] = true
L['Type %s or %s for available commands.'] = true

LocUtil:SetupKeybindNames(L, actionBarText, buttonBarText)

--[[-----------------------------------------------------------------------------
No Translations
-------------------------------------------------------------------------------]]
L['Version']                                  = true
L['Curse-Forge']                              = true
L['Bugs']                                     = true
L['Repo']                                     = true
L['Last-Update']                              = true
L['Interface-Version']                        = true
L['Game-Version']                             = true
L['Locale']                                   = true
L['Use-KeyDown(cvar ActionButtonUseKeyDown)'] = true
L['Features']                                 = true

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['Addon Info']                                     = 'Addon Info'
L['Addon Initialized Text Format']                  = '%s Initialized.  Type %s on the console for available commands.'
L['ALT']                                            = true
L['Available console commands']                     = true
L['CTRL']                                           = true
L['Enable']                                         = true
L['General']                                        = true
L['Hide']                                           = true
L['Info Console Command Text']                      = 'Prints additional info about the addon on this console'
L['Options Dialog']                                 = true
L['options']                                        = true
L['Settings']                                       = true
L['SHIFT']                                          = true
L['Show']                                           = true
L['Shows the config UI (default)']                  = true
L['Toggles visibility']                             = 'Toggles the visibility of all ActionbarPlus action bars. Use this to quickly hide or show the bars without opening the UI or options panel.'
L['Shows this help']                                = true
L['usage']                                          = true
L['No']                                             = true
L['Always']                                         = true
L['In-Combat']                                      = true
L['Click and drag to move the action bar']          = true
L['Right-click to open the settings dialog']        = true
L['General']                                        = true
L['General Configuration']                          = true
L['Toggle Action Bars']                             = true
L['Tooltip Options']                                = true
L['Tooltip Anchor']                                 = true
L['Tooltip Anchor::Description']                    = 'Select how and where the game tooltip should be displayed when hovering over an action button'
L['Debugging']                                      = true
L['Debugging::Description']                         = 'Debug Settings for troubleshooting'
L['Debugging Configuration']                        = true
L['Debugging::Category::Enable All::Button']        = 'Enable All'
L['Debugging::Category::Enable All::Button::Desc']  = 'Enables all log categories below.'
L['Debugging::Category::Disable All::Button']       = 'Disable All'
L['Debugging::Category::Disable All::Button::Desc'] = 'Disables all log categories below. Note that the default category (not shown here) will always be active.'
L['Log Level']                                      = true
L['Log Level::Description']                         = 'Higher log levels generate more logs:\nLog Levels: ERROR(5), WARN(10), INFO(15), DEBUG(20), FINE(25), FINER(30), FINEST(35), TRACE(50)'
L['Categories']                                     = true

-- new

L['Hide during taxi']                                    = true
L['Hide during taxi::Description']                       = 'Hides the action bars while the player is in taxi; flying from one point to another.'
L['Mouseover Glow']                                      = true
L['Mouseover Glow::Description']                         = 'Enables action button mouseover glow'
L['Hide text for smaller buttons']                       = true
L['Hide text for smaller buttons::Description']          = 'When checked, this option hides item count, keybind and index text when buttons are smaller than 35 in size'
L['Hide countdown numbers on cooldowns']                 = true
L['Hide countdown numbers on cooldowns::Description']    = 'When checked, this option hides countdown numbers from a spell, item, macro, etc'
L['Tooltip Visibility']                                  = true
L['Tooltip Visibility::Description']                     = 'Choose when you want the tooltip to show when not in combat. If a modifier is chosen, then you need to hold that modifier down to show the tooltip.'
L['Combat Override Key']                                 = true
L['Combat Override Key::Description']                    = 'Choose when you want the tooltip to show during combat. If a modifier is chosen, then you need to hold that modifier down to show the tooltip.'
L['Character Specific Frame Positions']                  = true
L['Character Specific Frame Positions::Description']     = 'By default, all frame positions (or anchors) are global across characters. If checked, the frame positions are saved at the character level.'
L['Reset Anchor']                                        = true
L['Reset Anchor::Description']                           = 'Resets the anchor (position) of the action bar group to the center of the screen.  This can be useful when the actionbar drag frame goes off screen.'
L['Show empty buttons']                                  = true
L['Show empty buttons::Description']                     = 'Check this option to always show the buttons on the action bar, even when they are empty.'
L['Show Button Numbers']                                 = true
L['Show Button Numbers::Description']                    = 'Show each button index on %s'
L['Show Keybind Text']                                   = true
L['Show Keybind Text::Description']                      = 'Show each button keybind text on %s'
L['Alpha']                                               = true
L['Alpha::Description']                                  = 'Set the opacity of the actionbar'
L['Size (Width & Height)']                               = true
L['Size (Width & Height)::Description']                  = 'The width and height of a buttons'
L['Rows']                                                = true
L['Rows::Description']                                   = 'The number of rows for the buttons'
L['Columns']                                             = true
L['Columns::Description']                                = 'The number of columns for the buttons'

L['Lock Actionbar']                                      = true
L['Lock Actionbar::Description']                         = [[

Options:
  Always: lock the frame at all times.
  In-Combat: lock the frame during combat.

Note: this option only prevents the frame from being moved and does not lock individual
action items.]]

L['Mouseover']                                           = true
L['Mouseover::Description']                              = 'Hide the frame mover at the top of the actionbar by default.  Mouseover to make it visible for moving the frame.'

L['Frame Handle Settings']                               = true
L['Alpha']                                               = true
L['Alpha::Description']                                  = 'Set the opacity of the frame handle.'

--[[-----------------------------------------------------------------------------
Needs Translations
-------------------------------------------------------------------------------]]
L['Requires ActionbarPlus-M6::Message']    = "This feature requires ActionbarPlus-M6."
L['ActionbarPlus-M6 URL']                  = "See https://www.curseforge.com/wow/addons/actionbarplus-m6"
L['Talents Switch Success Message Format'] = '[%s] spec action bars activated.'

L['Primary']             = true
L['Secondary']           = true
L['Equipment set is %s'] = true
L['Equipped']            = true
L['Talent Points']       = true

L['Equipment Set Options'] = true
L['Open Character Frame'] = true
L['Open Character Frame::Description'] = "Automatically opens the Character Frame when an equipment set button is clicked, allowing quick access to your equipped gear."
L['Open Equipment Manager'] = true
L['Open Equipment Manager::Description'] = "Also opens the Equipment Manager when an equipment set button is clicked, making it easy to manage your gear while viewing your character. This option only applies if 'Open Character Frame' is enabled."
L['Glow After Equip'] = true
L['Glow After Equip::Description'] = 'Makes the button glow when a set is equipped, providing clear visual feedback that the equipment set was successfully applied.'
