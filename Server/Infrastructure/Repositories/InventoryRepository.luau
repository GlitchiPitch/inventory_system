local ServerScriptService = game:GetService("ServerScriptService")
local MetaService = require(ServerScriptService.MetaService)
local Players = game:GetService("Players")

---@class InventoryRepository
---@field logger Logger
---@field _cache table<string, InventoryEntity>
---@field InventoryEntity InventoryEntity
local InventoryRepository = {}
InventoryRepository.__index = InventoryRepository

---@param logger Logger
---@param InventoryEntity InventoryEntity
---@return InventoryRepository
function InventoryRepository.new(logger, InventoryEntity)
	local self = setmetatable({}, InventoryRepository)
	self.logger = logger
	self.InventoryEntity = InventoryEntity
	self._cache = {}
	return self
end

---@param userId string
---@return InventoryEntity?
function InventoryRepository:getByPlayerId(userId)
	-- Проверить кэш
	if self._cache[userId] then
		return self._cache[userId]
	end

	-- Получить объект игрока
	local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
	if not playerInstance then
		return nil
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	if not metaPlayer then
		return nil
	end

	-- Получить данные инвентаря
	local inventoryData = metaPlayer.Data.Inventory
	if not inventoryData then
		return nil
	end

	-- Создать объект Inventory из данных
	-- Преобразовать Amulets из формата {name: count} в [{id: name, count: count}]
	local amuletsData = inventoryData["Amulets"] or {}
	local inventorySlots = {}
	for name, count in pairs(amuletsData) do
		inventorySlots[name] = {
			id = name,
			count = count,
		}
	end

	local fruitsData = inventoryData["Fruits"] or {}

	for name, count in pairs(fruitsData) do
		inventorySlots[name] = {
			id = name,
			count = count,
		}
	end

	local inventory = self.InventoryEntity.fromDataStructure({
		equippedItems = inventoryData.EquippedAccessories or {},
		inventorySlots = inventorySlots,
	})

	-- Добавить в кэш
	self._cache[userId] = inventory

	return inventory
end

---@param userId string
---@param inventory InventoryEntity
function InventoryRepository:save(userId, inventory)
	-- Обновить кэш
	self._cache[userId] = inventory

	-- Получить объект игрока
	local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
	if not playerInstance then
		return
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	if not metaPlayer then
		return
	end

	-- Сохранить данные инвентаря
	metaPlayer.Data.Inventory["EquippedAccessories"] = inventory:toDataStructure().equippedItems
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean
function InventoryRepository:addItemToPlayer(userId, itemId, count)
	if count <= 0 then
		return false
	end

	local inventory = self:getByPlayerId(userId)
	if not inventory then
		return false
	end

	local success = inventory:addItem(itemId, count)
	if success then
		self:save(userId, inventory)
	end

	return success
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean
function InventoryRepository:removeItemFromPlayer(userId, itemId, count)
	if count <= 0 then
		return false
	end

	local inventory = self:getByPlayerId(userId)
	if not inventory then
		return false
	end

	local success = inventory:removeItem(itemId, count)
	if success then
		self:save(userId, inventory)
	end

	return success
end

---@param userId string
---@param itemId string
---@param slot EquipmentSlotEntity
---@return boolean
function InventoryRepository:equipItem(userId, itemId, slot)
	local inventory = self:getByPlayerId(userId)
	if not inventory then
		return false
	end

	local success = inventory:equipItem(itemId, slot)
	if success then
		self:save(userId, inventory)
	end

	return success
end

---@param userId string
---@param slot EquipmentSlotEntity
---@return boolean
function InventoryRepository:unequipItem(userId, slot)
	local inventory = self:getByPlayerId(userId)
	if not inventory then
		return false
	end

	local success, unequippedItem = inventory:unequipItem(slot)
	if success then
		self:save(userId, inventory)
	end

	return success, unequippedItem
end

---@param userId string
function InventoryRepository:clearCache(userId)
	self._cache[userId] = nil
end

return InventoryRepository
