# r12 — SideGUI and module controls

## Side panel

Rebuilt from SideGUI.java, SideGUIHotbar.java, ConfigPanel.java, LocalConfigRect.java and SaveForm.java in the supplied Tenacity 5.1 source.

- Uses one 1100 × 700 surface (550 × 350 source units at 2x), without the former 1.25x nested canvas or full-screen dimmer.
- The actual panel peeks 80 pixels from the right edge. Clicking focuses it with a 250ms slide. Dragging its title far enough right docks it again; Escape also docks it.
- 72px hotbar with the Scripts / Configs / Info carousel, sliding selection, original icon font, refresh, and expanding search with Configs / Scripts selection.
- Local configs use the source's 332 × 76 cards, three columns, 24px gaps, original icon actions and neutral colors. Load, update from current settings, export and delete are functional.
- Save Config uses the source's compact 600 × 240 form. Forms block the panel beneath them, display submission errors, and close before the panel when Escape is pressed. Import and manual-copy export use larger forms for JSON.
- Search survives config refresh and sorting. Config timestamps are shown only when recorded by this revision; older configs are labeled Local config.
- Scripts lists installed Scripts-category modules with enable and settings actions. Info uses expandable help cards and provides access to Themes and Settings.
- Cloud configs remain unavailable; local import/export are the supported sharing path.

## Module controls

- Opening a Dropdown module mounts and animates only its own settings. Collapsing retains the controls; expanding another module preserves unfinished text, open menus and focus.
- Mode selectors use source proportions, outline, rotating arrow, 250ms expansion, 30px alternatives and hover highlighting. The current value is excluded. Right-click opens the selector; left-click and touch activation are also supported. Lists with more than seven alternatives scroll.
- Compatibility components can replace a mode list at runtime; visible choices refresh from that live definition.
- Dropdown booleans have animated knobs and corrected type size. Sliders have source-sized labels/rails and arrow-key adjustment after selection.
- Fixed zero-precision division, nonportable math.isfinite calls, unstable setting order, Modern settings overflowing the detail pane, and measurements that ignored nested GUI scaling.
- Corrected Combat and Movement icon glyphs. Custom icon-font glyphs are preferred where available; image/native-font fallbacks remain supported.
- Dropdown drag detection stops at the 30px header instead of including part of the first module row.
- Rebuilds on category/search/schema changes preserve scroll offsets. Modern sidebar expansion recalculates fitting.

## Installation

Replace the contents of the runtime filesystem's `tenacity/` folder with this release. Keep your generated user profile files. Use all three matching release files: `loader.lua`, `main.lua` and `guis/tenacity.lua`.

```lua
shared.TenacityDeveloper = true
loadstring(readfile('tenacity/loader.lua'))()
```

This package has not been published to GitHub. The remote loader will serve the version currently in that repository until these changes are published.

## Validation

- All 15 shipped Lua files compile with Luau 0.737.
- Namespace/layout, delimiter and startup/build/cache consistency checks pass.
- Headless tests execute the production renderer in both custom-asset and native-fallback modes. They exercise all three layouts, expansion isolation, mode changes and dynamic lists, numeric entry and clamping, slider keys, config update/load/export, side search, modal focus, Escape handling and viewport fitting.
- CI now runs compilation and renderer smoke tests with pinned Luau 0.737.

These tests simulate Roblox GUI APIs. Live engine rendering, font loading, mouse/touch routing and drag behavior still need a Roblox session; they are not claimed as visually verified or pixel-perfect. Game modules and Minecraft-specific features were not ported in this revision.
