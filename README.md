# Mother Base Builder

A Godot 4.6 prototype base-building simulation game inspired by Metal Gear Solid V's Mother Base system.

## Overview

Build and manage a sea-based Mother Base with a tree-like expansion system. Construct platforms, manage resources, launch expeditions, and create strategic combinations to optimize your base operations.

## Current Status

**Prototype Phase** - Core systems implemented and functional.

### Implemented Features

- Tree-based platform expansion (unlimited growth potential)
- 6 platform types: HQ, R&D, Combat, Support, Intel, Medical
- Resource system (Materials and Fuel) with auto-production
- Procedural platform generation for visual variety
- Combo system based on platform adjacency
- Expedition system for resource gathering
- Data-driven architecture for easy balancing
- Build size limits (100 platforms max)

## How to Run

### Requirements
- Godot Engine 4.6 or later
- No additional dependencies required

### Steps
1. Open Godot Engine
2. Click "Import" and select this project folder
3. Press **F5** or click "Play" to run

## Controls

### Building
- **Left Click** on platform → Show build slots
- **Left Click** on visible slot → Open build menu
- **Left Click** on empty space → Hide all slots
- **ESC** → Close menus / Deselect platform

### Camera
- **Right Click + Drag** → Pan camera
- **Mouse Wheel Up** → Zoom in
- **Mouse Wheel Down** → Zoom out

### Expeditions
- **E Key** → Open/Close expedition menu

## Game Mechanics

### Platform Types

| Type | Materials/s | Fuel/s | Description |
|------|-------------|---------|-------------|
| HQ | 0 | 0 | Central command, root of base |
| R&D | 2 | 0 | Research and technology development |
| Combat | 1 | 1 | Military operations and defense |
| Support | 0 | 2 | Logistics and supply operations |
| Intel | 0 | 1 | Intelligence gathering |
| Medical | 1 | 0 | Medical treatment and research |

### Combos

Platforms placed near each other create synergistic effects:

- **R&D + Intel** → +20% Research Speed
- **Combat + Support** → +15% Expedition Strength
- **Medical + Combat** → +25% Casualty Reduction
- **Intel + Combat** → +10% Expedition Strength

### Expeditions

Combat platforms launch missions to gather resources:

| Mission | Difficulty | Duration | Combat Power | Rewards |
|---------|-----------|----------|---------------|---------|
| Supply Raid | Easy | 60s | 2 | 100 Mat, 40 Fuel |
| Resource Scavenge | Easy | 45s | 1 | 80 Mat, 30 Fuel |
| Intel Gathering | Medium | 90s | 3 | 50 Mat, 60 Fuel |
| Heavy Assault | Hard | 120s | 5 | 200 Mat, 100 Fuel |

**Combat Power** = Number of Combat platforms + combo bonuses

## Project Structure

```
proj-0308/
├── scenes/           # Game scenes
├── scripts/          # Game logic
├── ui/               # User interface
├── assets/           # Game resources (placeholder)
├── config/           # Configuration files
├── data/             # Game data (JSON, etc.)
└── docs/             # Design documentation
```

## Systems Architecture

### Data-Driven Design
All platform stats, costs, and combo rules are defined in `platform_data.gd` for easy balancing.

### Autoload Singletons
- **ResourceSystem** - Global resource management
- **PlatformData** - Platform configuration and combo rules
- **ExpeditionSystem** - Mission management

### Key Components
- **Base System** - Manages platform tree and building
- **Platform System** - Individual platform logic and production
- **Combo System** - Detects and manages adjacency bonuses
- **Expedition System** - Handles missions and rewards

## Development Notes

### Starting Resources
- Materials: 200
- Fuel: 100

### Constraints
- Maximum platforms: 100
- Maximum children per platform: 6
- Base platform size: 10x10 units
- Slot distance from parent: 15 units

### Future Features (Planned)

- [ ] Platform upgrade system
- [ ] Save/Load functionality
- [ ] More platform types
- [ ] Visual polish and proper art
- [ ] Sound effects and music
- [ ] More expedition types
- [ ] Staff assignment to departments
- [ ] Event system
- [ ] Campaign mode

## Contributing

This is a prototype project. Suggestions and improvements are welcome.

## License

[Add your license here]

## Credits

- **Development**: [Your Name]
- **Engine**: Godot 4.6
- **Inspiration**: Metal Gear Solid V: The Phantom Pain

---

**Last Updated**: 2026-03-09
**Version**: 0.1.0 (Prototype)
