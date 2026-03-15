# Platform Builder Data Architecture

## Overview

This directory contains all externalized game data for Platform Builder. Designers can modify JSON files to adjust game balance, content, and configuration without touching any code.

## Directory Structure

```
data/
├── core/                          # Core game constants and settings
│   ├── game_constants.json       # Platform limits, staff economy, bonuses
│   ├── starting_resources.json   # Initial resources for new game
│   └── camera_settings.json      # Zoom, pan, and smooth movement settings
├── platforms/                     # Platform type definitions and rules
│   ├── platform_types.json       # 6 platform types (stats, costs, production)
│   ├── combo_rules.json          # Adjacency bonuses between platforms
│   └── bed_capacity.json         # Beds provided by each platform type
├── modules/                       # Procedural generation data
│   ├── module_library.json       # 18 module definitions
│   └── color_palettes.json       # 4 theme color palettes
├── expeditions/                   # Mission definitions
│   └── missions.json             # 4 expedition mission types
└── story/                        # Multi-language story content
    ├── story_chapters_en.json    # English story chapters
    └── story_chapters_zh.json    # Chinese story chapters
```

## File Formats

### 1. Core Constants (`core/game_constants.json`)

**Purpose:** Define fundamental game limits and economy settings.

**Key Sections:**
- `platform_limits`: Max platforms per department, children per platform
- `staff_economy`: Recruitment cost, upkeep costs, salary
- `department_bonuses`: Research speed and combat power multipliers
- `bed_capacity`: Beds provided by each platform type
- `debt_thresholds`: Warning and game over thresholds

**Example Modifications:**
- Increase max platforms per department: `"max_platforms_per_department": 8`
- Change recruit cost: `"recruit_cost_gmp": 75`
- Adjust research bonus: `"research_speed_per_staff": 0.15`

### 2. Starting Resources (`core/starting_resources.json`)

**Purpose:** Set initial resources for new game start.

**Resources Available:**
- `materials`: Building material (default: 200)
- `fuel`: Fuel resource (default: 100)
- `gmp`: Currency for recruiting (default: 300)
- `beds`: Starting bed capacity (default: 10)

### 3. Camera Settings (`core/camera_settings.json`)

**Purpose:** Configure camera controls and behavior.

**Settings:**
- `zoom`: Min/max distance and step size
- `pan`: Enable/disable, base speed, reference height
- `smooth`: Enable/disable and speed factor

### 4. Platform Types (`platforms/platform_types.json`)

**Purpose:** Define all platform types with stats, costs, and production rates.

**Available Platform Types:**
- HQ: Headquarters (free, central command)
- R&D: Research & Development (produces Materials)
- Combat: Military operations (produces Materials + Fuel)
- Support: Logistics (produces Fuel)
- Intel: Intelligence gathering (produces Fuel)
- Medical: Medical treatment (produces Materials)

**Platform Properties:**
- `production`: Materials and Fuel per second (multiplied by level)
- `costs`: Materials and Fuel to build
- `construction_time`: Time in seconds to build
- `tags`: Used for combo detection

**Balance Tips:**
- Higher production = higher build cost
- Support platforms produce Fuel, combat needs Fuel
- R&D platforms are expensive but boost research

### 5. Combo Rules (`platforms/combo_rules.json`)

**Purpose:** Define adjacency bonuses between platform types.

**Combo Structure:**
- `parent`: Parent platform type
- `child`: Child platform type
- `effect_type`: What bonus is applied
- `bonus`: Numeric bonus value
- `description`: Human-readable description

**Example:**
```json
{
  "parent": "R&D",
  "child": "Intel",
  "effect_type": "research_speed",
  "bonus": 0.2,
  "description": "Faster Research"
}
```

**Effect Types:**
- `research_speed`: +20% research speed
- `casualty_reduction`: -20% casualties
- `expedition_resource_reward`: +10% resource rewards
- `resource_production`: +10% production

### 6. Module Library (`modules/module_library.json`)

**Purpose:** Define procedural modules for platform generation.

**Module Categories:**
- `TOP`: High visibility modules on platform top (radar, antenna)
- `MIDDLE`: Mid-level structures (containers, fuel tanks)
- `EDGE`: Attached to platform edges (crane, turrets)
- `FLOOR`: Platform floor modules (helipad)

**Module Properties:**
- `scale`: [x, y, z] dimensions
- `height`: Visual height for positioning
- `can_rotate`: Whether module can rotate
- `fixed_angles`: Allowed rotation angles (empty = any angle)
- `snap_to_edge`: Whether module attaches to platform edge
- `color_palette`: Which color palette to use

### 7. Color Palettes (`modules/color_palettes.json`)

**Purpose:** Define color themes for procedural generation.

**Available Palettes:**
- Industrial: Gray, rust, dark metal
- Tech: Blue tones, high-tech appearance
- Military: Camo colors, browns and greens
- Medical: White, light blue, clean appearance

