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
		local logger = container:resolve("Logger")
		local inventoryRepository = container:resolve("InventoryRepository")
		local amuletsList = container:resolve("Shared.Data").AmuletsList
		local ringsList = container:resolve("Shared.Data").RingsList
		local bootsList = container:resolve("Shared.Data").BootsList
		local equipmentSlot = container:resolve("Shared.Domain").entities.EquipmentSlot
		return InventoryService.new(logger, inventoryRepository, amuletsList, ringsList, bootsList, equipmentSlot)
	end)

	-- Регистрация InventoryRemoteService
	self.diContainer:singleton("InventoryRemoteService", function(container)
		local remoteEventService = container:resolve("RemoteEventService")
		local inventoryService = container:resolve("InventoryService")
		local logger = container:resolve("Logger")
		return InventoryRemoteService.new(remoteEventService, inventoryService, logger)
	end)
end

function Services:init()
	local inventoryRemoteService = self.diContainer:resolve("InventoryRemoteService")

	inventoryRemoteService:init()
end

return Services
