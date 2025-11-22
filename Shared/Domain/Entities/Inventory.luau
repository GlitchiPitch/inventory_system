---@class InventoryEntity
---@field equippedItems table
---@field inventorySlots table
local InventoryEntity = {}
InventoryEntity.__index = InventoryEntity

---@return InventoryEntity
function InventoryEntity.new()
	local self = setmetatable({}, InventoryEntity)
	self.equippedItems = {}
	self.inventorySlots = {}
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

	-- Найти существующий слот с этим предметом
	for _, slot in ipairs(self.inventorySlots) do
		if slot.id == itemId then
			slot.count = slot.count + count
			return true
		end
	end

	-- Создать новый слот
	table.insert(self.inventorySlots, { id = itemId, count = count })
	return true
end

---@param itemId string
---@param count number
---@return boolean
function InventoryEntity:removeItem(itemId, count)
	if count <= 0 then
		return false
	end

	for i, slot in ipairs(self.inventorySlots) do
		if slot.id == itemId then
			if slot.count >= count then
				slot.count = slot.count - count
				if slot.count == 0 then
					table.remove(self.inventorySlots, i)
				end
				return true
			end
			return false -- Недостаточно предметов
		end
	end
	return false -- Предмет не найден
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
