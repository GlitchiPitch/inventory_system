local Players = game:GetService("Players")

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
local InventoryUI = {}
InventoryUI.__index = InventoryUI

---@param inventoryClientService InventoryClientService
---@param amuletsList AmuletsList
---@param fruitsList FruitsList
---@param EquipmentSlotEntity EquipmentSlotEntity
---@param ItemEntity ItemEntity
---@return InventoryUI
function InventoryUI.new(inventoryClientService, amuletsList, fruitsList, EquipmentSlotEntity, ItemEntity)
	print("Creating InventoryUI...")
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

	self:createUI()
	self:setupEventHandlers()
	self:setupEquipmentSlots()
	print("InventoryUI created successfully")
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

	self.mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.mainFrame.Visible then
			self.inventoryClientService:requestInventory()
		else
			self.selectedItem = nil
			self:clearSlots()
		end
	end)
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
	warn(inventoryData)

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
	print("Slot clicked:", slotIndex)
	if self.isEquipmentWindowOpen then
		print("Equipment window is open, ignoring slot click")
		return
	end

	-- Сбрасываем выделение всех UI слотов
	for _, slotButton in pairs(self.itemSlots) do
		slotButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
	end

	-- Выделяем текущий слот
	if self.itemSlots[slotIndex] then
		self.itemSlots[slotIndex].BorderColor3 = Color3.fromRGB(255, 255, 0) -- Желтая рамка для выделения
	end

	local inventoryData = self.inventoryClientService:getInventoryData()

	if not inventoryData then
		print("No inventory data available")
		return
	end

	if not inventoryData.inventorySlots then
		print("No inventory slots data available")
		return
	end

	local slotData = inventoryData.inventorySlots[slotIndex]
	if slotData then
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
			print("Attempting to unequip", slotData.id, "from", equippedSlotName)
		else
			-- Предмет не экипирован, ищем свободный слот
			local freeSlot = self:findFreeEquipmentSlot()
			if freeSlot then
				-- Отправляем запрос на экипировку
				self.inventoryClientService:requestEquipItem(slotData.id, freeSlot:getName())
				print("Attempting to equip", slotData.id, "to", freeSlot:getName())
			else
				print("No free equipment slot available for item", slotData.id)
			end
		end
	else
		print("No item data found for slot", slotIndex)
	end
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
		print("Equipping", self.draggedItem.id, "to", slotName)
		return
	end

	-- Обычный клик - проверить, есть ли предмет в слоте
	local inventoryData = self.inventoryClientService:getInventoryData()
	if inventoryData and inventoryData.equippedItems then
		local equippedItemId = inventoryData.equippedItems[slotName]
		if equippedItemId then
			-- Есть предмет в слоте - снимаем его
			self.inventoryClientService:requestUnequipItem(slotName)
			print("Unequipping item from", slotName)
		end
	end
end

function InventoryUI:onItemEquipped(itemId)
	print("Item equipped:", itemId)

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
	print("Item unequipped:", itemId)

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

return InventoryUI
