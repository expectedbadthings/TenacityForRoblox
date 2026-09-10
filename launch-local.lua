-- Start the installed release from local files without a remote refresh.
assert(not shared.TenacityBooting, 'Tenacity is already starting.')
local expected='r12-sidegui-controls'
local function source(path)
    local ok,value=pcall(readfile,'tenacity/'..path)
    assert(ok and type(value)=='string','Missing local file: tenacity/'..path..'. Install the complete r12 release.')
    return value
end
local main=source('main.lua')
local gui=source('guis/tenacity.lua')
local loader=source('loader.lua')
local actual=gui:match("Build%s*=%s*'([^']+)'")
assert(actual==expected,'Local GUI is '..tostring(actual)..'; install r12-sidegui-controls.')
assert(main:match("local expectedBuild%s*=%s*'([^']+)'")==expected,'Local main.lua is from another release; install r12 main.lua.')
assert(loader:match("local cacheRevision%s*=%s*'([^']+)'")=='tenacity-'..expected,'Local loader.lua is from another release; install r12 loader.lua.')
source('libraries/runtime.lua')
assert(loadstring(main,'@tenacity/main.lua'))
assert(loadstring(gui,'@tenacity/guis/tenacity.lua'))
local boot=assert(loadstring(loader,'@tenacity/loader.lua'))
shared.TenacityDeveloper=true
shared.TenacityRefresh=nil
boot()
