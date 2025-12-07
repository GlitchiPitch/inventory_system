# MetaService Usage Guide

## Overview

MetaService is a persistent data storage system in Roblox projects. Provides automatic player data saving with a simple API for reading/writing.

## Core Concepts

### Getting Player Object

```lua
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local MetaService = require(ServerScriptService.MetaService)

-- Get player object
local playerInstance = Players:GetPlayerByUserId(userId)
local metaPlayer = MetaService.Class.Player:Get(playerInstance)

if not metaPlayer then
    -- Player not found or not initialized
    return
end
```

### Data Structure

All data is stored in the `metaPlayer.Data` field:

```lua
metaPlayer.Data = {
    -- Simple values
    ["HW_Pumpkin"] = 100000,
    ["HW_Stars"] = 500,

    -- Nested tables for complex data
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

## Usage Patterns

### 1. Initializing Data for New Player

```lua
function initializePlayerData(metaPlayer, userId)
    -- Initialize currencies
    if not metaPlayer.Data["HW_Pumpkin"] then
        metaPlayer.Data["HW_Pumpkin"] = 0
    end

    -- Initialize inventory
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

    -- Initialize other systems
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

### 2. Reading Data

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

### 3. Saving Data

```lua
function savePlayerInventory(metaPlayer, inventoryData)
    -- Get current data to preserve existing fields
    local currentInventory = metaPlayer.Data.Inventory or {}

    -- Update data while maintaining compatibility
    metaPlayer.Data.Inventory = {
        equippedItems = inventoryData.equippedItems,
        inventorySlots = inventoryData.inventorySlots,
        -- Preserve other fields if they exist
        lastModified = currentInventory.lastModified or os.time()
    }

    -- MetaService will automatically save changes
end

function updatePlayerCurrency(metaPlayer, currencyType, amount)
    metaPlayer.Data[currencyType] = amount
    -- Automatic saving
end
```

### 4. Deleting Data

```lua
function clearPlayerInventory(metaPlayer)
    metaPlayer.Data.Inventory = nil
end

function resetPlayerData(metaPlayer)
    metaPlayer.Data = {}  -- Complete clearing of all data
end
```

## Best Practices

### Data Organization
- Use nested tables to group related data
- Use clear keys (Inventory, BattlepassShop, HW_Pumpkin)
- Store simple values (numbers, strings) at the top level

### Error Handling
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

### Performance
- Avoid frequent small updates - group changes together
- Use caching for frequently read data
- Clear cache when player leaves

### Debugging
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

## System Integration

### With Repositories
```lua
local DataStorePlayerRepository = {}

function DataStorePlayerRepository:getById(userId)
    -- ... getting metaPlayer ...

    local playerEntity = self.domain.entities.Player.new(userId)
    playerEntity.inventory = getPlayerInventory(metaPlayer)
    playerEntity.currencies = {
        pumpkins = metaPlayer.Data["HW_Pumpkin"] or 0,
        stars = metaPlayer.Data["HW_Stars"] or 0
    }

    return playerEntity
end

function DataStorePlayerRepository:save(playerEntity)
    -- ... getting metaPlayer ...

    savePlayerInventory(metaPlayer, playerEntity.inventory)
    updatePlayerCurrency(metaPlayer, "HW_Pumpkin", playerEntity.currencies.pumpkins)
    updatePlayerCurrency(metaPlayer, "HW_Stars", playerEntity.currencies.stars)
end
```

### With Feature Flags
```lua
function initializeDebugData(metaPlayer, featureFlagService)
    if featureFlagService:isEnabled("DEBUG_MODE") then
        metaPlayer.Data["HW_Pumpkin"] = 1000000  -- Starting resources for tests
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

## Common Mistakes

1. **Missing metaPlayer existence check**
   ```lua
   -- Bad
   local data = metaPlayer.Data.Inventory

   -- Good
   local data = metaPlayer and metaPlayer.Data.Inventory or {}
   ```

2. **Overwriting existing data**
   ```lua
   -- Bad - losing CoinsPurchaseCount
   metaPlayer.Data.BattlepassShop = {ownedItems = newItems}

   -- Good - preserve existing fields
   local current = metaPlayer.Data.BattlepassShop or {}
   metaPlayer.Data.BattlepassShop = {
       ownedItems = newItems,
       CoinsPurchaseCount = current.CoinsPurchaseCount
   }
   ```

3. **Missing initialization for new players**
   ```lua
   -- Always check and initialize data
   local inventory = metaPlayer.Data.Inventory
   if not inventory then
       inventory = {equippedItems = {}, inventorySlots = {}}
       metaPlayer.Data.Inventory = inventory
   end
   ```
