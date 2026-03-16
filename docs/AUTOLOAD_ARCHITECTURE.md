# Autoload Architecture Documentation

## Overview

This document explains the **autoload singleton architecture** used in the Platform Builder project. It serves as a guide for understanding why certain systems are global singletons and how they interact.

**Last Updated**: 2026-03-16

## Autoload Singletons (16 Total)

The project uses 16 autoload singletons. Below is the complete list with their purpose and justification.

### Core Configuration & Data (4)

#### 1. ConfigSystem
**Purpose**: Single source of truth for all game settings (language, debug mode, audio volumes) with file persistence to `user://settings.cfg`.

**Why Autoload?**: Configuration must be accessible from any system and needs to persist across scene changes.

**File**: `scripts/config_system.gd`

#### 2. PlatformData
**Purpose**: Data-driven platform stats and combo rules loaded from JSON configuration files.

**Why Autoload?**: Static configuration data accessed globally during platform generation and combat calculations.

**File**: `scripts/platform_data.gd`

#### 3. TextData
**Purpose**: Internationalization system managing English and Chinese translations for all game text.

**Why Autoload?**: All UI elements need translation support, requiring global access.

**File**: `scripts/text_data.gd`

#### 4. InputManager
**Purpose**: Centralized keyboard shortcuts and input routing with customizable key bindings.

**Why Autoload?**: All UI elements and game systems need consistent input handling.

**File**: `scripts/input_manager.gd`

### Core Game Systems (5)

#### 5. ResourceSystem
**Purpose**: Global resource tracking (Materials, Fuel, GMP, Staff, Beds) with production timers and upkeep logic.

**Why Autoload?**: Core economy system accessed from building, production, staff management, and UI systems.

**File**: `scripts/resource_system.gd`

#### 6. DepartmentSystem
**Purpose**: Manages staff assignments, department limits, specialty bonuses, and department statistics.

**Why Autoload?**: Multiple systems (building, expeditions, UI) interact with staff assignments.

**File**: `scripts/department_system.gd`

#### 7. GameSession
**Purpose**: Tracks game state, play statistics, win/lose conditions, and session management.

**Why Autoload?**: Core game state tracking needed across all systems for save/load functionality.

**File**: `scripts/game_session.gd`

#### 8. SaveSystem
**Purpose**: Handles save/load functionality with JSON serialization for both Story and Sandbox modes.

**Why Autoload?**: Save/load functionality must be accessible from any system or menu.

**File**: `scripts/save_system.gd`

### Visual & Content Generation (3)

#### 9. ModuleLibrary
**Purpose**: Library of visual module definitions (Radar, Antenna, Crane, Pipes, Container) for procedural platform generation.

**Why Autoload?**: Platform generation needs shared visual definitions across all platforms.

**File**: `scripts/module_library.gd`

#### 10. PlatformTemplates
**Purpose**: Templates defining module arrangement rules for different platform types (HQ, R&D, Combat, Support, Intel, Medical).

**Why Autoload?**: Platform generation needs shared arrangement rules.

**File**: `scripts/platform_templates.gd`

### Game Mode Specific Systems (4)

#### 11. ExpeditionSystem (Automated Resource Gathering)
**Purpose**: Manages automated expeditions, resource-gathering missions, and combat power calculations for background mechanics.

**Why Autoload?**: Core gameplay system for automated resource generation and mission management.

**File**: `scripts/expedition_system.gd`

**IMPORTANT**: See "Dual Expedition Systems" section below.

#### 12. DungeonCrawlerSystem (Interactive Combat)
**Purpose**: Manages interactive dungeon expeditions with turn-based combat for story progression and player-controlled encounters.

**Why Autoload?**: Core gameplay system for story mode combat progression.

**File**: `scripts/dungeon_crawler_system.gd`

**IMPORTANT**: See "Dual Expedition Systems" section below.

#### 13. ObjectiveSystem (Sandbox Mode)
**Purpose**: Manages onboarding objectives and tutorial tasks for Sandbox/Endless mode.

**Why Autoload?**: Provides guidance and progression structure for sandbox mode gameplay.

**File**: `scripts/objective_system.gd`

#### 14. StorySystem (Story Mode)
**Purpose**: Manages story chapters, narrative progression, and story mode specific objectives.

**Why Autoload?**: Story mode state tracking needed across multiple scenes and systems.

**File**: `scripts/story_system.gd`

**IMPORTANT**: See "Dual Objective Systems" section below.

### UI & Feedback Systems (2)

#### 15. NotificationSystem
**Purpose**: Global notification display system for game events (resources gained, expeditions completed, etc.).

