local ServerScriptService = game:GetService("ServerScriptService")
local MetaService = require(ServerScriptService.MetaService)
local Players = game:GetService("Players")

---@class InventoryRepository
---@field logger Logger
---@field _cache table<string, InventoryEntity>
---@field InventoryEntity InventoryEntity
---@field amuletsList table<string, string>
---@field fruitsList table<string, string>
---@field ringsList table<string, string>
local InventoryRepository = {}
InventoryRepository.__index = InventoryRepository

---@param logger Logger
---@param InventoryEntity InventoryEntity
---@param amuletsList table<string, string>
---@param fruitsList table<string, string>
---@param ringsList table<string, string>
---@return InventoryRepository
function InventoryRepository.new(logger, InventoryEntity, amuletsList, fruitsList, ringsList)
	local self = setmetatable({}, InventoryRepository)
	self.logger = logger
	self.InventoryEntity = InventoryEntity
	self.amuletsList = amuletsList or {}
	self.fruitsList = fruitsList or {}
	self.ringsList = ringsList or {}
	self._cache = {}
	return self
end

---@param userId string
---@return any?
function InventoryRepository:_getMetaPlayer(userId)
	local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
	if not playerInstance then
		return nil
	end

	local metaPlayer = MetaService.Class.Player:Get(playerInstance)
	return metaPlayer
end

---@param metaPlayer any
function InventoryRepository:_ensureEquippedArrays(metaPlayer)
	if not metaPlayer.Data.Inventory.Accessories.EquippedRings then
		metaPlayer.Data.Inventory.Accessories.EquippedRings = {}
	end
	if not metaPlayer.Data.Inventory.Accessories.EquippedAmulets then
		metaPlayer.Data.Inventory.Accessories.EquippedAmulets = {}
	end
end

---@param value any
---@return number
function InventoryRepository:_validateNumber(value)
	if type(value) == "number" then
		return value
	elseif type(value) == "boolean" then
		return value and 1 or 0
	else
		return 0
	end
end

---@param metaPlayer any
---@param itemName string
---@param arrayName string
function InventoryRepository:_addToEquippedArray(metaPlayer, itemName, arrayName)
	local array = metaPlayer.Data.Inventory.Accessories[arrayName]
	if not array then
		metaPlayer.Data.Inventory.Accessories[arrayName] = {}
		array = metaPlayer.Data.Inventory.Accessories[arrayName]
	end

	local alreadyEquipped = false
	for _, item in ipairs(array) do
		if item == itemName then
			alreadyEquipped = true
			break
		end
	end

	if not alreadyEquipped then
		table.insert(array, itemName)
	end
end

---@param metaPlayer any
---@param itemName string
---@param arrayName string
function InventoryRepository:_removeFromEquippedArray(metaPlayer, itemName, arrayName)
	local array = metaPlayer.Data.Inventory.Accessories[arrayName]
	if not array then
		return
	end

	for i, item in ipairs(array) do
		if item == itemName then
			table.remove(array, i)
			break
		end
	end
end

---@param userId string
---@param itemName string
---@param action string
function InventoryRepository:_handleEquippedItemLogic(userId, itemName, action)
	if not itemName then
		return
	end

	local metaPlayer = self:_getMetaPlayer(userId)
	if not metaPlayer then
		return
	end

	local itemType = nil
	if self:checkItemType("ring", itemName) then
		itemType = "ring"
	elseif self:checkItemType("amulet", itemName) then
		itemType = "amulet"
	end

	if not itemType then
		return
	end

	self:_ensureEquippedArrays(metaPlayer)

	local arrayName = itemType == "ring" and "EquippedRings" or "EquippedAmulets"

	if action == "add" then
		self:_addToEquippedArray(metaPlayer, itemName, arrayName)
	elseif action == "remove" then
		self:_removeFromEquippedArray(metaPlayer, itemName, arrayName)
	end
end

---@param itemType string
---@param itemName string
---@return boolean
function InventoryRepository:checkItemType(itemType, itemName)
	local typeLists = {
		amulet = self.amuletsList,
		fruit = self.fruitsList,
		ring = self.ringsList
	}
	return typeLists[itemType] and typeLists[itemType][itemName] ~= nil
end

---@param itemName string
---@return boolean
function InventoryRepository:checkIsAmulet(itemName)
	return self:checkItemType("amulet", itemName)
end

---@param itemName string
---@return boolean
function InventoryRepository:checkIsFruit(itemName)
	return self:checkItemType("fruit", itemName)
