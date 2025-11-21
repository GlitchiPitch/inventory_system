---@class PlayerEntity
---@field id string
---@field inventory InventoryEntity
local PlayerEntity = {}
PlayerEntity.__index = PlayerEntity

---@param id string
---@param inventory InventoryEntity
---@return PlayerEntity
function PlayerEntity.new(id, inventory)
	local self = setmetatable({}, PlayerEntity)
	self.id = id
	self.inventory = inventory or {}
	self.metaPlayer = nil
	return self
end

---@return string
function PlayerEntity:getId()
	return self.id
end

---@return InventoryEntity
function PlayerEntity:getInventory()
	return self.inventory
end

---@param inventory InventoryEntity
function PlayerEntity:setInventory(inventory)
	self.inventory = inventory
end

---@param itemId string
---@param slot EquipmentSlotEntity
---@return boolean
function PlayerEntity:equipItem(itemId, slot)
	return self.inventory:equipItem(itemId, slot)
end

---@param slot EquipmentSlotEntity
---@return boolean
function PlayerEntity:unequipItem(slot)
	return self.inventory:unequipItem(slot)
end

---@param itemId string
---@param count number
---@return boolean
function PlayerEntity:addItem(itemId, count)
	return self.inventory:addItem(itemId, count)
end

---@param itemId string
---@param count number
---@return boolean
function PlayerEntity:removeItem(itemId, count)
	return self.inventory:removeItem(itemId, count)
end

---@param itemId string
---@return boolean
function PlayerEntity:hasItem(itemId)
	return self.inventory:hasItem(itemId)
end

---@param itemId string
---@return number
function PlayerEntity:getItemCount(itemId)
	return self.inventory:getItemCount(itemId)
end

function PlayerEntity:setMetaPlayer(metaPlayer)
    self.metaPlayer = metaPlayer
end
return PlayerEntity
