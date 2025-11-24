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

---@param item table
---@return string?
function InventoryRepository:_getSlotNameForItem(item)
	local itemType = self:_getItemType(item.name)
	if itemType == "ring" then
		-- Для колец используем правую руку по умолчанию (как в клиенте)
		self.logger:debug("InventoryRepository", "Assigning rightHand slot for ring item:", item.name)
		return "rightHand"
	elseif itemType == "amulet" then
		-- Для амулетов используем шлем
		self.logger:debug("InventoryRepository", "Assigning helmet slot for amulet item:", item.name)
		return "helmet"
	else
		self.logger:debug("InventoryRepository", "No slot assigned for item:", item.name, "type:", itemType)
		return nil -- Для фруктов и других предметов слоты могут не быть нужны
	end
end

---@param itemName string
---@return string
function InventoryRepository:_getItemType(itemName)
	if self:checkIsAmulet(itemName) then
		return "amulet"
	elseif self:checkIsFruit(itemName) then
		return "fruit"
	elseif self:checkIsRing(itemName) then
		return "ring"
	else
		return "unknown"
	end
end

---@param accessories table
---@param itemName string
---@param instanceIndex number
---@return table?
function InventoryRepository:_findExistingItem(accessories, itemName, instanceIndex)
	local count = 0
	for _, item in ipairs(accessories) do
		if item.name == itemName then
			count = count + 1
			if count == instanceIndex then
				return item
			end
		end
	end
	return nil
end

