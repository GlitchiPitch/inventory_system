local ServerScriptService = game:GetService("ServerScriptService")
local MetaService = require(ServerScriptService.MetaService)
local Players = game:GetService("Players")

---@class DataStorePlayerRepository
---@field inventoryRepository InventoryRepository
---@field _cache table<string, PlayerEntity>
---@field PlayerEntity PlayerEntity
local DataStorePlayerRepository = {}
DataStorePlayerRepository.__index = DataStorePlayerRepository

---@param PlayerEntity PlayerEntity
---@param inventoryRepository InventoryRepository
---@return DataStorePlayerRepository
function DataStorePlayerRepository.new(PlayerEntity, inventoryRepository)
	local self = setmetatable({}, DataStorePlayerRepository)
	self.PlayerEntity = PlayerEntity
	self.inventoryRepository = inventoryRepository
	self._cache = {}
	return self
end

---@param userId string
---@return PlayerEntity?
function DataStorePlayerRepository:getById(userId)
	-- Проверить кэш
	if self._cache[userId] then
		return self._cache[userId]
	end

	-- Получить объект игрока из MetaService
	local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
	if not playerInstance then
		return nil
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	if not metaPlayer then
		return nil
	end

	-- Создать объект PlayerEntity на основе данных MetaService
	local playerEntity = self.PlayerEntity.new(userId)

	-- Загрузить инвентарь
	local inventory = self.inventoryRepository:getByPlayerId(userId)
	if inventory then
		playerEntity:setInventory(inventory)
	end
	-- Установить ссылку на metaPlayer для доступа к данным MetaService
	playerEntity:setMetaPlayer(metaPlayer)

	-- Добавить в кэш
	self._cache[userId] = playerEntity

	return playerEntity
end

---@param playerEntity PlayerEntity
function DataStorePlayerRepository:save(playerEntity)
	-- Добавить в кэш
	self._cache[playerEntity.userId] = playerEntity

	-- Сохранить в MetaService
	local playerInstance = Players:GetPlayerByUserId(tonumber(playerEntity.userId))
	if not playerInstance then
		return
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	if not metaPlayer then
		return
	end

	-- Сохранить инвентарь
	if playerEntity:getInventory() then
		self.inventoryRepository:save(playerEntity.userId, playerEntity:getInventory())
	end

	-- MetaService автоматически сохранит изменения
end

---@param userId string
function DataStorePlayerRepository:delete(userId)
	-- Удалить из кэша
	self._cache[userId] = nil

	-- Очистить данные в MetaService
	local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
	if not playerInstance then
		return
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	if not metaPlayer then
		return
	end

	-- Очистить данные BattlepassShop
	metaPlayer.Data.BattlepassShop = nil
end

---@param userId string
function DataStorePlayerRepository:clearCache(userId)
	self._cache[userId] = nil
	self.inventoryRepository:clearCache(userId)
end

---@param userId string
---@return boolean
function DataStorePlayerRepository:exists(userId)
	local player = self:getById(userId)
	return player ~= nil
end

return DataStorePlayerRepository
