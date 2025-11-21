# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/specification/v2.0.0.html).

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
