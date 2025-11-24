local Players = game:GetService("Players")
local MetaService = require(game.StarterPlayer.StarterPlayerScripts.MetaService)
---@class InventoryUI
---@field screenGui ScreenGui
---@field mainFrame Frame
---@field inventoryFrame Frame
---@field equipmentFrame Frame
---@field selectedItem table?
---@field isEquipmentWindowOpen boolean
---@field inventoryClientService InventoryClientService
---@field inventorySlots table
---@field equipmentSlots table
---@field equipButton TextButton?
---@field EquipmentSlotEntity EquipmentSlotEntity
---@field ItemEntity ItemEntity
---@field draggedItem table?
---@field dragIcon ImageLabel?
---@field isDeleteMode boolean
---@field deleteModeButton TextButton?
---@field slotsInfoLabel TextLabel?
local InventoryUI = {}
InventoryUI.__index = InventoryUI

---@param inventoryClientService InventoryClientService
---@param amuletsList AmuletsList
---@param fruitsList FruitsList
---@param ringsList RingsList
---@param bonusIcons table
---@param EquipmentSlotEntity EquipmentSlotEntity
---@param ItemEntity ItemEntity
---@param logger LoggerService
---@return InventoryUI
function InventoryUI.new(inventoryClientService, amuletsList, fruitsList, ringsList, bonusIcons, EquipmentSlotEntity, ItemEntity, logger)
	local self = setmetatable({}, InventoryUI)
	self.inventoryClientService = inventoryClientService
	self.amuletsList = amuletsList
	self.fruitsList = fruitsList
	self.ringsList = ringsList
	self.bonusIcons = bonusIcons
	self.logger = logger
	-- Объединяем списки предметов в один словарь
	self.allItemIcons = {}
	self.allItemBonuses = {}
	for itemName, itemData in pairs(amuletsList) do
		self.allItemIcons[itemName] = itemData.icon
		self.allItemBonuses[itemName] = {
			bonusType = itemData.bonusType,
			bonusValue = itemData.bonusValue
		}
	end
	for itemName, itemData in pairs(fruitsList) do
		self.allItemIcons[itemName] = itemData.icon
		self.allItemBonuses[itemName] = {
			bonusType = itemData.bonusType,
			bonusValue = itemData.bonusValue
		}
	end
	for itemName, itemData in pairs(ringsList) do
		self.allItemIcons[itemName] = itemData.icon
		self.allItemBonuses[itemName] = {
			bonusType = itemData.bonusType,
			bonusValue = itemData.bonusValue
		}
	end

	self.selectedItem = nil
	self.isEquipmentWindowOpen = false
	self.EquipmentSlotEntity = EquipmentSlotEntity
	self.ItemEntity = ItemEntity
	self.inventorySlots = {}
	self.itemSlots = {}
	self.equipmentSlots = {}
	self.draggedItem = nil
	self.isDeleteMode = false

	self:createUI()
	self:setupEventHandlers()
	self:setupEquipmentSlots()
	return self
end

