local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Domain = require(script.Domain)
local Infrastructure = require(script.Infrastructure)
local Data = require(script.Data)

---@class InventorySystemShared
local Shared = {}
Shared.__index = Shared

function Shared.new()
	local self = setmetatable({}, Shared)
	self.domain = Domain.new()
	self.infrastructure = Infrastructure.new()
	self.data = Data
	return self
end

function Shared:init()
	self.infrastructure.diContainer:singleton("Shared.Infrastructure", function()
		return self.infrastructure
	end)
    
    self.infrastructure.diContainer:singleton("Shared.Domain", function()
		return self.domain
	end)

	self.infrastructure.diContainer:singleton("Shared.Data", function()
		return self.data
	end)

end

return Shared
