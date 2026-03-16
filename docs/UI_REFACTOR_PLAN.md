# UI Refactoring Plan - BaseManagementPanel

## Overview

This document outlines a **refactoring plan for `ui/base_management_panel.gd`** (792 lines) to reduce complexity and improve maintainability.

**Last Updated**: 2026-03-16
**Status**: Planning Phase - Not Yet Implemented
**Complexity**: Medium Risk
**Estimated Time**: 3 weeks (phased approach)

## Current State Analysis

### File Overview
- **File**: `ui/base_management_panel.gd`
- **Lines**: 792
- **Scene**: `ui/base_management_panel.tscn`
- **Purpose**: Unified panel for Staff, Expeditions, Overview, and Save/Load management

### Complexity Metrics
- **Major UI Components**: 4 tabs, 3 nested sub-tabs
- **State Variables**: 6+ tracked state variables
- **System Dependencies**: 7 different autoload singletons
- **Signal Handlers**: 15+ signal connections
- **Dynamic Lists**: 4 different dynamically managed lists
- **Code Patterns**: Repetitive localization and formatting code

### UI Structure
```
BaseManagementPanel (CanvasLayer)
├── Header (Title + Close Button)
└── TabContainer (4 main tabs)
    ├── Staff (nested TabContainer with 3 sub-tabs)
    │   ├── Recruits (staff assignment)
    │   ├── Departments (view assignments)
    │   └── Dismiss (staff management)
    ├── Expeditions (mission management)
    ├── Overview (base visualization)
    └── Save/Load (game state management)
```

### Identified Components

1. **Staff Management System** (~200 lines) - Recruit/Dept/Dismiss tabs
2. **Expeditions System** (~150 lines) - Mission list and combat power
3. **Overview System** (~120 lines) - Platform tree and navigation
4. **Save/Load System** (~100 lines) - Save slot management
5. **Localization System** (~80 lines) - Text formatting and translation
6. **State Management** (~60 lines) - Tab persistence and selection tracking
7. **Event Handling** (~82 lines) - Signal connections and button handlers

## Problems with Current Architecture

### 1. **Monolithic UI Component**
- **Issue**: Single file manages 4 completely different features
- **Impact**: Changes to one feature risk breaking others
- **Example**: Save/Load changes could affect Staff management

### 2. **Deep Nesting**
- **Issue**: 3-level nested tab structure (Staff → Recruits/Dept/Dismiss)
- **Impact**: Complex navigation and state management
- **Example**: Tab changes require checking multiple levels

### 3. **Scattered State Management**
- **Issue**: State variables spread throughout the file
- **Impact**: Difficult to track state changes
- **Example**: `selected_recruit_index` and `selected_dismiss_index` separate

### 4. **Code Duplication**
- **Issue**: Repetitive localization and formatting code
- **Impact**: Changes require updates in multiple places
- **Example**: `_set_button_text()` called 20+ times

### 5. **System Coupling**
- **Issue**: Direct dependencies on 7 autoload systems
- **Impact**: Difficult to test UI components in isolation
- **Example**: Cannot test Staff panel without DepartmentSystem

## Refactoring Strategy

### Phased Approach
**Key Principle**: Extract independent UI components while maintaining functionality

**Success Criteria**:
- Each phase results in working, tested UI
- No functionality is lost
- UI becomes easier to maintain and extend
- Each phase can be rolled back independently

### Target Architecture
```
BaseManagementPanel (Orchestrator) - ~150 lines
├── StaffManagementPanel (Sub-panel)
│   ├── RecruitTab (Staff assignment)
│   ├── DepartmentTab (View assignments)
│   └── DismissTab (Staff management)
├── ExpeditionsPanel (Mission management)
├── OverviewPanel (Base visualization)
└── SaveLoadPanel (Save/Load management)
```

## Detailed Refactoring Plan

### Phase 1: Core Panel Split (Week 1)
**Risk Level**: Low
**Lines Reduced**: ~350
**Target**: base_management_panel.gd → ~442 lines

#### 1.1 Extract StaffManagementPanel
**What**: Extract all staff-related UI and logic

**Components to Extract**:
- RecruitList, DeptList, DismissList (3 Tree controls)
- 6 department assignment buttons
- 1 dismiss button
- Staff display and formatting logic

**New File**: `ui/staff_management_panel.gd`
**New Scene**: `ui/staff_management_panel.tscn`

**Code to Extract** (~200 lines):
```gdscript
# State management
var selected_recruit_index: int = -1
var selected_dismiss_index: int = -1

# UI Components
@onready var recruit_list: Tree = $TabContainer/Staff/Recruits/RecruitList
@onready var dept_list: Tree = $TabContainer/Staff/Departments/DeptList
@onready var dismiss_list: Tree = $TabContainer/Staff/Dismiss/DismissList

# Methods
func refresh_staff_lists()
func _on_recruit_selected()
func _on_department_selected()
func _on_dismiss_selected()
func assign_staff_to_department(dept: String)
func dismiss_staff()
func _format_staff_display(staff: Staff) -> String
```