function InventoryUI:createUI()
	self.logger:info("InventoryUI", "Creating UI elements")
	local player = Players.LocalPlayer
	local UI = player.PlayerGui:WaitForChild("UI")
	local frames = UI.Frames
	self.mainFrame = frames.Inventory.NewMain.body.lists.Accessories
	self.inventoryFrame = self.mainFrame.ScrollingFrame
	self.equipmentFrame = self.mainFrame.EquipmentFrame
	self.slotTemplate = self.mainFrame.ScrollingFrame.Template

	self.logger:debug("InventoryUI", "UI elements created - mainFrame:", self.mainFrame and "found" or "not found")

	-- Найти кнопку режима удаления
	self.deleteModeButton = self.equipmentFrame:FindFirstChild("DeleteModeButton")
	if self.deleteModeButton then
		self.logger:debug("InventoryUI", "DeleteModeButton found, connecting click handler")
		self.deleteModeButton.MouseButton1Click:Connect(function()
			self:toggleDeleteMode()
		end)
		self:updateDeleteModeButton()
	else
		self.logger:warn("InventoryUI", "DeleteModeButton not found")
	end

	-- Найти TextLabel для информации о слотах
	self.slotsInfoLabel = self.mainFrame:FindFirstChild("SlotsInfoLabel")
	if self.slotsInfoLabel then
		self.logger:debug("InventoryUI", "SlotsInfoLabel found")
	else
		self.logger:warn("InventoryUI", "SlotsInfoLabel not found")
	end

	self.mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		local visible = self.mainFrame.Visible
		self.logger:info("InventoryUI", "Inventory visibility changed to:", visible)
		self.isDeleteMode = false
		self:updateDeleteModeButton()
		if visible then
			self.logger:info("InventoryUI", "Inventory opened, requesting inventory data")
			self.inventoryClientService:requestInventory()
		else
			self.logger:info("InventoryUI", "Inventory closed, clearing slots")
			self.selectedItem = nil
			self:clearSlots()
			-- Сбросить режим удаления при закрытии инвентаря
			if self.isDeleteMode then
				self:toggleDeleteMode()
			end
		end
	end)
end

function InventoryUI:toggleDeleteMode()
	self.isDeleteMode = not self.isDeleteMode
	self:updateDeleteModeButton()

	if self.isDeleteMode then
		MetaService.Self:Fire(
			"Notification",
			"Create",
			"Delete mode enabled - click items to remove them",
			3,
			Color3.new(1, 0.5, 0)
		)
	else
		MetaService.Self:Fire("Notification", "Create", "Delete mode disabled", 3, Color3.new(0, 1, 0))
	end
end

function InventoryUI:updateDeleteModeButton()
	if self.isDeleteMode then
		self.deleteModeButton.ImageLabel.ImageTransparency = 0
		self.deleteModeButton.TextLabel.Visible = true
	else
		self.deleteModeButton.ImageLabel.ImageTransparency = 0.5
		self.deleteModeButton.TextLabel.Visible = false
	end
end