**Why Autoload?**: Centralized notification handling accessible from any system.

**File**: `scripts/notification_system.gd`

#### 16. FeedbackSystem
**Purpose**: Unified feedback effects including floating text, combo displays, and expedition completion effects.

**Why Autoload?**: Consistent visual feedback across all gameplay systems.

**File**: `scripts/feedback_system.gd`

## Important Architectural Decisions

### 1. Dual Expedition Systems (Intentional Design)

The project has **two separate expedition systems** that serve different purposes:

#### ExpeditionSystem - Automated Resource Gathering
- **Type**: Uncontrollable background mechanics
- **Purpose**: Earn resources passively
- **Gameplay**: Player sets up expeditions, they run automatically
- **Use Case**: Background resource generation while base building
- **Inspiration**: Mother Base automated operations from MGSV

#### DungeonCrawlerSystem - Interactive Combat
- **Type**: Partially controlled combat system
- **Purpose**: Advance story progression
- **Gameplay**: Turn-based combat with player decisions
- **Use Case**: Story mode encounters and tactical gameplay
- **Inspiration**: Turn-based RPG combat systems

**Why Both Exist?**: Both are **transitional systems** designed to provide different gameplay experiences before a full combat system is implemented. They serve different purposes:
- ExpeditionSystem provides the "Mother Base" feel of automated operations
- DungeonCrawlerSystem provides interactive combat encounters for story progression

**Future Plans**: These systems may be replaced or unified when a proper combat system is implemented. For now, they coexist to provide variety in gameplay experiences.

### 2. Dual Objective Systems (Mode-Specific Guidance)

The project has **two objective systems** for different game modes:

#### ObjectiveSystem - Sandbox/Endless Mode
- **Purpose**: Tutorial guidance and progression hints
- **Mode**: Sandbox/Endless mode
- **Function**: Helps new players understand mechanics
- **Example**: "Build your first platform", "Recruit 5 staff"

#### StorySystem - Story Mode
- **Purpose**: Narrative progression and chapter objectives
- **Mode**: Story mode only
- **Function**: Drives story forward with narrative objectives
- **Example**: "Chapter 1: Establish Mother Base", "Chapter 2: Recruit Ocelot"

**Why Both Exist?**: Different game modes need different types of guidance:
- Sandbox mode needs onboarding and mechanic explanations
- Story mode needs narrative-driven objectives

**Future Plans**: These systems could potentially be unified under a single quest/objective framework that adapts to the current game mode.

### 3. ComboSystem Architecture (Manual Creation)

**Important**: ComboSystem is **NOT an autoload** but is manually created in `base.gd` using `ComboSystem.new()`.

**Why Manual Creation?**: ComboSystem is tightly coupled to the base platform structure and requires access to build slots and platform adjacency.

**Current Status**: This creates an inconsistency with other core gameplay systems that are autoloads.

**Future Consideration**: ComboSystem could be converted to an autoload for consistency, but would need to handle platform tree structure references differently.

## Autoload Usage Guidelines

### When to Use Autoload

**Use Autoload when:**
- System needs to be accessible from multiple unrelated scenes
- System manages global state (resources, configuration, session data)
- System provides static/shared data (platform definitions, translations)
- System handles cross-cutting concerns (input, notifications, saving)

**Examples from this project:**
- ✅ ConfigSystem - Settings needed everywhere
- ✅ ResourceSystem - Global economy system
- ✅ TextData - Translation support for all UI
- ✅ SaveSystem - Save/load from anywhere

### When NOT to Use Autoload

**Avoid Autoload when:**
- System is specific to a single scene or gameplay mode
- System requires scene-specific node references
- System could be passed as a dependency or use signals instead
- System has heavy initialization that's not always needed

**Examples from this project:**
- ❌ ComboSystem - Scene-specific (tied to base structure)
- ❌ Individual platform controllers - Scene-specific logic
- ❌ Temporary UI panels - Can be passed as dependencies

## Communication Patterns

### Signal-Based Communication

The project uses signals extensively for loose coupling:

```gdscript
# ExpeditionSystem emits signals when expeditions complete
signal expedition_completed(expedition_id, rewards)

# ResourceSystem emits signals when resources change
signal resources_changed(materials, fuel, gmp)

# InputManager emits signals for keyboard shortcuts
signal shortcut_pressed(action_name)

# DepartmentSystem emits signals when staff assignments change
signal staff_assigned(staff_id, department)
```

This reduces direct dependencies between systems and makes the code more maintainable.

### Global Access Pattern