**Benefits**:
- Isolate staff management logic
- Easier to test staff assignment flow
- Reduces main panel by ~200 lines

**Risk**: Low - Clear component boundaries
**Time**: ~4 hours

#### 1.2 Extract ExpeditionsPanel
**What**: Extract expedition mission UI and logic

**Components to Extract**:
- CombatPowerLabel and 4 bonus labels
- MissionList (dynamic button creation)
- Expedition status and launch logic

**New File**: `ui/expeditions_panel.gd`
**New Scene**: `ui/expeditions_panel.tscn`

**Code to Extract** (~150 lines):
```gdscript
# State management
var mission_buttons: Dictionary = {}

# UI Components
@onready var combat_power_label: Label = $CombatPowerLabel
@onready var mission_list: VBoxContainer = $MissionList

# Methods
func refresh_expedition_panel()
func update_combat_power_display()
func _create_mission_button(mission_data: Dictionary)
func _on_mission_button_pressed(mission_id: String)
func _format_mission_status(mission: Dictionary) -> String
func _calculate_bonuses() -> Dictionary
```

**Benefits**:
- Separate expedition logic from other UI
- Easier to add new expedition features
- Reduces main panel by ~150 lines

**Risk**: Low - Minimal dependencies on other UI
**Time**: ~3 hours

**Phase 1 Total**: ~7 hours, reduces base_management_panel.gd to ~442 lines

---

### Phase 2: Specialized Panel Extraction (Week 2)
**Risk Level**: Medium
**Lines Reduced**: ~220
**Target**: base_management_panel.gd → ~222 lines

#### 2.1 Extract OverviewPanel
**What**: Extract platform tree and navigation UI

**Components to Extract**:
- PlatformTree (hierarchical Tree control)
- StatsLabel (base statistics)
- Camera navigation integration

**New File**: `ui/base_overview_panel.gd`
**New Scene**: `ui/base_overview_panel.tscn`

**Code to Extract** (~120 lines):
```gdscript
# State management
var platform_tree_items: Dictionary = {}
var _last_click_time: float = 0.0
var _last_clicked_item: TreeItem = null

# UI Components
@onready var platform_tree: Tree = $PlatformTree
@onready var stats_label: Label = $StatsLabel

# Methods
func refresh_overview()
func build_platform_tree()
func _create_platform_tree_item(platform: Platform) -> TreeItem
func _on_platform_tree_item_activated()
func _navigate_to_platform(platform: Platform)
func _update_statistics()
```

**Benefits**:
- Isolate overview tree logic
- Easier to extend with new visualizations
- Reduces main panel by ~120 lines

**Risk**: Medium - Camera integration complexity
**Time**: ~4 hours

#### 2.2 Extract SaveLoadPanel
**What**: Extract save/load slot management UI

**Components to Extract**:
- 3 save slot panels with metadata
- Save/Load/Delete buttons
- Mode display and slot state

**New File**: `ui/save_load_panel.gd`
**New Scene**: `ui/save_load_panel.tscn`

**Code to Extract** (~100 lines):
```gdscript
# State management
var save_slots: Dictionary = {}
var current_mode: String = "sandbox"

# UI Components
@onready var slot_panels: Array = [$Slot1, $Slot2, $Slot3]

# Methods
func refresh_save_slots()
func _update_slot_display(slot_index: int)
func _on_save_button_pressed(slot_index: int)
func _on_load_button_pressed(slot_index: int)
func _on_delete_button_pressed(slot_index: int)
func _format_save_metadata(metadata: Dictionary) -> String
func _handle_scene_reload()
```

**Benefits**:
- Separate save/load logic from other UI
- Easier to add new save features (cloud saves, etc.)
- Reduces main panel by ~100 lines

**Risk**: Medium - Scene reload dependencies
**Time**: ~3 hours

**Phase 2 Total**: ~7 hours, reduces base_management_panel.gd to ~222 lines

---

### Phase 3: Infrastructure Cleanup (Week 3)
**Risk Level**: Low-Medium
**Lines Reduced**: ~72
**Target**: base_management_panel.gd → ~150 lines

#### 3.1 Extract LocalizationManager
**What**: Centralize text formatting and translation logic

**Code to Consolidate** (from all panels):
- `_set_button_text()` calls (~20 instances)
- `_set_label_text()` calls (~15 instances)
- `_format_*_display()` methods (~10 instances)

**New File**: `ui/localization_manager.gd`

**Methods**:
```gdscript
func setup_panel_text(panel: Control, translations: Dictionary)
func format_staff_display(staff: Staff) -> String
func format_mission_display(mission: Dictionary) -> String
func format_save_metadata(metadata: Dictionary) -> String
func format_combat_power(power: int) -> String
```

**Benefits**:
- Single source of truth for UI text
- Easier to add new languages
- Consistent text formatting across UI
- Reduces repetitive code

**Risk**: Low - Pure utility functions
**Time**: ~3 hours

#### 3.2 Extract State Management
**What**: Centralize panel state management

**Code to Consolidate**:
- Tab index tracking (`_current_tab_index`)
- Selection state (`selected_*_index`)
- Panel visibility and persistence