function InventoryUI:setupEquipmentSlots()
	self.logger:info("InventoryUI", "Setting up equipment slots")
	for _, slotData in ipairs(self.EquipmentSlotEntity.getAllSlots()) do
		local buttonName = "EquipSlot_" .. slotData.name
		local slotButton = self.equipmentFrame:FindFirstChild(buttonName)
		self.logger:info("InventoryUI", "Looking for slot button:", buttonName, "found:", slotButton ~= nil)

		local slot =
			self.EquipmentSlotEntity.new(slotData.name, slotData.displayName, slotData.allowedItemTypes, slotButton)

		-- Подключаем обработчик клика для снятия экипировки
		if slotButton then
			slotButton.MouseButton1Click:Connect(function()
				self:onEquipmentSlotClicked(slotData.name)
			end)
			self.logger:info("InventoryUI", "Connected click handler for slot:", slotData.name)
		else
			self.logger:warn("InventoryUI", "Slot button not found for:", slotData.name)
		end

		table.insert(self.equipmentSlots, slot)
	end
	self.logger:info("InventoryUI", "Equipment slots setup complete, total slots:", #self.equipmentSlots)
end

function InventoryUI:createSlots(inventoryData)
	-- Очищаем существующие слоты перед созданием новых
	self:clearSlots()

	local slotIndex = 0
	for itemName, itemSlots in pairs(inventoryData.inventorySlots) do
		-- Для каждого экземпляра предмета создаем отдельный слот
		for i, _ in ipairs(itemSlots) do
			slotIndex = slotIndex + 1
			local slot = self.slotTemplate:Clone()
			local slotId = itemName .. "_" .. i -- Уникальный ID для каждого слота
			slot.Name = slotId
			slot.CountLabel.Text = "1" -- Каждый слот содержит 1 экземпляр
			slot.Parent = self.inventoryFrame
			slot.ItemNameLabel.Text = itemName
			slot.ItemIcon.Image = self.allItemIcons[itemName] or ""
			slot.Visible = true

			-- Проверяем, экипирован ли этот конкретный слот, и показываем Checkmark
			local currentInventoryData = self.inventoryClientService:getInventoryData()
			local checkmark = slot:FindFirstChild("Checkmark")
			if checkmark then
				local isEquipped = false
				if currentInventoryData and currentInventoryData.equippedItems then
					for _, equippedSlotId in pairs(currentInventoryData.equippedItems) do
						if equippedSlotId == slotId then
							isEquipped = true
							break
						end
					end
				end
				checkmark.Visible = isEquipped
			end

			-- Устанавливаем иконку и значение бонуса
			local bonusData = self.allItemBonuses[itemName]
			if bonusData then
				local bonusIconLabel = slot:FindFirstChild("BonusIconLabel")
				if bonusIconLabel then
					-- Скрываем bonusIconLabel для фруктов
					if self.fruitsList[itemName] then
						bonusIconLabel.Visible = false
					else
						local bonusIcon = self.bonusIcons[bonusData.bonusType]
						if bonusIcon then
							bonusIconLabel.Image = bonusIcon
							local bonusValueLabel = bonusIconLabel:FindFirstChild("BonusValueLabel")
							if bonusValueLabel then
								bonusValueLabel.Text = "+" .. tostring(bonusData.bonusValue * 100) .. "%"
							end
						end
					end
				end
			end

			slot.MouseButton1Click:Connect(function()
				self:onSlotClicked(slotId) -- Передаем уникальный ID слота
			end)

			local item = self.ItemEntity.new(slotId, itemName, "weapon", slot)
			table.insert(self.inventorySlots, item)
			self.itemSlots[slotId] = slot -- Сохраняем UI слот по уникальному ID
		end
	end
end

function InventoryUI:clearSlots()
	for _, slot in pairs(self.inventorySlots) do
		slot:destroy()
	end
	self.inventorySlots = {}
	self.itemSlots = {}
end

function InventoryUI:setupEventHandlers()
	self.logger:info("InventoryUI", "Setting up event handlers")

	-- Обработчик обновления инвентаря
	self.inventoryClientService:setOnInventoryUpdated(function(inventoryData)
		self.logger:info("InventoryUI", "Inventory updated event received")
		self:createSlots(inventoryData)
		self:updateEquipmentSlots()
		self:updateSlotsInfoLabel()
	end)

	-- Обработчик успешной экипировки
	self.inventoryClientService:setOnItemEquipped(function(itemId, slotName)
		self.logger:info("InventoryUI", "Item equipped event received - itemId:", itemId, "slotName:", slotName)
		self:onItemEquipped(itemId)
	end)

	-- Обработчик снятия экипировки
	local remoteEventService = self.inventoryClientService.remoteEventService
	remoteEventService:connectToEvent("ItemUnequipped", function(args)
		self.logger:info("InventoryUI", "Item unequipped event received - slotId:", args.slotId)
		self:onItemUnequipped(args.slotId)
	end)
end

function InventoryUI:onSlotClicked(slotId)
	self.logger:info("InventoryUI", "onSlotClicked called with slotId:", slotId)

	if self.isEquipmentWindowOpen then
		self.logger:info("InventoryUI", "Equipment window is open, ignoring slot click")
		return
	end

	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData then
		self.logger:warn("InventoryUI", "No inventory data available")
		return
	end

	-- Извлекаем имя предмета из slotId (убираем "_номер")
	local itemName = string.match(slotId, "^(.+)_%d+$")
	if not itemName then
		self.logger:error("InventoryUI", "Failed to extract itemName from slotId:", slotId)
		return
	end

	self.logger:info("InventoryUI", "Processing click for item:", itemName, "from slot:", slotId)

	if self.isDeleteMode then
		self.logger:info("InventoryUI", "Delete mode active, deleting item:", itemName)
		-- Режим удаления - удаляем один экземпляр предмета
		self:deleteItem(itemName, 1)
	else
		self.logger:info("InventoryUI", "Normal mode - checking equipment status for slot:", slotId)
		-- Обычный режим - экипировка/снятие
		-- Сбрасываем выделение всех UI слотов
		for _, slotButton in pairs(self.itemSlots) do
			slotButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
		end

		-- Выделяем текущий слот
		if self.itemSlots[slotId] then
			self.itemSlots[slotId].BorderColor3 = Color3.fromRGB(255, 255, 0) -- Желтая рамка для выделения
			self.logger:debug("InventoryUI", "Highlighted slot:", slotId)
		else
			self.logger:warn("InventoryUI", "Slot button not found for slotId:", slotId)
		end

		-- Проверяем, экипирован ли уже этот конкретный слот
		local isEquipped = false
		local equippedSlotName = nil
		if inventoryData.equippedItems then
			self.logger:debug("InventoryUI", "Checking equipped items:", inventoryData.equippedItems)
			for slotName, equippedSlotId in pairs(inventoryData.equippedItems) do
				if equippedSlotId == slotId then
					isEquipped = true
					equippedSlotName = slotName
					break
				end
			end
		else
			self.logger:warn("InventoryUI", "No equippedItems in inventory data")
		end

		if isEquipped then
			self.logger:info("InventoryUI", "Item is equipped in slot:", equippedSlotName, "- requesting unequip")
			-- Этот слот экипирован, снимаем его
			self.inventoryClientService:requestUnequipItem(equippedSlotName)
		else
			self.logger:info("InventoryUI", "Item is not equipped, looking for free slot")
			-- Этот слот не экипирован, ищем свободный слот экипировки
			local itemType = self.inventoryClientService:getItemType(itemName)
			self.logger:debug("InventoryUI", "Item type:", itemType)
			local freeSlot = self:findFreeEquipmentSlot(itemType)
			if freeSlot then
				self.logger:info("InventoryUI", "Found free slot:", freeSlot:getName(), "- requesting equip")
				-- Отправляем запрос на экипировку этого конкретного слота
				self.inventoryClientService:requestEquipItem(slotId, freeSlot:getName())
			else
				self.logger:warn("InventoryUI", "No free equipment slot found for item type:", itemType)
				MetaService.Self:Fire(
					"Notification",
					"Create",
					"No free equipment slot available for item",
					5,
					Color3.new(0.8, 0, 1)
				)
			end
		end
	end
end

function InventoryUI:deleteItem(itemId, count)
	if count <= 0 then
		return
	end

	-- Проверяем, экипирован ли хотя бы один экземпляр этого предмета
	local inventoryData = self.inventoryClientService:getInventoryData()
	if inventoryData and inventoryData.equippedItems then
		for _, equippedSlotId in pairs(inventoryData.equippedItems) do
			-- Извлекаем itemName из equippedSlotId
			local equippedItemName = string.match(equippedSlotId, "^(.+)_%d+$")
			if equippedItemName == itemId then
				-- Предмет экипирован, нельзя удалить
				MetaService.Self:Fire("Notification", "Create", "Cannot delete equipped item", 3, Color3.new(1, 0, 0))
				return
			end
		end
	end

	-- Отправляем запрос на удаление предмета
	self.inventoryClientService:requestRemoveItem(itemId, count)

	MetaService.Self:Fire("Notification", "Create", `Removed {count}x {itemId}`, 3, Color3.new(1, 0.5, 0))
end

function InventoryUI:findFreeEquipmentSlot(itemType)
	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData or not inventoryData.equippedItems then
		self.logger:warn("InventoryUI", "No inventory data or equippedItems available")
		return nil
	end

	self.logger:info("InventoryUI", "Finding free slot for item type:", itemType)

	self.logger:info("InventoryUI", "Current equipped items:", inventoryData.equippedItems)

	-- Специальная логика выбора слота в зависимости от типа предмета
	if itemType == "ring" then
		self.logger:info("InventoryUI", "Looking for slot for ring item")
		-- Кольца экипируются в левую руку в первую очередь (как на сервере)
		local leftHandSlot = self.EquipmentSlotEntity.LEFT_HAND
		local leftHandName = leftHandSlot:getName()
		local isLeftHandFree = not inventoryData.equippedItems[leftHandName]
		self.logger:info("InventoryUI", "Left hand slot:", leftHandName, "is free:", isLeftHandFree)
		if isLeftHandFree and leftHandSlot:canEquipItemType(itemType) then
			self.logger:info("InventoryUI", "Selected left hand slot for ring")
			return leftHandSlot
		end
		-- Если левая рука занята, пробуем правую
		local rightHandSlot = self.EquipmentSlotEntity.RIGHT_HAND
		local rightHandName = rightHandSlot:getName()
		local isRightHandFree = not inventoryData.equippedItems[rightHandName]
		self.logger:info("InventoryUI", "Right hand slot:", rightHandName, "is free:", isRightHandFree)
		if isRightHandFree and rightHandSlot:canEquipItemType(itemType) then
			self.logger:info("InventoryUI", "Selected right hand slot for ring")
			return rightHandSlot
		end
	elseif itemType == "weapon" then
		-- Оружие экипируется в левую руку в первую очередь
		local leftHandSlot = self.EquipmentSlotEntity.LEFT_HAND
		if not inventoryData.equippedItems[leftHandSlot:getName()] and leftHandSlot:canEquipItemType(itemType) then
			return leftHandSlot
		end
		-- Если левая рука занята, пробуем правую
		local rightHandSlot = self.EquipmentSlotEntity.RIGHT_HAND
		if not inventoryData.equippedItems[rightHandSlot:getName()] and rightHandSlot:canEquipItemType(itemType) then
			return rightHandSlot
		end
	else
		self.logger:info("InventoryUI", "Using standard slot selection for item type:", itemType)
		-- Для других типов предметов (amulet) используем стандартную логику
		local allSlots = self.EquipmentSlotEntity.getAllSlots()

		-- Ищем первый свободный слот, совместимый с типом предмета
		for _, slot in ipairs(allSlots) do
			local slotName = slot:getName()
			local isSlotFree = not inventoryData.equippedItems[slotName]
			local canEquip = slot:canEquipItemType(itemType)
			self.logger:info("InventoryUI", "Checking slot:", slotName, "is free:", isSlotFree, "can equip:", canEquip)
			if isSlotFree and canEquip then
				self.logger:info("InventoryUI", "Selected slot:", slotName, "for item type:", itemType)
				return slot
			end
		end
	end

	self.logger:info("InventoryUI", "No free slot found for item type:", itemType)
	return nil
end

function InventoryUI:onEquipmentSlotClicked(slotName)
	if self.draggedItem then
		-- Перетаскивание предмета - экипировать в этот слот
		self.inventoryClientService:requestEquipItem(self.draggedItem.id, slotName)
		MetaService.Self:Fire("Notification", "Create", "Equip" .. self.draggedItem.id, 5, Color3.new(0.8, 0, 1))
		return
	end

	-- Обычный клик - проверить, есть ли предмет в слоте
	local inventoryData = self.inventoryClientService:getInventoryData()
	if inventoryData and inventoryData.equippedItems then
		local equippedItemId = inventoryData.equippedItems[slotName]
		if equippedItemId then
			-- Есть предмет в слоте - снимаем его
			self.inventoryClientService:requestUnequipItem(slotName)
			MetaService.Self:Fire("Notification", "Create", "Unequip" .. equippedItemId, 5, Color3.new(0.8, 0, 1))
		end
	end
end

function InventoryUI:onItemEquipped(slotId)
	self.logger:info("InventoryUI", "Item equipped event for slotId:", slotId)

	-- Находим конкретный UI слот и показываем Checkmark
	local slotButton = self.itemSlots[slotId]
	if slotButton then
		local checkmark = slotButton:FindFirstChild("Checkmark")
		if checkmark then
			self.logger:debug("InventoryUI", "Showing checkmark for slotId:", slotId)
			checkmark.Visible = true
		else
			self.logger:warn("InventoryUI", "Checkmark not found for slotId:", slotId)
		end
	else
		self.logger:warn("InventoryUI", "Slot button not found for slotId:", slotId)
	end

	-- Обновление слотов экипировки происходит в обработчике InventoryUpdated,
	-- чтобы избежать дублирования обновлений и потенциальных несоответствий данных
end

function InventoryUI:onItemUnequipped(slotId)
	-- Находим конкретный UI слот и скрываем Checkmark
	local slotButton = self.itemSlots[slotId]
	if slotButton then
		local checkmark = slotButton:FindFirstChild("Checkmark")
		if checkmark then
			checkmark.Visible = false
		end
	end

	-- Обновление слотов экипировки происходит в обработчике InventoryUpdated,
	-- чтобы избежать дублирования обновлений и потенциальных несоответствий данных
end

function InventoryUI:updateEquipmentSlots()
	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData or not inventoryData.equippedItems then
		self.logger:warn("InventoryUI", "No inventory data for equipment slots update")
		return
	end

	self.logger:info("InventoryUI", "Updating equipment slots with data:", inventoryData.equippedItems)

	-- Получаем все доступные иконки предметов
	local allItemIcons = self.allItemIcons

	for _, slotEntity in ipairs(self.equipmentSlots) do
		local slotName = slotEntity:getName()
		local slotButton = slotEntity.slotButton
		local equippedIcon = slotButton and slotButton:FindFirstChild("EquippedIcon")
		local equippedItemId = inventoryData.equippedItems[slotName]

		self.logger:info("InventoryUI", "Processing slot:", slotName, "button exists:", slotButton ~= nil, "icon exists:", equippedIcon ~= nil, "equippedItemId:", equippedItemId or "none")

		if equippedIcon then
			if equippedItemId then
				-- Извлекаем имя предмета из equippedItemId (убираем "_номер")
				local itemName = string.match(equippedItemId, "^(.+)_%d+$")
				-- Получаем иконку предмета по имени
				local itemIconId = itemName and allItemIcons[itemName] or "0"
				self.logger:info("InventoryUI", "Setting icon for slot", slotName, "item:", itemName, "icon:", itemIconId)
				equippedIcon.Image = itemIconId or ""
				slotButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120) -- Выделяем занятые слоты
				slotButton.TextTransparency = 1 -- Полупрозрачный текст для занятых слотов
			else
				self.logger:info("InventoryUI", "Clearing slot", slotName)
				equippedIcon.Image = ""
				slotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Пустые слоты
				slotButton.TextTransparency = 0 -- Обычная прозрачность для пустых слотов
			end
		else
			self.logger:warn("InventoryUI", "EquippedIcon not found for slot", slotName)
		end
	end
end

function InventoryUI:updateSlotsInfoLabel()
	if not self.slotsInfoLabel then
		return
	end

	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData or not inventoryData.inventorySlots then
		self.slotsInfoLabel.Text = "Slots: 0/50"
		return
	end

	local usedSlots = 0
	for _, itemSlots in pairs(inventoryData.inventorySlots) do
		usedSlots = usedSlots + #itemSlots
	end

	local maxSlots = 50 -- Можно получить из InventoryEntity если понадобится
	local freeSlots = maxSlots - usedSlots

	self.slotsInfoLabel.Text = `Slots: {usedSlots}/{maxSlots} ({freeSlots} free)`
end

return InventoryUI
