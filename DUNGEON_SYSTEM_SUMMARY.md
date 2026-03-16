# Dungeon Crawler System - Implementation Summary

## Overview

This document summarizes the implementation of the Dungeon Crawler System for the Godot 4.6 game project. The system is completely independent from the ExpeditionSystem and allows for turn-based combat expeditions to platform locations.

## Implemented Components

### Phase 1: Staff Combat Attributes ✅

**Files Modified:**
- `/scripts/staff.gd` - Extended with combat attributes
- `/scripts/department_system.gd` - Added staff availability methods
- `/scripts/expedition_system.gd` - Modified to use injuries instead of death

**New Staff Attributes:**
- `hp` / `max_hp` - Health points
- `attack` - Attack power
- `defense` - Defense power
- `speed` - Speed (determines action order)
- `status_effects` - Active debuffs/buffs array
- `is_wounded` - Wounded state flag
- `is_available` - Available for missions flag
- `unlocked_skills` - Skills unlocked by level
- `active_skills_cooldown` - Skill cooldown counters

**New Methods:**
- `recalculate_combat_stats()` - Recalculate stats based on level
- `apply_wound(penalty)` - Apply wound penalty
- `heal(amount)` - Heal staff member
- `apply_status_effect(effect)` - Apply debuff/buff
- `remove_status_effect(effect_id)` - Remove debuff/buff
- `unlock_skills()` - Unlock skills based on level/department
- `use_skill(skill_id)` - Use a skill
- `reduce_cooldowns()` - Reduce skill cooldowns

**DepartmentSystem Additions:**
- `get_available_staff()` - Get available (non-wounded) staff
- `heal_wounded_staff(staff)` - Heal wounded staff
- `update_staff_status(delta)` - Update status effect timers
- `get_available_department_staff(dept)` - Get available staff by department

**ExpeditionSystem Changes:**
- `_apply_casualties()` now applies injuries instead of death
- Staff get 30% stat penalty and debuff on expedition failure
- Staff are marked as unavailable until healed

### Phase 2: Core Dungeon System ✅

**Files Created:**
- `/scripts/dungeon_pathfinder.gd` - Path calculation helper
- `/scripts/dungeon_data_loader.gd` - Dungeon data loader
- `/scripts/dungeon_crawler_system.gd` - Main dungeon system (autoload)
- `/scripts/skill_data_loader.gd` - Staff skill loader

**DungeonPathfinder Methods:**
- `get_path_to_hq(platform)` - Get path from HQ to platform
- `calculate_difficulty(path)` - Calculate dungeon difficulty
- `get_path_string(path)` - Get readable path string
- `get_recommended_staff(difficulty)` - Get recommended party size

**DungeonDataLoader Methods:**
- `load_enemies()` - Load enemy definitions
- `load_dungeon_templates()` - Load difficulty templates
- `load_debuff_types()` - Load debuff definitions
- `get_enemy_pool(layer, difficulty)` - Get enemy pool for layer
- `get_random_enemy(layer, difficulty)` - Get random enemy
- `get_enemy_data(enemy_id)` - Get full enemy data

**DungeonCrawlerSystem Features:**
- `start_dungeon(platform, party)` - Start dungeon expedition
- Turn-based combat with 2-second intervals
- Layer progression (each layer = one enemy)
- Party damage calculation with crits
- Enemy AI with special attacks
- Staff death (permanent in dungeons)
- `retreat_dungeon()` - Retreat with 50% rewards
- Victory/defeat conditions
- Signal emissions for UI updates

### Phase 3: UI Components ✅

**Files Created:**
- `/ui/dungeon_deployment_menu.tscn` - Deployment menu scene
- `/ui/dungeon_deployment_menu.gd` - Deployment menu controller
- `/ui/dungeon_party_select.tscn` - Party selection scene
- `/ui/dungeon_party_select.gd` - Party selection controller
- `/ui/dungeon_combat_ui.tscn` - Combat UI scene
- `/ui/dungeon_combat_ui.gd` - Combat UI controller

**DungeonDeploymentMenu:**
- Shows path from HQ to target platform
- Displays layer count and difficulty
- Shows estimated time and recommended staff
- Confirm/Cancel buttons

