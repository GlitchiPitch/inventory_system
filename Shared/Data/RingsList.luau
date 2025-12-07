local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local RingsModule = require(SharedModules.Rings)

---@class RingsList
local RingsList = {
    ["Lightning Orb"] = {
        icon = RingsModule["Lightning Orb"].Icon,
        bonusType = RingsModule["Lightning Orb"].BonusType,
        bonusValue = RingsModule["Lightning Orb"].BonusSize,
        rarity = RingsModule["Lightning Orb"].Rarity,
    },
    ["Shadow Gem"] = {
        icon = RingsModule["Shadow Gem"].Icon,
        bonusType = RingsModule["Shadow Gem"].BonusType,
        bonusValue = RingsModule["Shadow Gem"].BonusSize,
        rarity = RingsModule["Shadow Gem"].Rarity,
    },
    ["Wind Feather"] = {
        icon = RingsModule["Wind Feather"].Icon,
        bonusType = RingsModule["Wind Feather"].BonusType,
        bonusValue = RingsModule["Wind Feather"].BonusSize,
        rarity = RingsModule["Wind Feather"].Rarity,
    },

    -- Uncommon Rings (C rarity)
    ["Energy Crystal Ring"] = {
        icon = RingsModule["Energy Crystal Ring"].Icon,
        bonusType = RingsModule["Energy Crystal Ring"].BonusType,
        bonusValue = RingsModule["Energy Crystal Ring"].BonusSize,
        rarity = RingsModule["Energy Crystal Ring"].Rarity,
    },

    -- Rare Rings (B rarity)
    ["Damage Rune Ring"] = {
        icon = RingsModule["Damage Rune Ring"].Icon,
        bonusType = RingsModule["Damage Rune Ring"].BonusType,
        bonusValue = RingsModule["Damage Rune Ring"].BonusSize,
        rarity = RingsModule["Damage Rune Ring"].Rarity,
    },

    -- Epic Rings (A rarity)
    ["Gemstone Ring"] = {
        icon = RingsModule["Gemstone Ring"].Icon,
        bonusType = RingsModule["Gemstone Ring"].BonusType,
        bonusValue = RingsModule["Gemstone Ring"].BonusSize,
        rarity = RingsModule["Gemstone Ring"].Rarity,
    },
}

return RingsList