# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ActionbarPlus is a World of Warcraft addon that provides up to 10 supplementary floating action bars with up to 800 configurable buttons. It supports every WoW client (Retail, Classic Era, TBC, Wrath, Cata, Mists).

## Build & Release

See "Build & Release (WoW addons)" in the global `~/.claude/CLAUDE.md`. `w-sync-libs` (no `--version`) uses `dev/setup.yml` and syncs into `ActionbarPlus-Core/ThirdParty/Libs`.

## Architecture

### Addon modules (each is a separate Ace3 addon)

| Module | Role |
|---|---|
| `ActionbarPlus-Core/` | Shared library: namespace, constants, database, utility mixins |
| `ActionbarPlus-BarsUI/` | UI: bar frames, button rendering, event routing |
| `ActionbarPlus-OptionsUI/` | Options dialog UI |

`ActionbarPlus-BarsUI` and `ActionbarPlus-OptionsUI` declare `RequiredDeps: ActionbarPlus-Core`, so Core always loads first. SavedVariables: `ABP_PLUS` (see `ActionbarPlus-Core.toc`).

The V1 addon (`ActionbarPlus/`) is archived under `dev/legacy/` and frozen; all feature work goes in the modules above.

### Namespace & module registry

All code uses a central namespace object (`ns`) defined in `ActionbarPlus-Core/Libs/Namespace/Namespace.lua`. Modules register into `ns.O` via `ns:Register()` and are enriched by `Kapresoft-ModuleUtil-2-0` (`NamespaceModules.lua`). Access any module via `ns.O.ModuleName`.

### Bar & button lifecycle (`ActionbarPlus-BarsUI/`)

`BarModuleFactory.lua` creates one Ace3 module per bar (`ABP_2_0_F1Module` … `ABP_2_0_F10Module`). Each module owns a `BarFrame`, which owns N buttons (`Button_2_0_3.lua`).

Button behavior is composed from mixins in `Modules/Button_2_0_3_Components/`, notably:
- `ButtonWidgetMixin`: action attribute management, `UpdateAction()`
- `ActionEventsFrameMixin`: spell/action events routed only to matching buttons
- `WorldEventsFrameMixin`: system events broadcast to all buttons
- `ButtonUpdateFrameMixin`: per-frame update loop

### Two-frame event routing system

**`WorldEventsFrame_ABP_2_0`** (`WorldEventsFrameMixin.lua`) broadcasts events to *all* registered buttons, e.g. `PLAYER_ENTERING_WORLD`, `UPDATE_SHAPESHIFT_FORM`, `UNIT_AURA`.

**`ActionEventsFrame_ABP_2_0`** (`ActionEventsFrameMixin.lua`) routes events only to buttons whose action matches the event's spell/item ID: `UNIT_SPELLCAST_*`, cooldown, combat, glow events, etc.

When adding a new event:
- Use `ActionEventsFrame` if the event carries a spell/action ID and only relevant buttons should respond.
- Use `WorldEventsFrame` if every button needs to react (texture refresh, global state changes).

### Secure button attributes

Button actions are stored as Blizzard secure attributes, managed by `ButtonWidgetMixin`: the standard `type` plus ABP custom attributes (`abp_type`, `abp_battlepet`, ...; names in `ActionbarPlus-Core/Libs/Namespace/Constants.lua`). An attribute change fires `OnAttributeChanged`, which calls `UpdateAction()` to refresh the button.

### Flavor/version compatibility

`Namespace.lua` mixes `Kapresoft-GameVersionMixin-2-0` into `ns`. Branch on client differences with its checks (`ns:IsClassicEra()`, `ns:IsWOTLKOrLater()`, ...).

### Dev-only code

XML includes of dev files are wrapped in `<!--@do-not-package@-->` / `<!--@end-do-not-package@-->` (see `ActionbarPlus-Core/Libs/_Libs.xml`); a few Lua blocks use `--@debug@` / `--@end-debug@`. The packager strips both in release builds. Developer utilities live in `ActionbarPlus-Core/Libs/Developer/` (also ignored in `pkgmeta.yaml`) and `ActionbarPlus-BarsUI/Modules/Developer/`.

## Key conventions

- **Mixin-based OOP:** composition via `Mixin()`, not inheritance chains. Keep mixins focused on a single concern.
- **Testing in game:** `/etrace` to watch events, `/fstack` to inspect frames, `/dump` to inspect values.

## Code style

Formatting is enforced by `stylua.toml`: 100-column width, 2-space indent, Unix line endings, prefer single quotes, keep parens on function calls, collapse simple statements onto one line. Match this on touched lines; don't reformat whole files as a side effect of an unrelated change.
