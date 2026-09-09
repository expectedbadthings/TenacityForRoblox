# TenacityForRoblox API

The supported module API is intentionally small. Renderer objects are internal; game modules should register through `shared.Tenacity` or `shared.TenacityAPI`.

## Categories

`Combat`, `Movement`, `Render`, `Player`, `Exploit`, `Misc`, `Scripts`

## Create a module

```lua
local Tenacity = shared.Tenacity

local Example = Tenacity:Module('Movement', {
    Name = 'Example',
    Tooltip = 'Example Tenacity module',
    Function = function(enabled)
        print(enabled)
    end
})
```

`Tenacity:Module()` returns the real module object used by the core, so module identity, profile serialization and direct state reads remain intact.

## Settings

Use one generic `Setting` method:

```lua
local Enabled = Example:Setting({
    Type = 'toggle',
    Name = 'Enabled option',
    Default = true,
    Function = function(value) print(value) end
})

local Speed = Example:Setting({
    Type = 'slider',
    Name = 'Speed',
    Min = 1,
    Max = 50,
    Default = 20,
    Function = function(value) print(value) end
})

local Mode = Example:Setting({
    Type = 'dropdown',
    Name = 'Mode',
    List = {'Normal', 'Pulse'},
    Default = 'Normal'
})
```

Supported setting types: `toggle`, `slider`, `range`, `dropdown`, `color`, `text`, `list`, `bind`, `button`, `font`, and `targets`.

Convenience helpers are also available:

```lua
Example:ToggleSetting('Auto Jump', false, callback)
Example:Slider('Speed', 1, 50, 20, callback)
Example:Mode('Mode', {'Normal', 'Pulse'}, 'Normal', callback)
```

## Core helpers

```lua
Tenacity:Notify('Title', 'Message', 3, 'info')
Tenacity:GetModule('Speed')
Tenacity:GetCategory('Movement')

shared.TenacityAPI:Theme('Tenacity')
shared.TenacityAPI:Open()
shared.TenacityAPI:Close()
shared.TenacityAPI:ToggleGUI()
```

## Runtime paths

Remote source comes from `expectedbadthings/TenacityForRoblox` and local cache state lives under `tenacity/`.
