# API Documentation

This document provides API references for the major systems in Mother Base Builder.

## Table of Contents
- [ResourceSystem](#resourcesystem)
- [PlatformData](#platformdata)
- [Platform](#platform)
- [Base](#base)
- [ComboSystem](#combosystem)
- [ExpeditionSystem](#expeditionsystem)

---

## ResourceSystem

**Type**: Autoload Singleton
**File**: `scripts/resource_system.gd`

### Methods

#### `add_materials(amount: int)`
Add materials to the global resource pool.

**Parameters**: `amount` - Amount to add (can be negative)

#### `add_fuel(amount: int)`
Add fuel to the global resource pool.

**Parameters**: `amount` - Amount to add (can be negative)

#### `get_materials() -> int`
Get current material count.

**Returns**: Current material total

#### `get_fuel() -> int`
Get current fuel count.

**Returns**: Current fuel total

#### `spend_materials(amount: int) -> bool`
Spend materials if available.

**Parameters**: `amount` - Amount to spend
**Returns**: `true` if successful, `false` if insufficient

#### `spend_fuel(amount: int) -> bool`
Spend fuel if available.

**Parameters**: `amount` - Amount to spend
**Returns**: `true` if successful, `false` if insufficient

---

## PlatformData

**Type**: Autoload Singleton
**File**: `scripts/platform_data.gd`

### Methods

#### `get_platform_data(platform_type: String) -> Dictionary`
Get all data for a platform type.

**Parameters**: `platform_type` - Platform type (e.g., "R&D")
**Returns**: Dictionary containing platform data

#### `get_materials_production(platform_type: String) -> int`
Get materials production rate for a platform type.

**Parameters**: `platform_type` - Platform type
**Returns**: Materials per second

#### `get_fuel_production(platform_type: String) -> int`
Get fuel production rate for a platform type.

**Parameters**: `platform_type` - Platform type
**Returns**: Fuel per second

#### `get_build_cost(platform_type: String) -> Dictionary`
Get build cost for a platform type.

**Parameters**: `platform_type` - Platform type
**Returns**: `{"materials": int, "fuel": int}`

#### `get_tags(platform_type: String) -> Array`
Get tags for a platform type.

**Parameters**: `platform_type` - Platform type
**Returns**: Array of tag strings

#### `check_combo(tags_a: Array, tags_b: Array) -> Dictionary`
Check if two tag sets create a combo.

**Parameters**: `tags_a` - First platform's tags
**Parameters**: `tags_b` - Second platform's tags
**Returns**: Combo data if exists, empty dict otherwise

---

## Platform

**Type**: Node3D
**Class Name**: `Platform`
**File**: `scripts/platform.gd`

### Properties

#### `platform_type: String`
Type of this platform (HQ, R&D, Combat, etc.)

#### `level: int`
Platform upgrade level (default: 1)

#### `parent_platform: Platform`
Parent platform in the tree (null for HQ)

#### `child_platforms: Array[Platform]`
Child platforms built on this platform

#### `build_slots: Array[BuildSlot]`
Available build slots

#### `tags: Array`
Tags for combo detection

### Methods

#### `can_accept_child() -> bool`
Check if this platform can accept more children.

**Returns**: `true` if less than 6 children

#### `get_child_platform_count() -> int`
Get number of child platforms.

**Returns**: Child count

#### `get_all_descendants() -> Array[Platform]`
Get all descendant platforms recursively.

**Returns**: Array of all descendants

#### `get_neighbors(all_platforms: Array[Platform], range: float = 20.0) -> Array[Platform]`
Get neighboring platforms within range.

**Parameters**: `all_platforms` - All platforms in base
**Parameters**: `range` - Detection distance
**Returns**: Array of neighboring platforms

---

## Base

**Type**: Node3D
**Class Name**: `Base`
**File**: `scripts/base.gd`

### Properties

#### `hq_platform: Platform`
Root platform of the base

#### `all_platforms: Array[Platform]`
All platforms in the base

#### `build_menu: BuildMenu`
Reference to build menu UI

#### `expedition_menu: ExpeditionMenu`
Reference to expedition menu UI

#### `combo_system: ComboSystem`
Combo detection system

#### `expedition_system: ExpeditionSystem`
Mission management system

#### `MAX_PLATFORMS: int`
Maximum platforms allowed (100)

### Signals

#### `build_failed(reason: String)`
Emitted when platform build fails.

**Parameters**: `reason` - Failure reason

### Methods

#### `build_child_platform(parent_platform, slot, platform_type) -> Platform`
Build a new child platform.

**Parameters**: `parent_platform` - Parent platform
**Parameters**: `slot` - Build slot to use
**Parameters**: `platform_type` - Type to build
**Returns**: New platform instance or null

#### `get_total_platform_count() -> int`
Get total number of platforms.

**Returns**: Platform count

#### `open_expedition_menu()`
Open the expedition menu.

---

## ComboSystem

**Type**: Node
**Class Name**: `ComboSystem`
**File**: `scripts/combo_system.gd`

### Methods

#### `check_combos(all_platforms: Array[Platform]) -> Dictionary`
Check all platforms for active combos.

**Parameters**: `all_platforms` - All platforms
**Returns**: Dictionary of active combos

#### `get_active_combos() -> Dictionary`
Get all currently active combos.

**Returns**: Active combo data

#### `get_combo_count() -> int`
Get number of active combos.

**Returns**: Combo count

#### `get_total_bonus(effect_type: String) -> float`
Get total bonus for an effect type.

**Parameters**: `effect_type` - Effect type (e.g., "research_speed")
**Returns**: Total bonus (0.0 to 1.0+)

---

## ExpeditionSystem

**Type**: Node
**Class Name**: `ExpeditionManager`
**File**: `scripts/expedition_system.gd`

### Methods

#### `launch_expedition(mission_id: String) -> bool`
Launch an expedition.

**Parameters**: `mission_id` - Mission to launch
**Returns**: `true` if successful

#### `calculate_combat_power() -> int`
Calculate current combat power.

**Returns**: Combat power value

#### `get_available_missions() -> Dictionary`
Get missions that can be launched.

**Returns**: Available mission data

#### `get_active_expedition_count() -> int`
Get number of active expeditions.

**Returns**: Active expedition count

#### `get_expedition_time_remaining(mission_id: String) -> int`
Get time remaining for a mission.

**Parameters**: `mission_id` - Mission ID
**Returns**: Seconds remaining

### Signals

#### `expedition_started(mission_id: String)`
Emitted when expedition launches.

#### `expedition_completed(mission_id: String, rewards: Dictionary)`
Emitted when expedition completes.

#### `expedition_failed(mission_id: String, reason: String)`
Emitted when expedition fails.

---

Last Updated: 2026-03-09
