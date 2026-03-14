# ConfigSystem Refactoring Summary

## Overview

Fixed critical configuration management issues by implementing a data structure architecture with ConfigData class.

## Problems Solved

### 1. Infinite Loop Bug
**Before**: `main.gd:set_debug_mode()` called `config_system.apply_settings()` which called back to `main.gd:set_debug_mode()`, creating an infinite loop.

**After**: Removed loop by having ConfigSystem call main.gd, but main.gd never calls back to ConfigSystem.

### 2. Hard to Extend
**Before**: Adding new settings required changing function signatures: `apply_settings(lang, debug, audio, music, new_setting)`

**After**: Just add a field to ConfigData class, no API changes needed!

## Files Created

### `scripts/config_data.gd`
Configuration data structure that holds all game settings.

**Key Features**:
- Immutable-like design (RefCounted, use clone() to copy)
- Easy to extend (just add new fields)
- Type-safe (compiler checks structure)
- String representation for debugging

```gdscript
var language: String = "en"
var debug_mode: bool = false
var audio_volume: float = 1.0
var music_volume: float = 1.0

func clone() -> ConfigData
func to_string() -> String
```

## Files Modified

### `scripts/config_system.gd`
**API Changes**:
- ❌ OLD: `apply_settings(lang, debug, audio, music)`
- ✅ NEW: `get_config() -> ConfigData`
- ✅ NEW: `apply_config(config: ConfigData)` - Apply without saving
- ✅ NEW: `save_config(config: ConfigData)` - Apply and save

**Benefits**:
- Single parameter instead of 4+ parameters
- Immutable config snapshots via clone()
- Clear separation between apply (no save) and save (apply + persist)

### `ui/settings_menu.gd`
**Changes**:
- Uses `_pending_config: ConfigData` to track unsaved changes
- Calls `config_system.save_config(_pending_config)` on apply
- Cleaner state management with structured data

### `scripts/main.gd`
**Changes**:
- Removed `sync_to_config` parameter (was causing infinite loop)
- Removed `_toggle_debug_mode()` function
- Debug mode now ONLY controlled by settings menu, not keyboard

**Fixed Infinite Loop**:
```gdscript
# OLD (caused loop):
func set_debug_mode(enabled: bool, sync_to_config: bool = false):
    debug_mode = enabled
    if sync_to_config:
        config_system.apply_settings("", debug_mode)  # ← Called back to set_debug_mode()

# NEW (no loop):
func set_debug_mode(enabled: bool):
    debug_mode = enabled
    # NO callback to ConfigSystem
```

### `scripts/input_manager.gd`
**Changes**:
- Removed `debug_info_key_pressed` signal (was used for toggle)
- Removed D key binding
- Kept F key for debug info display (when in debug mode)

### `config_test.gd`
**Changes**:
- Updated to use new ConfigData API
- Added test for ConfigData cloning
- Added test for apply_config() without saving

## How to Use the New API

### Getting Current Configuration
```gdscript
var config_system = get_node_or_null("/root/ConfigSystem")
var current_config = config_system.get_config()
print(current_config.to_string())  # "ConfigData(lang=en, debug=false, audio=1.00, music=1.00)"
```

### Applying Configuration (Without Saving)
```gdscript
# For temporary changes (preview, testing)
var temp_config = ConfigData.new("zh", true, 0.5, 0.5)
config_system.apply_config(temp_config)
# Changes applied to game, but NOT saved to file
```

### Saving Configuration (With Apply)
```gdscript
# For persistent changes (settings menu)
var new_config = ConfigData.new("zh", true, 0.8, 0.9)
config_system.save_config(new_config)
# Changes applied to game AND saved to user://settings.cfg
```

### Modifying Configuration
```gdscript
# Get current, modify, save
var config = config_system.get_config()
config.language = "zh"
config.debug_mode = true
config_system.save_config(config)
```

## How to Add New Settings

### Step 1: Add field to ConfigData
```gdscript
# scripts/config_data.gd
var subtitles_enabled: bool = true
```

### Step 2: Update _init() parameters
```gdscript
func _init(..., p_subtitles_enabled: bool = true):
    ...
    subtitles_enabled = p_subtitles_enabled
```

