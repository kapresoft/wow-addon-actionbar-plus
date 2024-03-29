### 1.0.0.33
- Support for Mounts [WOTLK and Retail] [Issue #54](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/54)

### 1.0.0.32
- fix for confirmation dialog not showing on rows and col changes in settings
- fix for macro type drag and drop to ActionbarPlus action bar.

### 1.0.0.31.1
- Emergency fix for an addon loading bug that stemmed from a debug line comment in _Widget.xml

### 1.0.0.31
- Enhancement - Option to hide the mouseover glow [Issue #41](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/41)
- Bug Fix - Blur out items that do not [Issue #47](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/47)

### 1.0.0.30
- fix bug introduced in previous build [Issue #45](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/45)

### 1.0.0.29

- Range indicators for spells ~ Fix for [Issue #11](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/11)
- New option for showing tooltips ~ Fix for [Enh #30 - Hide tooltip](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/30)
- [Release Notes](https://github.com/kapresoft/wow-addon-actionbar-plus/wiki/Release-1.0.0.29-Notes)
### 1.0.0.28

- Fix for 3-state spells like Hunter/Flare, Mage/Blizzard [Issue #34 - Cooking Fire Spell Icon disappears after click](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/34)

### 1.0.0.27
- Fix for IsTypeMacro for retail
- Tooltip fix introduced in 1.0.0.26

### 1.0.0.26

- Fix a bug crash when continuously dragging and dropping action button items ~ [Issue #29 - Fatal Error](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/29)
- Fix macro item use cooldown i.e. `/use 14`; should now show the proper cooldown ~ [Issue #28 - Cooldown Count for Macros + Suggestion](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/28)

### 1.0.0.25
- KeyDown is now the trigger for pressing an action with a keybind (was previously KeyUp)
- The pickup action now utilizes the standard Pickup Action Key in the "Interface/ActionBars" settings [i.e., Shift, Alt, or Ctrl keys]. If 'None' is select, the default is 'Shift' key.
- Fix slow keybinding logic

### 1.0.0.24.1
- Version update for Wow Retail 9.2.7

### 1.0.0.24

- Keybind support for up to 50 ActionbarPlus buttons
- New Options at the Actionbar level to (1) show button index (2) show button keybind text
- See doc: https://github.com/kapresoft/wow-addon-actionbar-plus/wiki/Release-1.0.0.24-Notes

### 1.0.0.23

- Enable for Wrath of the Lich King (3.4.0)

### 1.0.0.22

- Support for conditional macros (castsequence and modifiers)
- Updating icons for macros with conditional key modifiers (shift, ctrl, alt, etc) are still not supported due to WoW API Event limitations [Issue #19](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/19). The current workaround is to also add the macros in the blizzard action bars (in addition to ActionbarPlus action bars) so that the events that update the spell icons for these conditional macros are triggered.
- See screenshots and notes on pull request [PR #22 ](https://github.com/kapresoft/wow-addon-actionbar-plus/pull/22)

### 1.0.0.21.1
- TOC file interface version upgrade for wow retail

### 1.0.0.21
- Option to lock action bars [Issue #18](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/18)
  - See doc: https://github.com/kapresoft/wow-addon-actionbar-plus/wiki/Release-1.0.0.21-Notes

### 1.0.0.20
- Enhancement work for resizing actionbar buttons [Issue #6](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/6)
- Per Character Macro rename fix for [Issue #14](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/14)

### 1.0.0.19-beta
- Bump WoW Vanilla Interface version update to 11403

### 1.0.0.17-beta
- Macro rename fix [Issue #9](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/9)

### 1.0.0.16-beta
- Process event updates on enabled buttons only [Issue #7](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/7)

### 1.0.0.15-beta
- Delay activation of actionbar on taxi events, i.e. flying.
- Hide-when-taxi: When disabled, should not hide action bars [Issue #2](https://github.com/kapresoft/wow-addon-actionbar-plus/issues/2)

### 1.0.0.14-beta

#### General
- debug-only on internal tools
- disable unused MacroIconCategories and ArtTextureID
- MacroTextureDialog debug mode only
- Delay activation of actionbar on taxi events, i.e. flying.

#### Fixed Issues
- Hide-when-taxi: When disabled, should not hide action bars
  * Issue: https://github.com/kapresoft/wow-addon-actionbar-plus/issues/2

### 1.0.0.13-beta
- Added @debug@ statements

### 1.0.0.12-beta, 1.0.0.11-beta, 1.0.0.10-beta, 1.0.0.9-beta
- version info fix
- added additional docs (Release Checklist)

### 1.0.0.8-beta
- Add CurseForge and Github Issues URL information to addon initial load message

### 1.0.0.7-beta to 1.0.0.6-beta
- Optional dependences to Ace3, LibStub and others so these libs are not included in the install

### 1.0.0.5-beta
- Removed `no-lib-strip` causing the libraries not to be declared after
install and shows an error of 'PrettyPrint' not being available in WoW.

### 1.0.0.2-beta to 1.0.0.4-beta
- Add dependencies to pkgmetada

### 1.0.3-alpha
- Vanilla interface version update
- pkgmeta changes (changelog and license)

### 1.0.2-alpha
- Initial Release
