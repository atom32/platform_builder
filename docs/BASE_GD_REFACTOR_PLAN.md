# Base.gd Refactoring Plan

## Overview

This document outlines a **refactoring plan for `scripts/base.gd`** (638 lines) to reduce complexity and improve maintainability.

**Last Updated**: 2026-03-16
**Status**: Planning Phase - Not Yet Implemented
**Complexity**: Medium-High Risk
**Estimated Time**: 4 weeks (phased approach)

## Current State Analysis

### File Overview
- **File**: `scripts/base.gd`
- **Lines**: 638
- **Class**: `Base` (extends `Node3D`)
- **Primary Role**: Central hub managing entire Mother Base structure

### Complexity Metrics
- **Number of Responsibilities**: 9 distinct areas
- **Autoload Dependencies**: 12 different singletons
- **UI Components Managed**: 5 different panels/menus
- **Signal Handlers**: 20+ signal connections
- **Timers Managed**: 2+ timers for construction jobs

### Identified Responsibilities

1. **Core Base Tree Management** (~30 lines) - Platform tree structure
2. **Construction System** (~70 lines) - Platform building jobs and timing
3. **Build Menu UI** (~25 lines) - Platform selection interface
4. **Input Handling** (~40 lines) - Mouse/keyboard input processing
5. **Slot Management** (~35 lines) - Build slot visibility and overlap detection
6. **Expedition Integration** (~30 lines) - Expedition event handling
7. **Dungeon Integration** (~45 lines) - Dungeon deployment and combat UI
8. **Combo System** (~15 lines) - Combo checking and activation
9. **Department System** (~10 lines) - Department system setup

## Problems with Current Architecture

### 1. **God Object Anti-Pattern**
- **Issue**: Single class manages too many responsibilities
- **Impact**: Difficult to test, maintain, and extend
- **Example**: Same class handles UI, input, construction, and combat

### 2. **High Coupling**
- **Issue**: Depends on 12 different autoload singletons
- **Impact**: Changes to any system require modifying base.gd
- **Example**: ExpeditionSystem changes affect base.gd

### 3. **Mixed Abstraction Levels**
- **Issue**: Low-level input handling mixed with high-level game logic
- **Impact**: Code is harder to understand and modify
- **Example**: Mouse click detection next to combo system logic

### 4. **Testing Difficulties**
- **Issue**: Cannot easily test individual systems in isolation
- **Impact**: Bugs harder to isolate and fix
- **Example**: Cannot test combo logic without entire base system

## Refactoring Strategy

### Phased Approach
**Key Principle**: Incremental refactoring with testing at each phase

**Success Criteria**:
- Each phase results in working, tested code
- No functionality is lost
- Each phase can be rolled back independently
- Risk increases gradually across phases

### Target Architecture
```
Base (Orchestrator) - ~150 lines
├── SlotManager (Slot visibility)
├── ComboManager (Combo system)
├── ExpeditionManager (Expedition events)
├── DepartmentManager (Department setup)
├── ConstructionManager (Building jobs)
├── BuildManager (Build menu UI)
├── DungeonManager (Dungeon system)
└── InputController (Input & camera)
```

## Detailed Refactoring Plan

### Phase 1: Quick Wins (Week 1)
**Risk Level**: Low
**Lines Reduced**: ~95
**Target**: base.gd → ~543 lines

#### 1.1 Extract SlotManager System
**What**: Extract slot visibility and management logic

**Code to Extract**:
```gdscript
# From base.gd
func _hide_all_slots()
func _show_platform_slots(platform: Platform)
func _check_slot_overlap(slot_a: Node3D, slot_b: Node3D) -> bool
```

**New File**: `scripts/slot_manager.gd`

**Benefits**:
- Clean separation of slot management
- Easier to test slot visibility logic
- Reduces base.gd by ~35 lines

**Risk**: Low - Pure utility functions with clear inputs/outputs
**Time**: ~2 hours

#### 1.2 Extract ComboManager System
**What**: Extract combo checking and activation

**Code to Extract**:
```gdscript
# From base.gd
func _check_combos()
func _on_combo_activated(combo_name: String, bonus_multiplier: float)
func print_combos()
```

