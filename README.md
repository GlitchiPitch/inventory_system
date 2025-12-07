# Inventory System v0.0.18

A comprehensive inventory and equipment management system for Roblox games, built with Clean Architecture principles.

## 🌟 Features

### Core Functionality
- **50-slot Inventory**: Complete inventory management with capacity limits
- **Equipment System**: 4 equipment slots (Left Hand, Right Hand, Helmet, Boots)
- **Item Types**: Weapons, Rings, Amulets, Boots with unique bonuses
- **Real-time Sync**: Client-server synchronization for inventory state
- **Data Persistence**: MetaService integration for persistent player data

### Item Collections
- **Fruits System**: 18 different fruits with various bonuses (Void, Titan, Tesla, etc.)
- **Rings Collection**: Elemental rings (Lightning Orb, Shadow Gem, Wind Feather)
- **Amulets Collection**: Elemental stones and crystals (Earth Stone, Fire Crystal, etc.)
- **Boots Collection**: Armor boots (Leather, Steel, Mithril, Dragon boots)

### Technical Features
- **Clean Architecture**: Organized into Shared, Server, and Client layers
- **Dependency Injection**: Service container with singleton/transient patterns
- **Type Safety**: Comprehensive Lua type annotations
- **Error Handling**: Robust validation and user feedback
- **Network Events**: Remote event system for client-server communication

## 🏗️ Architecture

```
├── Shared/           # Business logic and domain entities
│   ├── Domain/       # Entities (Player, Item, Inventory, EquipmentSlot)
│   ├── Infrastructure/ # Services (Logger, RemoteEvent, FeatureFlag)
│   └── Data/         # Item definitions (Fruits, Rings, Amulets, Boots)
├── Server/           # Server-side logic and persistence
│   ├── Infrastructure/
│   │   ├── Repositories/  # Data access layer
│   │   └── Services/      # Business logic services
│   └── init.luau      # Server initialization
└── Client/           # Client-side UI and interaction
    ├── UI/           # Inventory user interface
    └── Services/     # Client services
```

## 🚀 Quick Start

### Prerequisites
- Roblox Studio
- [Rojo](https://rojo.space/) 7.6.1+
- [Aftman](https://github.com/LPGhatguy/aftman) for tooling

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd inventory-system-aae/v0
   ```

2. **Install dependencies**
   ```bash
   aftman install
   ```

3. **Build the place**
   ```bash
   rojo build -o "v0.rbxlx"
   ```

4. **Open in Roblox Studio**
   - Open `v0.rbxlx` in Roblox Studio
   - Start Rojo server:
   ```bash
   rojo serve
   ```

## 📖 Usage

### Basic Inventory Operations

```lua
-- Get client inventory service
local inventoryService = game:GetService("InventorySystemClient"):getInventoryClientService()

-- Add item to inventory
inventoryService:requestAddItem("Leather Boots", 1)

-- Equip item
inventoryService:requestEquipItem("Leather Boots_1", "boots")

-- Remove item
inventoryService:requestRemoveItem("Leather Boots", 1)
```

### Equipment Slots

- **Left Hand**: Weapons, Rings
- **Right Hand**: Weapons, Rings
- **Helmet**: Amulets
- **Boots**: Boots only

### Item Types & Bonuses

Each item provides bonuses displayed with icons:
- **⚡ Energy**: Energy regeneration bonuses
- **💎 Gems**: Gem collection bonuses
- **💥 Damage**: Damage enhancement bonuses

## 🔧 Development

### Project Structure Details

#### Shared Layer
- **Domain Entities**: Core business logic classes
- **Infrastructure Services**: Cross-platform services (Logger, RemoteEvent)
- **Data Modules**: Item definitions and configurations

#### Server Layer
- **InventoryService**: Business logic for inventory operations
- **InventoryRepository**: Data persistence with MetaService
- **InventoryRemoteService**: Network event handling

#### Client Layer
- **InventoryUI**: User interface components
- **InventoryClientService**: Client-side inventory management
- **UI Components**: Equipment panels and inventory grids

### Adding New Items

1. **Define item data** in appropriate list (e.g., `Shared/Data/BootsList.luau`):
```lua
["New Boots"] = {
    icon = "rbxassetid://...",
    bonusType = "Damage",
    bonusValue = 50,
}
```

2. **Update data exports** in `Shared/Data/init.luau`

3. **Add item type support** if needed in `Shared/Domain/Entities/Item.luau`

### Testing

```bash
# Run linter
selene .

# Build and test
rojo build -o "test.rbxlx"
```

## 📋 API Reference

### InventoryClientService

| Method | Description |
|--------|-------------|
| `requestAddItem(itemId, count)` | Add items to inventory |
| `requestRemoveItem(itemId, count)` | Remove items from inventory |
| `requestEquipItem(slotId, slotName)` | Equip item in slot |
| `requestUnequipItem(slotName)` | Unequip item from slot |
| `getInventoryData()` | Get current inventory state |
| `getItemCount(itemId)` | Get count of specific item |

### Equipment Slots

| Slot Name | Allowed Types | Description |
|-----------|---------------|-------------|
| `leftHand` | weapon, ring | Left hand equipment |
| `rightHand` | weapon, ring | Right hand equipment |
| `helmet` | amulet | Head equipment |
| `boots` | boots | Foot equipment |

## 🐛 Troubleshooting

### Common Issues

**Inventory not syncing**: Check MetaService connection and network events
**Items not equipping**: Verify item type compatibility with equipment slot
**UI not updating**: Ensure client service event handlers are properly connected

### Debug Mode

Enable debug logging in services by setting logger level to DEBUG.

## 📄 License

This project is part of the Roblox Inventory System implementation.

## 🤝 Contributing

1. Follow Clean Architecture principles
2. Maintain type safety with Lua annotations
3. Update documentation for new features
4. Test changes thoroughly before committing

## 📚 Additional Resources

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Rojo Documentation](https://rojo.space/docs)
- [Roblox Lua Style Guide](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals)