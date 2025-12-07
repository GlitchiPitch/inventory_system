local Players = game:GetService("Players")
local MetaService = require(script.Parent.Parent.Parent.Parent.Parent)
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
---@param ringsList RingsList
---@param fruitsList FruitsList
---@param bonusIcons table
---@param EquipmentSlotEntity EquipmentSlotEntity
---@param ItemEntity ItemEntity
---@param logger LoggerService
---@return InventoryUI
function InventoryUI.new(
	inventoryClientService,
	amuletsList,
	ringsList,
	fruitsList,
	bootsList,
	bonusIcons,
	EquipmentSlotEntity,
	ItemEntity,
	logger
)
	local self = setmetatable({}, InventoryUI)
	self.inventoryClientService = inventoryClientService
	self.amuletsList = amuletsList
	self.ringsList = ringsList
	self.fruitsList = fruitsList
	self.bonusIcons = bonusIcons
	self.logger = logger
	-- Объединяем списки предметов в один словарь
	self.allItemIcons = {}
	self.allItemBonuses = {}
	for itemName, itemData in pairs(amuletsList) do
		self.allItemIcons[itemName] = itemData.icon
		self.allItemBonuses[itemName] = {
			bonusType = itemData.bonusType,
			bonusValue = itemData.bonusValue,
			rarity = itemData.rarity,
		}
	end
	for itemName, itemData in pairs(ringsList) do
		self.allItemIcons[itemName] = itemData.icon
		self.allItemBonuses[itemName] = {
			bonusType = itemData.bonusType,
			bonusValue = itemData.bonusValue,
			rarity = itemData.rarity,
		}
	end
	for itemName, itemData in pairs(fruitsList) do
		self.allItemIcons[itemName] = itemData.icon
		self.allItemBonuses[itemName] = {
			bonusType = itemData.bonusType,
			bonusValue = itemData.bonusValue,
			rarity = itemData.rarity,
		}
	end

	for itemName, itemData in pairs(bootsList) do
		self.allItemIcons[itemName] = itemData.icon
		self.allItemBonuses[itemName] = {
			bonusType = itemData.bonusType,
			bonusValue = itemData.bonusValue,
			rarity = itemData.rarity,
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
	local player = Players.LocalPlayer
	local UI = player.PlayerGui:WaitForChild("UI")
	local frames = UI.Frames
	self.mainFrame = frames.Inventory.NewMain.body.lists.Accessories
	self.inventoryFrame = self.mainFrame.ScrollingFrame
	self.equipmentFrame = self.mainFrame.EquipmentFrame
	self.slotTemplate = self.mainFrame.ScrollingFrame.Template

	-- Найти кнопку режима удаления
	self.deleteModeButton = self.equipmentFrame:FindFirstChild("DeleteModeButton")
	if self.deleteModeButton then
		self.deleteModeButton.MouseButton1Click:Connect(function()
			self:toggleDeleteMode()
		end)
		self:updateDeleteModeButton()
	end

	self.mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		local visible = self.mainFrame.Visible
		self.isDeleteMode = false
		self:updateDeleteModeButton()
		if visible then
			self.inventoryClientService:requestInventory()
		else
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

function InventoryUI:resetInventory()
	MetaService.Self:Fire("Notification", "Create", "Resetting inventory...", 3, Color3.new(1, 0.5, 0))
	self.inventoryClientService:requestResetInventory()
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
	for _, slotData in ipairs(self.EquipmentSlotEntity.getAllSlots()) do
		local buttonName = "EquipSlot_" .. slotData.name
		local slotButton = self.equipmentFrame:FindFirstChild(buttonName)

		local slot =
			self.EquipmentSlotEntity.new(slotData.name, slotData.displayName, slotData.allowedItemTypes, slotButton)

		-- Подключаем обработчик клика для снятия экипировки
		if slotButton then
			slotButton.MouseButton1Click:Connect(function()
				self:onEquipmentSlotClicked(slotData.name)
			end)
		end

		table.insert(self.equipmentSlots, slot)
	end
end

function InventoryUI:createSlots(inventoryData)
	-- Очищаем существующие слоты перед созданием новых
	self:clearSlots()

	-- Получаем данные игрока для проверки экипированного фрукта
	local playerData = MetaService.Data
	local equippedFruit = playerData and playerData.Fruit or ""

	-- Если есть экипированный фрукт и его нет в инвентаре, добавляем его для отображения
	if equippedFruit ~= "" and not inventoryData.inventorySlots[equippedFruit] then
		inventoryData.inventorySlots[equippedFruit] = { true } -- Добавляем один слот для фрукта
	end

	local slotIndex = 0
	for itemName, itemSlots in pairs(inventoryData.inventorySlots) do
		-- Для каждого экземпляра предмета создаем отдельный слот
		for i, _ in ipairs(itemSlots) do
			slotIndex = slotIndex + 1
			local slot = self.slotTemplate:Clone()
			local rarityColor = MetaService.Utils.Colors:GetRarityColor3(self.allItemBonuses[itemName].rarity)
			slot.BackgroundColor3 = rarityColor
			slot.BackgroundTransparency = 0
			slot.RaritySymbol.BackgroundColor3 = rarityColor
			slot.RarityBackground.BackgroundColor3 = rarityColor:Lerp(Color3.new(0, 0, 0), 0.5)
			slot.RarityBackground.ImageColor3 = rarityColor:Lerp(Color3.new(0, 0, 0), 0.5)
			slot.RaritySymbol.TextLabel.Text = self.allItemBonuses[itemName].rarity
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

				-- Дополнительная проверка для фруктов: если фрукт экипирован в playerData.Fruit
				if not isEquipped and equippedFruit ~= "" and itemName == equippedFruit then
					isEquipped = true
				end

				checkmark.Visible = isEquipped
			end

			-- Устанавливаем иконку и значение бонуса
			local bonusData = self.allItemBonuses[itemName]
			if bonusData then
				local bonusIconLabel = slot:FindFirstChild("BonusIconLabel")
				if bonusIconLabel then
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
	-- Обработчик обновления инвентаря
	self.inventoryClientService:setOnInventoryUpdated(function(inventoryData)
		self:createSlots(inventoryData)
		self:updateEquipmentSlots()
		self:updateSlotsInfoLabel()
	end)

	-- Обработчик успешной экипировки
	self.inventoryClientService:setOnItemEquipped(function(itemId, slotName)
		self:onItemEquipped(itemId)
	end)

	-- Обработчик снятия экипировки
	local remoteEventService = self.inventoryClientService.remoteEventService
	remoteEventService:connectToEvent("ItemUnequipped", function(args)
		self:onItemUnequipped(args.slotId)
	end)
end

function InventoryUI:onSlotClicked(slotId)
	if self.isEquipmentWindowOpen then
		return
	end

	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData then
		return
	end

	-- Извлекаем имя предмета из slotId (убираем "_номер")
	local itemName = string.match(slotId, "^(.+)_%d+$")
	if not itemName then
		return
	end

	if self.isDeleteMode then
		-- Режим удаления - удаляем один экземпляр предмета
		self:deleteItem(itemName, 1)
	else
		-- Обычный режим - экипировка/снятие
		-- Сбрасываем выделение всех UI слотов
		for _, slotButton in pairs(self.itemSlots) do
			slotButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
		end

		-- Выделяем текущий слот
		if self.itemSlots[slotId] then
			self.itemSlots[slotId].BorderColor3 = Color3.fromRGB(255, 255, 0) -- Желтая рамка для выделения
		end

		-- Проверяем, экипирован ли уже этот конкретный слот
		local isEquipped = false
		local equippedSlotName = nil
		if inventoryData.equippedItems then
			for slotName, equippedSlotId in pairs(inventoryData.equippedItems) do
				if equippedSlotId == slotId then
					isEquipped = true
					equippedSlotName = slotName
					break
				end
			end
		end

		if isEquipped then
			-- Этот слот экипирован, снимаем его
			self.inventoryClientService:requestUnequipItem(equippedSlotName)
		else
			-- Этот слот не экипирован, ищем свободный слот экипировки
			local itemType = self.inventoryClientService:getItemType(itemName)
			local freeSlot = self:findFreeEquipmentSlot(itemType)
			if freeSlot then
				-- Отправляем запрос на экипировку этого конкретного слота
				self.inventoryClientService:requestEquipItem(slotId, freeSlot:getName())
			else
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
		return nil
	end

	-- Специальная логика выбора слота в зависимости от типа предмета
	if itemType == "ring" then
		-- Кольца экипируются в левую руку в первую очередь (как на сервере)
		local leftHandSlot = self.EquipmentSlotEntity.LEFT_HAND
		local leftHandName = leftHandSlot:getName()
		local isLeftHandFree = not inventoryData.equippedItems[leftHandName]
		if isLeftHandFree and leftHandSlot:canEquipItemType(itemType) then
			return leftHandSlot
		end
		-- Если левая рука занята, пробуем правую
		local rightHandSlot = self.EquipmentSlotEntity.RIGHT_HAND
		local rightHandName = rightHandSlot:getName()
		local isRightHandFree = not inventoryData.equippedItems[rightHandName]
		if isRightHandFree and rightHandSlot:canEquipItemType(itemType) then
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
		-- Для других типов предметов (amulet) используем стандартную логику
		local allSlots = self.EquipmentSlotEntity.getAllSlots()

		-- Ищем первый свободный слот, совместимый с типом предмета
		for _, slot in ipairs(allSlots) do
			local slotName = slot:getName()
			local isSlotFree = not inventoryData.equippedItems[slotName]
			local canEquip = slot:canEquipItemType(itemType)
			if isSlotFree and canEquip then
				return slot
			end
		end
	end

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
	-- Находим конкретный UI слот и показываем Checkmark
	local slotButton = self.itemSlots[slotId]
	if slotButton then
		local checkmark = slotButton:FindFirstChild("Checkmark")
		if checkmark then
			checkmark.Visible = true
		else
		end
	else
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
		return
	end

	-- Получаем все доступные иконки предметов
	local allItemIcons = self.allItemIcons

	for _, slotEntity in ipairs(self.equipmentSlots) do
		local slotName = slotEntity:getName()
		local slotButton = slotEntity.slotButton
		local equippedIcon = slotButton and slotButton:FindFirstChild("EquippedIcon")
		local equippedItemId = inventoryData.equippedItems[slotName]

		if equippedIcon then
			if equippedItemId then
				-- Извлекаем имя предмета из equippedItemId (убираем "_номер")
				local itemName = string.match(equippedItemId, "^(.+)_%d+$")
				-- Получаем иконку предмета по имени
				local itemIconId = itemName and allItemIcons[itemName] or "0"
				equippedIcon.Image = itemIconId or ""
				slotButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120) -- Выделяем занятые слоты
				slotButton.TextTransparency = 1 -- Полупрозрачный текст для занятых слотов
			else
				equippedIcon.Image = ""
				slotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Пустые слоты
				slotButton.TextTransparency = 0 -- Обычная прозрачность для пустых слотов
			end
		else
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