end

---@param itemName string
---@return boolean
function InventoryRepository:checkIsRing(itemName)
	return self:checkItemType("ring", itemName)
end

---@param userId string
---@return InventoryEntity?
function InventoryRepository:getByPlayerId(userId)
	-- Проверить кэш
	-- if self._cache[userId] then
	-- 	return self._cache[userId]
	-- end

	local metaPlayer = self:_getMetaPlayer(userId)
	if not metaPlayer then
		return nil
	end

	-- Получить данные инвентаря
	local inventoryData = metaPlayer.Data.Inventory.Accessories
	if not inventoryData then
		return nil
	end

	-- Создать объект Inventory из данных
	-- Преобразовать данные из формата {name: count} в inventorySlots

	local inventorySlots = {}

	local function createSlotsForItem(name, count)
		local validatedCount = self:_validateNumber(count)
		if validatedCount > 0 then
			inventorySlots[name] = {}
			for i = 1, validatedCount do
				local slotId = name .. "_" .. i
				table.insert(inventorySlots[name], { id = name, slotId = slotId })
			end
		end
	end

	local amuletsData = inventoryData["Amulets"] or {}
	for name, count in pairs(amuletsData) do
		createSlotsForItem(name, count)
	end

	local fruitsData = inventoryData["Fruits"] or {}
	for name, count in pairs(fruitsData) do
		createSlotsForItem(name, count)
	end

	local ringsData = inventoryData["Rings"] or {}
	for name, count in pairs(ringsData) do
		createSlotsForItem(name, count)
	end

	local inventory = self.InventoryEntity.fromDataStructure({
		equippedItems = inventoryData.EquippedAccessories or {},
		inventorySlots = inventorySlots,
	})

	self:_ensureEquippedArrays(metaPlayer)

	-- Добавить в кэш
	-- self._cache[userId] = inventory

	return inventory
end

---@param userId string
---@param inventory InventoryEntity
function InventoryRepository:save(userId, inventory)
	-- Обновить кэш
	self._cache[userId] = inventory

	local metaPlayer = self:_getMetaPlayer(userId)
	if not metaPlayer then
		return
	end

	-- Сохранить данные инвентаря
	local data = inventory:toDataStructure()
	metaPlayer.Data.Inventory["EquippedAccessories"] = data.equippedItems
	-- Сохранить предметы по категориям

	local amuletsData = {}
	local fruitsData = {}
	local ringsData = {}

	for itemName, itemSlots in pairs(data.inventorySlots) do
		local count = self:_validateNumber(#itemSlots)
		if self:checkItemType("amulet", itemName) then
			amuletsData[itemName] = count
		elseif self:checkItemType("fruit", itemName) then
			fruitsData[itemName] = count
		elseif self:checkItemType("ring", itemName) then
			ringsData[itemName] = count
		end
	end

	metaPlayer.Data.Inventory["Amulets"] = amuletsData
	metaPlayer.Data.Inventory["Fruits"] = fruitsData
	metaPlayer.Data.Inventory["Rings"] = ringsData

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
---@param slotId string
---@param slot EquipmentSlotEntity
---@return boolean
function InventoryRepository:equipItem(userId, slotId, slot)
	local inventory = self:getByPlayerId(userId)
	if not inventory then
		return false
	end

	local success = inventory:equipItem(slotId, slot)
	if success then
		self:save(userId, inventory)

		-- Извлечь itemName из slotId для дополнительной логики
		local itemName = string.match(slotId, "^(.+)_%d+$")
		self:_handleEquippedItemLogic(userId, itemName, "add")
	end

	return success
end

---@param userId string
---@param slot EquipmentSlotEntity
---@return boolean, string?
function InventoryRepository:unequipItem(userId, slot)
	local inventory = self:getByPlayerId(userId)
	if not inventory then
		return false
	end

	local success, unequippedSlotId = inventory:unequipItem(slot)
	if success then
		self:save(userId, inventory)

		-- Извлечь itemName из unequippedSlotId для дополнительной логики
		local unequippedItemName = unequippedSlotId and string.match(unequippedSlotId, "^(.+)_%d+$")
		self:_handleEquippedItemLogic(userId, unequippedItemName, "remove")
	end

	return success, unequippedSlotId
end

---@param userId string
function InventoryRepository:clearCache(userId)
	self._cache[userId] = nil
end

return InventoryRepository
