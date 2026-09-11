-- This place uses the shared BedWars implementation.
local tenacity = assert(shared.Tenacity, 'Tenacity core is unavailable')
local runtime = assert(shared.TenacityRuntime, 'Tenacity runtime is unavailable')

local path = 'tenacity/games/6872274481.lua'
local source = runtime.Read(path)
local loader, err = loadstring(source, '@'..path)
if not loader then
	tenacity:Notify('Tenacity', 'Failed to load BedWars support: '..tostring(err), 30, 'alert')
	error(err, 0)
end

return loader(...)
