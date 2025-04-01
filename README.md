|  |  |
|--------|----------|
|[![Branch Build](https://github.com/kapresoft/wow-addon-actionbar-plus/actions/workflows/dev-build.yml/badge.svg)](https://github.com/kapresoft/wow-addon-actionbar-plus/actions/workflows/dev-build.yml)| [![Release Build](https://github.com/kapresoft/wow-addon-actionbar-plus/actions/workflows/release-build.yml/badge.svg)](https://github.com/kapresoft/wow-addon-actionbar-plus/actions/workflows/release-build.yml)|

# ActionbarPlus
> A [World of Warcraft](https://worldofwarcraft.com/) AddOn

![download-count](https://cf.way2muchnoise.eu/full_566626_downloads.svg?badge_style=for_the_badge) ![supported-wow-versions](https://cf.way2muchnoise.eu/versions/World%20of%20Warcraft%20Versions_566626_all.svg?badge_style=for_the_badge)

[//]: # (https://cf.way2muchnoise.eu/)
[//]: # (See more on badges at: https://support.curseforge.com/en/support/solutions/articles/9000206928-curseforge-badges)

[Releases](../../releases) | [Milestones](../../milestones) | [Known Issues](../../issues) | [Curse Forge](https://legacy.curseforge.com/wow/addons/actionbarplus/files)

## Actionbars Everywhere, Make you click happy

>Available for all of World of Warcraft Versions

## Description

ActionbarPlus is a versatile floating action bar add-on that enables you to create and customize up to 10 supplementary action bars. With the flexibility to place them anywhere within the game, these floating action bars can enhance your gaming experience by providing additional functionality and convenience. Whether you need quick access to frequently used spells, items, or macros, or simply want to streamline your UI, ActionbarPlus offers a powerful solution that can help you achieve your goals.

### Features

- Action buttons triggers on KeyDown (not KeyUp)
- Action bars can be dynamically positioned anywhere on the screen, offering unparalleled flexibility and customization to fit your unique gameplay style and UI preferences.
- Customizable button size and number of buttons (rows and columns) with a maximum of 800 buttons arranged in a grid of 20 x 40
- The ability to bind keys to action buttons using the World of Warcraft Keybinding options is supported.
- [WowAce](https://www.wowace.com/projects/ace3) profile support includes the ability to switch between profiles, copy a profile, and reset a profile.
- `ABP:SmarMount(..)` A dynamic function that can be utilized in macros for dynamic mounting based on the current area. (More details below)

#### Additional Configuration Options

- **Toggle Button Mouseover Glow Feature:** Activate a visual glow effect on action buttons upon mouseover, making it easier to identify active buttons during gameplay.
- **Tooltip Visibility, Anchor, and Combat Override Key Options:** Gain full control over tooltips with customizable visibility, anchoring positions, and the ability to set keys for overriding tooltip behavior in combat, providing crucial information exactly when and where you need it.
- **Equipment Set**: Supports integrating equipment sets directly into the action bars. Clicking an action button linked to an equipment set will not only activate that set but also visually indicate its active status. Any updates to your gear, like swapping a piece of equipment, automatically refresh the button's active state to accurately reflect your current equipment set. Furthermore, the tooltip for each action button is enhanced to show whether the represented equipment set is fully equipped, offering instant insight into your gear status.
- **Actionbar Frame Specific Options:** Fine-tune individual actionbar frames with specific options, including but not limited to positioning, scaling, and more, for ultimate control over your interface layout.
- **Profile Management:** Enhanced profile management features allow for more efficient setup and switching between different UI configurations, saving you time and effort in customizing your experience.

#### ABP:SmartMount(...) Dynamic Function

Enhance your World of Warcraft experience with our addon's latest feature. A dynamic function that intelligently selects between your specified flying and ground mounts based on the current area's flyability, ensuring seamless mount selection even in special zones like the city of Dalaran (WOTLK). 

Easily integrate it into your gameplay through macros for an optimized and hassle-free mounting experience.

Syntax: 
```
ABP:SmartMount('<flying-mount-name>', '<ground-mount-name>')
```

Example Macro: 
```
/run ABP:SmartMount('Swift Yellow Wind Rider','Black War Raptor')
```

## Docs
- [Wiki](../../wiki)
- [Getting Started](../../wiki/Getting-Started)

### Author Notes

- Please submit bugs and feature requests at [Github/ActionbarPlus/issues](../../issues)
- [Milestones](../../milestones)
- [Releases](../../releases)
- [About the Author (Tony Lagnada)](https://tony.resume.lagnada.com/)

## AddOn Distribution

**Curse Forge**
- https://www.curseforge.com/wow/addons/actionbarplus

**WoW Interface**
- https://www.wowinterface.com/downloads/info26522-ActionbarPlus.html

## Donations

As a software engineer, I am passionate about this project and have dedicated a significant amount of time and effort to creating a high-quality product. If you enjoy using this World of Warcraft add-on, please consider supporting me through a donation via [Paypal&trade;](https://www.paypal.com/donate/?hosted_button_id=AX58YP3GSGXVU) or the Bitcoin Address provided below. Your support is greatly appreciated. Thank you in advance for your generosity.

- **[Paypal&trade; Donation](https://www.paypal.com/donate/?hosted_button_id=AX58YP3GSGXVU)**
- **[Bitcoin Donation](https://www.blockchain.com/btc/address/3QQVAwJGkKHMM2oq6CLVWYgfx83TFVwp39)**

## Miscellaneous

- [For Developers](doc/DEV.md)
- [Contributing](doc/CONTRIBUTING.md)
- [Release Checklist](doc/RELEASE-CHECKLIST.md)

## Temporary
- we are going to commit this file and watch the build trigger!

## Try My Other AddOns
- [Saved Dungeons &amp; Raids](https://www.curseforge.com/wow/addons/saved-dungeons-raids)
- [MacrobarPlus](https://www.curseforge.com/wow/addons/macrobarplus)
- [Addon Template](https://www.curseforge.com/wow/addons/addon-template)
