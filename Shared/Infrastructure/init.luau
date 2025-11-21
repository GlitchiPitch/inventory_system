local DIContainer = require(script.DIContainer)
local Services = require(script.Services)

local RemoteEvent = script.RemoteEvent

---@class InventorySystemSharedInfrastructure
---@field remoteEvent RemoteEvent
---@field diContainer DIContainer
---@field services table
local Infrastructure = {}
Infrastructure.__index = Infrastructure

function Infrastructure.new()
    local self = setmetatable({}, Infrastructure)
    self.remoteEvent = RemoteEvent
    self.diContainer = DIContainer.new()
    self.services = Services.new(self.diContainer, self.remoteEvent)
    return self
end



return Infrastructure
