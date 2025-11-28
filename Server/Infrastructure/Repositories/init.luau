local DataStorePlayerRepository = require(script.DataStorePlayerRepository)
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
	
	-- Регистрация InventoryRepository
	self.diContainer:singleton("InventoryRepository", function(container)
		local logger = container:resolve("Logger")

		---@type InventorySystemDomain
		local domain = container:resolve("Shared.Domain")

		local InventoryEntity = domain.entities.Inventory
		local amuletsList = container:resolve("Shared.Data").AmuletsList
		local ringsList = container:resolve("Shared.Data").RingsList
		return InventoryRepository.new(logger, InventoryEntity, amuletsList, ringsList)
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
