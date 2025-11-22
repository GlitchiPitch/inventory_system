local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local AmuletsModule = require(SharedModules.Amulets)

---@class AmuletsList
local AmuletsList = {
	["Earth Stone"] = {
		icon = AmuletsModule["Earth Stone"].Icon,
		bonusType = AmuletsModule["Earth Stone"].BonusType,
		bonusValue = AmuletsModule["Earth Stone"].BonusSize,
	},
	["Fire Crystal"] = {
		icon = AmuletsModule["Fire Crystal"].Icon,
		bonusType = AmuletsModule["Fire Crystal"].BonusType,
		bonusValue = AmuletsModule["Fire Crystal"].BonusSize,
	},
	["Ice Shard"] = {
		icon = AmuletsModule["Ice Shard"].Icon,
		bonusType = AmuletsModule["Ice Shard"].BonusType,
		bonusValue = AmuletsModule["Ice Shard"].BonusSize,
	},
}

return AmuletsList
