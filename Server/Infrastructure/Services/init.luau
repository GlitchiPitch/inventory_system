local InventoryService = require(script.InventoryService)
local InventoryRemoteService = require(script.InventoryRemoteService)

---@class ServerInventorySystemServices
local Services = {}
Services.__index = Services

---@param diContainer DIContainer
---@return ServerInventorySystemServices
function Services.new(diContainer)
	local self = setmetatable({}, Services)
	self.diContainer = diContainer
	self:_registerServices()
	return self
end

function Services:_registerServices()
	-- Регистрация InventoryService
	self.diContainer:singleton("InventoryService", function(container)
		local inventoryRepository = container:resolve("InventoryRepository")
		local itemDefinitions = container:resolve("ItemDefinitions")
		return InventoryService.new(inventoryRepository, itemDefinitions)
	end)

	-- Регистрация InventoryRemoteService
	self.diContainer:singleton("InventoryRemoteService", function(container)
		local remoteEventService = container:resolve("RemoteEventService")
		local inventoryService = container:resolve("InventoryService")
		return InventoryRemoteService.new(remoteEventService, inventoryService)
	end)
end

function Services:init()
	local inventoryRemoteService = self.diContainer:resolve("InventoryRemoteService")

	inventoryRemoteService:init()
end

return Services
