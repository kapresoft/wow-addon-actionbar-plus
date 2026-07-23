# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ActionbarPlus is a World of Warcraft addon that provides up to 10 supplementary floating action bars with up to 800 configurable buttons. It supports all WoW versions (Retail, Classic, TBC, Wrath, Cata, Mists).

## Build & Release

### Pull external library dependencies

```shell
w-sync-libs              # for V1 (Legacy)
w-sync-libs --version 2  # for V2
# Output goes to .release/
```

### Deployment to local WoW installs

#### One-time deploy
```shell
w-deployer -c ./dev/deployer-config.lua
```

#### Continuous Deploy with 'quiet' -q and 'watch' -w mode

```shell
w-deployer -c ./dev/deployer-config.lua -qw
```

### Clean build
```shell
./dev/release-clean.sh
```
### Release process
1. Create pull requests
2. Create tag to publish--an automated github action will push any tag created
3. Verify CurseForge build is green, then publish the GitHub draft release

There are no automated tests. Validation is done in-game.

## Architecture

### Addon modules (each is a separate Ace3 addon)

**V1 (Legacy — frozen, no new feature work):**

| Module | Role |
|---|---|
| `ActionbarPlus/` | Database, profile management, slash commands, SmartMount |

**V2 (Next Gen — active development):**

| Module | Role |
|---|---|
| `ActionbarPlus-Core/` | Shared library — namespace, constants, utility mixins, flavor compat |
| `ActionbarPlus-BarsUI/` | UI — bar frames, button rendering, event routing |
| `ActionbarPlus-OptionsUI/` | Options dialog UI |

`ActionbarPlus-BarsUI` declares `RequiredDeps: ActionbarPlus-Core` in its TOC, so Core always loads first.

### Namespace & module registry (V2 pattern)

All V2 code uses a central namespace object (`ns`) defined in `ActionbarPlus-Core/Libs/Namespace/Namespace.lua`. Modules register themselves into `ns.O` via `ns:Register()` and are enriched by `Kapresoft-ModuleUtil-2-0`. Access any module from anywhere via `ns.O.ModuleName`.

### Bar & button lifecycle (`ActionbarPlus-BarsUI/`)

`BarModuleFactory.lua` creates one Ace3 module per bar (`ABP_2_0_F1Module` … `ABP_2_0_F10Module`). Each module owns a `BarFrame` which owns N buttons.

Buttons are composed from mixins in `Modules/Button_2_0_3_Components/`:
- `ButtonWidgetMixin` — action attribute management, `UpdateAction()`
- `ButtonStateMixin` — checked/active state, `OnSpellCast()`
- `ActionEventsFrameMixin` — spell/action events routed only to matching buttons
- `WorldEventsFrameMixin` — system events broadcast to all buttons
- `ButtonUpdateFrameMixin` — per-frame update loop

### Two-frame event routing system

**`WorldEventsFrame_ABP_2_0`** (`WorldEventsFrameMixin.lua`) — broadcasts events to *all* registered buttons. Used for: `PLAYER_ENTERING_WORLD`, `UPDATE_SHAPESHIFT_FORM`, `UNIT_AURA`.

**`ActionEventsFrame_ABP_2_0`** (`ActionEventsFrameMixin.lua`) — routes events only to buttons whose action matches the event's spell/item ID. Used for all `UNIT_SPELLCAST_*` events, cooldown events, combat events, glow events, etc.

When adding a new event:
- Use `ActionEventsFrame` if the event carries a spell/action ID and only relevant buttons should respond.
- Use `WorldEventsFrame` if every button needs to react (texture refresh, global state changes).

### Secure button attributes

Button actions are stored as Blizzard secure attributes set by `ButtonWidgetMixin`:
- `abp_type` — `spell` | `item` | `macro` | `macrotext` | `mount` | `companion` | `battlepet` | `petaction` | `equipmentset`
- `abp_spell`, `abp_item`, `abp_macrotext`, etc.

Changes to these attributes fire `OnAttributeChanged`, which calls `UpdateAction()` → button visuals refresh.

### Flavor/version compatibility

`ActionbarPlus-Core/Libs/Flavor/` contains per-version files (`Retail.lua`, `Wrath.lua`, `Cata.lua`, etc.) that set feature flags. Check these when using APIs that differ across WoW versions.

### Debug-only code

Wrap debug-only Lua with `--@debug@` / `--@end-debug@` tokens. The BigWigsMods packager strips these blocks in release builds. Developer utilities live in `ActionbarPlus/Core/Lib/Developer/` and are excluded from packaging via `pkgmeta.yaml`.

## Key conventions

- **Mixin-based OOP** — composition via `Mixin()`, not inheritance chains. Keep mixins focused on a single concern.
- **No unit test framework** — test in-game. Use `/etrace` to watch events, `/fstack` to inspect frames, `/dump` to inspect values.
- **EmmyLua annotations** — the codebase uses EmmyLua (`---@param`, `---@return`, `---@class`) for IDE type checking. Maintain these on public APIs.
- **V1 vs V2** — `ActionbarPlus/` is V1 (frozen). All new feature work goes in the V2 modules (`ActionbarPlus-Core`, `ActionbarPlus-BarsUI`, `ActionbarPlus-OptionsUI`).
