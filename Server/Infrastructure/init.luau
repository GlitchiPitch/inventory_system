local Repositories = require(script.Repositories)
local Services = require(script.Services)

---@class ServerInventorySystemInfrastructure
local Infrastructure = {}
Infrastructure.__index = Infrastructure

---@param diContainer DIContainer
function Infrastructure.new(diContainer)
	local self = setmetatable({}, Infrastructure)
	self.diContainer = diContainer
	self.repositories = Repositories.new(diContainer)
	self.services = Services.new(diContainer)
	return self
end

function Infrastructure:init()
    self.services:init()
end

return Infrastructure