local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local RingsModule = require(SharedModules.Rings)

---@class RingsList
local RingsList = {
    ["Lightning Orb"] = {
        icon = RingsModule["Lightning Orb"].Icon,
        bonusType = RingsModule["Lightning Orb"].BonusType,
        bonusValue = RingsModule["Lightning Orb"].BonusSize,
    },
    ["Shadow Gem"] = {
        icon = RingsModule["Shadow Gem"].Icon,
        bonusType = RingsModule["Shadow Gem"].BonusType,
        bonusValue = RingsModule["Shadow Gem"].BonusSize,
    },
    ["Wind Feather"] = {
        icon = RingsModule["Wind Feather"].Icon,
        bonusType = RingsModule["Wind Feather"].BonusType,
        bonusValue = RingsModule["Wind Feather"].BonusSize,
    },
}

return RingsList