# Changelog

All notable changes to the Mother Base Builder project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Staff System (Iteration 10.5)**
  - Individual Staff entity with unique ID, name, skill level, and specialty
  - Staff recruitment creates individual Staff entities with random names
  - Recruit Pool system for unassigned staff
  - Staff Management UI (Press U) with TabContainer interface
  - Recruits tab: View and assign unassigned staff to departments
  - Departments tab: View all department assignments
  - Dismiss tab: View and dismiss staff to reduce upkeep
  - Staff can now be tracked individually with their attributes

- **Staff System (Iteration 10)**
- **Staff System (Iteration 10)**
  - New resources: GMP (Global Money Points), staff_count, bed_capacity
  - Staff recruitment system (50 GMP per staff, requires available bed)
  - Department assignment system (R&D, Combat, Support, Intel, Medical)
  - Staff upkeep system (1 Material per staff per minute)
  - Department bonuses: R&D (+10% research speed per staff), Combat (+0.5 combat power per staff)
  - Bed capacity from platforms: Support (+5 beds), Medical (+3 beds)
  - Efficiency penalty when upkeep not paid

- **Notification System**
  - Temporary on-screen notifications (5 second auto-dismiss)
  - Messages for staff recruitment, department assignment, expeditions, upkeep
  - Visual fade-out effect
  - Right-aligned notification container

### Changed
- **Platform Generator Refactor**
  - Rule-based template system for platform generation
  - Module library with 13 module types (radar, antenna, crane, pipes, container, turret, solar_panel, vent, satellite_dish, helipad, comms_array, fuel_tank, defenses_emplacement)
  - Platform templates for each type (HQ, R&D, Combat, Support, Intel, Medical)
  - Three-layer generation: top, middle, and edge modules
  - Six edge slots per platform for attachments
  - Themed color palettes (industrial, tech, military, medical)
  - Platforms now visually represent their function

## [0.1.0] - 2026-03-09

### Added
- **Core Systems**
  - Tree-based platform expansion system
  - Resource management (Materials and Fuel)
  - Base size limits (100 platforms max)
  - Data-driven platform configuration

- **Platform System**
  - 6 platform types: HQ, R&D, Combat, Support, Intel, Medical
  - Each platform can have up to 6 child platforms
  - Procedural visual generation
  - Resource production per platform

- **Combo System**
  - Tag-based adjacency detection
  - 4 combo rules with bonuses
  - Real-time combo tracking

- **Expedition System**
  - 4 mission types (Easy to Hard)
  - Combat power calculation
  - Time-based mission completion
  - Resource rewards

- **UI**
  - Resource HUD display
  - Build menu with platform selection
  - Expedition menu (Press E)
  - Real-time stats display

- **Camera Controls**
  - Right-click drag to pan
  - Mouse wheel zoom

### Technical
- Godot 4.6 project
- GDScript for all game logic
- Autoload singletons for global systems
- Signal-based architecture
- Raycast-based click detection

### Known Limitations
- Placeholder geometry (procedural generation)
- No sound effects or music
- No save/load functionality
- No platform upgrades
- Hardcoded configuration (not yet data-driven)

### Roadmap
- [ ] Platform upgrade system
- [ ] Save/Load functionality
- [ ] More platform types and combos
- [ ] Visual polish and proper art assets
- [ ] Audio system
- [ ] More expedition types
- [ ] Staff assignment to departments