Most systems access autoloads using the global path pattern:

```gdscript
var config_system = get_node_or_null("/root/ConfigSystem")
if config_system:
    var debug_mode = config_system.debug_mode
```

**Pros**: Simple, works everywhere
**Cons**: Tight coupling to autoload names, harder to test

**Alternative (Future)**: Dependency injection

```gdscript
# Instead of:
var resources = ResourceSystem.materials

# Could be:
func _init(resource_system):
    self.resource_system = resource_system
```

## Data-Driven Design

Many autoload systems use JSON configuration files:

### PlatformData
```json
{
  "platforms": {
    "HQ": {
      "production": {"materials": 0, "fuel": 0},
      "beds": 5
    },
    "R&D": {
      "production": {"materials": 2, "fuel": 0},
      "beds": 0
    }
  }
}
```

### ModuleLibrary
```json
{
  "modules": {
    "Radar": {"mesh": "res://models/radar.obj"},
    "Antenna": {"mesh": "res://models/antenna.obj"}
  }
}
```

**Benefits**:
- Easy to balance and modify game data without changing code
- Designers can tweak values without programming knowledge
- Quick iteration on gameplay mechanics

## Known Architecture Issues

### 1. Over-reliance on Singletons (17 Global Systems)
**Impact**: High coupling through global access
**Severity**: Medium
**Mitigation**: Use signals and dependency injection where possible

### 2. Manual System Dependencies
**Pattern**: Many systems use `get_node_or_null("/root/SystemName")`
**Impact**: Tight coupling to specific autoload names
**Consideration**: Could use dependency injection or proper signal patterns

### 3. Transitional Systems
**Systems**: ExpeditionSystem, DungeonCrawlerSystem
**Status**: Intentionally temporary before full combat implementation
**Future**: May be replaced or unified

## Future Improvements

### High Priority
1. **Clarify Combat System Future** - Decide on final combat system architecture
2. **Unify Objective Systems** - Create single quest framework that adapts to game mode
3. **ComboSystem Consistency** - Decide if ComboSystem should be autoload or establish clear pattern for manual creation

### Medium Priority
4. **Dependency Injection** - Reduce `get_node_or_null()` usage for better testability
5. **Conditional Loading** - Only load StorySystem and DungeonCrawlerSystem when needed
6. **Signal-Based Notifications** - Consider replacing NotificationSystem with signal-based approach

### Low Priority
7. **GameModeManager Simplification** - Could be handled by scene transitions instead of global state
8. **FeedbackSystem Optimization** - Could be scene-scoped with proper injection

## Architecture Quality Assessment

### Strengths
- ✅ Good separation of concerns between systems
- ✅ Proper use of autoloads for truly global data/configuration
- ✅ Strong signal-based communication patterns
- ✅ Excellent data-driven design with JSON configuration
- ✅ Clear separation between game modes (Story vs Sandbox)
- ✅ Intentional design choices for dual systems (not accidental)

### Weaknesses
- ⚠️ High number of global singletons (16 autoloads + 1 manual)
- ⚠️ Manual system creation inconsistency (ComboSystem)
- ⚠️ Transitional systems create architectural uncertainty
- ⚠️ Tight coupling through global node access patterns

### Overall Score: 7/10

The architecture has solid foundations with **intentional design choices** for different gameplay experiences. The dual expedition and objective systems are purposeful, not accidental - they serve different game modes and player experiences.

**Key Insight**: This architecture prioritizes **functionality and rapid prototyping** over strict architectural purity. The 16 autoloads support a complex base-building game with multiple progression systems, game modes, and player experiences.

## Conclusion

This autoload architecture supports a complex base-building game with:
- Multiple game modes (Story vs Sandbox)
- Different progression systems (automated vs interactive)
- Rich gameplay experiences (resource management vs tactical combat)

The current design is **intentional and functional**, not accidental or sloppy. The dual expedition and objective systems exist to provide variety in gameplay experiences while a full combat system is being developed.

**When making architectural changes, always consider:**
1. Does this system need global access? (Use autoload only when necessary)
2. Is this a transitional system? (Document temporary designs)
3. Can signals reduce coupling? (Prefer signals over direct system access)
4. Will this scale? (Consider future game modes and features)
5. Is this intentional or accidental? (Understand the design rationale)

## Related Documentation

- `ARCHITECTURE.md` - Overall system architecture (root directory)
- `docs/architecture.md` - Base system architecture (older, March 9)
- `CLAUDE.md` - Project overview and implementation details
- `MEMORY.md` - Auto-memory for Claude Code context
