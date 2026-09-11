# TenacityForRoblox


## Loader

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/expectedbadthings/TenacityForRoblox/main/loader.lua', true))()
```

The loader caches source under `tenacity/` and uses `shared.Tenacity` as the single
runtime core object. `shared.TenacityAPI` exposes the reduced public GUI API.

## Layout

- `loader.lua` — cache-first bootstrap
- `main.lua` — session/module bootstrap
- `guis/loading.lua` — independent Tenacity startup experience
- `guis/tenacity.lua` — Dropdown / Modern / Compact ClickGUI renderer
- `libraries/gui-api.lua` — small declarative API for new modules
- `games/` — universal and game-specific modules
- `assets/tenacity/` — original Tenacity visual resources used by the port
- `profiles/` — shipped default data; per-user state is generated locally

## Reduced module API

New modules can avoid renderer internals:

```lua
local Tenacity = shared.Tenacity

local Speed = Tenacity:Module('Movement', {
    Name = 'ExampleSpeed',
    Tooltip = 'Example module using the reduced API',
    Function = function(enabled)
        print('ExampleSpeed:', enabled)
    end
})

Speed:Slider('Speed', 1, 50, 20, function(value)
    print(value)
end)

Speed:ToggleSetting('Auto Jump', false, function(enabled)
    print(enabled)
end)

Speed:Mode('Mode', {'Normal', 'Pulse'}, 'Normal', function(mode)
    print(mode)
end)
```

The canonical GUI categories are `Combat`, `Movement`, `Render`, `Player`,
`Exploit`, `Misc`, and `Scripts`.

## Development flags

- `shared.TenacityRefresh = true` — force source refresh on the next bootstrap
- `shared.TenacityDeveloper = true` — prefer local development files
- `shared.TenacityIndependent = true` — load the interface without game modules