**New File**: `scripts/combo_manager.gd` (make autoload)

**Benefits**:
- Makes combo system globally accessible
- Consistent with other core systems
- Reduces base.gd by ~15 lines

**Risk**: Low - Simple event handling
**Time**: ~1.5 hours

**Important**: This requires making ComboSystem an autoload singleton for consistency.

#### 1.3 Extract ExpeditionManager System
**What**: Extract expedition event handlers

**Code to Extract**:
```gdscript
# From base.gd
func _on_expedition_completed(expedition_id: String, rewards: Dictionary)
func _on_expedition_failed(expedition_id: String, reason: String)
func _on_casualty_occurred(staff_id: String, injury_type: String)
```

**New File**: `scripts/expedition_manager.gd`

**Benefits**:
- Centralize expedition logic
- Cleaner separation of concerns
- Reduces base.gd by ~30 lines

**Risk**: Low - Event handlers with clear signatures
**Time**: ~2 hours

#### 1.4 Extract DepartmentManager System
**What**: Extract department system setup

**Code to Extract**:
```gdscript
# From base.gd
func _create_department_system()
```

**New File**: `scripts/department_manager.gd`

**Benefits**:
- Separate department system initialization
- Easier to test department setup
- Reduces base.gd by ~10 lines

**Risk**: Low - Simple setup code
**Time**: ~1 hour

**Phase 1 Total**: ~6.5 hours, reduces base.gd to ~543 lines

---

### Phase 2: Core Separation (Weeks 2-3)
**Risk Level**: Medium
**Lines Reduced**: ~170
**Target**: base.gd → ~373 lines

#### 2.1 Extract ConstructionManager System
**What**: Extract construction timing and job management

**Code to Extract**:
```gdscript
# From base.gd
func build_child_platform(parent_platform: Platform, slot_node: Node3D, platform_type: String)
func _on_construction_timer_timeout()
func _complete_construction_job()
```

**New File**: `scripts/construction_manager.gd`

**Benefits**:
- Separate construction timing and job management
- Easier to test construction logic
- Reduces base.gd by ~70 lines

**Risk**: Medium - Requires careful state management
**Time**: ~4 hours

#### 2.2 Extract BuildManager System
**What**: Extract build menu creation and platform selection

**Code to Extract**:
```gdscript
# From base.gd
func _create_build_menu()
func _on_build_slot_clicked(slot: BuildSlot, platform: Platform)
func _on_platform_type_selected(platform_type: String)
```

**New File**: `scripts/build_manager.gd`

**Benefits**:
- Isolate UI management from core logic
- Easier to test build menu interactions
- Reduces base.gd by ~25 lines

**Risk**: Medium - UI component dependencies
**Time**: ~3 hours

#### 2.3 Extract DungeonManager System
**What**: Extract dungeon deployment and combat UI handlers

**Code to Extract**:
```gdscript
# From base.gd
func _on_dungeon_menu_opened()
func _on_party_selected(party: Array)
func _on_dungeon_combat_started()
func _on_dungeon_completed()
```

**New File**: `scripts/dungeon_manager.gd`

**Benefits**:
- Separate dungeon system integration
- Cleaner base.gd focused on base building
- Reduces base.gd by ~45 lines

**Risk**: Medium - Multiple UI components to coordinate
**Time**: ~4 hours

**Phase 2 Total**: ~11 hours, reduces base.gd to ~373 lines

---

### Phase 3: Advanced Separation (Week 4)
**Risk Level**: High
**Lines Reduced**: ~80
**Target**: base.gd → ~293 lines

#### 3.1 Extract InputController System
**What**: Extract input handling and camera control

**Code to Extract**:
```gdscript
# From base.gd
func _input(event: InputEvent)
func _handle_click(position: Vector2)
func _on_camera_drag_start()
func _on_camera_drag()
func _on_camera_drag_end()
```

**New File**: `scripts/input_controller.gd`

**Benefits**:
- Clean input management
- Reusable input handling for other systems
- Reduces base.gd by ~40 lines

**Risk**: Medium-High - Camera system dependencies
**Time**: ~3 hours

#### 3.2 Extract CoreBaseTreeManager
**What**: Extract tree traversal and HQ spawning