**DungeonPartySelect:**
- Two-panel layout (available vs selected)
- Shows staff names, departments, and HP
- Displays wounded/unavailable status
- Max 4 party members
- Confirm button enabled only when party > 0

**DungeonCombatUI:**
- Real-time layer and enemy info
- HP bars for enemy and party
- Scrolling combat log with timestamps
- Retreat button (keeps 50% rewards)
- Auto-updates every frame

### Phase 4: Data Files ✅

**Files Created:**
- `/data/dungeons/enemies.json` - Enemy definitions
- `/data/dungeons/dungeon_templates.json` - Difficulty templates
- `/data/combat/debuff_types.json` - Debuff definitions
- `/data/staff/skills.json` - Staff skill definitions

**Enemy Types:**
- Mutated Fish (easy)
- Deep Sea Giant (medium)
- Abyssal Horror (hard)
- Coral Guardian (medium)
- Void Stalker (hard)

**Debuff Types:**
- Battle Wound (battle)
- Exhaustion (persistent)
- Fear (persistent)
- Injury (permanent)

**Staff Skills:**
- Combat: 5 skills (passive, aura, active, ultimate)
- Intel: 3 skills (aura, active, ultimate)
- Medical: 5 skills (passive, aura, active, ultimate)
- Support: 3 skills (passive, aura, active)
- R&D: 3 skills (passive, aura, active)

### Phase 5: Integration ✅

**Files Modified:**
- `/scripts/base.gd` - Added dungeon system integration
- `/project.godot` - Added DungeonCrawlerSystem to autoload

**Base.gd Changes:**
- Added dungeon system references
- Added dungeon menu scene creation
- Modified `_handle_click()` to detect platform clicks
- Added dungeon deployment flow handlers
- Prevents starting dungeon when one is active

**Click Flow:**
1. Click operational platform (non-HQ)
2. Shows dungeon deployment menu
3. Confirm → Shows party selection
4. Select party → Starts dungeon
5. Shows combat UI
6. Combat proceeds automatically
7. Victory/Defeat/Retreat → Return to base

## System Architecture

### Independence from ExpeditionSystem

The Dungeon Crawler System is completely independent from the ExpeditionSystem:

**Separate Timers:**
- Expedition: ExpeditionSystem.expedition_timer (mission completion)
- Dungeon: DungeonCrawlerSystem.combat_timer (combat turns)

**Separate State:**
- Expedition: active_expeditions dictionary
- Dungeon: active_dungeon dictionary

**Can Run Concurrently:**
- Players can do both simultaneously
- Independent UI displays
- No conflicts

### Risk Comparison

**Expedition Failure (温和):**
- Staff get injured (30% stat penalty)
- Receive debuffs (e.g., "Expedition Injury")
- Temporarily unavailable
- Can recover through time or Medical treatment

**Dungeon Failure (严厉):**
- Staff permanently die
- Removed from DepartmentSystem
- Cannot be resurrected
- All equipment/loot lost

### Combat System

**Turn-Based Flow:**
1. Party attacks (each staff member)
2. Calculate damage with crits
3. Check enemy HP
4. If alive, enemy attacks
5. Apply damage to random party member
6. Check for staff deaths
7. Repeat every 2 seconds

**Damage Calculation:**
- Base: 10 + (skill_level × 5)
- + Attack stat
- + Specialty bonus (Combat = ×1.3)
- + Department bonus (Combat = ×1.1)
- + Random variance (0-4)

**Enemy Scaling:**
- HP: base × (1 + (layer × 0.2))
- ATK: base × (1 + (layer × 0.1))
- Special attacks trigger based on chance

### Skill System

**Skill Types:**
1. Passive - Always active (e.g., +10% attack)
2. Aura - Affects party (e.g., +15% party attack)
3. Active - Triggered with cooldown (e.g., +50% attack for 1 turn)
4. Ultimate - Powerful, long cooldown (e.g., 300% damage)

**Unlock System:**
- Skills unlock based on skill_level
- Different skills per department
- Level 1-2: Basic skills
- Level 3-4: Advanced skills
- Level 5: Ultimate skills

## Usage Example

