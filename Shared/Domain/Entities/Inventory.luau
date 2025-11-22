---@class InventoryEntity
---@field equippedItems table
---@field inventorySlots table
---@field maxSlots number
local InventoryEntity = {}
InventoryEntity.__index = InventoryEntity

local DEFAULT_MAX_SLOTS = 50

---@return InventoryEntity
function InventoryEntity.new()
	local self = setmetatable({}, InventoryEntity)
	self.equippedItems = {}
	self.inventorySlots = {}
	self.maxSlots = DEFAULT_MAX_SLOTS
	return self
end

---@return table
function InventoryEntity:getEquippedItems()
	return self.equippedItems
end

---@param slot EquipmentSlotEntity
---@return string?
function InventoryEntity:getEquippedItem(slot)
	return self.equippedItems[slot:getName()]
end

---@return table
function InventoryEntity:getInventorySlots()
	return self.inventorySlots
end

---@param itemId string
---@return number
function InventoryEntity:getItemCount(itemId)
	for slotName, slot in pairs(self.inventorySlots) do
		if slotName == itemId then
			return slot.count
		end
	end
	return 0
end

---@param itemId string
---@return boolean
function InventoryEntity:hasItem(itemId)
	return self:getItemCount(itemId) > 0
end

---@param itemId string
---@param count number
---@return boolean
function InventoryEntity:addItem(itemId, count)
	if count <= 0 then
		return false
	end

	-- Проверить лимит инвентаря (количество уникальных предметов)
	local currentUniqueItems = 0
	for _ in pairs(self.inventorySlots) do
		currentUniqueItems = currentUniqueItems + 1
	end

	-- Найти существующий слот с этим предметом
	if self.inventorySlots[itemId] then
		self.inventorySlots[itemId].count = self.inventorySlots[itemId].count + count
		return true
	end

	-- Проверить, не превысит ли добавление нового слота лимит
	if currentUniqueItems >= self.maxSlots then
		return false -- Инвентарь полон
	end

	-- Создать новый слот
	self.inventorySlots[itemId] = { id = itemId, count = count }
	return true
end

---@return number
function InventoryEntity:getTotalSlotsUsed()
	return #self.inventorySlots
end

---@return number
function InventoryEntity:getMaxSlots()
	return self.maxSlots
end

---@return boolean
function InventoryEntity:isFull()
	return self:getTotalSlotsUsed() >= self.maxSlots
end

---@param itemId string
---@param count number
---@return boolean
function InventoryEntity:removeItem(itemId, count)
	if count <= 0 then
		return false
	end

	local slot = self.inventorySlots[itemId]
	if not slot then
		return false -- Предмет не найден
	end

	if slot.count >= count then
		slot.count = slot.count - count
		if slot.count == 0 then
			self.inventorySlots[itemId] = nil
		end
		return true
	end
	return false -- Недостаточно предметов
end

---@param itemId string
---@param slot EquipmentSlotEntity
---@return boolean
function InventoryEntity:equipItem(itemId, slot)
	-- Проверить, есть ли предмет в инвентаре
	if not self:hasItem(itemId) then
		return false
	end

	-- Снять текущий предмет из слота, если есть
	local currentEquipped = self:getEquippedItem(slot)
	if currentEquipped then
		self:unequipItem(slot)
	end

	-- Экипировать новый предмет
	self.equippedItems[slot:getName()] = itemId
	return true
end

---@param slot EquipmentSlotEntity
---@return boolean
function InventoryEntity:unequipItem(slot)
	local equippedItem = self:getEquippedItem(slot)
	if not equippedItem then
		return false
	end

	-- Снять предмет из экипировки
	self.equippedItems[slot:getName()] = nil

	-- Вернуть предмет в инвентарь (если его там нет)
	if not self:hasItem(equippedItem) then
		self:addItem(equippedItem, 1)
	end

	return true, equippedItem
end

---@return table
function InventoryEntity:toDataStructure()
	return {
		equippedItems = self.equippedItems,
		inventorySlots = self.inventorySlots,
	}
end

---@param data table
---@return InventoryEntity
function InventoryEntity.fromDataStructure(data)
	local inventory = InventoryEntity.new()
	inventory.equippedItems = data.equippedItems or {}
	inventory.inventorySlots = data.inventorySlots or {}
	return inventory
end

return InventoryEntity
