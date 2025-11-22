---@class InventoryClientService
---@field remoteEventService RemoteEventService
---@field _inventoryData table?
---@field _onInventoryUpdated function?
local InventoryClientService = {}
InventoryClientService.__index = InventoryClientService

---@param remoteEventService RemoteEventService
---@return InventoryClientService
function InventoryClientService.new(remoteEventService)
	local self = setmetatable({}, InventoryClientService)
	self.remoteEventService = remoteEventService
	self._inventoryData = nil
	self._onInventoryUpdated = nil

	self:setupEventHandlers()
	return self
end

function InventoryClientService:setupEventHandlers()
	-- Обработчик обновления инвентаря
	self.remoteEventService:connectToEvent("InventoryUpdated", function(args)
		self._inventoryData = args
		if self._onInventoryUpdated then
			self._onInventoryUpdated(self._inventoryData)
		end
	end)

	-- Обработчик ошибок
	self.remoteEventService:connectToEvent("Error", function(args)
	end)

	-- Обработчик успешного добавления предмета
	self.remoteEventService:connectToEvent("ItemAdded", function(args)
	end)

	-- Обработчик успешного удаления предмета
	self.remoteEventService:connectToEvent("ItemRemoved", function(args)
	end)

	-- Обработчик успешной экипировки
	self.remoteEventService:connectToEvent("ItemEquipped", function(args)
	end)

	-- Обработчик успешного снятия экипировки
	self.remoteEventService:connectToEvent("ItemUnequipped", function(args)
	end)
end

---@return table?
function InventoryClientService:getInventoryData()
	return self._inventoryData
end

--- Запросить инвентарь с сервера
function InventoryClientService:requestInventory()
	self.remoteEventService:fireServer("GetInventory", {})
end

---@param itemId string
---@param count number?
function InventoryClientService:requestAddItem(itemId, count)
	self.remoteEventService:fireServer("AddItem", {
		itemId = itemId,
		count = count or 1,
	})
end

---@param itemId string
---@param count number?
function InventoryClientService:requestRemoveItem(itemId, count)
	self.remoteEventService:fireServer("RemoveItem", {
		itemId = itemId,
		count = count or 1,
	})
end

---@param itemId string
---@param slotName string
function InventoryClientService:requestEquipItem(itemId, slotName)
	self.remoteEventService:fireServer("EquipItem", {
		itemId = itemId,
		slotName = slotName,
	})
end

---@param slotName string
function InventoryClientService:requestUnequipItem(slotName)
	self.remoteEventService:fireServer("UnequipItem", {
		slotName = slotName,
	})
end

---@param itemId string
---@return number
function InventoryClientService:getItemCount(itemId)
	if not self._inventoryData or not self._inventoryData.inventorySlots then
		return 0
	end

	for _, slot in ipairs(self._inventoryData.inventorySlots) do
		if slot.id == itemId then
			return slot.count
		end
	end
	return 0
end

---@param itemId string
---@return boolean
function InventoryClientService:hasItem(itemId)
	return self:getItemCount(itemId) > 0
end

---@param slotName string
---@return string?
function InventoryClientService:getEquippedItem(slotName)
	if not self._inventoryData or not self._inventoryData.equippedItems then
		return nil
	end

	return self._inventoryData.equippedItems[slotName]
end

---@return table
function InventoryClientService:getInventorySlots()
	if not self._inventoryData or not self._inventoryData.inventorySlots then
		return {}
	end

	return self._inventoryData.inventorySlots
end

---@return table
function InventoryClientService:getEquippedItems()
	if not self._inventoryData or not self._inventoryData.equippedItems then
		return {}
	end

	return self._inventoryData.equippedItems
end

function InventoryClientService:setOnInventoryUpdated(callback)
	self._onInventoryUpdated = callback
end

return InventoryClientService
