---@class InventoryClientService
---@field remoteEventService RemoteEventService
---@field _inventoryData table?
---@field _onInventoryUpdated function?
---@field _onItemEquipped function?
local InventoryClientService = {}
InventoryClientService.__index = InventoryClientService

---@param remoteEventService RemoteEventService
---@param logger LoggerService
---@return InventoryClientService
function InventoryClientService.new(remoteEventService, amuletsList, ringsList, fruitsList, bootsList, logger)
	local self = setmetatable({}, InventoryClientService)
	self.remoteEventService = remoteEventService
	self._inventoryData = nil
	self._onInventoryUpdated = nil
	self._onItemEquipped = nil
	self._amuletsList = amuletsList
	self._ringsList = ringsList
	self._fruitsList = fruitsList
	self._bootsList = bootsList
	self.logger = logger
	self:setupEventHandlers()
	return self
end

function InventoryClientService:setupEventHandlers()
	-- Обработчик обновления инвентаря
	self.remoteEventService:connectToEvent("InventoryUpdated", function(args)
		self._inventoryData = args
		if self._onInventoryUpdated then
			self._onInventoryUpdated(self._inventoryData)
		else
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

	-- Обработчик сброса инвентаря
	self.remoteEventService:connectToEvent("InventoryReset", function(args)
		-- Очистить локальные данные
		self._inventoryData = nil
	end)

	-- Обработчик успешной экипировки
	self.remoteEventService:connectToEvent("ItemEquipped", function(args)
		-- Обновляем локальные данные equippedItems
		if self._inventoryData and self._inventoryData.equippedItems then
			self._inventoryData.equippedItems[args.slotName] = args.slotId
		end

		if self._onItemEquipped then
			self._onItemEquipped(args.slotId, args.slotName)
		else
		end
	end)

	-- Обработчик успешного снятия экипировки
	self.remoteEventService:connectToEvent("ItemUnequipped", function(args)
		-- Обновляем локальные данные equippedItems
		if self._inventoryData and self._inventoryData.equippedItems then
			-- Находим и удаляем slotId из equippedItems
			for slotName, equippedSlotId in pairs(self._inventoryData.equippedItems) do
				if equippedSlotId == args.slotId then
					self._inventoryData.equippedItems[slotName] = nil
					break
				end
			end
		end

		if self._onItemUnequipped then
			self._onItemUnequipped(args.slotId)
		end
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

---@param slotId string
---@param slotName string
function InventoryClientService:requestEquipItem(slotId, slotName)
	self.remoteEventService:fireServer("EquipItem", {
		slotId = slotId,
		slotName = slotName,
	})
end

---@param slotName string
function InventoryClientService:requestUnequipItem(slotName)
	self.remoteEventService:fireServer("UnequipItem", {
		slotName = slotName,
	})
end

--- Запросить сброс инвентаря
function InventoryClientService:requestResetInventory()
	self.remoteEventService:fireServer("ResetInventory", {})
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

---@param callback function(itemId: string, slotName: string)
function InventoryClientService:setOnItemEquipped(callback)
	self._onItemEquipped = callback
end

---@param callback function(slotId: string)
function InventoryClientService:setOnItemUnequipped(callback)
	self._onItemUnequipped = callback
end

---@param itemId string
---@return string
function InventoryClientService:getItemType(itemId)
	if self._amuletsList[itemId] then
		return "amulet"
	elseif self._ringsList[itemId] then
		return "ring"
	elseif self._fruitsList[itemId] then
		return "fruit"
	elseif self._bootsList[itemId] then
		return "boots"
	end

	return "weapon" -- по умолчанию
end

return InventoryClientService