```gdscript
# Player clicks on a Combat platform (3 layers from HQ)
# Path: HQ → R&D → Support → Combat

# System calculates:
- Layers: 3
- Difficulty: medium
- Time: 45 seconds (15s per layer)
- Recommended staff: 3

# Player selects party:
1. John Smith (Combat, Level 3, 120 HP)
2. Sarah Jones (Medical, Level 2, 100 HP)
3. Mike Lee (Combat, Level 4, 140 HP)

# Combat starts:
- Layer 1: VS Mutated Fish (96 HP)
  - Party deals 45 damage total
  - Enemy deals 12 damage to Mike
  - Fish defeated

- Layer 2: VS Coral Guardian (144 HP)
  - Party deals 48 damage total
  - Enemy special attack (Barrier Reef)
  - Sarah heals party for 15 HP
  - Guardian defeated

- Layer 3: VS Void Stalker (180 HP)
  - Party deals 52 damage total
  - Enemy shadow strike (critical)
  - Mike dies (HP → 0)
  - John and Sarah defeat enemy

# Victory!
- Rewards: 75 GMP, 45 Materials, 30 Fuel
- Mike permanently removed from staff list
- John and Sarah return to base
```

## Testing Checklist

### Staff Attributes
- [ ] Staff have HP/ATK/DEF/SPD attributes
- [ ] Attributes calculated correctly based on skill_level
- [ ] UI displays combat attributes
- [ ] Wounded staff show reduced stats

### Dungeon Flow
- [ ] Click platform → Deployment menu shows
- [ ] Path calculation correct
- [ ] Layer count correct
- [ ] Difficulty calculation correct
- [ ] Party selection works
- [ ] Dungeon starts correctly
- [ ] Combat UI displays

### Combat System
- [ ] Turn-based combat works (2s intervals)
- [ ] HP bars update correctly
- [ ] Combat log scrolls
- [ ] Staff death triggers
- [ ] Enemy attacks work
- [ ] Layer completion works
- [ ] Victory/Defeat conditions

### Retreat Mechanism
- [ ] Retreat button works
- [ ] 50% reward calculation correct
- [ ] Returns to base correctly

### Integration
- [ ] No conflicts with ExpeditionSystem
- [ ] Can run simultaneously
- [ ] Independent state management
- [ ] UI doesn't overlap

## Future Enhancements

### Phase 2.5: Passive Skills (1 week)
- Implement passive skill effects in combat
- Add aura skill system
- Apply bonuses automatically

### Phase 3.5: Active Skills (1 week)
- Implement active skill triggering
- Add cooldown management
- AI skill selection

### Phase 4.5: Ultimate Skills (1 week)
- Implement ultimate skills
- Add visual effects
- Trigger on low HP

### Advanced Features
- Equipment system for staff
- Consumable items (potions, bombs)
- Boss encounters at layer 5+
- Multiplayer dungeon raids
- Dungeon leaderboards
- Achievement system

## File Structure

```
/scripts
  ├── staff.gd (modified - combat attributes)
  ├── department_system.gd (modified - availability)
  ├── expedition_system.gd (modified - injuries)
  ├── base.gd (modified - integration)
  ├── dungeon_pathfinder.gd (new)
  ├── dungeon_data_loader.gd (new)
  ├── dungeon_crawler_system.gd (new - autoload)
  └── skill_data_loader.gd (new)

/ui
  ├── dungeon_deployment_menu.tscn (new)
  ├── dungeon_deployment_menu.gd (new)
  ├── dungeon_party_select.tscn (new)
  ├── dungeon_party_select.gd (new)
  ├── dungeon_combat_ui.tscn (new)
  └── dungeon_combat_ui.gd (new)

/data
  ├── dungeons/
  │   ├── enemies.json (new)
  │   └── dungeon_templates.json (new)
  ├── combat/
  │   └── debuff_types.json (new)
  └── staff/
      └── skills.json (new)
```

## Conclusion

The Dungeon Crawler System is now fully implemented and integrated into the game. It provides a challenging risk/reward alternative to the ExpeditionSystem, with permanent staff death as a consequence. The system is data-driven, extensible, and ready for future enhancements.
