# Expedition Systems Documentation

## Overview

This document explains the **two expedition/combat systems** in the Platform Builder project and why they exist separately.

**Last Updated**: 2026-03-16

## Executive Summary

The project has **two separate expedition systems** that serve **fundamentally different gameplay purposes**:

1. **ExpeditionSystem** - Automated resource generation (passive gameplay)
2. **DungeonCrawlerSystem** - Interactive turn-based combat (active gameplay)

**Key Insight**: These are **NOT duplicate implementations** but **intentional design choices** to provide different player experiences. Both systems are **transitional** - they exist until a full combat system is implemented in the future.

## System Comparison

| Aspect | ExpeditionSystem | DungeonCrawlerSystem |
|--------|------------------|----------------------|
| **Purpose** | Resource generation | Combat progression |
| **Gameplay Style** | Passive, set-and-forget | Active, turn-based combat |
| **Player Control** | High-level (launch/cancel) | Full tactical control |
| **Combat** | Abstract probability rolls | Real-time turn-based HP combat |
| **Rewards** | Materials, Fuel, GMP, Recruits | GMP, Materials, Fuel |
| **Staff Risk** | Injuries (temporary debuff) | Death (permanent) |
| **Game Mode** | Both Sandbox and Story | Standalone combat content |
| **UI** | Base Management Panel | Dungeon Combat UI |
| **Duration** | 60 seconds (modified by R&D) | Variable, based on layers |
| **Concurrency** | Multiple expeditions | Single dungeon at a time |
| **Difficulty** | Based on combat power | Scales per layer (+20% HP, +10% attack) |

## System 1: ExpeditionSystem (Automated Resource Generation)

### File Location
`scripts/expedition_system.gd` (474 lines)

### Core Purpose
**Automated resource generation through abstract expeditions** - inspired by Mother Base's automated operations from Metal Gear Solid V.

### Gameplay Role
- **Economic Engine**: Provides passive resource income
- **Strategic Layer**: Players manage expeditions as part of base economy
- **Staff Utilization**: Gives purpose to staff beyond platform bonuses

### How It Works

#### Starting an Expedition
```
Player opens Base Management Panel (E key)
→ Clicks Expeditions tab
→ Selects mission from available list
→ System checks combat power requirements
→ Player launches expedition
→ 60-second timer starts (modified by R&D staff)
```

#### Combat/Success Mechanics
- **Abstract Combat**: No direct combat visualization
- **Success Calculation**: Probability-based with department bonuses:
  - Base success chance: 50%
  - Intel staff: +5% success chance per staff
  - Support staff: +10% resource yield per staff
  - Medical staff: Reduces casualties
  - R&D staff: -2% duration per staff (max 50% reduction)
- **Result Types**:
  - Critical Success (5% chance): 150% reward bonus
  - Success: Full rewards
  - Partial Success: 50% rewards
  - Failure: No rewards

#### Reward System
- **Base Rewards**: Defined in mission data (JSON)
- **Resource Types**: Materials, Fuel, GMP
- **Special Rewards**: Recruits (on success/critical success)
- **Multipliers**: Support staff bonus, critical success bonus
- **Casualties**: Injuries instead of death (30% stat penalty, temporary)

#### User Interface
- **Access**: Base Management Panel → Expeditions Tab
- **Information**: Mission list, combat power, success chances
- **Feedback**: Notifications on completion

### Integration with Other Systems
- **ResourceSystem**: Direct resource addition
- **DepartmentSystem**: Staff count and bonus calculations
- **NotificationSystem**: Completion and casualty notifications
- **ComboSystem**: Optional combo bonuses
- **GameModeManager**: Works in both Sandbox and Story modes

### Player Experience
**Passive, Strategic Gameplay**:
1. Build Combat platforms for combat power
2. Assign staff to departments (Intel, Support, Medical, R&D)
3. Launch expeditions that match your combat power
4. Wait for completion (60 seconds)
5. Collect rewards automatically

**Appeal**: Players who enjoy base building and strategic planning

## System 2: DungeonCrawlerSystem (Interactive Combat)

### File Location
`scripts/dungeon_crawler_system.gd` (367 lines)

