# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Important Rules

**NO EMOJIS ALLOWED** - All documentation, comments, and communication must be emoji-free. This includes:
- Code comments
- Documentation files (README.md, CHANGELOG.md, etc.)
- CLAUDE.md
- Commit messages
- Any other text content in this repository

## Project Overview

This is a **Godot 4.6** prototype game project inspired by the Mother Base system from Metal Gear Solid V.

### Game Concept
- **Genre**: Top-down base-building simulation
- **Visual Style**: Simple 3D with placeholder geometry (boxes, cylinders)
- **Core Feature**: Tree-based expansion system like MGSV Mother Base
- **Architecture**: HQ → Platforms → Child Platforms → ... (hierarchical tree)

### Platform Types
- HQ (root platform, creates the base)
- R&D, Combat, Support, Intel, Medical (max 6 per department)
- Each platform can have up to 6 child platforms
- Unlimited expansion potential through tree growth

### Development Progress

**Iteration 1 - COMPLETE** - Ocean scene with blue plane
- HQ platform (gray box)
- Top-down camera

**Iteration 2 - COMPLETE** - Platform scene with type, level, production_value
- Base manager that spawns HQ and manages platforms
- 6 build slots around HQ in circular formation
- Click detection on build slots (prints to console)

**Iteration 3 - COMPLETE** - Build system: Click slot → spawn platform
- Platform type "R&D" (hardcoded)
- Slot occupation tracking (occupied slots can't be clicked)
- Slot mesh hidden when platform is built
- Platform properties: type, level=1, production_value=10

**Iteration 4 - COMPLETE** - Procedural platform generation with random modules
- 5 module types: Radar, Antenna, Crane, Pipes, Container
- Random positions (-3.5 to 3.5), random rotation (0-360°)
- Random industrial colors for variety
- Camera zoom with mouse wheel (15-80 distance range)

**Iteration 5 - COMPLETE** - Resource system with Materials and Fuel
- Global ResourceSystem singleton (autoload)
- Platforms produce resources every second
- Production rates: R&D (+2 Materials), Support (+2 Fuel)
- Console output every 5 seconds showing totals

**Iteration 6 - COMPLETE** - Basic UI with resource display (top-left corner)
- HUD updates twice per second
- Platform build costs implemented
- R&D Platform: 50 Materials + 10 Fuel
- Resource checking before building
- Success/failure console feedback
- Starting resources: 100 Materials, 50 Fuel

**Iteration 9 - COMPLETE** ✅ (Major Architecture Change)
- **Tree-based expansion system** (each platform has its own build slots)
- Platforms can have child platforms (up to 6 per platform)
- Camera panning with right-click + drag
- Hierarchical platform structure (HQ → children → grandchildren...)
- True Mother Base expansion like MGSV
- Each platform manages its own 6 expansion slots
- Department system maintained (6 platforms per department type)
- Starting resources increased to 200 Materials, 100 Fuel

**Iteration 10.5 - COMPLETE** ✅ (Staff System Refactor)
- **Individual Staff Entities**: Staff are now tracked as individual objects
- Staff have unique IDs, names, skill levels (1-5), and specialties
- **Recruit Pool**: New recruits go to the recruit pool (unassigned staff)
- **Staff Management UI**: Press U to open the staff menu
- Three tabs: Recruits, Departments, Dismiss
- Staff assignment through UI instead of keyboard shortcuts
- Staff dismissal system to reduce upkeep costs
- Productivity multipliers based on skill level and specialty matching

**Prototype Complete!** All core systems implemented for the prototype.

### Scope Limitations (Prototype Only)
- NO combat
- NO characters
- NO animations
- Build menu (platform type selection hardcoded as R&D)
- Platform upgrades

## Project Configuration

- **Engine Version**: Godot 4.6
- **Rendering**: Mobile rendering method (optimized for performance)
- **Physics Engine**: Jolt Physics (configured for 3D)
- **Platform Targets**: Desktop and Mobile

## Running the Project

Open the project in the Godot Editor and press F5 to run, or use the command line:

```bash
# If Godot is in your PATH
godot --path /Users/ning/proj-0308

# Or specify the Godot executable directly
/Applications/Godot_mono.app/Contents/MacOS/Godot --path /Users/ning/proj-0308
```

## File Conventions

- **Scripts**: GDScript files use `.gd` extension
- **Scenes**: Godot scene files use `.tscn` extension
- **Line Endings**: LF (enforced by .gitattributes)
- **Character Encoding**: UTF-8 (enforced by .editorconfig)

## Project Structure

```
/scenes          - Scene files (.tscn)
    main.tscn    - Main game scene     platform.tscn - Platform scene     build_slot.tscn - Build slot scene
/scripts         - Game logic scripts (.gd)
    main.gd      - Main game controller     base.gd      - Base system     platform.gd  - Platform logic     build_slot.gd - Build slot logic     platform_generator.gd - Procedural generation     resource_system.gd - Resource management ✅ (Autoload singleton)
    staff.gd     - Individual Staff entity class
    department_system.gd - Department management ✅ (Autoload singleton)

/ui              - User interface scenes
    hud.tscn     - Resource HUD     hud.gd       - HUD controller     build_menu.tscn - Build menu     build_menu.gd - Build menu controller
    staff_menu.tscn - Staff management UI     staff_menu.gd - Staff menu controller ```

## Current Implementation Details

### Platform System (`scripts/platform.gd`)
- **Tree Structure**: Each platform can have up to 6 child platforms
- **Properties**: `platform_type`, `level`, `production_value`, `parent_platform`, `child_platforms`, `build_slots`
- **Methods**:
  - `get_type()`, `get_level()`, `get_production()`, `upgrade()`
  - `add_child_platform()` - Add child to this platform
  - `can_accept_child()` - Check if more children allowed
  - `get_all_descendants()` - Recursively get all descendants
  - `_create_build_slots()` - Create 6 expansion slots
- **Procedural Generation**: Calls `PlatformGenerator.generate_platform()` on ready (non-HQ only)
- **Resource Production**: Timer-based production every 1 second
- **Production Rates** (per second, multiplied by level):
  - HQ: 0 Materials, 0 Fuel
  - R&D: 2 Materials, 0 Fuel
  - Support: 0 Materials, 2 Fuel
  - Combat: 1 Materials, 1 Fuel
  - Intel: 0 Materials, 1 Fuel
  - Medical: 1 Materials, 0 Fuel

### Base System (`scripts/base.gd`) - Tree Architecture
- **HQ Management**: Spawns and tracks HQ as root of platform tree
- **Tree Tracking**: `all_platforms` array contains all platforms in the base
- **Camera Panning**: Right-click + drag to move camera
- **Build Logic**:
  - Finds which platform owns the clicked slot
  - Checks parent capacity (max 6 children per platform)
  - Checks department capacity (max 6 platforms per department type)
  - Builds child platform at slot position
- **Platform Costs**:
  - R&D: 50 Materials, 10 Fuel
  - Support: 30 Materials, 40 Fuel
  - Combat: 40 Materials, 30 Fuel
  - Intel: 35 Materials, 25 Fuel
  - Medical: 25 Materials, 25 Fuel

### Platform Generator (`scripts/platform_generator.gd`)
- **Module Types**: Radar (dish), Antenna (tall pole), Crane (tall box), Pipes (small cylinders), Container (small box)
- **Generation**: 2-5 random modules per platform
- **Position**: Random within x/z range -3.5 to 3.5
- **Rotation**: Random 0-360 degrees
- **Colors**: Random industrial colors (gray, rust, blue-gray, dark gray, yellow-tan, dark metal)

### Resource System (`scripts/resource_system.gd`)
- **Global Singleton**: Accessible from anywhere via `ResourceSystem`
- **Resources**: Materials, Fuel, GMP (currency), Staff Count, Bed Capacity
- **Functions**: `add_materials()`, `add_fuel()`, `add_gmp()`, `add_staff()`, `add_beds()`
- **Spending**: `spend_materials()`, `spend_fuel()`, `spend_gmp()` - Returns true if successful
- **Recruitment**: `recruit_staff()` - Creates new Staff entity via DepartmentSystem
- **Upkeep**: Staff cost 1 Material per minute (efficiency penalty if unpaid)
- **Debug Output**: Prints totals every 5 seconds
- **Starting Resources**: 200 Materials, 100 Fuel, 300 GMP, 10 Beds

### UI System (`ui/hud.gd` and `ui/hud.tscn`)
- **CanvasLayer** with VBoxContainer layout
- **Two Labels**: Materials and Fuel display
- **Position**: Top-left corner (20px offset)
- **Update Rate**: Twice per second (0.5s interval)
- **Font Size**: 24pt for readability

### Build Menu (`ui/build_menu.gd` and `ui/build_menu.tscn`)
- **Panel with 5 buttons** for platform selection
- **Centered on screen** when slot is clicked
- **Dynamic button states**:
  - Shows department count: "R&D (2/6)"
  - Disabled when department full: "R&D (Dept Full - 6/6)"
  - Disabled when parent platform full: "R&D (Parent Full)"
- **Resource costs displayed** in button text

### Staff Entity (`scripts/staff.gd`)
- **Individual Staff**: Each staff is a unique entity with ID, name, skills
- **Properties**: `id`, `first_name`, `last_name`, `department`, `skill_level` (1-5), `specialty`
- **Specialties**: Combat, Research, Logistics, Medicine, Engineering, or None
- **Productivity**: Multiplier based on skill level and specialty-department matching
- **Recruit Pool**: Staff with empty `department` are in the recruit pool

### Staff Menu (`ui/staff_menu.gd` and `ui/staff_menu.tscn`)
- **Hotkey**: Press U to toggle the staff menu
- **TabContainer** with three tabs:
  1. **Recruits Tab**: View unassigned staff, assign to departments with buttons
  2. **Departments Tab**: View all department assignments
  3. **Dismiss Tab**: View all staff, dismiss selected to reduce upkeep
- **Dynamic Updates**: Lists refresh when menu opens or actions are taken

### Department System (`scripts/department_system.gd`)
- **Global Singleton**: Accessible via `DepartmentSystem`
- **Staff List**: Tracks all Staff entities in the base
- **Recruit Pool**: `get_recruit_pool()` returns unassigned staff
- **Assignment**: `assign_staff_member()` assigns individual staff to departments
- **Dismissing**: `dismiss_staff()` removes staff from the base
- **Bonuses**: Calculates research speed and combat power from assigned staff

### Main Camera & Game Controller (`scripts/main.gd`)
- **Zoom Control**: Mouse wheel up/down
- **Zoom Range**: 15 (closest) to 80 (farthest) units
- **Zoom Speed**: 5 units per scroll step
- **Camera Panning**: Right-click + drag to move camera (handled by base.gd)
- **Starting Resources**: Grants 200 Materials, 100 Fuel, 300 GMP, 10 Beds on game start
- **Hotkeys**: R (recruit staff), U (open staff menu)

### Base System (`scripts/base.gd`) - Tree Architecture
- **Tree Management**: HQ is root, tracks all platforms in tree structure
- **Platform Discovery**: Finds which platform owns clicked slot
- **Dual Capacity Checks**:
  1. Department capacity (6 per department type)
  2. Parent capacity (6 children per platform)
- **Camera Panning**: Right-click + drag to pan camera around base
- **Build Costs**:
  - R&D: 50 Materials, 10 Fuel
  - Support: 30 Materials, 40 Fuel
  - Combat: 40 Materials, 30 Fuel
  - Intel: 35 Materials, 25 Fuel
  - Medical: 25 Materials, 25 Fuel

## Development Notes

- The `.godot/` directory contains editor-specific data and is gitignored
- Android export templates are gitignored (`/android/`)
- Use the Godot Editor UI to modify `project.godot` rather than editing it directly

## Game Loop Summary (Tree-Based System)

1. **Start**: Player gets 200 Materials, 100 Fuel, 300 GMP
2. **Explore**: HQ has 6 expansion slots (visible as yellow circles)
3. **Build**: Click slot → Select platform type → Check capacities → Child platform appears
4. **Expand**: New platforms also have 6 expansion slots
5. **Grow**: Base expands in tree structure (HQ → children → grandchildren...)
6. **Produce**: All platforms generate resources over time
7. **Navigate**: Right-click + drag to pan camera, scroll to zoom
8. **Recruit**: Press R to recruit staff (50 GMP, requires available bed)
9. **Assign**: Press U to open Staff Management, assign staff to departments
10. **Upkeep**: Staff cost 1 Material per minute per staff

## Tree Expansion Example

```
HQ (Level 0)
├── R&D Platform 1 (Level 1)
│   ├── Support Platform (Level 2)
│   │   └── Medical Platform (Level 3)
│   └── Combat Platform (Level 2)
├── R&D Platform 2 (Level 1)
│   └── [4 more expansion slots]
└── [4 more expansion slots from HQ]
```

**Total potential**: Unlimited (theoretically 6^n platforms at level n)

## GDScript Quick Reference

When writing GDScript:

- Use snake_case for functions and variables
- Use PascalCase for classes
- Use `_ready()` for initialization
- Use `_process(delta)` for per-frame updates
- Use `_physics_process(delta)` for physics updates
