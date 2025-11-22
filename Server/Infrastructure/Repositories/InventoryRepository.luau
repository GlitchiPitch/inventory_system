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

---@param itemName string
---@return boolean
function InventoryRepository:checkIsAmulet(itemName)
	return self.amuletsList[itemName] ~= nil
end

---@param itemName string
---@return boolean
function InventoryRepository:checkIsFruit(itemName)
	return self.fruitsList[itemName] ~= nil
end

---@param itemName string
---@return boolean
function InventoryRepository:checkIsRing(itemName)
	return self.ringsList[itemName] ~= nil
end

---@param userId string
---@return InventoryEntity?
function InventoryRepository:getByPlayerId(userId)
	-- Проверить кэш
	-- if self._cache[userId] then
	-- 	return self._cache[userId]
	-- end

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
	-- Преобразовать данные из формата {name: count} в inventorySlots
	-- Валидация типов: конвертируем boolean в number
	local function validateCount(count)
		if type(count) == "boolean" then
			return count and 1 or 0
		elseif type(count) == "number" then
			return count
		else
			return 0
		end
	end

	local inventorySlots = {}

	local amuletsData = inventoryData["Amulets"] or {}
	for name, count in pairs(amuletsData) do
		inventorySlots[name] = {
			id = name,
			count = validateCount(count),
		}
	end

	local fruitsData = inventoryData["Fruits"] or {}
	for name, count in pairs(fruitsData) do
		inventorySlots[name] = {
			id = name,
			count = validateCount(count),
		}
	end

	local ringsData = inventoryData["Rings"] or {}
	for name, count in pairs(ringsData) do
		inventorySlots[name] = {
			id = name,
			count = validateCount(count),
		}
	end

	local inventory = self.InventoryEntity.fromDataStructure({
		equippedItems = inventoryData.EquippedAccessories or {},
		inventorySlots = inventorySlots,
	})

	-- Инициализируем массив EquippedRings если его нет
	if not metaPlayer.Data.Inventory.EquippedRings then
		metaPlayer.Data.Inventory.EquippedRings = {}
		self.logger:info("InventoryRepository", string.format("EquippedRings array initialized for player %s", userId))
	end

	-- Инициализируем массив EquippedAmulets если его нет
	if not metaPlayer.Data.Inventory.EquippedAmulets then
		metaPlayer.Data.Inventory.EquippedAmulets = {}
		self.logger:info("InventoryRepository", string.format("EquippedAmulets array initialized for player %s", userId))
	end

	-- Добавить в кэш
	-- self._cache[userId] = inventory

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
	local data = inventory:toDataStructure()
	metaPlayer.Data.Inventory["EquippedAccessories"] = data.equippedItems
	-- Сохранить предметы по категориям
	-- Гарантируем, что count всегда number
	local function ensureNumber(value)
		if type(value) == "number" then
			return value
		elseif type(value) == "boolean" then
			return value and 1 or 0
		else
			return 0
		end
	end

	local amuletsData = {}
	local fruitsData = {}
	local ringsData = {}

	for itemName, slot in pairs(data.inventorySlots) do
		local count = ensureNumber(slot.count)
		if self:checkIsAmulet(itemName) then
			amuletsData[itemName] = count
		elseif self:checkIsFruit(itemName) then
			fruitsData[itemName] = count
		elseif self:checkIsRing(itemName) then
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

		-- Дополнительная логика для колец
		if self:checkIsRing(itemId) then
			local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
			if playerInstance then
				local metaPlayer = MetaService.Class.Player:Get(playerInstance)
				if metaPlayer then
					-- Инициализируем массив EquippedRings если его нет
					if not metaPlayer.Data.Inventory.EquippedRings then
						metaPlayer.Data.Inventory.EquippedRings = {}
					end

					-- Добавляем кольцо в массив, если его там нет
					local alreadyEquipped = false
					for _, ring in ipairs(metaPlayer.Data.Inventory.EquippedRings) do
						if ring == itemId then
							alreadyEquipped = true
							break
						end
					end

					if not alreadyEquipped then
						table.insert(metaPlayer.Data.Inventory.EquippedRings, itemId)
						-- self.logger:info("InventoryRepository", string.format("Ring %s equipped for player %s", itemId, userId))
					end
				end
			end
		end

		-- Дополнительная логика для амулетов
		if self:checkIsAmulet(itemId) then
			local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
			if playerInstance then
				local metaPlayer = MetaService.Class.Player:Get(playerInstance)
				if metaPlayer then
					-- Инициализируем массив EquippedAmulets если его нет
					if not metaPlayer.Data.Inventory.EquippedAmulets then
						metaPlayer.Data.Inventory.EquippedAmulets = {}
					end

					-- Добавляем амулет в массив, если его там нет
					local alreadyEquipped = false
					for _, amulet in ipairs(metaPlayer.Data.Inventory.EquippedAmulets) do
						if amulet == itemId then
							alreadyEquipped = true
							break
						end
					end

					if not alreadyEquipped then
						table.insert(metaPlayer.Data.Inventory.EquippedAmulets, itemId)
						-- self.logger:info("InventoryRepository", string.format("Amulet %s equipped for player %s", itemId, userId))
					end
				end
			end
		end
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

		-- Дополнительная логика для колец
		if unequippedItem and self:checkIsRing(unequippedItem) then
			local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
			if playerInstance then
				local metaPlayer = MetaService.Class.Player:Get(playerInstance)
				if metaPlayer and metaPlayer.Data.Inventory.EquippedRings then
					-- Удаляем кольцо из массива EquippedRings
					for i, ring in ipairs(metaPlayer.Data.Inventory.EquippedRings) do
						if ring == unequippedItem then
							table.remove(metaPlayer.Data.Inventory.EquippedRings, i)
							-- self.logger:info("InventoryRepository", string.format("Ring %s unequipped for player %s", unequippedItem, userId))
							break
						end
					end
				end
			end
		end

		-- Дополнительная логика для амулетов
		if unequippedItem and self:checkIsAmulet(unequippedItem) then
			local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
			if playerInstance then
				local metaPlayer = MetaService.Class.Player:Get(playerInstance)
				if metaPlayer and metaPlayer.Data.Inventory.EquippedAmulets then
					-- Удаляем амулет из массива EquippedAmulets
					for i, amulet in ipairs(metaPlayer.Data.Inventory.EquippedAmulets) do
						if amulet == unequippedItem then
							table.remove(metaPlayer.Data.Inventory.EquippedAmulets, i)
							-- self.logger:info("InventoryRepository", string.format("Amulet %s unequipped for player %s", unequippedItem, userId))
							break
						end
					end
				end
			end
		end
	end

	return success, unequippedItem
end

---@param userId string
function InventoryRepository:clearCache(userId)
	self._cache[userId] = nil
end

return InventoryRepository
