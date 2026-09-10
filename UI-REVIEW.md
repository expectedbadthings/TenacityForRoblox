# Tenacity 5.1 UI source comparison

Compared against the supplied Java files under `C:/Users/nobol/Documents/Tenacity 5.1/dev/tenacity`: `HUDMod`, `ClickGUIMod`, `ArrayListMod`, dropdown `ModuleRect`, `ModeComponent`, and `BooleanComponent`.

The active Roblox renderer is near the end of `guis/tenacity.lua`. Changing the earlier compatibility controls alone does not change the displayed interface.

Changes:

- Render now includes HUD and ClickGUI modules. HUD is enabled by default and controls the client name, watermark, theme, array list, lowercase text, shadows, and animations. ClickGUI opens the interface and exposes style, tab height, outlines, and transparency. Existing profile serialization saves these settings. RightShift remains the global opener.
- Dropdown rows use the reference's `(35,37,43)` background, `(32,32,32)` settings area, bold enabled names, muted disabled names, rotating arrows, and 250–300 ms expansion/toggle transitions. Mode selectors use a 64 px setting row, a 36 px selection box, and 30 px choices at the port's 2x presentation scale.
- Module settings remain alive during expansion/collapse. Option lists shrink with their containing rows. Toggle knobs and the Modern navigation rail animate.
- Modern descriptions occupy their own line. Compact keybinds reserve room beside names. Automatically arranged category panels use viewport-dependent row spacing and scroll limits. Manually placed panels keep their positions.
- HUD entries retain identity across toggles and reorder with animation. Cancelled exits cannot destroy re-enabled rows. The version follows the measured watermark width; narrow viewports reserve vertical clearance for the array list.

Validation: Luau 0.737 compilation, repository validation, Lua delimiter scan, and `tools/test_hud_motion.py` all pass. The regression harness executes the actual HUD update and dropdown expansion functions with UI doubles, including rapid exit/re-entry and reduced-motion cases.

Limits: no live Roblox render comparison was completed. This is not a pixel-perfect parity certification. Roblox font rendering, executor font support, and Minecraft shader effects differ. The additional HUD watermark modes, Minecraft inventory/potion overlays, and all Java ClickGUI settings are not fully ported. Test live at multiple window sizes, rapidly toggle/expand modules, change profiles, and check custom names and keybinds before claiming 1:1 parity.
