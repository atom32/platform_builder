# Documentation Index

Complete documentation for the Platform Builder project.

**Last Updated**: March 16, 2026

## Quick Start

### For New Developers
1. Start with [README.md](../README.md) - Project overview
2. Read [Autoload Architecture](#new-architecture-documentation) for system overview ⭐ **NEW**
3. Check [CLAUDE.md](../CLAUDE.md) for AI assistant usage

### For Feature Implementation
1. Review [REFACTOR_PLAN.md](../REFACTOR_PLAN.md) for roadmap
2. Check corresponding design documents in `design/`
3. Review system documentation in `systems/`

### For Recent Changes
- See [CHANGELOG.md](../CHANGELOG.md) for version history
- Check [Display Settings README](../DISPLAY_SETTINGS_README.md) for latest feature

---

## Core Documentation (Project Root)

- **[README.md](../README.md)** - Project overview and quick start
- **[CLAUDE.md](../CLAUDE.md)** - Claude Code usage guide
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - System architecture design
- **[CHANGELOG.md](../CHANGELOG.md)** - Version history and changes
- **[REFACTOR_PLAN.md](../REFACTOR_PLAN.md)** - Refactoring roadmap

---

## New Architecture Documentation ⭐ **MARCH 2026**

### Essential Reading
- **[Autoload Architecture](AUTOLOAD_ARCHITECTURE.md)** - Complete analysis of 16 autoload singletons
- **[Expedition Systems](EXPEDITION_SYSTEMS.md)** - Why two expedition/combat systems exist

### Refactoring Plans (Not Yet Implemented)
- **[Base.gd Refactoring Plan](BASE_GD_REFACTOR_PLAN.md)** - Reduce base.gd from 638 to ~293 lines
- **[UI Refactoring Plan](UI_REFACTOR_PLAN.md)** - Reduce UI complexity from 792 to ~150 lines

### Game Loop Reference

**Build** → Construct platforms to expand base
**Produce** → Platforms generate resources over time
**Optimize** → Create combos for bonuses
**Expedition** → Launch missions for more resources
**Expand** → Repeat and grow

**Controls**:
- Mouse Wheel - Zoom in/out
- Right-click + Drag - Pan camera
- R - Recruit staff (50 GMP)
- E - Open Base Management Panel
- F - Toggle debug info (when debug mode enabled)
- H - Hide/Show HUD sidebar

---

## Feature Documentation

### Display Settings
- **[Display Settings README](../DISPLAY_SETTINGS_README.md)** - Complete display settings system documentation
- **[Display Settings Quick Start](../DISPLAY_SETTINGS_QUICK_START.md)** - Quick start guide

---

## Design Documents

### Game Design Analysis
- **[Deep Sea Development Plan](design/DEEP_SEA_DEVELOPMENT_PLAN.md)** - Deep sea mode implementation plan
- **[Dungeon System Summary](design/DUNGEON_SYSTEM_SUMMARY.md)** - Dungeon crawler system overview
- **[Procedural Platform Dungeon](design/PROCEDURAL_PLATFORM_DUNGEON.md)** - Procedural dungeon generation
- **[Roguelike Tower Climb](design/ROGUELIKE_TOWER_CLIMB.md)** - Roguelike mode design
- **[Mercenary Base Combat](design/MERCENARY_BASE_COMBAT.md)** - Combat system design
- **[PvP Analysis](design/PVP_ANALYSIS.md)** - Player vs Player mechanics
- **[Fun Analysis](design/FUN_ANALYSIS.md)** - Gameplay fun factor analysis
- **[Gameplay Analysis](design/GAMEPLAY_ANALYSIS.md)** - Core gameplay analysis

---

## System Documentation

### Architecture
- **[Architecture Analysis](architecture/ARCHITECTURE_ANALYSIS.md)** - Comprehensive architecture review (Chinese)
- **[Godot Architecture Analysis](architecture/ARCHITECTURE_ANALYSIS_GODOT.md)** - Godot-specific architecture review (Chinese)
- **[Architecture Improvement](architecture/ARCHITECTURE_IMPROVEMENT.md)** - Settings architecture improvements

### Assets & UI
- **[Assets Integrated](assets/ASSETS_INTEGRATED.md)** - Asset integration guide (Chinese)
- **[Asset Quick Start](assets/ASSET_QUICK_START.md)** - Asset integration quick start (Chinese)
- **[UI Asset Specifications](assets/UI_ASSET_SPECIFICATIONS.md)** - UI asset requirements (Chinese)
- **[Combat UI Upgrade Summary](assets/COMBAT_UI_UPGRADE_SUMMARY.md)** - Combat UI improvements (Chinese)

### Systems
- **[Resource System Turn-Based Migration](systems/RESOURCE_SYSTEM_TURN_BASED_MIGRATION.md)** - Turn-based resource system refactoring
- **[ConfigSystem Refactor](systems/CONFIGSYSTEM_REFACTOR.md)** - Configuration system improvements
- **[Verification Checklist](systems/VERIFICATION_CHECKLIST.md)** - System verification checklist

---

**Documentation Version**: 1.1
**Maintainer**: Development Team