### Core Purpose
**Interactive turn-based combat with dungeon layer progression** - inspired by traditional RPG dungeon crawling.

### Gameplay Role
- **Combat Content**: Provides active combat gameplay
- **Progression System**: Layer-based difficulty scaling
- **Staff Management**: Tactical party selection and risk management

### How It Works

#### Starting a Dungeon
```
Player accesses dungeon deployment UI
→ Selects target platform (distance/difficulty)
→ Chooses party of staff members (up to 4)
→ Starts combat sequence
→ Turn-based combat begins (2-second intervals)
```

#### Combat Mechanics
- **Turn-Based**: 2-second intervals between turns
- **Party System**: Player selects staff members with HP, attack, defense
- **Combat Flow**:
  1. Party attacks simultaneously
  2. Enemy counterattacks
  3. Special abilities (15% critical hit chance for Combat staff)
  4. Victory/defeat determination per layer
- **Layer Progression**: Multiple layers with increasing difficulty:
  - Enemy HP: +20% per layer
  - Enemy attack: +10% per layer
- **Death**: Permanent staff death if HP reaches 0

#### Reward System
- **Base Rewards**: 20 GMP per layer
- **Difficulty Bonus**: +10 GMP for hard layers
- **Resources**: 15 Materials × layers, 10 Fuel × layers
- **Retreat Option**: 50% reward retention if player retreats
- **Total Rewards**: GMP = (20 × layers) + bonuses

#### User Interface
- **Access**: Dungeon deployment and party selection menus
- **Combat UI**: Real-time visualization of combat turns
- **Feedback**: HP bars, damage numbers, layer progress

### Integration with Other Systems
- **ResourceSystem**: GMP, Materials, Fuel distribution
- **DepartmentSystem**: Staff management and death handling
- **DungeonCombatUI**: Real-time combat visualization
- **Staff System**: HP, attack, defense attributes
- **Pathfinder System**: Platform distance/difficulty calculation

### Player Experience
**Active, Tactical Gameplay**:
1. Select staff with good combat stats
2. Choose dungeon difficulty based on party strength
3. Watch turn-based combat unfold
4. Make strategic decisions (retreat or push forward)
5. Risk staff death for higher rewards

**Appeal**: Players who enjoy tactical combat and risk management

## Why Two Systems Exist

### Intentional Design Decision

The dual systems are **NOT accidental duplicates** but **intentional design choices** to provide different gameplay experiences:

#### 1. Different Player Preferences
- **ExpeditionSystem**: Appeals to base builders and strategy gamers
- **DungeonCrawlerSystem**: Appeals to RPG and combat fans

#### 2. Different Gameplay Pacing
- **ExpeditionSystem**: Slow, strategic, long-term planning
- **DungeonCrawlerSystem**: Fast, tactical, immediate decisions

#### 3. Different Risk Profiles
- **ExpeditionSystem**: Low risk (injuries, not death)
- **DungeonCrawlerSystem**: High risk (permanent death)

#### 4. Different Game Loops
- **ExpeditionSystem**: Supports base building loop
- **DungeonCrawlerSystem**: Provides combat content loop

### Transitional Architecture

Both systems are **intentionally transitional**:

**Current State**: Two separate systems provide variety
**Future Vision**: May be replaced or enhanced by a full combat system

**Rationale**: Rather than waiting for a perfect combat system, the project provides two functional systems that serve different gameplay niches.

## Code Architecture

### Shared Patterns

Both systems share these architectural patterns:

1. **Autoload Singletons**: Both are global autoloads
2. **JSON Data Loading**: External data for missions/dungeons
3. **Resource Integration**: Interface with ResourceSystem
4. **Timer Management**: Use Timer nodes for progression
5. **Department Integration**: Leverage DepartmentSystem for staff calculations

### Code Quality Assessment

**Strengths**:
- ✅ **Well-Separated**: Clear architectural boundaries
- ✅ **Independent Operation**: Can run simultaneously
- ✅ **Minimal Duplication**: Different approaches, little shared code
- ✅ **Good Integration**: Clean interfaces with other systems

**No Significant Issues**:
- The systems are properly separated
- Code duplication is minimal and appropriate
- Architectural patterns are consistent

## Future Evolution

### Current Plans (Transitional)