---@param userId string
---@param slotId string
---@param action string
function InventoryRepository:_handleEquippedItemLogic(userId, slotId, action)
	if not slotId then
		return
	end

	local metaPlayer = self:_getMetaPlayer(userId)
	if not metaPlayer then
		return
	end

	local accessories = metaPlayer.Data.Inventory.Accessories
	if not accessories or type(accessories) ~= "table" then
		return
	end

	-- Извлечь itemName и индекс из slotId (например, "Shadow Gem_2" -> "Shadow Gem", 2)
	local itemName, indexStr = string.match(slotId, "^(.+)_(%d+)$")
	if not itemName or not indexStr then
		return
	end

	local index = tonumber(indexStr)
	if not index then
		return
	end

	-- Проверить, что предмет может быть экипирован (кольцо или амулет)
	local isEquipable = self:checkItemType("ring", itemName) or self:checkItemType("amulet", itemName)
	if not isEquipable then
		return
	end

	-- Найти предмет по индексу в массиве accessories
	if accessories[index] and accessories[index].name == itemName then
		accessories[index].equipped = (action == "add")
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
	local accessoriesData = metaPlayer.Data.Inventory.Accessories
	if not accessoriesData or type(accessoriesData) ~= "table" then
		return nil
	end

	-- Создать объект Inventory из данных
	-- Преобразовать массив предметов в inventorySlots и equippedItems

	local inventorySlots = {}
	local equippedItems = {}

	-- Группировать предметы по имени для подсчета количества
	local itemCounts = {}

	for _, item in ipairs(accessoriesData) do
		-- Все предметы в массиве принадлежат игроку
		itemCounts[item.name] = (itemCounts[item.name] or 0) + 1
		if item.equipped then
			-- Использовать сохраненный slotId или slotName
			local slotName = item.slotName or self:_getSlotNameForItem(item)
			if slotName then
				if item.slotId then
					-- У нас есть конкретный slotId
					equippedItems[slotName] = item.slotId
					self.logger:debug("InventoryRepository", "Loading equipped item:", item.name, "slotId:", item.slotId, "in slot:", slotName)
				else
					-- Fallback: определить slotId на основе типа предмета
					equippedItems[slotName] = item.name .. "_1"
					self.logger:debug("InventoryRepository", "Loading equipped item (fallback):", item.name, "in slot:", slotName, "slotId:", item.name .. "_1")
				end
			end
		end
	end

	-- Создать inventorySlots на основе подсчитанных предметов
	for itemName, count in pairs(itemCounts) do
		local validatedCount = self:_validateNumber(count)
		if validatedCount > 0 then
			inventorySlots[itemName] = {}
			for i = 1, validatedCount do
				local slotId = itemName .. "_" .. i
				table.insert(inventorySlots[itemName], { id = itemName, slotId = slotId })
			end
		end
	end

	local inventory = self.InventoryEntity.fromDataStructure({
		equippedItems = equippedItems,
		inventorySlots = inventorySlots,
	})

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

	-- Получить текущий массив предметов или создать новый
	local currentAccessories = metaPlayer.Data.Inventory.Accessories
	if not currentAccessories or type(currentAccessories) ~= "table" then
		currentAccessories = {}
	end

	local data = inventory:toDataStructure()

	-- Создать словарь equipped предметов для быстрого поиска (по slotId)
	local equippedItemsMap = {}
	for slotName, slotId in pairs(data.equippedItems) do
		equippedItemsMap[slotId] = {
			slotName = slotName,
			slotId = slotId
		}
		self.logger:debug("InventoryRepository", "Preparing to save equipped item:", slotId, "in slot:", slotName)
	end

	-- Создать словарь предметов в инвентаре с их количеством
	local inventoryItemsMap = {}
	for itemName, itemSlots in pairs(data.inventorySlots) do
		local count = self:_validateNumber(#itemSlots)
		if count > 0 then
			inventoryItemsMap[itemName] = count
		end
	end

	-- Обновить массив Accessories
	local newAccessories = {}

	-- Добавить предметы из инвентаря
	for itemName, count in pairs(inventoryItemsMap) do
		local itemType = self:_getItemType(itemName)

		-- Для каждого экземпляра предмета добавить отдельный элемент
		for i = 1, count do
			local slotId = itemName .. "_" .. i
			local equippedInfo = equippedItemsMap[slotId]
			local isEquipped = equippedInfo ~= nil

			local itemData = {
				name = itemName,
				type = itemType,
				equipped = isEquipped
			}

			-- Добавить slotName и slotId для экипированных предметов
			if isEquipped then
				itemData.slotName = equippedInfo.slotName
				itemData.slotId = equippedInfo.slotId
				self.logger:debug("InventoryRepository", "Saving equipped item:", itemName, "slotId:", slotId, "slotName:", equippedInfo.slotName)
			end

			-- Добавить level если есть в существующих данных
			local existingItem = self:_findExistingItem(currentAccessories, itemName, i)
			if existingItem and existingItem.level then
				itemData.level = existingItem.level
			end

			table.insert(newAccessories, itemData)
		end
	end

	-- Сохранить обновленный массив
	metaPlayer.Data.Inventory.Accessories = newAccessories
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

		-- Обновить флаги equipped в массиве Accessories
		self:_handleEquippedItemLogic(userId, slotId, "add")
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

		-- Обновить флаги equipped в массиве Accessories
		self:_handleEquippedItemLogic(userId, unequippedSlotId, "remove")
	end

	return success, unequippedSlotId
end

---@param userId string
function InventoryRepository:clearCache(userId)
	self._cache[userId] = nil
end

return InventoryRepository

-- Пример новой структуры данных Accessories в metaPlayer.Data.Inventory.Accessories
-- Теперь данные хранятся в виде массива предметов с флагом equipped
-- Тип предмета определяется динамически по имени
-- Все предметы в массиве принадлежат игроку (owned = true по умолчанию)
-- local Accessories = {
-- 	{
-- 		name = "Amulet_1",
-- 		level = 1,
-- 		equipped = true
-- 	},
-- 	{
-- 		name = "Amulet_1", -- второй экземпляр того же предмета
-- 		level = 1,
-- 		equipped = false
-- 	},
-- 	{
-- 		name = "Fruit_1",
-- 		equipped = false
-- 	},
-- 	{
-- 		name = "Ring_1",
-- 		level = 1,
-- 		equipped = false
-- 	}
-- }
