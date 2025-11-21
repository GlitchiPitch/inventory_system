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
		local slot = self.EquipmentSlotEntity.new(slotData.name, slotData.displayName, slotData.allowedItemTypes, slotButton)
		table.insert(self.equipmentSlots, slot)
	end
end

function InventoryUI:createSlots(inventoryData)
	warn(inventoryData)
	self.itemSlots = {} -- Инициализируем массив UI слотов

	for i, slotData in ipairs(inventoryData.inventorySlots) do
		local slot = self.slotTemplate:Clone()
		slot.Name = slotData.id
		slot.CountLabel.Text = slotData.count
		slot.Parent = self.inventoryFrame
		slot.ItemNameLabel.Text = slotData.id
		slot.ItemIcon.Image = `rbxassetid://{self.amuletsList[slotData.id] or 0}`
		slot.Visible = true

		-- Проверяем, экипирован ли предмет, и показываем Checkmark
		local currentInventoryData = self.inventoryClientService:getInventoryData()
		local checkmark = slot:FindFirstChild("Checkmark")
		if checkmark then
			local isEquipped = false
			if currentInventoryData and currentInventoryData.equippedItems then
				for _, equippedItemId in pairs(currentInventoryData.equippedItems) do
					if equippedItemId == slotData.id then
						isEquipped = true
						break
					end
				end
			end
			checkmark.Visible = isEquipped
		end

		slot.MouseButton1Click:Connect(function()
			self:onSlotClicked(i) -- Передаем индекс вместо имени
		end)

		local item = self.ItemEntity.new(slotData.id, slotData.id, "weapon", slot)
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

function InventoryUI:findFreeEquipmentSlot(itemId) -- itemId зарезервировано для будущей логики определения типа предмета
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
