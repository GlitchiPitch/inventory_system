---@class InventorySystemEntities
local Entities = {}

-- Импорт сущностей
local Player = require(script.Player)
local Item = require(script.Item)
local Inventory = require(script.Inventory)
local EquipmentSlot = require(script.EquipmentSlot)

---@class Entities
---@field Player PlayerEntity
---@field Item ItemEntity
---@field Inventory InventoryEntity
---@field EquipmentSlot EquipmentSlotEntity
Entities.__index = Entities

function Entities.new()
	local self = setmetatable({}, Entities)
	self.Player = Player
	self.Item = Item
	self.Inventory = Inventory
	self.EquipmentSlot = EquipmentSlot

	return self
end

return Entities
