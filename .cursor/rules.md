оставлять в коде записи -- TODO: для дальнейших действий
названия методов с маленькой буквы camelCase
при реализации новых модулей, инициализация и подключение к основной системе делается в последнюю очередь


Прямые импорты только дочерних объектов пример (script.<Module>) запрещены импорты (script.Parent)


Пример как выглядит главный класс клиента и сервера
```lua
---@class MainClass
local MainClass = {}
MainClass.__index = MainClass

function MainClass.new() end
function MainClass:init() end
function MainClass:start() end

```

Клиент стартует после инициализации сервера, клиент узнает о том что сервер загрузился через проверку аттрибута у ReplicatedStorage:GetAttribute("ServerIsLoaded")

Пример проверки
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

инициализация слоев 