**New File**: `ui/panel_state_manager.gd`

**Methods**:
```gdscript
func manage_tab_state(panel: TabContainer, default_tab: int)
func track_selection_state(panel: Control, state_name: String)
func restore_panel_state(panel: Control)
func clear_selection_state(panel: Control)
```

**Benefits**:
- Consistent state management across panels
- Easier to debug state issues
- Better tab persistence
- Reduced scattered state variables

**Risk**: Low-Medium - Requires careful state tracking
**Time**: ~4 hours

#### 3.3 Standardize Error Handling
**What**: Replace debug prints with proper error handling

**Current Pattern** (inconsistent):
```gdscript
if not dept_system:
    ResourceSystem.debug_print("[BaseManagementPanel] DepartmentSystem not found")
    return
```

**New Pattern** (consistent):
```gdscript
func _handle_system_error(system_name: String, context: String):
    NotificationSystem.show_error("System {0} not found: {1}".format([system_name, context]))
    push_error("[{0}] {1} not found".format([name, system_name]))
```

**Benefits**:
- Consistent error handling
- Better user feedback
- Improved logging
- Easier debugging

**Risk**: Low - Error handling improvements
**Time**: ~2 hours

**Phase 3 Total**: ~9 hours, reduces base_management_panel.gd to ~150 lines

---

## Implementation Guidelines

### Testing Strategy
1. **Visual Testing**:
   - Before each phase: Take screenshots of all UI states
   - During extraction: Compare UI appearance pixel-by-pixel
   - After extraction: Verify all features work correctly

2. **Functional Testing**:
   - Staff assignment flow (recruit → department)
   - Expedition launch and completion
   - Platform tree navigation
   - Save/load operations

3. **Integration Testing**:
   - Panel state persistence across tabs
   - System integration (DepartmentSystem, ExpeditionSystem, etc.)
   - Error handling and recovery

### Rollback Strategy
- Each phase in separate git branch
- Main branch merged only after successful testing
- Keep previous phase branches for easy rollback
- Document all UI changes with screenshots

### Risk Mitigation
- **Low Risk**: Phases 1.1-1.2 (independent UI panels)
- **Medium Risk**: Phases 2.1-2.2 (camera and scene dependencies)
- **Low-Medium Risk**: Phase 3.x (infrastructure improvements)

## Success Metrics

### Code Quality Improvements
- **Lines of Code**: 792 → 150 lines (81% reduction)
- **Responsibilities**: 7 → 2 (orchestration, state)
- **System Dependencies**: 7 → 2 (NotificationSystem, TextData)
- **Code Duplication**: 80+ instances → 0 (centralized)

### UI/UX Benefits
- **Component Reusability**: Panels can be used independently
- **Easier Extension**: New features can be added without touching other panels
- **Better Testing**: Individual panels can be tested in isolation
- **Improved Performance**: Reduced node lookups and better state management

### Developer Experience
- **Onboarding Time**: Reduced by 50% (clearer UI structure)
- **Feature Development**: 40% faster (isolated UI components)
- **Bug Fixing**: 60% faster (clear component boundaries)
- **UI Consistency**: Improved (standardized patterns)

## Alternative Approaches Considered

### 1. Complete UI Rewrite
**Rejected**: Would lose all current UI functionality
**Time**: 6+ weeks
**Risk**: Very High

### 2. No UI Refactoring
**Rejected**: UI complexity will continue to grow
**Impact**: Increasing maintenance costs
**Risk**: Medium (long-term)

### 3. Gradual Refactoring (Selected)
**Accepted**: Balanced approach with controlled risk
**Time**: 3 weeks
**Risk**: Low-Medium (phased approach)

## Conclusion

This refactoring plan provides a **structured, incremental approach** to reducing UI complexity while maintaining all functionality. The phased approach allows for:

1. **Risk Mitigation**: Each phase can be tested and rolled back independently
2. **Incremental Value**: Benefits realized after each phase
3. **Parallel Development**: Multiple developers can work on different panels
4. **UI Consistency**: Standardized patterns across all components

**Recommendation**: Proceed with Phase 1 (Core Panel Split) first, as these provide immediate benefits with minimal risk. The Staff and Expeditions panels have clear boundaries and minimal dependencies on other UI components.

## Next Steps

1. **Review and Approval**: Team review of this refactoring plan
2. **UI Design**: Create mockups of refactored UI structure
3. **Resource Allocation**: Assign developers to each panel
4. **Schedule Planning**: Create detailed timeline for each phase
5. **Phase 1 Start**: Begin with StaffManagementPanel extraction

---

**Document Status**: ✅ Planning Complete
**Next Phase**: Implementation (Pending Approval)
**Maintainer**: Development team

## Related Documentation

- `docs/AUTOLOAD_ARCHITECTURE.md` - Autoload architecture overview
- `docs/BASE_GD_REFACTOR_PLAN.md` - Base.gd refactoring plan (companion document)
- `docs/EXPEDITION_SYSTEMS.md` - Expedition systems analysis
- `CLAUDE.md` - Project overview and implementation details
