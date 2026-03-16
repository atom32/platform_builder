# Settings Architecture Improvement

## Problem Identified by User

Settings should be **menu-level functionality**, unified across all game modes.
- Settings should NOT depend on specific game mode initialization
- Settings should be applied consistently regardless of mode (Story/Sandbox)

## Previous Architecture Issues

### Problem 1: ConfigSystem Applied Settings Too Early
```gdscript
func _init():
    _load_config()  # Called during autoload initialization
    
func _load_config():
    // Load config...
    _apply_to_game()  // ❌ Other autoloads may not be ready yet!
```

**Issue**: ConfigSystem is autoload #1, but TextData, ResourceSystem, etc.
may not be initialized when _init() is called.

### Problem 2: Duplicate Logic in Game Modes
```gdscript
// main.gd
func _ready():
    // Manually apply debug mode
    debug_mode = config_system.debug_mode
    resource_system.debug_mode = debug_mode
```

**Issue**: Application logic scattered across codebase, not unified.

## New Architecture

### ConfigSystem: Unified Settings Manager

```gdscript
// ConfigSystem initialization flow
func _init():
    _load_config()  // Load from file only, don't apply yet
    
func _ready():
    // Called AFTER all autoloads are initialized
    _apply_to_game()  // ✅ Safe to apply now
    
func _apply_to_game():
    // Apply to ALL game systems
    TextData.set_language(language)
    ResourceSystem.set_debug_mode(debug_mode)
    Main.set_debug_mode(debug_mode)  // Via callback
```

### Game Scenes: Remove Duplicate Logic

```gdscript
// main.gd - BEFORE (duplicate logic)
func _ready():
    debug_mode = config_system.debug_mode
    resource_system.debug_mode = debug_mode  // ❌ Duplicate

// main.gd - AFTER (clean)
func _ready():
    // ConfigSystem already applied everything
    debug_mode = config_system.debug_mode  // ✅ Just read, don't apply
```

## Benefits

1. **✅ Unified Settings**: All game modes use same settings
2. **✅ Menu-Level**: Settings applied once, everywhere
3. **✅ No Duplication**: Single source of truth (ConfigSystem)
4. **✅ Timing Correct**: Applied after all autoloads ready
5. **✅ Maintainable**: Changes in one place affect all modes

## Testing

### Before Fix
- Settings menu: Shows Chinese (saved)
- Free Sandbox: English (config not applied)
- Story Mode: Chinese (had separate init)

### After Fix
- Settings menu: Shows Chinese (saved)
- Free Sandbox: Chinese ✅ (config applied)
- Story Mode: Chinese ✅ (config applied)

## Implementation Details

### Modified Files
1. `scripts/config_system.gd`
   - Added `_ready()` method
   - Moved `_apply_to_game()` call from `_init()` to `_ready()`
   
2. `scripts/main.gd`
   - Removed duplicate debug_mode application
   - Now only reads from ConfigSystem

### Call Flow

```
Game Start
  ↓
ConfigSystem._init()
  → Load config from file
  → Store in _current_config
  ↓
[All other autoloads initialize]
  ↓
ConfigSystem._ready()
  → _apply_to_game()
  → Apply to TextData (language)
  → Apply to ResourceSystem (debug_mode)
  → Apply to Main (debug_mode via callback)
  ↓
Game Scenes Start
  → All settings already applied ✅
```

## Principle

**Settings are menu-level functionality, not game-level.**

Like graphics options or audio settings in any game:
- Set once in menu
- Apply everywhere
- Don't depend on game mode
