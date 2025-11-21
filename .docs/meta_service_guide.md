# Руководство по работе с MetaService

## Обзор

MetaService - это система персистентного хранения данных в Roblox проектах. Предоставляет автоматическое сохранение данных игроков с простой API для чтения/записи.

## Основные концепции

### Получение объекта игрока

```lua
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local MetaService = require(ServerScriptService.MetaService)

-- Получить объект игрока
local playerInstance = Players:GetPlayerByUserId(userId)
local metaPlayer = MetaService.Class.Player:Get(playerInstance)

if not metaPlayer then
    -- Игрок не найден или не инициализирован
    return
end
```

### Структура данных

Все данные хранятся в поле `metaPlayer.Data`:

```lua
metaPlayer.Data = {
    -- Простые значения
    ["HW_Pumpkin"] = 100000,
    ["HW_Stars"] = 500,

    -- Вложенные таблицы для комплексных данных
    ["Inventory"] = {
        equippedItems = {
            leftHand = "sword_001",
            rightHand = "shield_002",
            helmet = "helmet_003"
        },
        inventorySlots = {
            {id = "sword_001", count = 1},
            {id = "potion_005", count = 10}
        }
    },

    ["BattlepassShop"] = {
        ownedItems = {"item_1", "item_2"},
        lastShopUpdate = 1234567890,
        CoinsPurchaseCount = 5
    }
}
```

## Паттерны использования

### 1. Инициализация данных для нового игрока

```lua
function initializePlayerData(metaPlayer, userId)
    -- Инициализация валют
    if not metaPlayer.Data["HW_Pumpkin"] then
        metaPlayer.Data["HW_Pumpkin"] = 0
    end

    -- Инициализация инвентаря
    local inventory = metaPlayer.Data.Inventory
    if not inventory then
        inventory = {
            equippedItems = {
                leftHand = nil,
                rightHand = nil,
                helmet = nil
            },
            inventorySlots = {}
        }
        metaPlayer.Data.Inventory = inventory
    end

    -- Инициализация других систем
    local battlepassData = metaPlayer.Data.BattlepassShop
    if not battlepassData then
        battlepassData = {
            ownedItems = {},
            lastShopUpdate = os.time()
        }
        metaPlayer.Data.BattlepassShop = battlepassData
    end
end
```

### 2. Чтение данных

```lua
function getPlayerInventory(metaPlayer)
    local inventory = metaPlayer.Data.Inventory
    return inventory or {
        equippedItems = {leftHand = nil, rightHand = nil, helmet = nil},
        inventorySlots = {}
    }
end

function getPlayerCurrency(metaPlayer, currencyType)
    return metaPlayer.Data[currencyType] or 0
end
```

### 3. Сохранение данных

```lua
function savePlayerInventory(metaPlayer, inventoryData)
    -- Получить текущие данные для сохранения существующих полей
    local currentInventory = metaPlayer.Data.Inventory or {}

    -- Обновить данные, сохраняя совместимость
    metaPlayer.Data.Inventory = {
        equippedItems = inventoryData.equippedItems,
        inventorySlots = inventoryData.inventorySlots,
        -- Сохранить другие поля, если они есть
        lastModified = currentInventory.lastModified or os.time()
    }

    -- MetaService автоматически сохранит изменения
end

function updatePlayerCurrency(metaPlayer, currencyType, amount)
    metaPlayer.Data[currencyType] = amount
    -- Автоматическое сохранение
end
```

### 4. Удаление данных

```lua
function clearPlayerInventory(metaPlayer)
    metaPlayer.Data.Inventory = nil
end

function resetPlayerData(metaPlayer)
    metaPlayer.Data = {}  -- Полная очистка всех данных
end
```

## Лучшие практики

### Организация данных
- Используйте вложенные таблицы для группировки связанных данных
- Используйте понятные ключи (Inventory, BattlepassShop, HW_Pumpkin)
- Храните простые значения (числа, строки) на верхнем уровне

