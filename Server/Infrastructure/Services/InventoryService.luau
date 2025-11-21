---@class InventoryService
---@field inventoryRepository InventoryRepository
---@field itemDefinitions table<string, ItemEntity>?
---@field EquipmentSlot EquipmentSlotEntity?
local InventoryService = {}
InventoryService.__index = InventoryService

---@param inventoryRepository InventoryRepository
---@param itemDefinitions table<string, ItemEntity>?
---@param EquipmentSlot EquipmentSlotEntity?
---@return InventoryService
function InventoryService.new(inventoryRepository, itemDefinitions, EquipmentSlot)
    local self = setmetatable({}, InventoryService)
    self.inventoryRepository = inventoryRepository
    self.itemDefinitions = itemDefinitions or {}
    self.EquipmentSlot = EquipmentSlot
    return self
end

---@param userId string
---@return InventoryEntity?
function InventoryService:getPlayerInventory(userId)
    print("InventoryService: Getting inventory for userId:", userId)
    local inventory = self.inventoryRepository:getByPlayerId(userId)
    print("InventoryService: Retrieved inventory:", inventory)
    return inventory
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean, string?
function InventoryService:addItem(userId, itemId, count)
    if count <= 0 then
        return false, "Invalid item count"
    end

    -- Валидация предмета (если есть определения)
    if self.itemDefinitions[itemId] then
        local item = self.itemDefinitions[itemId]
        if item:getMaxStack() > 0 and count > item:getMaxStack() then
            return false, "Item count exceeds maximum stack size"
        end
    end

    local success = self.inventoryRepository:addItemToPlayer(userId, itemId, count)
    if not success then
        return false, "Failed to add item to inventory"
    end

    return true, nil
end

---@param userId string
---@param itemId string
---@param count number
---@return boolean, string?
function InventoryService:removeItem(userId, itemId, count)
    if count <= 0 then
        return false, "Invalid item count"
    end

    local inventory = self.inventoryRepository:getByPlayerId(userId)
    if not inventory then
        return false, "Player inventory not found"
    end

    if inventory:getItemCount(itemId) < count then
        return false, "Insufficient item count"
    end

    local success = self.inventoryRepository:removeItemFromPlayer(userId, itemId, count)
    if not success then
        return false, "Failed to remove item from inventory"
    end

    return true, nil
end

---@param userId string
---@param itemId string
---@param slotName string
---@return boolean, string?
function InventoryService:equipItem(userId, itemId, slotName)
    local inventory = self.inventoryRepository:getByPlayerId(userId)
    if not inventory then
        return false, "Player inventory not found"
    end

    -- Проверить, есть ли предмет в инвентаре
    if not inventory:hasItem(itemId) then
        return false, "Item not found in inventory"
    end

    warn(inventory, userId, itemId, slotName)
    -- Получить слот экипировки
    local slot = self.EquipmentSlot.getByName(slotName)
    if not slot then
        return false, "Invalid equipment slot"
    end

    -- Валидация типа предмета (если есть определения)
    if self.itemDefinitions[itemId] then
        local item = self.itemDefinitions[itemId]
        if not item:canBeEquipped() then
            return false, "Item cannot be equipped"
        end

        if not slot:canEquipItemType(item:getType()) then
            return false, "Item type not allowed in this slot"
        end

        -- Проверить, что предмет подходит для этого слота
        if item:getEquipmentSlot() and item:getEquipmentSlot():getName() ~= slotName then
            return false, "Item can only be equipped in specific slot"
        end
    else
        -- Базовая проверка для предметов без определений
        if not slot:canEquipItemType("weapon") then
            return false, "Only weapons can be equipped"
        end
    end

    local success = self.inventoryRepository:equipItem(userId, itemId, slot)
    if not success then
        return false, "Failed to equip item"
    end

    return true, nil
end

---@param userId string
---@param slotName string
---@return boolean, string?
function InventoryService:unequipItem(userId, slotName)
    local inventory = self.inventoryRepository:getByPlayerId(userId)
    if not inventory then
        return false, "Player inventory not found"
    end

    -- Получить слот экипировки
    local slot = self.EquipmentSlot.getByName(slotName)
    if not slot then
        return false, "Invalid equipment slot"
    end

    -- Проверить, есть ли что-то в слоте
    if not inventory:getEquippedItem(slot) then
        return false, "No item equipped in this slot"
    end

    local success = self.inventoryRepository:unequipItem(userId, slot)
    if not success then
        return false, "Failed to unequip item"
    end

    return true, nil
end

---@param userId string
---@param itemId string
---@return boolean
function InventoryService:hasItem(userId, itemId)
    local inventory = self.inventoryRepository:getByPlayerId(userId)
    return inventory and inventory:hasItem(itemId) or false
end

---@param userId string
---@param itemId string
---@return number
function InventoryService:getItemCount(userId, itemId)
    local inventory = self.inventoryRepository:getByPlayerId(userId)
    return inventory and inventory:getItemCount(itemId) or 0
end

return InventoryService
