local AmuletsList = require(script.AmuletsList)
local RingsList = require(script.RingsList)
local FruitsList = require(script.FruitsList)

local BonusIcons = {
    Energy = "rbxassetid://95399152641597",
    Damage = "rbxassetid://120524693255496",
    Gems = "rbxassetid://124904701085442",
}

---@class InventorySystemData
local Data = {
    AmuletsList = AmuletsList,
    RingsList = RingsList,
    FruitsList = FruitsList,
    BonusIcons = BonusIcons,
}

return Data