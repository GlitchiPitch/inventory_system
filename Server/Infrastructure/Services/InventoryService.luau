local MetaService = require(game.ServerScriptService.MetaService)

---@class InventoryService
---@field logger Logger
---@field inventoryRepository InventoryRepository
---@field amuletsList table<string, string>
---@field ringsList table<string, string>
---@field EquipmentSlot EquipmentSlotEntity?
local InventoryService = {}
InventoryService.__index = InventoryService

---@param logger Logger
---@param inventoryRepository InventoryRepository
---@param amuletsList table<string, string>
---@param ringsList table<string, string>
---@param fruitsList table<string, string>
---@param EquipmentSlot EquipmentSlotEntity?
---@return InventoryService
function InventoryService.new(logger, inventoryRepository, amuletsList, ringsList, fruitsList, EquipmentSlot)
	local self = setmetatable({}, InventoryService)
	self.logger = logger
	self.inventoryRepository = inventoryRepository
	self.amuletsList = amuletsList or {}
	self.ringsList = ringsList or {}
	self.fruitsList = fruitsList or {}

	-- Объединяем списки предметов в один словарь для валидации
	self.allItemIcons = {}
	for itemName, iconId in pairs(amuletsList or {}) do
		self.allItemIcons[itemName] = iconId
	end
	for itemName, iconId in pairs(ringsList or {}) do
		self.allItemIcons[itemName] = iconId
	end
	for itemName, iconId in pairs(fruitsList or {}) do
		self.allItemIcons[itemName] = iconId
	end

	self.EquipmentSlot = EquipmentSlot
	return self
end

---@param userId string
---@return InventoryEntity?
function InventoryService:getPlayerInventory(userId)
	local inventory = self.inventoryRepository:getByPlayerId(userId)
	return inventory
end

---@param userId string
---@return boolean
function InventoryService:resetPlayerInventory(userId)
	local metaPlayer = self.inventoryRepository:_getMetaPlayer(userId)
	if not metaPlayer then
		return false
	end

	-- Очистить данные инвентаря
	metaPlayer.Data.Inventory.Accessories = {}

	-- Создать новый пустой инвентарь
	local emptyInventory = self.inventoryRepository.InventoryEntity.new()
	self.inventoryRepository:save(userId, emptyInventory)

	return true
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean, string?
function InventoryService:addItem(userId, itemId, count)
	if count <= 0 then
		return false, "Invalid item count"
	end

	-- Валидация предмета - проверить что он существует в списке предметов
	if not self.allItemIcons[itemId] then
		return false, "Unknown item"
	end

	local inventory = self.inventoryRepository:getByPlayerId(userId)
	if not inventory then
		return false, "Player inventory not found"
	end

	-- Проверить лимит инвентаря
	if inventory:isFull() then
		return false, "Inventory is full"
	end

	local success = self.inventoryRepository:addItemToPlayer(userId, itemId, count)
	if not success then
		return false, "Failed to add item to inventory"
	end

	return true, nil
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean, string?
function InventoryService:removeItem(userId, itemId, count)
	if count <= 0 then
		return false, "Invalid item count"
	end

	local inventory = self.inventoryRepository:getByPlayerId(userId)
	if not inventory then
		return false, "Player inventory not found"
	end

	if inventory:getItemCount(itemId) < count then
		return false, "Insufficient item count"
	end

	-- Проверить, что ни один экземпляр этого предмета не экипирован
	for _, equippedSlotId in pairs(inventory.equippedItems) do
		local equippedItemName = string.match(equippedSlotId, "^(.+)_%d+$")
		if equippedItemName == itemId then
			return false, "Cannot remove equipped item"
		end
	end

	local success = self.inventoryRepository:removeItemFromPlayer(userId, itemId, count)
	if not success then
		return false, "Failed to remove item from inventory"
	end

	return true, nil
end

