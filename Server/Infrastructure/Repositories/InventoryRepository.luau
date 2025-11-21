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
		self.logger:warn("InventoryRepository", "Player instance not found for userId: " .. userId)
		return nil
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	if not metaPlayer then
		self.logger:warn("InventoryRepository", "MetaPlayer not found for userId: " .. userId)
		return nil
	end

    warn(metaPlayer)

	-- Получить данные инвентаря
	local inventoryData = metaPlayer.Data.Inventory
	if not inventoryData then
		self.logger:warn("InventoryRepository", "Inventory data not found for userId: " .. userId)
		return nil
	end

	-- Создать объект Inventory из данных
	-- Преобразовать Amulets из формата {name: count} в [{id: name, count: count}]
	local amuletsData = inventoryData["Amulets"] or {}
	local inventorySlots = {}
	for name, count in pairs(amuletsData) do
		inventorySlots[name]= {
			id = name,
			count = count
		}
	end

	local inventory = self.InventoryEntity.fromDataStructure({
		equippedItems = inventoryData.EquippedAccessories or {},
		inventorySlots = inventorySlots,
	})

	-- Добавить в кэш
	self._cache[userId] = inventory

	self.logger:info("InventoryRepository", "Loaded inventory for userId: " .. userId)
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
		self.logger:warn("InventoryRepository", "Player instance not found for userId: " .. userId .. " during save")
		return
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	if not metaPlayer then
		self.logger:warn("InventoryRepository", "MetaPlayer not found for userId: " .. userId .. " during save")
		return
	end

	-- Сохранить данные инвентаря
	metaPlayer.Data.Inventory["EquippedAccessories"] = inventory:toDataStructure().equippedItems

	self.logger:info("InventoryRepository", "Saved inventory for userId: " .. userId)
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean
function InventoryRepository:addItemToPlayer(userId, itemId, count)
	if count <= 0 then
		self.logger:warn("InventoryRepository", "Attempted to add invalid count: " .. count .. " for item: " .. itemId)
		return false
	end

	local inventory = self:getByPlayerId(userId)
	if not inventory then
		self.logger:error("InventoryRepository", "Could not get inventory for userId: " .. userId)
		return false
	end

	local success = inventory:addItem(itemId, count)
	if success then
		self:save(userId, inventory)
		self.logger:info("InventoryRepository", "Added " .. count .. " of item " .. itemId .. " to player " .. userId)
	else
		self.logger:warn("InventoryRepository", "Failed to add item " .. itemId .. " to player " .. userId)
	end

	return success
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean
function InventoryRepository:removeItemFromPlayer(userId, itemId, count)
	if count <= 0 then
		self.logger:warn(
			"InventoryRepository",
			"Attempted to remove invalid count: " .. count .. " for item: " .. itemId
		)
		return false
	end

	local inventory = self:getByPlayerId(userId)
	if not inventory then
		self.logger:error("InventoryRepository", "Could not get inventory for userId: " .. userId)
		return false
	end

	local success = inventory:removeItem(itemId, count)
	if success then
		self:save(userId, inventory)
		self.logger:info(
			"InventoryRepository",
			"Removed " .. count .. " of item " .. itemId .. " from player " .. userId
		)
	else
		self.logger:warn("InventoryRepository", "Failed to remove item " .. itemId .. " from player " .. userId)
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
		self.logger:error("InventoryRepository", "Could not get inventory for userId: " .. userId)
		return false
	end

	local success = inventory:equipItem(itemId, slot)
	if success then
		self:save(userId, inventory)
		self.logger:info(
			"InventoryRepository",
			"Equipped item " .. itemId .. " in slot " .. slot:getName() .. " for player " .. userId
		)
	else
		self.logger:warn("InventoryRepository", "Failed to equip item " .. itemId .. " for player " .. userId)
	end

	return success
end

---@param userId string
---@param slot EquipmentSlotEntity
---@return boolean
function InventoryRepository:unequipItem(userId, slot)
	local inventory = self:getByPlayerId(userId)
	if not inventory then
		self.logger:error("InventoryRepository", "Could not get inventory for userId: " .. userId)
		return false
	end

	local success = inventory:unequipItem(slot)
	if success then
		self:save(userId, inventory)
		self.logger:info(
			"InventoryRepository",
			"Unequipped item from slot " .. slot:getName() .. " for player " .. userId
		)
	else
		self.logger:warn(
			"InventoryRepository",
			"Failed to unequip item from slot " .. slot:getName() .. " for player " .. userId
		)
	end

	return success
end

---@param userId string
function InventoryRepository:clearCache(userId)
	self._cache[userId] = nil
	self.logger:info("InventoryRepository", "Cleared inventory cache for userId: " .. userId)
end

return InventoryRepository
