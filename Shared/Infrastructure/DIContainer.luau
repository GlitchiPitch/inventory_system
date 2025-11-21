---@class service
---@field factory function
---@field lifecycle string
---@field instance any

-- Простой DI Container для внедрения зависимостей
---@class DIContainer
---@field _services table<string, service>
local DIContainer = {}
DIContainer.__index = DIContainer

-- Типы жизненного цикла
DIContainer.Lifecycle = {
	SINGLETON = "singleton",
	TRANSIENT = "transient",
}

---@return DIContainer
function DIContainer.new()
	local self = setmetatable({}, DIContainer)
	self._services = {} -- name -> { factory, lifecycle, instance }
	return self
end

-- Регистрация singleton зависимости
---@param name string
---@param factory function
---@return DIContainer
function DIContainer:singleton(name, factory)
	self._services[name] = {
		factory = factory,
		lifecycle = self.Lifecycle.SINGLETON,
		instance = nil,
	}
	return self
end

-- Регистрация transient зависимости
---@param name string
---@param factory function
---@return DIContainer
function DIContainer:transient(name, factory)
	self._services[name] = {
		factory = factory,
		lifecycle = self.Lifecycle.TRANSIENT,
		instance = nil,
	}
	return self
end

-- Разрешение зависимости
---@generic T
---@param name '"InventoryRepository"' | '"ItemDefinitions"' | '"InventoryRemoteService"' | '"RemoteEventService"' | '"InventoryService"' | '"PlayerRepository"' | '"Shared.Domain"' | '"FeatureFlagService"'
---@return T
function DIContainer:resolve(name)
	local service = self._services[name]
	if not service then
		error("Service not registered: " .. name)
	end

	if service.lifecycle == self.Lifecycle.SINGLETON then
		if not service.instance then
			service.instance = service.factory(self)
		end
		return service.instance
	else
		return service.factory(self)
	end
end

-- Проверка регистрации сервиса
---@param name string
---@return boolean
function DIContainer:has(name)
	return self._services[name] ~= nil
end

-- Получение всех зарегистрированных сервисов
function DIContainer:getServices()
	local names = {}
	for name in pairs(self._services) do
		table.insert(names, name)
	end
	return names
end

return DIContainer
