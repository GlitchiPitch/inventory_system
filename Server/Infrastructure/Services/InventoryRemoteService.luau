---@class InventoryRemoteService
---@field remoteEventService RemoteEventService
---@field inventoryService InventoryService
---@field logger Logger
local InventoryRemoteService = {}
InventoryRemoteService.__index = InventoryRemoteService

---@param remoteEventService RemoteEventService
---@param inventoryService InventoryService
---@param logger Logger
---@return InventoryRemoteService
function InventoryRemoteService.new(remoteEventService, inventoryService, logger)
    local self = setmetatable({}, InventoryRemoteService)
    self.remoteEventService = remoteEventService
    self.inventoryService = inventoryService
    self.logger = logger

    self:setupEventHandlers()
    return self
end

function InventoryRemoteService:init()
    -- Явная инициализация сервиса (если нужно)
end

function InventoryRemoteService:setupEventHandlers()
    -- Получение инвентаря
    self.remoteEventService:connectToEvent("GetInventory", function(player, _args)
        self:handleGetInventory(player)
    end)

    -- Добавление предмета
    self.remoteEventService:connectToEvent("AddItem", function(player, args)
        self:handleAddItem(player, args)
    end)

    -- Удаление предмета
    self.remoteEventService:connectToEvent("RemoveItem", function(player, args)
        self:handleRemoveItem(player, args)
    end)

    -- Экипировка предмета
    self.remoteEventService:connectToEvent("EquipItem", function(player, args)
        self:handleEquipItem(player, args)
    end)

	-- Снятие предмета
    self.remoteEventService:connectToEvent("UnequipItem", function(player, args)
        self:handleUnequipItem(player, args)
    end)

    -- Сброс инвентаря
    self.remoteEventService:connectToEvent("ResetInventory", function(player, _args)
        self:handleResetInventory(player)
    end)
end

---@param player Player
function InventoryRemoteService:handleGetInventory(player)
    local userId = tostring(player.UserId)

    local inventory = self.inventoryService:getPlayerInventory(userId)

    if inventory then
        local inventoryData = inventory:toDataStructure()
        self.remoteEventService:fireClient(player, "InventoryUpdated", inventoryData)
    else
        self.remoteEventService:fireClient(player, "Error", {message = "Failed to load inventory"})
    end
end

---@param player Player
---@param args table
function InventoryRemoteService:handleAddItem(player, args)
    local userId = tostring(player.UserId)
    local itemId = args.itemId
    local count = args.count or 1

    if not itemId then
        self.remoteEventService:fireClient(player, "Error", {message = "ItemId is required"})
        return
    end

    local success, errorMessage = self.inventoryService:addItem(userId, itemId, count)
    if success then
        self.remoteEventService:fireClient(player, "ItemAdded", {itemId = itemId, count = count})
        -- Отправить обновленный инвентарь
        self:handleGetInventory(player)
    else
        self.remoteEventService:fireClient(player, "Error", {message = errorMessage or "Failed to add item"})
    end
end

---@param player Player
---@param args table
function InventoryRemoteService:handleRemoveItem(player, args)
    local userId = tostring(player.UserId)
    local itemId = args.itemId
    local count = args.count or 1

    if not itemId then
        self.remoteEventService:fireClient(player, "Error", {message = "ItemId is required"})
        return
    end

    local success, errorMessage = self.inventoryService:removeItem(userId, itemId, count)
    if success then
        self.remoteEventService:fireClient(player, "ItemRemoved", {itemId = itemId, count = count})
        -- Отправить обновленный инвентарь
        self:handleGetInventory(player)
    else
        self.remoteEventService:fireClient(player, "Error", {message = errorMessage or "Failed to remove item"})
    end
end

---@param player Player
---@param args table
function InventoryRemoteService:handleEquipItem(player, args)
    local userId = tostring(player.UserId)
    local slotId = args.slotId
    local slotName = args.slotName

    if not slotId or not slotName then
        self.remoteEventService:fireClient(player, "Error", {message = "SlotId and slotName are required"})
        return
    end

    local success, errorMessage = self.inventoryService:equipItem(userId, slotId, slotName)
    if success then
        self.remoteEventService:fireClient(player, "ItemEquipped", {slotId = slotId, slotName = slotName})
        -- Отправить обновленный инвентарь
        self:handleGetInventory(player)
    else
        self.remoteEventService:fireClient(player, "Error", {message = errorMessage or "Failed to equip item"})
    end
end

---@param player Player
---@param args table
function InventoryRemoteService:handleUnequipItem(player, args)
    local userId = tostring(player.UserId)
    local slotName = args.slotName

    if not slotName then
        self.remoteEventService:fireClient(player, "Error", {message = "SlotName is required"})
        return
    end

    local success, unequippedItem = self.inventoryService:unequipItem(userId, slotName)
    if success then
        self.remoteEventService:fireClient(player, "ItemUnequipped", {slotId = unequippedItem or ""})
        -- Отправить обновленный инвентарь
        self:handleGetInventory(player)
    else
        self.remoteEventService:fireClient(player, "Error", {message = unequippedItem or "Failed to unequip item"})
    end
end

---@param player Player
function InventoryRemoteService:handleResetInventory(player)
    local userId = tostring(player.UserId)

    local success = self.inventoryService:resetPlayerInventory(userId)
    if success then
        self.remoteEventService:fireClient(player, "InventoryReset", {})
        -- Отправить обновленный инвентарь
        self:handleGetInventory(player)
    else
        self.remoteEventService:fireClient(player, "Error", {message = "Failed to reset inventory"})
    end
end

return InventoryRemoteService