---@param userId string
---@param slotId string
---@param slotName string
---@return boolean, string?
function InventoryService:equipItem(userId, slotId, slotName)
	local inventory = self.inventoryRepository:getByPlayerId(userId)
	if not inventory then
		return false, "Player inventory not found"
	end

	-- Извлечь itemName из slotId
	local itemName = string.match(slotId, "^(.+)_%d+$")
	if not itemName then
		return false, "Invalid slotId format"
	end


	-- Проверить, есть ли предмет в инвентаре
	if not inventory:hasItem(itemName) then
		return false, "Item not found in inventory"
	end

	-- Проверить, что slotId существует в inventorySlots
	local slotExists = false
	if inventory.inventorySlots[itemName] then
		for _, slotData in ipairs(inventory.inventorySlots[itemName]) do
			if slotData.slotId == slotId then
				slotExists = true
				break
			end
		end
	end
	if not slotExists then
		return false, "Slot not found in inventory"
	end

	local slot = self.EquipmentSlot:getByName(slotName)
	if not slot then
		return false, "Invalid equipment slot"
	end

	-- Проверить, что слот свободен
	local equippedItem = inventory:getEquippedItem(slot)
	if equippedItem then
		self.logger:warn("InventoryService", "Cannot equip item - slot", slotName, "is already occupied by:", equippedItem)
		return false, "Equipment slot is already occupied"
	end

	-- Валидация предмета - проверить что он существует и может быть экипирован
	if not self.allItemIcons[itemName] then
		return false, "Unknown item"
	end

	-- Проверить, что предмет не является фруктом
	if self.fruitsList[itemName] then
		local metaPlayer = MetaService.Class.Player:Get(game.Players:GetPlayerByUserId(tonumber(userId)))
		metaPlayer:Notification("Fruits cannot be equipped", 3, Color3.new(1, 0.239215, 0.239215))
		return false, "Fruits cannot be equipped"
	end

	-- Проверить совместимость слота с типом предмета
	local itemType = self:getItemType(itemName)
	if not slot:canEquipItemType(itemType) then
		return false, "Item cannot be equipped in this slot"
	end

	local success = self.inventoryRepository:equipItem(userId, slotId, slot)
	if not success then
		self.logger:error("InventoryService", "Failed to equip item in repository")
		return false, "Failed to equip item"
	end

	self.logger:info("InventoryService", "Successfully equipped item:", slotId, "in slot:", slotName)
	return true, nil
end

---@param userId string
---@param slotName string
---@return boolean, string?
function InventoryService:unequipItem(userId, slotName)
	self.logger:info("InventoryService", "Unequipping item for user", userId, "from slot:", slotName)

	local inventory = self.inventoryRepository:getByPlayerId(userId)
	if not inventory then
		self.logger:error("InventoryService", "Player inventory not found for user:", userId)
		return false, "Player inventory not found"
	end

	-- Получить слот экипировки
	local slot = self.EquipmentSlot:getByName(slotName)
	if not slot then
		self.logger:error("InventoryService", "Invalid equipment slot:", slotName)
		return false, "Invalid equipment slot"
	end

	-- Проверить, есть ли что-то в слоте
	local equippedItem = inventory:getEquippedItem(slot)
	if not equippedItem then
		self.logger:warn("InventoryService", "No item equipped in slot:", slotName)
		return false, "No item equipped in this slot"
	end

	self.logger:info("InventoryService", "Unequipping item:", equippedItem, "from slot:", slotName)

	local success, unequippedItem = self.inventoryRepository:unequipItem(userId, slot)
	if not success then
		self.logger:error("InventoryService", "Failed to unequip item from repository")
		return false, "Failed to unequip item"
	end

	self.logger:info("InventoryService", "Successfully unequipped item:", unequippedItem)
	return true, unequippedItem
end

---@param itemId string
---@return string
function InventoryService:getItemType(itemId)
	if self.amuletsList[itemId] then
		return "amulet"
	elseif self.ringsList[itemId] then
		return "ring"
	elseif self.fruitsList[itemId] then
		return "weapon" -- фрукты считаем оружием
	end

	return "weapon" -- по умолчанию
end

---@param userId string
---@param itemId string
---@return boolean
function InventoryService:hasItem(userId, itemId)
	local inventory = self.inventoryRepository:getByPlayerId(userId)
	return inventory and inventory:hasItem(itemId) or false
end

---@param userId string
---@param itemId string
---@return number
function InventoryService:getItemCount(userId, itemId)
	local inventory = self.inventoryRepository:getByPlayerId(userId)
	return inventory and inventory:getItemCount(itemId) or 0
end

return InventoryService