Both systems are considered **transitional** until a full combat system is designed:

**Short Term**: Keep both systems as-is
**Medium Term**: Enhance各自 systems based on player feedback
**Long Term**: Consider unified combat system

### Potential Unified Combat System

If a unified combat system is developed, it could:

1. **Hybrid Approach**: Optional combat during expeditions
   - Expeditions default to abstract (current ExpeditionSystem)
   - Players can opt-in to tactical combat (DungeonCrawlerSystem style)
   - Risk/reward: tactical combat offers higher rewards but casualties

2. **Separate Systems**: Keep both for different purposes
   - Expeditions for resource generation
   - Dungeons for story missions and special content

3. **Progressive Combat**: Enhanced expedition combat
   - Start with abstract combat (expeditions)
   - Unlock tactical combat (dungeon crawler)
   - Full combat system for boss battles/story events

### Recommendation: Maintain Separation

**Current Recommendation**: **Keep both systems separate**

**Rationale**:
- Different gameplay purposes (economic vs combat)
- Different player expectations (passive vs active)
- Different complexity levels (simple vs complex)
- Both systems work well as-is

**Future Consideration**: Only unify if:
- Player feedback strongly suggests it
- A unified combat system offers clear benefits
- The complexity of unification is justified

## Integration with Game Modes

### Sandbox Mode
- **ExpeditionSystem**: ✅ Full integration for resource generation
- **DungeonCrawlerSystem**: ✅ Available for combat content

### Story Mode
- **ExpeditionSystem**: ✅ Full integration for resource generation
- **DungeonCrawlerSystem**: ✅ Potentially used for story missions

### Future Game Modes
Both systems could support additional game modes:
- **Challenge Mode**: Time-limited expeditions
- **Hardcore Mode**: Permadeath dungeons
- **Co-op Mode**: Multiplayer expeditions or dungeons

## Technical Implementation

### File Structure
```
scripts/
├── expedition_system.gd        (474 lines)
├── dungeon_crawler_system.gd   (367 lines)
└── department_system.gd        (Shared dependency)

data/
├── expeditions.json            (Expedition missions)
└── dungeons.json               (Dungeon definitions)

ui/
├── base_management_panel.tscn  (Expedition UI)
└── dungeon_combat_ui.tscn      (Dungeon combat UI)
```

### Key Classes and Methods

#### ExpeditionSystem
```gdscript
class_name ExpeditionSystem
extends Node

# Core methods
func launch_expedition(mission_id: String)
func _on_expedition_timer_timeout()
func calculate_success_chance() -> float
func distribute_rewards(result_type: String)
```

#### DungeonCrawlerSystem
```gdscript
class_name DungeonCrawlerSystem
extends Node

# Core methods
func start_dungeon(platform_id, party: Array)
func _on_combat_timer_timeout()
func process_combat_turn()
func handle_layer_complete()
```

## Performance Considerations

### ExpeditionSystem
- **Low Performance Impact**: Simple timer-based checks
- **Multiple Concurrent**: Can handle many expeditions simultaneously
- **Database**: Minimal state storage per expedition

### DungeonCrawlerSystem
- **Medium Performance Impact**: Turn-based calculations every 2 seconds
- **Single Instance**: Only one dungeon at a time
- **Combat Calculations**: More complex per-turn logic

## Conclusion

The dual expedition systems in Platform Builder are **intentional, well-designed, and appropriate** for the game's current state:

1. **ExpeditionSystem** provides excellent passive resource generation
2. **DungeonCrawlerSystem** provides engaging tactical combat
3. Both systems serve different gameplay purposes and player preferences
4. The architecture is clean with minimal code duplication
5. Both systems are transitional and may evolve in the future

**Key Takeaway**: This is not a bug or architectural flaw, but a **thoughtful design decision** to provide varied gameplay experiences while a full combat system is being developed.

## Related Documentation

- `docs/AUTOLOAD_ARCHITECTURE.md` - Autoload architecture overview
- `CLAUDE.md` - Project overview and implementation details
- `MEMORY.md` - Auto-memory for Claude Code context

---

**Document Status**: ✅ Complete
**Next Review**: When combat system development begins
**Maintainer**: Development team