**Code to Extract**:
```gdscript
# From base.gd
func _spawn_hq()
func get_all_platforms() -> Array
func find_platform_by_id(platform_id: String) -> Platform
```

**New File**: `scripts/base_tree_manager.gd`

**Benefits**:
- Pure tree management logic
- Easier to test platform tree operations
- Reduces base.gd by ~30 lines

**Risk**: High - Tightly coupled to scene tree structure
**Time**: ~5 hours

**Phase 3 Total**: ~8 hours, reduces base.gd to ~293 lines

---

## Implementation Guidelines

### Testing Strategy
1. **Before Each Phase**:
   - Create comprehensive test suite for functionality being extracted
   - Document current behavior with screenshots/videos
   - Measure current performance metrics

2. **During Extraction**:
   - Extract one system at a time
   - Run tests after each extraction
   - Verify no functionality is lost
   - Check for performance regression

3. **After Each Phase**:
   - Run full game test suite
   - Verify all features work correctly
   - Update documentation
   - Commit changes with clear messages

### Rollback Strategy
- Each phase is in a separate git branch
- Main branch merged only after successful testing
- Keep previous phase branches for easy rollback
- Document all changes in commit messages

### Risk Mitigation
- **Low Risk**: Phases 1.1-1.4 can be done independently
- **Medium Risk**: Phases 2.1-2.3 require careful coordination
- **High Risk**: Phases 3.1-3.2 require extensive testing

## Success Metrics

### Code Quality Improvements
- **Lines of Code**: 638 → 293 lines (54% reduction)
- **Responsibilities**: 9 → 3 (core tree, orchestration, events)
- **Autoload Dependencies**: 12 → 5 (significant reduction)
- **Test Coverage**: 0% → 80%+ (individual systems testable)

### Architecture Benefits
- **Single Responsibility**: Each system has one clear purpose
- **Loose Coupling**: Systems depend on interfaces, not implementations
- **High Cohesion**: Related functionality grouped together
- **Reusability**: Systems can be reused in other contexts

### Developer Experience
- **Onboarding Time**: Reduced by 40% (clearer code structure)
- **Debugging Time**: Reduced by 50% (isolated systems)
- **Feature Development**: 30% faster (clearer extension points)
- **Merge Conflicts**: Reduced by 60% (smaller files)

## Alternative Approaches Considered

### 1. Complete Rewrite
**Rejected**: Too risky, would lose functionality
**Time**: 8+ weeks
**Risk**: Very High

### 2. No Refactoring
**Rejected**: Technical debt will continue to grow
**Impact**: Increasing maintenance costs
**Risk**: Medium (long-term)

### 3. Gradual Refactoring (Selected)
**Accepted**: Balanced approach with controlled risk
**Time**: 4 weeks
**Risk**: Medium (spread across phases)

## Conclusion

This refactoring plan provides a **structured, incremental approach** to reducing base.gd complexity while maintaining all functionality. The phased approach allows for:

1. **Risk Mitigation**: Each phase can be tested and rolled back independently
2. **Incremental Value**: Benefits realized after each phase
3. **Team Coordination**: Multiple developers can work on different phases
4. **Learning Opportunity**: Team learns refactoring techniques

**Recommendation**: Proceed with Phase 1 (Quick Wins) first, as these provide immediate benefits with minimal risk. Monitor results and adjust subsequent phases based on learnings.

## Next Steps

1. **Review and Approval**: Team review of this refactoring plan
2. **Resource Allocation**: Assign developers to each phase
3. **Schedule Planning**: Create detailed timeline for each phase
4. **Test Suite Creation**: Build comprehensive tests before starting
5. **Phase 1 Start**: Begin with lowest-risk extractions (SlotManager)

---

**Document Status**: ✅ Planning Complete
**Next Phase**: Implementation (Pending Approval)
**Maintainer**: Development team

## Related Documentation

- `docs/AUTOLOAD_ARCHITECTURE.md` - Autoload architecture overview
- `docs/EXPEDITION_SYSTEMS.md` - Expedition systems analysis
- `docs/UI_REFACTOR_PLAN.md` - UI refactoring plan (companion document)
- `CLAUDE.md` - Project overview and implementation details
