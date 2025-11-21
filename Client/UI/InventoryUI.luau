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
---@param EquipmentSlotEntity EquipmentSlotEntity
---@param ItemEntity ItemEntity
---@return InventoryUI
function InventoryUI.new(inventoryClientService, amuletsList, EquipmentSlotEntity, ItemEntity)
	print("Creating InventoryUI...")
	local self = setmetatable({}, InventoryUI)
	self.inventoryClientService = inventoryClientService
	self.amuletsList = amuletsList
	self.selectedItem = nil
	self.isEquipmentWindowOpen = false
	self.EquipmentSlotEntity = EquipmentSlotEntity
	self.ItemEntity = ItemEntity
	self.inventorySlots = {}
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
		local slot = self.EquipmentSlotEntity.new(slotData.name, slotData.displayName, slotData.allowedItemTypes, slotButton)
		table.insert(self.equipmentSlots, slot)
	end
end

function InventoryUI:createSlots(inventoryData)
	warn(inventoryData)
	for name, count in inventoryData.inventorySlots do
		local slot = self.slotTemplate:Clone()
		slot.Name = name
		slot.CountLabel.Text = count
		slot.Parent = self.inventoryFrame
		slot.ItemNameLabel.Text = name
		slot.ItemIcon.Image = `rbxassetid://{self.amuletsList[name]}`
		slot.Visible = true

		-- Проверяем, экипирован ли предмет, и показываем Checkmark
		local currentInventoryData = self.inventoryClientService:getInventoryData()
		local checkmark = slot:FindFirstChild("Checkmark")
		if checkmark then
			local isEquipped = false
			if currentInventoryData and currentInventoryData.equippedItems then
				for _, equippedItemId in pairs(currentInventoryData.equippedItems) do
					if equippedItemId == name then
						isEquipped = true
						break
					end
				end
			end
			checkmark.Visible = isEquipped
		end

		slot.MouseButton1Click:Connect(function()
			self:onSlotClicked(name)
		end)

		local item = self.ItemEntity.new(name, name, "weapon", slot)
		warn(item)  
		table.insert(self.inventorySlots, item)
	end
end

function InventoryUI:clearSlots()
	for _, slot in pairs(self.inventorySlots) do
		slot:destroy()
	end
	self.inventorySlots = {}
end

function InventoryUI:setupEventHandlers()
	-- Обработчик обновления инвентаря
	self.inventoryClientService:setOnInventoryUpdated(function(inventoryData)
		self:createSlots(inventoryData)
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

	-- Сбрасываем выделение всех слотов
	for _, slot in pairs(self.inventorySlots) do
		slot.BorderColor3 = Color3.fromRGB(100, 100, 100)
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

	warn(self.inventorySlots)
	local slotData = self.inventorySlots[slotIndex]
	warn(slotData)
	if slotData then
		-- Находим свободную ячейку экипировки
		local freeSlot = self:findFreeEquipmentSlot(slotData.id)
		if freeSlot then
			-- Отправляем запрос на экипировку
			self.inventoryClientService:requestEquipItem(slotData.id, freeSlot:getName())
			print("Attempting to equip", slotData.id, "to", freeSlot:getName())
		else
			print("No free equipment slot available for item", slotData.id)
		end
	else
		print("No item data found for slot", slotIndex)
	end
end

function InventoryUI:findFreeEquipmentSlot(itemId)
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
	if not self.draggedItem then
		return
	end

	-- Отправляем запрос на экипировку
	self.inventoryClientService:requestEquipItem(self.draggedItem.id, slotName)
	print("Equipping", self.draggedItem.id, "to", slotName)
end

function InventoryUI:updateInventoryDisplay(inventoryData)
	print("Updating inventory display")
	if not inventoryData then
		print("No inventory data provided")
		return
	end

	print("Inventory data received:", inventoryData)
	print("Inventory slots:", inventoryData.inventorySlots)

	-- Очищаем все слоты
	for _, slotButton in pairs(self.itemSlots) do
		local itemIcon = slotButton:FindFirstChild("ItemIcon")
		local countLabel = slotButton:FindFirstChild("CountLabel")
		if itemIcon then
			itemIcon.Image = ""
		end
		if countLabel then
			countLabel.Text = ""
		end
		slotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end

	-- Заполняем слоты предметами
	if inventoryData.inventorySlots then
		print("Processing", #inventoryData.inventorySlots, "inventory slots")
		for i, slotData in ipairs(inventoryData.inventorySlots) do
			print("Processing slot", i, "with item:", slotData.id, "count:", slotData.count)
			if i <= 25 and self.itemSlots[i] then -- 5x5 = 25 слотов
				local itemIcon = self.itemSlots[i]:FindFirstChild("ItemIcon")
				local countLabel = self.itemSlots[i]:FindFirstChild("CountLabel")

				if itemIcon then
					-- Здесь можно добавить логику для получения иконки предмета
					itemIcon.Image = "rbxassetid://0" -- Заглушка
				end

				if countLabel then
					countLabel.Text = tostring(slotData.count)
				end

				self.itemSlots[i].BackgroundColor3 = Color3.fromRGB(70, 70, 70) -- Выделяем занятые слоты
				print("Updated slot", i, "with item", slotData.id)
			else
				print("Slot", i, "out of range or not found")
			end
		end
	else
		print("No inventorySlots in data")
	end

	-- Обновляем слоты экипировки
	self:updateEquipmentSlots()
end

function InventoryUI:onItemEquipped(itemId)
	print("Item equipped:", itemId)

	-- Находим слот инвентаря с этим предметом и показываем Checkmark
	for _, slot in pairs(self.inventorySlots) do
		local itemNameLabel = slot:FindFirstChild("ItemNameLabel")
		if itemNameLabel and itemNameLabel.Text == itemId then
			local checkmark = slot:FindFirstChild("Checkmark")
			if checkmark then
				checkmark.Visible = true
			end
			break
		end
	end
end

function InventoryUI:onItemUnequipped(itemId)
	print("Item unequipped:", itemId)

	-- Находим слот инвентаря с этим предметом и скрываем Checkmark
	for _, slot in pairs(self.inventorySlots) do
		local itemNameLabel = slot:FindFirstChild("ItemNameLabel")
		if itemNameLabel and itemNameLabel.Text == itemId then
			local checkmark = slot:FindFirstChild("Checkmark")
			if checkmark then
				checkmark.Visible = false
			end
			break
		end
	end
end

function InventoryUI:updateEquipmentSlots()
	local inventoryData = self.inventoryClientService:getInventoryData()
	if not inventoryData or not inventoryData.equippedItems then
		return
	end

	for slotName, slotButton in pairs(self.equipmentSlots) do
		local equippedIcon = slotButton:FindFirstChild("EquippedIcon")
		local equippedItemId = inventoryData.equippedItems[slotName]

		if equippedIcon then
			if equippedItemId then
				-- Здесь можно добавить логику для получения иконки предмета
				equippedIcon.Image = "rbxassetid://0" -- Заглушка
				slotButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120) -- Выделяем занятые слоты
			else
				equippedIcon.Image = ""
				slotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Пустые слоты
			end
		end
	end
end

return InventoryUI
