# Architecture Documentation

## System Architecture

### Core Systems

#### 1. Base System (`scripts/base.gd`)
- **Responsibility**: Root manager for entire base
- **Key Functions**:
  - Platform creation and tracking
  - Build slot management
  - Click detection routing
  - Camera control

#### 2. Platform System (`scripts/platform.gd`)
- **Responsibility**: Individual platform logic
- **Key Functions**:
  - Resource production (timer-based)
  - Child platform management
  - Build slot creation
  - Tag assignment

#### 3. Resource System (`scripts/resource_system.gd`)
- **Type**: Autoload Singleton
- **Responsibility**: Global resource tracking
- **Resources**: Materials, Fuel
- **Production**: Platforms add to global pool every second

#### 4. Combo System (`scripts/combo_system.gd`)
- **Type**: Managed by Base
- **Responsibility**: Detect and manage platform combos
- **Detection**: Checks platform adjacency (≤20 units)
- **Bonuses**: Modifies gameplay mechanics

#### 5. Expedition System (`scripts/expedition_system.gd`)
- **Type**: Autoload Singleton
- **Responsibility**: Mission management
- **Flow**: Launch → Timer → Complete → Rewards

### Data Flow

```
Player Input → Base._input()
            → Base._handle_click()
            → Platform.show_build_slots()
            → BuildMenu.show_menu()
            → Base.build_child_platform()
            → Platform.add_child_platform()
            → ComboSystem.check_combos()
            → ResourceSystem.add_resources()
```

### Scene Graph

```
Main (Node3D)
├── Camera3D
└── Base (Node3D)
    ├── HQ_Platform (Platform)
    │   ├── Mesh
    │   ├── ClickArea (Area3D)
    │   ├── ProductionTimer
    │   └── BuildSlots (x6)
    │       └── BuildSlot (Node3D)
    │           ├── Area3D
    │           └── Mesh
    ├── R&D_Platform (Platform)
    └── ... (more platforms)
```

### UI Scene Graph

```
Main
├── HUD (CanvasLayer)
│   └── VBoxContainer
│       ├── MaterialsLabel
│       ├── FuelLabel
│       ├── BaseSizeLabel
│       ├── ComboLabel
│       ├── ExpeditionLabel
│       └── CombatPowerLabel
├── BuildMenu (Control)
│   └── Panel
└── ExpeditionMenu (Control)
    └── Panel
```

### Collision Layers

- **Layer 1**: (Unused)
- **Layer 2**: Build Slots (Area3D for raycasting)
- **Layer 3**: (Unused)
- **Layer 4**: Platforms (ClickArea for selection)

### Key Patterns

#### Singleton Pattern
- ResourceSystem, PlatformData, ExpeditionSystem
- Global access via autoload
- Managed state across scenes

#### Observer Pattern
- Signals for loose coupling
- `platform_clicked`, `expedition_started`, `combo_activated`

#### Factory Pattern
- Platform instantiation from scene templates
- Procedural generation for variety

#### Data-Driven Design
- `PlatformData` centralizes all configuration
- Easy to add/modify platform types
- Balance changes without code modification

### Performance Considerations

- **Timer-based production**: 1-second intervals, minimal impact
- **Raycast optimization**: Only on user input, not per-frame
- **Combo checking**: O(n²) but only on build events
- **Procedural generation**: Once at platform creation

### Future Architecture Plans

1. **Save/Load System**
   - Serialize platform tree to JSON
   - Store resource state
   - Mission progress

2. **Event System**
   - Global event bus for game events
   - Decouple systems further

3. **Asset Management**
   - Asset loading system
   - Preload critical resources
   - Stream large assets

---

Last Updated: 2026-03-09