**Adding New Palettes:**
```json
{
  "name": "Custom",
  "description": "My custom theme",
  "colors": {
    "primary": "#RRGGBB",
    "secondary": "#RRGGBB",
    "accent": "#RRGGBB",
    "highlight": "#RRGGBB",
    "neutral": "#RRGGBB"
  }
}
```

### 8. Expeditions (`expeditions/missions.json`)

**Purpose:** Define expedition mission types.

**Mission Properties:**
- `duration`: Time in seconds
- `required_combat_power`: Minimum combat power required
- `difficulty`: Easy/Medium/Hard
- `rewards`: Materials, Fuel, GMP, Recruits

**Balance Tips:**
- Longer duration = higher rewards
- Higher combat power requirement = better rewards
- Consider player's current progression

### 9. Story Chapters (`story/story_chapters_*.json`)

**Purpose:** Multi-language story content with chapters, objectives, and dialogue.

**Language Files:**
- `story_chapters_en.json`: English
- `story_chapters_zh.json`: Chinese
- Add more languages by creating `story_chapters_xx.json`

**Chapter Structure:**
- `objectives`: Quest objectives
- `dialogues`: Story conversations
- `completion`: Rewards and next chapter

**Objective Types:**
- `build_platform`: Build specific platform type
- `recruit_staff`: Recruit N staff members
- `assign_staff`: Assign N staff to departments
- `send_expedition`: Complete N expeditions
- `total_platforms`: Have N total platforms
- `all_departments`: Build all department types
- `staff_count`: Have N staff members
- `platform_level`: Build platform at depth N

**Dialogue Triggers:**
- `chapter_start`: When chapter loads
- `objective_complete`: When specific objective completes
- `chapter_complete`: When chapter finishes

## Guidelines for Designers

### 1. File Naming Convention
- Use lowercase with underscores: `platform_types.json`
- Language files: `story_chapters_xx.json` (xx = language code)

### 2. JSON Validation
- Always validate JSON after editing (use online validator)
- Ensure proper comma placement (no trailing commas)
- Use double quotes for strings, not single quotes

### 3. Balance Considerations
- **Platform Balance**: Production rate vs build cost
- **Economy Balance**: Income vs upkeep costs
- **Progression**: Early game vs late game scaling
- **Combo Balance**: Bonuses should be meaningful but not overpowered

### 4. Testing Modifications
1. Save the JSON file
2. Restart the game (or reload scene)
3. Test the modified content
4. Check console for JSON parsing errors

### 5. Version Control
- Always commit JSON files with your changes
- Add comments in commit messages about what changed
- Use descriptive commit messages: "Increase R&D production by 50%"

## Common Modifications

### Change Starting Resources
Edit `core/starting_resources.json`:
```json
{
  "resources": {
    "materials": 500,  // Was 200
    "fuel": 200,       // Was 100
    "gmp": 500,        // Was 300
    "beds": 20         // Was 10
  }
}
```

### Adjust Platform Build Costs
Edit `platforms/platform_types.json`, find the platform, modify `costs`:
```json
{
  "type": "R&D",
  "costs": {
    "materials": 75,  // Was 50
    "fuel": 20        // Was 10
  }
}
```

### Add New Expedition Mission
Edit `expeditions/missions.json`, add to `missions` array:
```json
{
  "id": "new_mission",
  "name": "Mission Name",
  "description": "Mission description",
  "duration": 90,
  "required_combat_power": 4,
  "difficulty": "Medium",
  "rewards": {
    "materials": 150,
    "fuel": 75,
    "gmp": 60,
    "recruits": 1
  }
}
```

### Add New Story Chapter
Edit both language files, add to `chapters` array:
```json
{
  "id": "chapter_07",
  "name": "Chapter Name",
  "description": "Chapter description",
  "objectives": [],
  "dialogues": [],
  "completion": {
    "required_objectives": [],
    "next_chapter": null,
    "rewards": {}
  }
}
```

## Troubleshooting

### Game Won't Start After JSON Edit
1. Check JSON syntax (missing commas, brackets)
2. Look for error messages in console
3. Validate JSON using online tool
4. Compare with backup/original file

### Changes Not Appearing
1. Make sure you saved the JSON file
2. Restart the game completely
3. Check for typos in field names
4. Verify file is in correct directory

### Story Language Not Switching
1. Verify language code in filename (en, zh, etc.)
2. Check ConfigSystem language setting
3. Ensure both language files exist
4. Check console for loading errors

## Support

For questions about data file formats or balance considerations:
1. Check this README first
2. Review existing JSON files for examples
3. Consult with technical team for complex changes
4. Test thoroughly before committing changes

## Version History

- **v1.0** (Current): Initial unified data architecture implementation
  - Externalized all hardcoded game data to JSON
  - Multi-language story support
  - Modular loader system
  - Designer-friendly documentation
