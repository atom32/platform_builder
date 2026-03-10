# Platform Builder - Architecture Design

## Current Problems

### Code Structure Issues

1. **Main.gd** - Mixed responsibilities
   - Camera control
   - Input handling
   - Game initialization
   - Event processing
   - Debug features

2. **Base.gd** - Too many responsibilities
   - Platform data management
   - UI management (BuildMenu, ExpeditionMenu)
   - Click detection
   - Camera dragging
   - System connections

3. **Missing abstractions**
   - No unified game flow manager
   - No independent input system
   - No independent camera controller
   - UI tightly coupled with business logic

## Proposed Architecture

### Layer Separation

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (UI, Camera, Input, Notifications)     │
├─────────────────────────────────────────┤
│            Application Layer            │
│  (Game Flow, Player Actions, Commands)  │
├─────────────────────────────────────────┤
│             Domain Layer                │
│  (Platforms, Staff, Resources, Rules)   │
├─────────────────────────────────────────┤
│          Infrastructure Layer           │
│  (Data, Save/Load, Autoload Singletons) │
└─────────────────────────────────────────┘
```

## Component Responsibilities

### 1. Presentation Layer

#### CameraController (NEW)
**File:** `scripts/presentation/camera_controller.gd`

Responsibilities:
- Camera zoom (scroll wheel)
- Camera pan (right-click drag)
- Camera focus on platforms
- Camera movement smoothing

**Should NOT:**
- Know about game logic
- Know about resources
- Make game decisions

#### InputManager (NEW)
**File:** `scripts/presentation/input_manager.gd`

Responsibilities:
- Map input actions to game commands
- Handle keyboard shortcuts (R, U, E, TAB, etc.)
- Forward mouse clicks to interaction system
- Input context switching (menu vs gameplay)

**Should NOT:**
- Execute game logic directly
- Know about resources/staff

#### UIManager (NEW)
**File:** `scripts/presentation/ui_manager.gd`

Responsibilities:
- Show/hide UI panels
- Update HUD displays
- Handle UI events
- Coordinate UI layer ordering

**Should NOT:**
- Make game decisions
- Modify game state directly

### 2. Application Layer

#### GameDirector (NEW)
**File:** `scripts/application/game_director.gd`

Responsibilities:
- Manage game state (Ready, Playing, Paused, GameOver, Victory)
- Coordinate between systems
- Handle game flow transitions
- Execute player commands

**Key Methods:**
```gdscript
func start_new_game()
func pause_game()
func resume_game()
func end_game_victory()
func end_game_defeat(reason: String)
func execute_command(command: GameCommand)
```

#### Command Pattern (NEW)
**File:** `scripts/application/commands/`

Commands for player actions:
- `BuildPlatformCommand`
- `RecruitStaffCommand`
- `AssignStaffCommand`
- `LaunchExpeditionCommand`
- `DismissStaffCommand`

Each command:
- Validates action
- Executes action
- Can be undone (optional)

#### InteractionManager (NEW)
**File:** `scripts/application/interaction_manager.gd`

Responsibilities:
- Handle world clicks (platforms, slots)
- Raycast and hit detection
- Forward interactions to appropriate handlers

### 3. Domain Layer

#### PlatformRepository (EXTRACT FROM Base)
**File:** `scripts/domain/platform_repository.gd`

Responsibilities:
- Store and manage platform data
- Query platforms (by type, position, parent)
- Platform tree structure management

**Pure data - NO UI, NO input**

#### StaffRepository (EXTRACT FROM DepartmentSystem)
**File:** `scripts/domain/staff_repository.gd`

Responsibilities:
- Store and manage staff data
- Query staff (by department, skill, etc.)
- Staff assignment tracking

**Pure data - NO UI**

#### ResourceService (REFACTOR ResourceSystem)
**File:** `scripts/domain/resource_service.gd`

Responsibilities:
- Track resource amounts
- Resource production/consumption
- Upkeep calculations
- Resource validation

**Pure business logic - NO UI**

#### GameRulesService (NEW)
**File:** `scripts/domain/game_rules_service.gd`

Responsibilities:
- Build cost calculations
- Platform capacity rules
- Staff salary rules
- Victory/failure condition checks

**Pure rules - NO side effects**

### 4. Infrastructure Layer

#### GameStateManager (REFACTOR GameSession)
**File:** `scripts/infrastructure/game_state_manager.gd`

Responsibilities:
- Track session statistics
- Save/Load game state
- Session lifecycle management

#### EventBus (NEW)
**File:** `scripts/infrastructure/event_bus.gd`

Centralized event system:
```gdscript
# Game events
signal game_started()
signal game_paused()
signal game_resumed()
signal game_ended_victory()
signal game_ended_defeat(reason: String)

# Domain events
signal platform_built(platform: Platform, parent: Platform)
signal staff_recruited(staff: Staff)
signal staff_assigned(staff: Staff, department: String)
signal expedition_launched(mission_id: String)

# Resource events
signal resources_changed(resources: Dictionary)
signal upkeep_paid(cost: int)
```

## Refactoring Plan

### Phase 1: Extract Presentation
1. Create `CameraController` - extract from Main.gd
2. Create `InputManager` - extract from Main.gd and Base.gd
3. Create `UIManager` - extract UI coordination

### Phase 2: Extract Application Logic
1. Create `GameDirector` - central coordinator
2. Create `InteractionManager` - handle clicks
3. Create Command pattern for actions

### Phase 3: Extract Domain
1. Create `PlatformRepository` - extract data from Base.gd
2. Create `StaffRepository` - extract from DepartmentSystem
3. Create `GameRulesService` - consolidate rules

### Phase 4: Refactor Infrastructure
1. Create `EventBus` - replace scattered signals
2. Rename `GameSession` to `GameStateManager`
3. Add save/load support

## File Structure (After Refactor)

```
scripts/
├── presentation/
│   ├── camera_controller.gd
│   ├── input_manager.gd
│   └── ui_manager.gd
├── application/
│   ├── game_director.gd
│   ├── interaction_manager.gd
│   └── commands/
│       ├── build_platform_command.gd
│       ├── recruit_staff_command.gd
│       ├── assign_staff_command.gd
│       └── launch_expedition_command.gd
├── domain/
│   ├── platform_repository.gd
│   ├── staff_repository.gd
│   ├── resource_service.gd
│   └── game_rules_service.gd
├── infrastructure/
│   ├── game_state_manager.gd
│   ├── event_bus.gd
│   └── save_manager.gd (future)
└── entities/
    ├── platform.gd
    ├── staff.gd
    └── build_slot.gd
```

## Benefits

1. **Clear responsibilities** - Each class has one job
2. **Testable** - Business logic separated from UI
3. **Maintainable** - Changes isolated to specific layers
4. **Scalable** - Easy to add new features
5. **Debuggable** - Clear flow of execution

## Migration Strategy

1. **Don't delete old code** - Create new structure alongside
2. **Gradual migration** - One system at a time
3. **Backward compatibility** - Keep old APIs working
4. **Test at each step** - Ensure functionality preserved

## Next Steps

1. Review and approve this architecture
2. Start with Phase 1 (Presentation layer)
3. Test after each component extraction
4. Update documentation as we go
