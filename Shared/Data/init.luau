local AmuletsList = require(script.AmuletsList)
local FruitsList = require(script.FruitsList)
local RingsList = require(script.RingsList)

local BonusIcons = {
    Energy = "rbxassetid://95399152641597",
    Damage = "rbxassetid://120524693255496",
    Gems = "rbxassetid://124904701085442",
}

---@class InventorySystemData
local Data = {
    AmuletsList = AmuletsList,
    FruitsList = FruitsList,
    RingsList = RingsList,
    BonusIcons = BonusIcons,
}

return Data