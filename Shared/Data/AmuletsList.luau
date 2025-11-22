local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModules = ReplicatedStorage.SharedModules
local AmuletsModule = require(SharedModules.Amulets)

---@class AmuletsList
local AmuletsList = {
    ["Earth Stone"] =  AmuletsModule["Earth Stone"].Icon,
    ["Fire Crystal"] =  AmuletsModule["Fire Crystal"].Icon,
    ["Ice Shard"] =  AmuletsModule["Ice Shard"].Icon,
    
}


return AmuletsList