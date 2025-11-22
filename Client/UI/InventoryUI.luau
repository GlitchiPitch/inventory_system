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
---@param EquipmentSlotEntity EquipmentSlotEntity
---@param ItemEntity ItemEntity
---@return InventoryUI
function InventoryUI.new(inventoryClientService, amuletsList, fruitsList, EquipmentSlotEntity, ItemEntity)
	local self = setmetatable({}, InventoryUI)
	self.inventoryClientService = inventoryClientService
	self.amuletsList = amuletsList
	self.fruitsList = fruitsList

	-- Объединяем списки предметов в один словарь
	self.allItemIcons = {}
	for itemName, iconId in pairs(amuletsList) do
		self.allItemIcons[itemName] = iconId
	end
	for itemName, iconId in pairs(fruitsList) do
		self.allItemIcons[itemName] = iconId
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
	self.deleteModeButton = self.mainFrame:FindFirstChild("DeleteModeButton")
	if self.deleteModeButton then
		self.deleteModeButton.MouseButton1Click:Connect(function()
			self:toggleDeleteMode()
		end)
		self:updateDeleteModeButton()
	end

	-- Найти TextLabel для информации о слотах
	self.slotsInfoLabel = self.mainFrame:FindFirstChild("SlotsInfoLabel")

	self.mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.mainFrame.Visible then
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
		MetaService.Self:Fire(
			"Notification",
			"Create",
			"Delete mode disabled",
			3,
			Color3.new(0, 1, 0)
		)
	end
end

function InventoryUI:updateDeleteModeButton()
	if not self.deleteModeButton then return end

	if self.isDeleteMode then
		self.deleteModeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Красный для режима удаления
		self.deleteModeButton.Text = "Exit Delete Mode"
	else
		self.deleteModeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Серый для обычного режима
		self.deleteModeButton.Text = "Delete Mode"
	end
end

function InventoryUI:setupEquipmentSlots()
	for _, slotData in ipairs(self.EquipmentSlotEntity.getAllSlots()) do
		local slotButton = self.equipmentFrame:FindFirstChild("EquipSlot_" .. slotData.name)
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

	for slotName, slotData in pairs(inventoryData.inventorySlots) do
		local slot = self.slotTemplate:Clone()
		slot.Name = slotName
		slot.CountLabel.Text = slotData.count
		slot.Parent = self.inventoryFrame
		slot.ItemNameLabel.Text = slotName
		slot.ItemIcon.Image = `rbxassetid://{self.allItemIcons[slotName] or 0}`
		slot.Visible = true

		-- Проверяем, экипирован ли предмет, и показываем Checkmark
		local currentInventoryData = self.inventoryClientService:getInventoryData()
		local checkmark = slot:FindFirstChild("Checkmark")
		if checkmark then
			local isEquipped = false
			if currentInventoryData and currentInventoryData.equippedItems then
				for _, equippedItemId in pairs(currentInventoryData.equippedItems) do
					if equippedItemId == slotName then
						isEquipped = true
						break
					end
				end
			end
			checkmark.Visible = isEquipped
		end

		slot.MouseButton1Click:Connect(function()
			self:onSlotClicked(slotName) -- Передаем индекс вместо имени
		end)

		local item = self.ItemEntity.new(slotName, slotName, "weapon", slot)
		table.insert(self.inventorySlots, item)
		table.insert(self.itemSlots, slot) -- Добавляем UI слот в массив
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
	local remoteEventService = self.inventoryClientService.remoteEventService
	remoteEventService:connectToEvent("ItemEquipped", function(args)
		self:onItemEquipped(args.itemId)
	end)

	-- Обработчик снятия экипировки
	remoteEventService:connectToEvent("ItemUnequipped", function(args)
		self:onItemUnequipped(args.itemId)
	end)
end

