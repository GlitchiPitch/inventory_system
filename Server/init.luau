local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = require(ReplicatedStorage.Shared.InventorySystemShared)
local ServerInfrastructureRepositories = require(script.Infrastructure.Repositories)
local ServerInfrastructureServices = require(script.Infrastructure.Services)
---@class InventorySystemServer
local Server = {}
Server.__index = Server

function Server.new()
	local self = setmetatable({}, Server)
	self.shared = Shared.new()
	self.services = ServerInfrastructureServices.new(self.shared.infrastructure.diContainer)
	self.repositories = ServerInfrastructureRepositories.new(self.shared.infrastructure.diContainer)
	return self
end

function Server:init()
	self.shared:init()
	-- Инициализация репозиториев
	self.repositories:init()

	-- Инициализация сервисов
	self.services:init()
end

local server = Server.new()
server:init()

return Server