### Обработка ошибок
```lua
function safeGetPlayerData(userId)
    local playerInstance = Players:GetPlayerByUserId(tonumber(userId))
    if not playerInstance then
        warn("Player not found:", userId)
        return nil
    end

    local metaPlayer = MetaService.Class.Player:Get(playerInstance)
    if not metaPlayer then
        warn("MetaPlayer not initialized for:", userId)
        return nil
    end

    return metaPlayer
end
```

### Производительность
- Избегайте частых мелких обновлений - группируйте изменения
- Используйте кэширование для часто читаемых данных
- Очищайте кэш при выходе игрока

### Отладка
```lua
function debugPlayerData(metaPlayer, userId)
    print("=== Player Data Debug ===")
    print("UserId:", userId)
    print("Data keys:", table.concat(table.keys(metaPlayer.Data), ", "))

    if metaPlayer.Data.Inventory then
        print("Inventory equipped:", metaPlayer.Data.Inventory.equippedItems)
        print("Inventory slots count:", #metaPlayer.Data.Inventory.inventorySlots)
    end

    print("Currencies:")
    for key, value in pairs(metaPlayer.Data) do
        if type(value) == "number" and key:match("^HW_") then
            print("  ", key, "=", value)
        end
    end
end
```

## Интеграция с системами

### С репозиториями
```lua
local DataStorePlayerRepository = {}

function DataStorePlayerRepository:getById(userId)
    -- ... получение metaPlayer ...

    local playerEntity = self.domain.entities.Player.new(userId)
    playerEntity.inventory = getPlayerInventory(metaPlayer)
    playerEntity.currencies = {
        pumpkins = metaPlayer.Data["HW_Pumpkin"] or 0,
        stars = metaPlayer.Data["HW_Stars"] or 0
    }

    return playerEntity
end

function DataStorePlayerRepository:save(playerEntity)
    -- ... получение metaPlayer ...

    savePlayerInventory(metaPlayer, playerEntity.inventory)
    updatePlayerCurrency(metaPlayer, "HW_Pumpkin", playerEntity.currencies.pumpkins)
    updatePlayerCurrency(metaPlayer, "HW_Stars", playerEntity.currencies.stars)
end
```

### С Feature Flags
```lua
function initializeDebugData(metaPlayer, featureFlagService)
    if featureFlagService:isEnabled("DEBUG_MODE") then
        metaPlayer.Data["HW_Pumpkin"] = 1000000  -- Стартовые ресурсы для тестов
        metaPlayer.Data.Inventory = {
            equippedItems = {
                leftHand = "debug_sword",
                rightHand = "debug_shield",
                helmet = "debug_helmet"
            },
            inventorySlots = {
                {id = "debug_sword", count = 1},
                {id = "debug_shield", count = 1},
                {id = "debug_helmet", count = 1}
            }
        }
    end
end
```

## Типичные ошибки

1. **Отсутствие проверки существования metaPlayer**
   ```lua
   -- Плохо
   local data = metaPlayer.Data.Inventory

   -- Хорошо
   local data = metaPlayer and metaPlayer.Data.Inventory or {}
   ```

2. **Перезапись существующих данных**
   ```lua
   -- Плохо - теряем CoinsPurchaseCount
   metaPlayer.Data.BattlepassShop = {ownedItems = newItems}

   -- Хорошо - сохраняем существующие поля
   local current = metaPlayer.Data.BattlepassShop or {}
   metaPlayer.Data.BattlepassShop = {
       ownedItems = newItems,
       CoinsPurchaseCount = current.CoinsPurchaseCount
   }
   ```

3. **Отсутствие инициализации для новых игроков**
   ```lua
   -- Всегда проверяйте и инициализируйте данные
   local inventory = metaPlayer.Data.Inventory
   if not inventory then
       inventory = {equippedItems = {}, inventorySlots = {}}
       metaPlayer.Data.Inventory = inventory
   end
   ```
