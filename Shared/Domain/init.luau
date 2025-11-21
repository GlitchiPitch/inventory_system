local Entities = require(script.Entities)

---@class InventorySystemDomain
---@field entities Entities
local Domain = {}
Domain.__index = Domain

function Domain.new()
    local self = setmetatable({}, Domain)
    self.entities = Entities.new()
    return self
end

return Domain