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
	if self.inventorySlots[itemId] then
		return #self.inventorySlots[itemId]
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

	-- Проверить лимит инвентаря (количество всех слотов)
	local currentSlotsUsed = self:getTotalSlotsUsed()

	-- Проверить, не превысит ли добавление новых слотов лимит
	if currentSlotsUsed + count > self.maxSlots then
		return false -- Инвентарь полон
	end

	-- Инициализировать массив слотов для этого предмета, если его нет
	if not self.inventorySlots[itemId] then
		self.inventorySlots[itemId] = {}
	end

	-- Добавить count отдельных слотов для этого предмета
	for i = 1, count do
		local slotId = itemId .. "_" .. (#self.inventorySlots[itemId] + 1)
		table.insert(self.inventorySlots[itemId], { id = itemId, slotId = slotId })
	end

	return true
end

---@return number
function InventoryEntity:getTotalSlotsUsed()
	local totalSlots = 0
	for _, itemSlots in pairs(self.inventorySlots) do
		totalSlots = totalSlots + #itemSlots
	end
	return totalSlots
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

	local itemSlots = self.inventorySlots[itemId]
	if not itemSlots or #itemSlots < count then
		return false -- Недостаточно предметов
	end

	-- Удалить count слотов с конца массива
	for i = 1, count do
		table.remove(itemSlots)
	end

	-- Если слотов не осталось, удалить запись полностью
	if #itemSlots == 0 then
		self.inventorySlots[itemId] = nil
	end

	return true
end

---@param slotId string
---@param slot EquipmentSlotEntity
---@return boolean
function InventoryEntity:equipItem(slotId, slot)
	-- Извлечь itemName из slotId (убираем "_номер")
	local itemName = string.match(slotId, "^(.+)_%d+$")
	if not itemName then
		return false
	end

	-- Проверить, есть ли предмет в инвентаре
	if not self:hasItem(itemName) then
		return false
	end

	-- Проверить, что slotId действительно существует в inventorySlots
	local slotExists = false
	if self.inventorySlots[itemName] then
		for _, slotData in ipairs(self.inventorySlots[itemName]) do
			if slotData.slotId == slotId then
				slotExists = true
				break
			end
		end
	end
	if not slotExists then
		return false
	end

	-- Снять текущий предмет из слота, если есть
	local currentEquipped = self:getEquippedItem(slot)
	if currentEquipped then
		print("InventoryEntity: Unequipping existing item", currentEquipped, "from slot", slot:getName())
		self:unequipItem(slot)
	end

	-- Экипировать новый предмет
	print("InventoryEntity: Equipping item", slotId, "in slot", slot:getName())
	self.equippedItems[slot:getName()] = slotId
	return true
end

---@param slot EquipmentSlotEntity
---@return boolean, string?
function InventoryEntity:unequipItem(slot)
	local equippedSlotId = self:getEquippedItem(slot)
	if not equippedSlotId then
		return false
	end

	-- Извлечь itemName из slotId
	local itemName = string.match(equippedSlotId, "^(.+)_%d+$")
	if not itemName then
		return false
	end

	-- Снять предмет из экипировки
	self.equippedItems[slot:getName()] = nil

	-- Вернуть предмет в инвентарь (если его там нет)
	if not self:hasItem(itemName) then
		self:addItem(itemName, 1)
	end

	return true, equippedSlotId
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
