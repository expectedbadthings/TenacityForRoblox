# r11 — Tenacity 5.1 source fidelity

Compared directly with the supplied Tenacity 5.1 Java source.

- Dropdown: centered title/icon groups measured with the loaded font, 22px headers and 18px module names at the existing 2x source scale.
- Dropdown: source idle color (35, 37, 43), settings color (32, 32, 32), enabled bold text, source text opacity, animated hover/toggle colors, and original dropdown-arrow asset.
- Modern: measured 24px module titles and separate wrapped 18px descriptions, with 300ms hover-in and 400ms hover-out fades.
- Modern: themed enabled toggle tile, animated check visibility, white module titles, and Space to clear a keybind.
- Category selection supports both image icons and fallback text glyphs.
- Settings > ClickGUI layout exposes all three layouts, Screen Height / Value scroll modes, and the source 100–500 Tab Height range. Screen Height uses two thirds of the viewport; Value uses source units at 2x scale.
- Loader cache revision and manifest updated for r11.

## Local use

Copy the contents of this folder into the runtime filesystem's `tenacity/` directory, then run:

```lua
shared.TenacityDeveloper = true
loadstring(readfile('tenacity/loader.lua'))()
```

The remote GitHub loader will only serve this revision after these files are published there. This delivery does not publish changes.

## Validation

All 15 Lua files compiled with Luau 0.737. Repository validation and delimiter checks passed. Live Roblox rendering and interactions have not been tested. This is a closer interface adaptation, not complete Minecraft-to-Roblox feature parity; platform-specific modules and cloud services remain as implemented in r10.

## Startup hotfix

Corrected main.lua to accept r11-source-fidelity. The previous package retained the r10 startup gate and rejected the new GUI. Added a validator checking bootstrap, GUI, and cache revision consistency. Replace main.lua from this corrected package along with the r11 files.
