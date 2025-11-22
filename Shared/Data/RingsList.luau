local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local RingsModule = require(SharedModules.Rings)

---@class RingsList
local RingsList = {
    ["Lightning Orb"] =  RingsModule["Lightning Orb"].Icon,
    ["Shadow Gem"] =  RingsModule["Shadow Gem"].Icon,
    ["Wind Feather"] =  RingsModule["Wind Feather"].Icon,
}

return RingsList