---@class EquipmentSlotEntity   
---@field name string
---@field displayName string
---@field allowedItemTypes table
local EquipmentSlotEntity = {}
EquipmentSlotEntity.__index = EquipmentSlotEntity

---@enum SlotName
EquipmentSlotEntity.SlotName = {
    LEFT_HAND = "leftHand",
    RIGHT_HAND = "rightHand",
    HELMET = "helmet",
    BOOTS = "boots"
}

---@param name string
---@param displayName string
---@param allowedItemTypes table
---@return EquipmentSlotEntity
function EquipmentSlotEntity.new(name, displayName, allowedItemTypes, slotButton)
    local self = setmetatable({}, EquipmentSlotEntity)
    self.name = name
    self.displayName = displayName
    self.allowedItemTypes = allowedItemTypes or {}
    self.slotButton = slotButton
    return self
end

---@return string
function EquipmentSlotEntity:getName()
    return self.name
end

---@return string
function EquipmentSlotEntity:getDisplayName()
    return self.displayName
end

---@param itemType string
---@return boolean
function EquipmentSlotEntity:canEquipItemType(itemType)
    for _, allowedType in ipairs(self.allowedItemTypes) do
        if allowedType == itemType then
            return true
        end
    end
    return false
end

---@return table
function EquipmentSlotEntity:getAllowedItemTypes()
    return self.allowedItemTypes
end

-- Предопределенные слоты экипировки
EquipmentSlotEntity.LEFT_HAND = EquipmentSlotEntity.new(
    EquipmentSlotEntity.SlotName.LEFT_HAND,
    "Left Hand",
    {"weapon", "ring"}
)

EquipmentSlotEntity.RIGHT_HAND = EquipmentSlotEntity.new(
    EquipmentSlotEntity.SlotName.RIGHT_HAND,
    "Right Hand",
    {"weapon", "ring"}
)

EquipmentSlotEntity.HELMET = EquipmentSlotEntity.new(
    EquipmentSlotEntity.SlotName.HELMET,
    "Helmet",
    {"amulet"}
)

EquipmentSlotEntity.BOOTS = EquipmentSlotEntity.new(
    EquipmentSlotEntity.SlotName.BOOTS,
    "Boots",
    {"boots"}
)

---@param slotName string
---@return EquipmentSlotEntity?
function EquipmentSlotEntity:getByName(slotName)
    if slotName == EquipmentSlotEntity.SlotName.LEFT_HAND then
        return EquipmentSlotEntity.LEFT_HAND
    elseif slotName == EquipmentSlotEntity.SlotName.RIGHT_HAND then
        return EquipmentSlotEntity.RIGHT_HAND
    elseif slotName == EquipmentSlotEntity.SlotName.HELMET then
        return EquipmentSlotEntity.HELMET
    elseif slotName == EquipmentSlotEntity.SlotName.BOOTS then
        return EquipmentSlotEntity.BOOTS
    end
    return nil
end

---@return table
function EquipmentSlotEntity.getAllSlots()
    return {
        EquipmentSlotEntity.RIGHT_HAND,
        EquipmentSlotEntity.LEFT_HAND,
        EquipmentSlotEntity.HELMET,
        EquipmentSlotEntity.BOOTS
    }
end

return EquipmentSlotEntity
