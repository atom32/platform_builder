# Platform Builder Documentation Hub

Welcome to the comprehensive documentation for the Platform Builder project, a Godot 4.6 base-building simulation game inspired by Mother Base from Metal Gear Solid V.

**Last Updated**: 2026-03-16

## Quick Start

### New Developers?
Start here:
1. [Project README](../README.md) - Project overview and setup
2. [Autoload Architecture](AUTOLOAD_ARCHITECTURE.md) ⭐ **System architecture overview**
3. [Game Loop](#game-loop) - Understanding how the game works

### Need System Details?
See [System Documentation](#system-documentation) below

### Planning Changes?
Check [Architecture Decisions](#architecture-decisions)

---

## Game Loop

### Core Gameplay
1. **Start**: Player receives starting resources (200 Materials, 100 Fuel, 300 GMP, 10 Beds)
2. **Explore**: HQ has 6 expansion slots (visible as yellow circles)
3. **Build**: Click slot → Select platform type → Check capacities → Platform appears
4. **Expand**: New platforms also have 6 expansion slots
5. **Grow**: Base expands in tree structure (HQ → children → grandchildren...)
6. **Produce**: All platforms generate resources over time
7. **Navigate**: Right-click + drag to pan camera, scroll to zoom
8. **Recruit**: Press R to recruit staff (50 GMP, requires available bed)
9. **Manage**: Press E to open Base Management Panel
10. **Upkeep**: Staff cost 1 Material per minute

### Controls
- **Mouse Wheel** - Zoom in/out
- **Right-click + Drag** - Pan camera
- **R** - Recruit staff (50 GMP)
- **E** - Open Base Management Panel
- **F** - Toggle debug info (when debug mode enabled)
- **H** - Hide/Show HUD sidebar

### Resources
- **Materials** - Used for building platforms and staff upkeep
- **Fuel** - Used for building platforms and expeditions
- **GMP** - Currency for recruiting staff
- **Staff Count** - Current staff vs bed capacity
- **Bed Capacity** - Maximum staff based on platforms

### Platform Types
- **HQ** - Root of tree, provides 5 beds
- **R&D** - Produces Materials, research bonuses
- **Combat** - Produces Materials + Fuel, combat power
- **Support** - Produces Fuel, bed capacity
- **Intel** - Produces Fuel, intel bonuses
- **Medical** - Produces Materials, bed capacity

---

## System Documentation

### [Autoload Architecture](AUTOLOAD_ARCHITECTURE.md) ⭐ **NEW**
**Overview**: Complete documentation of the 16 autoload singletons that power the game.

**Key Topics**:
- Why each system is an autoload
- Intentional design decisions (dual expedition systems)
- Usage guidelines and best practices
- Future improvement recommendations

**Read This When**: You're new to the project, need to understand system architecture, or planning to add a new system.

### [Expedition Systems](EXPEDITION_SYSTEMS.md) ⭐ **NEW**
**Overview**: Detailed explanation of the two expedition/combat systems and why they exist separately.

**Key Topics**:
- ExpeditionSystem (automated resource generation)
- DungeonCrawlerSystem (interactive turn-based combat)
- Why both exist: Different gameplay purposes
- Future evolution plans

**Read This When**: You're working on expedition/combat features or confused about having two systems.

### [API Reference](api.md)
**Overview**: Detailed API documentation for game systems.

**Read This When**: You need to use a specific system API or implementing a new feature.

### [Internationalization](i18n.md)
**Overview**: Multi-language support (English and Chinese).

**Read This When**: You're adding UI text, translating content, or working with TextData.

### [Legacy Architecture](architecture.md)
**Overview**: Older base system architecture documentation (March 9).

**Note**: For current architecture, see [Autoload Architecture](AUTOLOAD_ARCHITECTURE.md).

---

## Architecture Decisions

### [Base.gd Refactoring Plan](BASE_GD_REFACTOR_PLAN.md) ⭐ **PLANNED**
**Overview**: 3-phase plan to reduce base.gd from 638 to ~293 lines.

**Key Topics**:
- Current complexity analysis (9 distinct responsibilities)
- Extraction plan for 8 subsystems
- Risk assessment and mitigation
- Implementation timeline (4 weeks)

**Status**: Planning complete, not yet implemented.

### [UI Refactoring Plan](UI_REFACTOR_PLAN.md) ⭐ **PLANNED**
**Overview**: 3-phase plan to reduce base_management_panel.gd from 792 to ~150 lines.

**Key Topics**:
- Current UI complexity analysis (4 major tabs, 3 nested)
- Panel extraction plan (Staff, Expeditions, Overview, Save/Load)
- State management improvements
- Implementation timeline (3 weeks)

**Status**: Planning complete, not yet implemented.

---

## Planning & Roadmap

### [Project Roadmap](roadmap.md)
**Overview**: Development milestones and future goals.

**Read This When**: You're new to the project, planning features, or want to know what's coming next.

---

## Design Philosophy

### Core Principles

1. **Tree-Based Expansion**
   - Platforms expand in a tree structure (not grid-based)
   - Each platform can have up to 6 child platforms
   - Unlimited growth potential

2. **Strategic Depth**
   - Combo system rewards intelligent layout planning
   - Different platforms provide different bonuses
   - Expeditions require strategic force composition

3. **Accessibility**
   - Simple controls
   - Clear visual feedback
   - Easy to understand, hard to master

### Game Loop Summary

**Build** → Construct platforms to expand base
**Produce** → Platforms generate resources over time
**Optimize** → Create combos for bonuses
**Expedition** → Launch missions for more resources
**Expand** → Repeat and grow

---

## Quick Reference

### Common Tasks

**Add a new autoload system**:
1. Read [Autoload Architecture](AUTOLOAD_ARCHITECTURE.md) for guidelines
2. Check if autoload is truly necessary
3. Add to project.godot [autoload] section
4. Document in autoload architecture

**Modify UI components**:
1. Read [UI Refactoring Plan](UI_REFACTOR_PLAN.md) for current structure
2. Check if component should be extracted
3. Update documentation after changes

**Work on expedition/combat**:
1. Read [Expedition Systems](EXPEDITION_SYSTEMS.md) first
2. Understand why two systems exist
3. Plan changes based on future combat system vision

**Debug system issues**:
1. Check [Autoload Architecture](AUTOLOAD_ARCHITECTURE.md) for system overview
2. Review [API Reference](api.md) for system APIs
3. Use debug mode (F key when enabled)

### System Dependencies

**Core Systems** (most depended upon):
- ResourceSystem - Resource management
- DepartmentSystem - Staff management
- PlatformData - Platform definitions
- TextData - Translations

**UI Systems** (user interface):
- InputManager - Keyboard shortcuts
- NotificationSystem - In-game messages
- FeedbackSystem - Visual effects

**Game Mode Systems**:
- GameModeManager - Sandbox vs Story mode
- StorySystem - Story progression
- ObjectiveSystem - Tutorial/objectives

---

## Development Status

**Current Phase**: Prototype Complete (v0.1.0)

**All Core Systems Implemented**:
- ✅ Tree-based platform expansion
- ✅ Resource production and management
- ✅ Staff recruitment and assignment
- ✅ Expedition systems (both automated and interactive)
- ✅ Combo system
- ✅ Base management UI
- ✅ Save/Load system

**Next Milestones**:
- Documentation and cleanup (current)
- Visual polish and UI improvements
- Balance adjustments
- Potential combat system unification

---

## Contributing to Documentation

### Adding New Documentation
1. Create new .md files in this directory
2. Update this README.md with a link
3. Add clear "Last Updated" dates
4. Cross-reference related documents

### Documentation Standards
- **Clear Titles**: Descriptive, searchable titles
- **Last Updated**: Always include update dates
- **Cross-References**: Link to related documents
- **Code Examples**: Use proper syntax highlighting
- **No Emojis**: Follow project's no-emoji policy

---

**Last Updated**: 2026-03-16
**Documentation Maintainer**: Development Team
**Project Version**: Prototype Phase (Pre-Alpha)

---

**Return to [Project README](../README.md)** | **Return to [Project Root](../)**