function InventoryUI:onSlotClicked(slotIndex)
	if self.isEquipmentWindowOpen then
		return
	end

	local inventoryData = self.inventoryClientService:getInventoryData()

	if not inventoryData then
		return
	end

	if not inventoryData.inventorySlots then
		return
	end

	local slotData = inventoryData.inventorySlots[slotIndex]
	if slotData then
		if self.isDeleteMode then
			-- Режим удаления - удаляем предмет
			self:deleteItem(slotData.id, slotData.count)
		else
			-- Обычный режим - экипировка/снятие
			-- Сбрасываем выделение всех UI слотов
			for _, slotButton in pairs(self.itemSlots) do
				slotButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
			end

			-- Выделяем текущий слот
			if self.itemSlots[slotIndex] then
				self.itemSlots[slotIndex].BorderColor3 = Color3.fromRGB(255, 255, 0) -- Желтая рамка для выделения
			end

			-- Проверяем, экипирован ли уже этот предмет
			local isEquipped = false
			local equippedSlotName = nil
			if inventoryData.equippedItems then
				for slotName, equippedItemId in pairs(inventoryData.equippedItems) do
					if equippedItemId == slotData.id then
						isEquipped = true
						equippedSlotName = slotName
						break
					end
				end
			end

			if isEquipped then
				-- Предмет уже экипирован, снимаем его
				self.inventoryClientService:requestUnequipItem(equippedSlotName)
			else
				-- Предмет не экипирован, ищем свободный слот
				local freeSlot = self:findFreeEquipmentSlot()
				if freeSlot then
					-- Отправляем запрос на экипировку
					self.inventoryClientService:requestEquipItem(slotData.id, freeSlot:getName())
				else
					print("No free equipment slot available for item", slotData.id)
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
end

function InventoryUI:deleteItem(itemId, count)
	if count <= 0 then return end

	-- Отправляем запрос на удаление предмета
	self.inventoryClientService:requestRemoveItem(itemId, count)

	MetaService.Self:Fire(
		"Notification",
		"Create",
		`Removed {count}x {itemId}`,
		3,
		Color3.new(1, 0.5, 0)
	)
end

function InventoryUI:findFreeEquipmentSlot() -- itemId зарезервировано для будущей логики определения типа предмета
	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData or not inventoryData.equippedItems then
		return nil
	end

	-- Получаем все доступные слоты экипировки
	local allSlots = self.EquipmentSlotEntity.getAllSlots()

	-- Ищем первый свободный слот, совместимый с типом предмета
	for _, slot in ipairs(allSlots) do
		local slotName = slot:getName()
		if not inventoryData.equippedItems[slotName] then
			-- Для базовой логики считаем, что все предметы типа "weapon"
			-- и совместимы со всеми слотами
			if slot:canEquipItemType("weapon") then
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

function InventoryUI:onItemEquipped(itemId)
	-- Находим UI слот инвентаря с этим предметом и показываем Checkmark
	for _, slotButton in pairs(self.itemSlots) do
		local itemNameLabel = slotButton:FindFirstChild("ItemNameLabel")
		if itemNameLabel and itemNameLabel.Text == itemId then
			local checkmark = slotButton:FindFirstChild("Checkmark")
			if checkmark then
				checkmark.Visible = true
			end
			break
		end
	end

	-- Обновляем слоты экипировки
	self:updateEquipmentSlots()
end

function InventoryUI:onItemUnequipped(itemId)
	-- Находим UI слот инвентаря с этим предметом и скрываем Checkmark
	for _, slotButton in pairs(self.itemSlots) do
		local itemNameLabel = slotButton:FindFirstChild("ItemNameLabel")
		if itemNameLabel and itemNameLabel.Text == itemId then
			local checkmark = slotButton:FindFirstChild("Checkmark")
			if checkmark then
				checkmark.Visible = false
			end
			break
		end
	end

	-- Обновляем слоты экипировки
	self:updateEquipmentSlots()
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
				-- Получаем иконку предмета
				local itemIconId = allItemIcons[equippedItemId] or "0"
				equippedIcon.Image = `rbxassetid://{itemIconId}`
				slotButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120) -- Выделяем занятые слоты
				slotButton.TextTransparency = 1 -- Полупрозрачный текст для занятых слотов
			else
				equippedIcon.Image = ""
				slotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Пустые слоты
				slotButton.TextTransparency = 0 -- Обычная прозрачность для пустых слотов
			end
		end
	end
end

function InventoryUI:updateSlotsInfoLabel()
	if not self.slotsInfoLabel then return end

	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData or not inventoryData.inventorySlots then
		self.slotsInfoLabel.Text = "Slots: 0/50"
		return
	end

	local usedSlots = #inventoryData.inventorySlots
	local maxSlots = 50 -- Можно получить из InventoryEntity если понадобится
	local freeSlots = maxSlots - usedSlots

	self.slotsInfoLabel.Text = `Slots: {usedSlots}/{maxSlots} ({freeSlots} free)`
end

return InventoryUI
