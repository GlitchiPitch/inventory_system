# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/specification/v2.0.0.html).

## [0.0.8] - 2025-11-22

### Added
- **Equipment Expansion**: Rings can be equipped in left/right hand slots, amulets in helmet slot
- **New Item Types**: Added RING and AMULET item types to ItemEntity with equipment compatibility
- **Rings System**: Implemented Lightning Orb, Shadow Gem, Wind Feather rings with asset integration
- **Amulets System**: Added Earth Stone, Fire Crystal, Ice Shard amulets with elemental properties
- **Inventory Capacity**: 50-slot inventory limit with full/empty state tracking and validation

### Changed
- **Equipment Logic**: Updated slot compatibility rules for new item types (weapons/rings in hands, amulets in helmet)
- **Data Structure**: Enhanced inventory persistence to support equipped rings and amulets
- **Item Management**: Extended server-side validation for ring and amulet equipment operations

### Technical Details
- **Equipment Slots**: Expanded allowedItemTypes for LEFT_HAND/RIGHT_HAND ("weapon", "ring") and HELMET ("amulet")
- **Data Persistence**: Updated InventoryRepository with ring and amulet equipment tracking
- **Asset Integration**: Connected RingsList and AmuletsList with external SharedModules for icon assets

### Next Steps
- Complete drag-and-drop inventory UI implementation
- Add item rarity colors and visual effects
- Implement comprehensive item tooltips with stats
- Create inventory filtering and search system

## [0.0.7] - 2025-11-22

### Added
- **Rings System**: New RingsList with elemental rings (Lightning Orb, Shadow Gem, Wind Feather)
- **Inventory Capacity**: Added 50-slot limit for inventory with full/empty state tracking
- **New Item Types**: Added RING and AMULET item types to ItemEntity
- **Equipment Expansion**: Rings can now be equipped in left/right hand slots, amulets in helmet slot

### Changed
- **Inventory Data Structure**: Refactored from array to dictionary format for better performance and item lookup
- **Amulets Reorganization**: Streamlined amulets list to focus on elemental stones and crystals
- **Fruits System**: Updated to use external FruitsModule for asset management
- **Equipment Logic**: Updated slot compatibility rules for new item types

### Technical Details
- **Data Structure**: Changed inventory slots from `[{id, count}]` array to `{itemId: {id, count}}` dictionary
- **Performance**: Improved item lookup O(1) vs O(n) for inventory operations
- **Memory Management**: Better slot tracking and capacity management

### Next Steps
- Implement drag-and-drop inventory interface
- Add item rarity colors and visual effects
- Create comprehensive item tooltips system
- Add inventory filtering and search capabilities

## [0.0.6] - 2025-11-22

### Changed
- **Code Cleanup**: Removed debug print/warn statements from all services and repositories
- **User Notifications**: Added MetaService notifications for equipment operations
- **UI Feedback**: Enhanced user feedback when attempting to equip items without free slots

### Fixed
- **Notification System**: Integrated proper notification handling for equip/unequip actions

### Technical Details
- **Logging**: Cleaned up excessive logging across InventoryRepository, InventoryRemoteService, and UI components
- **User Experience**: Added real-time notifications for equipment operations via MetaService

### Next Steps
- Implement drag-and-drop inventory interface
- Add item rarity colors and visual effects
- Create comprehensive item tooltips system

## [0.0.5] - 2025-11-22

### Fixed
- **Equipment Slot Icons**: Fixed rbxassetid:// prefix for equipment slot images to ensure proper loading
- **Equipment Slot Text**: Added TextTransparency changes for occupied equipment slots (0.5 opacity when filled, 0 when empty)

### Changed
- **UI Visual Feedback**: Enhanced equipment slot visual states with text transparency changes

### Technical Details
- **Image Loading**: Consistent rbxassetid:// prefix usage across all UI elements
- **Slot State Visualization**: Text transparency indicates equipment slot occupation status

### Next Steps
- Complete drag-and-drop inventory interface implementation
- Add item rarity colors and visual feedback
- Implement inventory grid layout and item positioning

## [0.0.4] - 2025-11-21

### Added
- **Fruits System**: New FruitsList with 20 different fruits (Void, Titan, Tesla, etc.) with asset IDs
- **Extended Amulets**: Added elemental stones and crystals (Earth Stone, Fire Crystal, Ice Shard, etc.)
- **Network Synchronization**: Complete InventoryRemoteService for client-server communication
- **Server Inventory Logic**: Full server-side inventory management with validation and persistence
- **Remote Event Handlers**: Event-driven architecture for inventory operations (add, remove, equip, unequip)

### Changed
- **Inventory Service**: Enhanced with comprehensive item validation and business logic
- **Equipment System**: Improved equip/unequip operations with server-side validation
- **Data Structure**: Extended item definitions to include both amulets and fruits

### Fixed
- **Item Validation**: Server-side validation for all inventory operations
- **Network Communication**: Proper error handling and client updates for all operations

### Technical Details
- **Remote Events**: 5 core inventory events (GetInventory, AddItem, RemoveItem, EquipItem, UnequipItem)
- **Server Validation**: Business rules validation for item existence, counts, and equipment compatibility
- **Data Persistence**: MetaService integration for all inventory state changes

### Next Steps
- Complete client-side UI implementation (drag-and-drop interface)
- Implement visual feedback and item tooltips
- Add inventory filtering and sorting capabilities

## [0.0.3] - 2025-11-21

### Changed
- **Inventory Data Structure**: Refactored inventory slots from dictionary to array format for better UI compatibility
- **UI Slot Management**: Improved inventory slot selection and visual feedback
- **Equipment Logic**: Fixed equipment checkmark display and slot validation
- **Repository Cleanup**: Removed unused ItemDefinitions repository and updated DI container

### Fixed
- **Inventory Persistence**: Corrected saving of equipped items data structure
- **UI Updates**: Fixed slot indexing and item display logic

### Technical Details
- **Data Format**: Changed from `{itemName: count}` to `[{id: itemName, count: count}]` array
- **UI Performance**: Optimized slot rendering and selection logic
- **Memory Management**: Improved cleanup of UI elements and data structures

### Next Steps
- Implement drag-and-drop functionality for inventory management
- Add server-side validation for equipment operations
- Create comprehensive item definitions system

## [0.0.1] - 2025-11-21

### Added
- **Project Architecture**: Implemented Clean Architecture with separation into Shared, Server, and Client layers
- **Infrastructure**: Added DI Container with singleton/transient patterns
- **Services**: Implemented RemoteEvent, Logger, and FeatureFlag services
- **Domain Entities**: Created Player, Item, Inventory, and EquipmentSlot entities with business logic
- **Player Repository**: Integrated with MetaService for data persistence and caching
- **Documentation**: Added comprehensive MetaService guide and project plan

### Changed
- **Project Structure**: Restructured from src/ to Client/Server/Shared folders
- **Project Configuration**: Updated default.project.json for new architecture

### Technical Details
- **Equipment System**: Three equipment slots (leftHand, rightHand, helmet)
- **Data Storage**: Integration with MetaService for persistent player data
- **Inventory Logic**: Business rules for item validation and equipment management

### Next Steps
- Implement server-side inventory logic and repository
- Create Diablo-style drag-and-drop UI interface
- Add network synchronization for client-server communication
