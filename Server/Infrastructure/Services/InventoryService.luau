local MetaService = require(game.ServerScriptService.MetaService)

---@class InventoryService
---@field inventoryRepository InventoryRepository
---@field amuletsList table<string, string>
---@field ringsList table<string, string>
---@field EquipmentSlot EquipmentSlotEntity?
local InventoryService = {}
InventoryService.__index = InventoryService

---@param inventoryRepository InventoryRepository
---@param amuletsList table<string, string>
---@param ringsList table<string, string>
---@param fruitsList table<string, string>
---@param EquipmentSlot EquipmentSlotEntity?
---@return InventoryService
function InventoryService.new(inventoryRepository, amuletsList, ringsList, fruitsList, EquipmentSlot)
	local self = setmetatable({}, InventoryService)
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

	local success = self.inventoryRepository:removeItemFromPlayer(userId, itemId, count)
	if not success then
		return false, "Failed to remove item from inventory"
	end

	return true, nil
end

---@param userId string
---@param itemId string
---@param slotName string
---@return boolean, string?
function InventoryService:equipItem(userId, itemId, slotName)
	local inventory = self.inventoryRepository:getByPlayerId(userId)
	if not inventory then
		return false, "Player inventory not found"
	end

	-- Проверить, есть ли предмет в инвентаре
	if not inventory:hasItem(itemId) then
		return false, "Item not found in inventory"
	end

	-- Получить слот экипировки
	local slot = self.EquipmentSlot:getByName(slotName)
	if not slot then
		return false, "Invalid equipment slot"
	end

	-- Валидация предмета - проверить что он существует и может быть экипирован
	if not self.allItemIcons[itemId] then
		return false, "Unknown item"
	end

	-- Проверить, что предмет не является фруктом
	if self.fruitsList[itemId] then
		local metaPlayer = MetaService.Class.Player:Get(game.Players:GetPlayerByUserId(tonumber(userId)))
		metaPlayer:Notification("Fruits cannot be equipped", 3, Color3.new(1, 0.239215, 0.239215))
		return false, "Fruits cannot be equipped"
	end

	-- Проверить совместимость слота с типом предмета
	local itemType = self:getItemType(itemId)
	if not slot:canEquipItemType(itemType) then
		return false, "Item cannot be equipped in this slot"
	end

	local success = self.inventoryRepository:equipItem(userId, itemId, slot)
	if not success then
		return false, "Failed to equip item"
	end

	return true, nil
end

---@param userId string
---@param slotName string
---@return boolean, string?
function InventoryService:unequipItem(userId, slotName)
	local inventory = self.inventoryRepository:getByPlayerId(userId)
	if not inventory then
		return false, "Player inventory not found"
	end

	-- Получить слот экипировки
	local slot = self.EquipmentSlot:getByName(slotName)
	if not slot then
		return false, "Invalid equipment slot"
	end

	-- Проверить, есть ли что-то в слоте
	if not inventory:getEquippedItem(slot) then
		return false, "No item equipped in this slot"
	end

	local success, unequippedItem = self.inventoryRepository:unequipItem(userId, slot)
	if not success then
		return false, "Failed to unequip item"
	end

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
