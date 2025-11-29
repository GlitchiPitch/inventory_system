local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local FruitsModule = require(SharedModules.Fruits)

---@class FruitsList
local FruitsList = {

	-- Common Fruits
	["Pebble Fruit"] = {
		icon = FruitsModule["Pebble Fruit"].Icon,
		bonusType = FruitsModule["Pebble Fruit"].BonusType,
		bonusValue = FruitsModule["Pebble Fruit"].BonusSize,
	},
	["Sprout Fruit"] = {
		icon = FruitsModule["Sprout Fruit"].Icon,
		bonusType = FruitsModule["Sprout Fruit"].BonusType,
		bonusValue = FruitsModule["Sprout Fruit"].BonusSize,
	},
	["Gleam Fruit"] = {
		icon = FruitsModule["Gleam Fruit"].Icon,
		bonusType = FruitsModule["Gleam Fruit"].BonusType,
		bonusValue = FruitsModule["Gleam Fruit"].BonusSize,
	},

	-- Uncommon Fruits
	["Gale Fruit"] = {
		icon = FruitsModule["Gale Fruit"].Icon,
		bonusType = FruitsModule["Gale Fruit"].BonusType,
		bonusValue = FruitsModule["Gale Fruit"].BonusSize,
	},
	["Spring Fruit"] = {
		icon = FruitsModule["Spring Fruit"].Icon,
		bonusType = FruitsModule["Spring Fruit"].BonusType,
		bonusValue = FruitsModule["Spring Fruit"].BonusSize,
	},
	["Quartz Fruit"] = {
		icon = FruitsModule["Quartz Fruit"].Icon,
		bonusType = FruitsModule["Quartz Fruit"].BonusType,
		bonusValue = FruitsModule["Quartz Fruit"].BonusSize,
	},

	-- Rare Fruits
	["Spike Fruit"] = {
		icon = FruitsModule["Spike Fruit"].Icon,
		bonusType = FruitsModule["Spike Fruit"].BonusType,
		bonusValue = FruitsModule["Spike Fruit"].BonusSize,
	},
	["Boulder Fruit"] = {
		icon = FruitsModule["Boulder Fruit"].Icon,
		bonusType = FruitsModule["Boulder Fruit"].BonusType,
		bonusValue = FruitsModule["Boulder Fruit"].BonusSize,
	},
	["Pack Fruit"] = {
		icon = FruitsModule["Pack Fruit"].Icon,
		bonusType = FruitsModule["Pack Fruit"].BonusType,
		bonusValue = FruitsModule["Pack Fruit"].BonusSize,
	},

	-- Epic Fruits
	["Tesla Fruit"] = {
		icon = FruitsModule["Tesla Fruit"].Icon,
		bonusType = FruitsModule["Tesla Fruit"].BonusType,
		bonusValue = FruitsModule["Tesla Fruit"].BonusSize,
	},
	["Horizon Fruit"] = {
		icon = FruitsModule["Horizon Fruit"].Icon,
		bonusType = FruitsModule["Horizon Fruit"].BonusType,
		bonusValue = FruitsModule["Horizon Fruit"].BonusSize,
	},
	["Magma Fruit"] = {
		icon = FruitsModule["Magma Fruit"].Icon,
		bonusType = FruitsModule["Magma Fruit"].BonusType,
		bonusValue = FruitsModule["Magma Fruit"].BonusSize,
	},

	-- Legendary Fruits
	["Midas Fruit"] = {
		icon = FruitsModule["Midas Fruit"].Icon,
		bonusType = FruitsModule["Midas Fruit"].BonusType,
		bonusValue = FruitsModule["Midas Fruit"].BonusSize,
	},
	["Titan Fruit"] = {
		icon = FruitsModule["Titan Fruit"].Icon,
		bonusType = FruitsModule["Titan Fruit"].BonusType,
		bonusValue = FruitsModule["Titan Fruit"].BonusSize,
	},

	-- Mythical Fruits
	["Void Fruit"] = {
		icon = FruitsModule["Void Fruit"].Icon,
		bonusType = FruitsModule["Void Fruit"].BonusType,
		bonusValue = FruitsModule["Void Fruit"].BonusSize,
	},
	["Soul Fruit"] = {
		icon = FruitsModule["Soul Fruit"].Icon,
		bonusType = FruitsModule["Soul Fruit"].BonusType,
		bonusValue = FruitsModule["Soul Fruit"].BonusSize,
	},

	-- Divine Fruits
	["Singularity Fruit"] = {
		icon = FruitsModule["Singularity Fruit"].Icon,
		bonusType = FruitsModule["Singularity Fruit"].BonusType,
		bonusValue = FruitsModule["Singularity Fruit"].BonusSize,
	},
}

return FruitsList
