local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local BootsModule = require(SharedModules.Accessories.Boots)

---@class BootsList
local BootsList = {
	-- Common Boots (D rarity)
	["Leather Boots"] = {
		icon = BootsModule["Leather Boots"].Icon,
		bonusType = BootsModule["Leather Boots"].BonusType,
		bonusValue = BootsModule["Leather Boots"].BonusSize,
		rarity = BootsModule["Leather Boots"].Rarity,
	},

	-- Uncommon Boots (C rarity)
	["Steel Boots"] = {
		icon = BootsModule["Steel Boots"].Icon,
		bonusType = BootsModule["Steel Boots"].BonusType,
		bonusValue = BootsModule["Steel Boots"].BonusSize,
		rarity = BootsModule["Steel Boots"].Rarity,
	},

	-- Rare Boots (B rarity)
	["Mithril Boots"] = {
		icon = BootsModule["Mithril Boots"].Icon,
		bonusType = BootsModule["Mithril Boots"].BonusType,
		bonusValue = BootsModule["Mithril Boots"].BonusSize,
		rarity = BootsModule["Mithril Boots"].Rarity,
	},

	-- Epic Boots (A rarity)
	["Dragon Boots"] = {
		icon = BootsModule["Dragon Boots"].Icon,
		bonusType = BootsModule["Dragon Boots"].BonusType,
		bonusValue = BootsModule["Dragon Boots"].BonusSize,
		rarity = BootsModule["Dragon Boots"].Rarity,
	},
}

return BootsList