### Step 3: Update clone() method
```gdscript
func clone() -> ConfigData:
    return ConfigData.new(language, debug_mode, audio_volume, music_volume, subtitles_enabled)
```

### Step 4: Add public getter in ConfigSystem
```gdscript
# scripts/config_system.gd
var subtitles_enabled: bool:
    get:
        return _current_config.subtitles_enabled
```

### Step 5: Add to save/load
```gdscript
# In _save_config():
config.set_value(SECTION_GENERAL, "subtitles_enabled", _current_config.subtitles_enabled)

# In _load_config():
var subs = config.get_value(SECTION_GENERAL, "subtitles_enabled", true)
```

### Step 6: Add UI to settings menu
```gdscript
# ui/settings_menu.gd
var _subtitles_check: CheckBox

func _update_ui():
    _subtitles_check.button_pressed = _pending_config.subtitles_enabled

func _on_subtitles_toggled(toggled_on: bool):
    _pending_config.subtitles_enabled = toggled_on
```

**NO function signature changes needed!** Just add the field and use it.

## Verification Steps

1. **Start Game**: Verify ConfigData loads correctly
   ```
   [ConfigSystem] Config loaded: ConfigData(lang=en, debug=false, audio=1.00, music=1.00)
   ```

2. **Open Settings Menu** (E key → Settings button)
   - Verify current settings display correctly
   - Change language and debug mode
   - Click Apply & Return

3. **Check Console Output**:
   ```
   [SettingsMenu] Settings saved to ConfigSystem: ConfigData(lang=zh, debug=true, audio=1.00, music=1.00)
   [ConfigSystem] Config saved: ConfigData(lang=zh, debug=true, audio=1.00, music=1.00)
   ```

4. **Verify Persistence**:
   - Restart game
   - Check settings menu (should show previous changes)
   - Check debug mode status (F key should show debug info if enabled)

5. **Test File Persistence**:
   - Check `user://settings.cfg` file
   - Should contain:
   ```ini
   [general]
   language="zh"
   debug_mode=true
   audio_volume=1.0
   music_volume=1.0
   ```

6. **Test No Infinite Loop**:
   - Enable debug mode in settings
   - Press F key (should print debug info, NOT toggle)
   - Check console for repeated "Debug mode set to:" messages (should NOT repeat)

7. **Run Test Script**:
   ```bash
   # Temporarily add to project.godot:
   [autoload]
   ConfigTest="*res://config_test.gd"

   # Run game and check console for test results
   ```

## Benefits Achieved

✅ **Fixed Infinite Loop**: No more recursive calls between ConfigSystem and main.gd
✅ **Easy to Extend**: Add new settings by adding fields to ConfigData
✅ **Type Safe**: Compiler checks config structure
✅ **Immutable Snapshots**: clone() creates independent config copies
✅ **Clean API**: Single parameter instead of 4+ parameters
✅ **Clear Intent**: apply_config() vs save_config() makes purpose explicit
✅ **Better Testing**: ConfigData can be easily created and passed around
✅ **Future-Proof**: Graphics settings, subtitles, etc. can be added easily

## Migration Guide for Other Developers

If you have code that uses the old API:

### Old Code
```gdscript
config_system.apply_settings("zh", true, 0.8, 0.9)
```

### New Code
```gdscript
var new_config = ConfigData.new("zh", true, 0.8, 0.9)
config_system.save_config(new_config)
```

### Old Code
```gdscript
var lang = config_system.language
var debug = config_system.debug_mode
```

### New Code (same, but cleaner)
```gdscript
var config = config_system.get_config()
var lang = config.language
var debug = config.debug_mode
```

## Testing Checklist

- [ ] Game starts without errors
- [ ] Settings menu opens and displays current settings
- [ ] Language switch works (English ↔ Chinese)
- [ ] Debug mode toggle works in settings menu
- [ ] Settings persist after game restart
- [ ] F key prints debug info when debug mode is enabled
- [ ] No infinite loop in console output
- [ ] Config test script passes all tests
- [ ] user://settings.cfg file is created and updated correctly
