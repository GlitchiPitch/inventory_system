leave -- TODO: entries in code for further actions
method names with lowercase camelCase
when implementing new modules, initialization and connection to the main system is done last


Direct imports only for child objects example (script.<Module>) imports (script.Parent) are forbidden


Example of how the main client and server class looks
```lua
---@class MainClass
local MainClass = {}
MainClass.__index = MainClass

function MainClass.new() end
function MainClass:init() end
function MainClass:start() end

```

Client starts after server initialization, client learns that server has loaded through attribute check in ReplicatedStorage:GetAttribute("ServerIsLoaded")

Check example
```lua
local client = Client.new()

if ReplicatedStorage:GetAttribute("ServerIsLoaded") then
	client:init()
	client:start()
else
	ReplicatedStorage:GetAttributeChangedSignal("ServerIsLoaded"):Connect(function()
		client:init()
		client:start()
	end)
end

```

layer initialization 