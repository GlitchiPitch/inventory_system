local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = require(ReplicatedStorage.Shared.InventorySystemShared)

local InventoryUI = require(script.UI.InventoryUI)
local InventoryService = require(script.Services.InventoryService)

local MetaService = require(game.StarterPlayer.StarterPlayerScripts.MetaService)


---@class InventorySystemClient
---@field shared InventorySystemShared
---@field diContainer DIContainer
local Client = {}
Client.__index = Client

function Client.new()
	local self = setmetatable({}, Client)
	self.shared = Shared.new()
	self.diContainer = self.shared.infrastructure.diContainer
	self.MetaService = MetaService
	self:_registerServices()
	return self
end

function Client:_registerServices()
	-- Регистрация InventoryClientService
	self.diContainer:singleton("InventoryClientService", function(container)
		local remoteEventService = container:resolve("RemoteEventService")
		---@type InventorySystemData
		local data = container:resolve("Shared.Data")
		local amuletsList = data.AmuletsList
		local ringsList = data.RingsList
		local fruitsList = data.FruitsList
		return InventoryService.new(remoteEventService, amuletsList, ringsList, fruitsList)
	end)

	-- Регистрация InventoryUI
	self.diContainer:singleton("InventoryUI", function(container)
		local inventoryClientService = container:resolve("InventoryClientService")
		---@type InventorySystemData
		local data = container:resolve("Shared.Data")
		---@type InventorySystemDomain
		local domain = container:resolve("Shared.Domain")

		local EquipmentSlotEntity = domain.entities.EquipmentSlot
		local ItemEntity = domain.entities.Item
		local amuletsList = data.AmuletsList
		local fruitsList = data.FruitsList
		local ringsList = data.RingsList
		local bonusIcons = data.BonusIcons

		return InventoryUI.new(inventoryClientService, amuletsList, fruitsList, ringsList, bonusIcons, EquipmentSlotEntity, ItemEntity)
	end)
end

function Client:init()
	self.shared:init()
	self.diContainer:resolve("InventoryClientService")
	self.diContainer:resolve("InventoryUI")
end

---@return InventoryClientService
function Client:getInventoryClientService()
	return self.diContainer:resolve("InventoryClientService")
end

---@return InventoryUI
function Client:getInventoryUI()
	return self.diContainer:resolve("InventoryUI")
end

local client = Client.new()
client:init()

return Client
