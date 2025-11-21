local DataStorePlayerRepository = require(script.DataStorePlayerRepository)
local ItemDefinitions = require(script.ItemDefinitions)
local InventoryRepository = require(script.InventoryRepository)

---@class ServerInfrastructureRepositories
---@field diContainer DIContainer
local ServerInfrastructureRepositories = {}
ServerInfrastructureRepositories.__index = ServerInfrastructureRepositories

---@param diContainer DIContainer
---@return ServerInfrastructureRepositories
function ServerInfrastructureRepositories.new(diContainer)
	local self = setmetatable({}, ServerInfrastructureRepositories)
	self.diContainer = diContainer
	return self
end

function ServerInfrastructureRepositories:init()
	-- Регистрация ItemDefinitions
	self.diContainer:singleton("ItemDefinitions", function()
		return ItemDefinitions.new()
	end)

	-- Регистрация InventoryRepository
	self.diContainer:singleton("InventoryRepository", function(container)
		local logger = container:resolve("Logger")

		---@type InventorySystemDomain
		local domain = container:resolve("Shared.Domain")

		local InventoryEntity = domain.entities.Inventory
		return InventoryRepository.new(logger, InventoryEntity)
	end)

	self.diContainer:singleton("PlayerRepository", function(container)
		--@type InventorySystemDomain
		local domain = container:resolve("Shared.Domain")

		local inventoryRepository = container:resolve("InventoryRepository")
		local PlayerEntity = domain.entities.Player
		local playerRepository = DataStorePlayerRepository.new(PlayerEntity, inventoryRepository)
		-- Очистка кэша при выходе игрока
		---@param player Player
		game.Players.PlayerRemoving:Connect(function(player)
			playerRepository:clearCache(tostring(player.UserId))
		end)

		return playerRepository
	end)
end

return ServerInfrastructureRepositories
