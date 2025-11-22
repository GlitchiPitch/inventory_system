local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local FruitsModule = require(SharedModules.Fruits)

---@class FruitsList
local FruitsList = {

	["Bari Fruit"] = {
		icon = FruitsModule["Bari Fruit"].Icon,
		bonusType = FruitsModule["Bari Fruit"].BonusType,
		bonusValue = FruitsModule["Bari Fruit"].BonusSize,
	},
	["Gomu Fruit"] = {
		icon = FruitsModule["Gomu Fruit"].Icon,
		bonusType = FruitsModule["Gomu Fruit"].BonusType,
		bonusValue = FruitsModule["Gomu Fruit"].BonusSize,
	},
	["Ice Fruit"] = {
		icon = FruitsModule["Ice Fruit"].Icon,
		bonusType = FruitsModule["Ice Fruit"].BonusType,
		bonusValue = FruitsModule["Ice Fruit"].BonusSize,
	},
	["Love Fruit"] = {
		icon = FruitsModule["Love Fruit"].Icon,
		bonusType = FruitsModule["Love Fruit"].BonusType,
		bonusValue = FruitsModule["Love Fruit"].BonusSize,
	},
	["Magma Fruit"] = {
		icon = FruitsModule["Magma Fruit"].Icon,
		bonusType = FruitsModule["Magma Fruit"].BonusType,
		bonusValue = FruitsModule["Magma Fruit"].BonusSize,
	},
	["Phoenix Fruit"] = {
		icon = FruitsModule["Phoenix Fruit"].Icon,
		bonusType = FruitsModule["Phoenix Fruit"].BonusType,
		bonusValue = FruitsModule["Phoenix Fruit"].BonusSize,
	},
	["Quake Fruit"] = {
		icon = FruitsModule["Quake Fruit"].Icon,
		bonusType = FruitsModule["Quake Fruit"].BonusType,
		bonusValue = FruitsModule["Quake Fruit"].BonusSize,
	},
	["Rumble Fruit"] = {
		icon = FruitsModule["Rumble Fruit"].Icon,
		bonusType = FruitsModule["Rumble Fruit"].BonusType,
		bonusValue = FruitsModule["Rumble Fruit"].BonusSize,
	},
}

return FruitsList