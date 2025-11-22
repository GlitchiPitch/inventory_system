---@class ItemEntity
---@field id string
---@field name string
---@field itemType string
---@field rarity string
---@field canEquip boolean
---@field equipmentSlot EquipmentSlotEntity?
---@field maxStack number
local ItemEntity = {}
ItemEntity.__index = ItemEntity

---@enum ItemType
ItemEntity.ItemType = {
	WEAPON = "weapon",
	ARMOR = "armor",
	CONSUMABLE = "consumable",
	MATERIAL = "material",
	RING = "ring",
	AMULET = "amulet",
}

---@enum ItemRarity
ItemEntity.ItemRarity = {
	COMMON = "common",
	UNCOMMON = "uncommon",
	RARE = "rare",
	EPIC = "epic",
	LEGENDARY = "legendary",
}

---@param id string
---@param name string
---@param itemType string
---@return ItemEntity
function ItemEntity.new(id, name, itemType, slotButton)
	local self = setmetatable({}, ItemEntity)
	self.id = id
	self.name = name
	self.itemType = itemType
	self.slotButton = slotButton
	return self
end

---@return string
function ItemEntity:getId()
	return self.id
end

---@return string
function ItemEntity:getName()
	return self.name
end

---@return string
function ItemEntity:getType()
	return self.itemType
end

function ItemEntity:destroy()
    
    self.slotButton:Destroy()
end

return ItemEntity
