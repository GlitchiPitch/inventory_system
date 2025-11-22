local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local FruitsModule = require(SharedModules.Fruits)

---@class FruitsList
local FruitsList = {

	["Bari Fruit"] = FruitsModule["Bari Fruit"].Icon,
	["Gomu Fruit"] = FruitsModule["Gomu Fruit"].Icon,
	["Ice Fruit"] = FruitsModule["Ice Fruit"].Icon,
	["Love Fruit"] = FruitsModule["Love Fruit"].Icon,
	["Magma Fruit"] = FruitsModule["Magma Fruit"].Icon,
	["Phoenix Fruit"] = FruitsModule["Phoenix Fruit"].Icon,
	["Quake Fruit"] = FruitsModule["Quake Fruit"].Icon,
	["Rumble Fruit"] = FruitsModule["Rumble Fruit"].Icon,
}

return FruitsList