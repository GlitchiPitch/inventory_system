# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/specification/v2.0.0.html).

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
