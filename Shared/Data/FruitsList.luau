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
		rarity = FruitsModule["Pebble Fruit"].Rarity,
	},
	["Sprout Fruit"] = {
		icon = FruitsModule["Sprout Fruit"].Icon,
		bonusType = FruitsModule["Sprout Fruit"].BonusType,
		bonusValue = FruitsModule["Sprout Fruit"].BonusSize,
		rarity = FruitsModule["Sprout Fruit"].Rarity,
	},
	["Gleam Fruit"] = {
		icon = FruitsModule["Gleam Fruit"].Icon,
		bonusType = FruitsModule["Gleam Fruit"].BonusType,
		bonusValue = FruitsModule["Gleam Fruit"].BonusSize,
		rarity = FruitsModule["Gleam Fruit"].Rarity,
	},

	-- Uncommon Fruits
	["Gale Fruit"] = {
		icon = FruitsModule["Gale Fruit"].Icon,
		bonusType = FruitsModule["Gale Fruit"].BonusType,
		bonusValue = FruitsModule["Gale Fruit"].BonusSize,
		rarity = FruitsModule["Gale Fruit"].Rarity,
	},
	["Spring Fruit"] = {
		icon = FruitsModule["Spring Fruit"].Icon,
		bonusType = FruitsModule["Spring Fruit"].BonusType,
		bonusValue = FruitsModule["Spring Fruit"].BonusSize,
		rarity = FruitsModule["Spring Fruit"].Rarity,
	},
	["Quartz Fruit"] = {
		icon = FruitsModule["Quartz Fruit"].Icon,
		bonusType = FruitsModule["Quartz Fruit"].BonusType,
		bonusValue = FruitsModule["Quartz Fruit"].BonusSize,
		rarity = FruitsModule["Quartz Fruit"].Rarity,
	},

	-- Rare Fruits
	["Spike Fruit"] = {
		icon = FruitsModule["Spike Fruit"].Icon,
		bonusType = FruitsModule["Spike Fruit"].BonusType,
		bonusValue = FruitsModule["Spike Fruit"].BonusSize,
		rarity = FruitsModule["Spike Fruit"].Rarity,
	},
	["Boulder Fruit"] = {
		icon = FruitsModule["Boulder Fruit"].Icon,
		bonusType = FruitsModule["Boulder Fruit"].BonusType,
		bonusValue = FruitsModule["Boulder Fruit"].BonusSize,
		rarity = FruitsModule["Boulder Fruit"].Rarity,
	},
	["Pack Fruit"] = {
		icon = FruitsModule["Pack Fruit"].Icon,
		bonusType = FruitsModule["Pack Fruit"].BonusType,
		bonusValue = FruitsModule["Pack Fruit"].BonusSize,
		rarity = FruitsModule["Pack Fruit"].Rarity,
	},

	-- Epic Fruits
	["Tesla Fruit"] = {
		icon = FruitsModule["Tesla Fruit"].Icon,
		bonusType = FruitsModule["Tesla Fruit"].BonusType,
		bonusValue = FruitsModule["Tesla Fruit"].BonusSize,
		rarity = FruitsModule["Tesla Fruit"].Rarity,
	},
	["Horizon Fruit"] = {
		icon = FruitsModule["Horizon Fruit"].Icon,
		bonusType = FruitsModule["Horizon Fruit"].BonusType,
		bonusValue = FruitsModule["Horizon Fruit"].BonusSize,
		rarity = FruitsModule["Horizon Fruit"].Rarity,
	},
	["Magma Fruit"] = {
		icon = FruitsModule["Magma Fruit"].Icon,
		bonusType = FruitsModule["Magma Fruit"].BonusType,
		bonusValue = FruitsModule["Magma Fruit"].BonusSize,
		rarity = FruitsModule["Magma Fruit"].Rarity,
	},

	-- Legendary Fruits
	["Midas Fruit"] = {
		icon = FruitsModule["Midas Fruit"].Icon,
		bonusType = FruitsModule["Midas Fruit"].BonusType,
		bonusValue = FruitsModule["Midas Fruit"].BonusSize,
		rarity = FruitsModule["Midas Fruit"].Rarity,
	},
	["Titan Fruit"] = {
		icon = FruitsModule["Titan Fruit"].Icon,
		bonusType = FruitsModule["Titan Fruit"].BonusType,
		bonusValue = FruitsModule["Titan Fruit"].BonusSize,
		rarity = FruitsModule["Titan Fruit"].Rarity,
	},

	-- Mythical Fruits
	["Void Fruit"] = {
		icon = FruitsModule["Void Fruit"].Icon,
		bonusType = FruitsModule["Void Fruit"].BonusType,
		bonusValue = FruitsModule["Void Fruit"].BonusSize,
		rarity = FruitsModule["Void Fruit"].Rarity,
	},
	["Soul Fruit"] = {
		icon = FruitsModule["Soul Fruit"].Icon,
		bonusType = FruitsModule["Soul Fruit"].BonusType,
		bonusValue = FruitsModule["Soul Fruit"].BonusSize,
		rarity = FruitsModule["Soul Fruit"].Rarity,
	},

	-- Divine Fruits
	["Singularity Fruit"] = {
		icon = FruitsModule["Singularity Fruit"].Icon,
		bonusType = FruitsModule["Singularity Fruit"].BonusType,
		bonusValue = FruitsModule["Singularity Fruit"].BonusSize,
		rarity = FruitsModule["Singularity Fruit"].Rarity,
	},
}

return FruitsList
