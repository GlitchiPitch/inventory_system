local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local AmuletsModule = require(SharedModules.Amulets)

---@class AmuletsList
local AmuletsList = {
	["Earth Stone"] = {
		icon = AmuletsModule["Earth Stone"].Icon,
		bonusType = AmuletsModule["Earth Stone"].BonusType,
		bonusValue = AmuletsModule["Earth Stone"].BonusSize,
		rarity = AmuletsModule["Earth Stone"].Rarity,
	},
	["Fire Crystal"] = {
		icon = AmuletsModule["Fire Crystal"].Icon,
		bonusType = AmuletsModule["Fire Crystal"].BonusType,
		bonusValue = AmuletsModule["Fire Crystal"].BonusSize,
		rarity = AmuletsModule["Fire Crystal"].Rarity,
	},
	["Ice Shard"] = {
		icon = AmuletsModule["Ice Shard"].Icon,
		bonusType = AmuletsModule["Ice Shard"].BonusType,
		bonusValue = AmuletsModule["Ice Shard"].BonusSize,
		rarity = AmuletsModule["Ice Shard"].Rarity,
	},

	-- Uncommon Amulets (C rarity)
	["Energy Pendant"] = {
		icon = AmuletsModule["Energy Pendant"].Icon,
		bonusType = AmuletsModule["Energy Pendant"].BonusType,
		bonusValue = AmuletsModule["Energy Pendant"].BonusSize,
		rarity = AmuletsModule["Energy Pendant"].Rarity,
	},

	-- Rare Amulets (B rarity)
	["Damage Talisman"] = {
		icon = AmuletsModule["Damage Talisman"].Icon,
		bonusType = AmuletsModule["Damage Talisman"].BonusType,
		bonusValue = AmuletsModule["Damage Talisman"].BonusSize,
		rarity = AmuletsModule["Damage Talisman"].Rarity,
	},

	-- Epic Amulets (A rarity)
	["Gem Amulet"] = {
		icon = AmuletsModule["Gem Amulet"].Icon,
		bonusType = AmuletsModule["Gem Amulet"].BonusType,
		bonusValue = AmuletsModule["Gem Amulet"].BonusSize,
		rarity = AmuletsModule["Gem Amulet"].Rarity,
	},
}

return AmuletsList
