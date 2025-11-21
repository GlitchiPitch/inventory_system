---@class ItemDefinitions
local ItemDefinitions = {}

-- Определения предметов
-- TODO: Добавить реальные определения предметов
ItemDefinitions.items = {
    -- Пример определения предмета
    -- ["sword"] = {
    --     name = "Sword",
    --     type = "weapon",
    --     rarity = "common",
    --     maxStack = 1
    -- }
}

---@return ItemDefinitions
function ItemDefinitions.new()
    local self = setmetatable({}, ItemDefinitions)
    return self
end

return ItemDefinitions
