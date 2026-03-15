extends Node

## Configuration System
## Manages all game configuration with file persistence
## This is the single source of truth for all game settings
## Autoload singleton - accessible via ConfigSystem anywhere in the game

## Configuration file path
const CONFIG_FILE_PATH = "user://settings.cfg"

## Section and key constants
const SECTION_GENERAL = "general"
const KEY_LANGUAGE = "language"
const KEY_DEBUG_MODE = "debug_mode"
const KEY_AUDIO_VOLUME = "audio_volume"
const KEY_MUSIC_VOLUME = "music_volume"

## Internal storage (private)
var _current_config: ConfigData

## Public read-only accessors
var language: String:
	get:
		return _current_config.language

var debug_mode: bool:
	get:
		return _current_config.debug_mode

var audio_volume: float:
	get:
		return _current_config.audio_volume

var music_volume: float:
	get:
		return _current_config.music_volume

func _init():
	_load_config()

## Load configuration from file
func _load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)

	if err != OK:
		print("[ConfigSystem] No config file found, using defaults")
		_current_config = ConfigData.new()
		_save_config()
		return

	# Load settings from file into ConfigData
	var lang = config.get_value(SECTION_GENERAL, KEY_LANGUAGE, "en")
	var debug = config.get_value(SECTION_GENERAL, KEY_DEBUG_MODE, false)
	var audio = config.get_value(SECTION_GENERAL, KEY_AUDIO_VOLUME, 1.0)
	var music = config.get_value(SECTION_GENERAL, KEY_MUSIC_VOLUME, 1.0)

	_current_config = ConfigData.new(lang, debug, audio, music)
	print("[ConfigSystem] Config loaded: ", _current_config.get_as_string())

	# NOTE: Don't apply here in _init()
	# Other autoloads may not be ready yet
	# Application happens in _ready() after all autoloads are initialized

## Save configuration to file
func _save_config():
	var config = ConfigFile.new()

	# Save settings from ConfigData
	config.set_value(SECTION_GENERAL, KEY_LANGUAGE, _current_config.language)
	config.set_value(SECTION_GENERAL, KEY_DEBUG_MODE, _current_config.debug_mode)
	config.set_value(SECTION_GENERAL, KEY_AUDIO_VOLUME, _current_config.audio_volume)
	config.set_value(SECTION_GENERAL, KEY_MUSIC_VOLUME, _current_config.music_volume)

	var err = config.save(CONFIG_FILE_PATH)
	if err == OK:
		print("[ConfigSystem] Config saved successfully")
	else:
		push_error("[ConfigSystem] Failed to save config: error code ", err)

## Get current config (returns a clone)
func get_config() -> ConfigData:
	return _current_config.clone()

## Apply config to game (NO save)
## Use this to update game systems without persisting to file
func apply_config(config: ConfigData):
	_current_config = config.clone()
	_apply_to_game()
	print("[ConfigSystem] Config applied: ", _current_config.get_as_string())

## Save config to file AND apply to game
## Use this to persist settings and update game systems
func save_config(config: ConfigData):
	_current_config = config.clone()
	_apply_to_game()
	_save_config()
	print("[ConfigSystem] Config saved: ", _current_config.get_as_string())

## Called when all autoloads are ready
## Apply configuration to all game systems
func _ready():
	# Apply loaded configuration to all game systems
	# This is called after all autoloads are initialized
	_apply_to_game()

## Internal: Apply current config to all game systems
func _apply_to_game():
	print("[ConfigSystem] Applying configuration to all game systems...")

	# Apply language to TextData
	var text_data = get_node_or_null("/root/TextData")
	if text_data and text_data.has_method("set_language"):
		text_data.set_language(_current_config.language)
		print("[ConfigSystem] Applied language: ", _current_config.language)

	# Apply debug mode to all systems
	_apply_debug_mode(_current_config.debug_mode)

## Internal: Apply debug mode specifically
func _apply_debug_mode(debug_enabled: bool):
	# Apply to ResourceSystem
	var resource_system = get_node_or_null("/root/ResourceSystem")
	if resource_system:
		if resource_system.has_method("set_debug_mode"):
			resource_system.set_debug_mode(debug_enabled)
		else:
			resource_system.debug_mode = debug_enabled
		print("[ConfigSystem] Applied debug mode to ResourceSystem: ", debug_enabled)

	# Apply to main scene (if in game)
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("set_debug_mode"):
		main_scene.set_debug_mode(debug_enabled)
		print("[ConfigSystem] Applied debug mode to main scene: ", debug_enabled)

## Get available languages (for settings menu)
func get_available_languages() -> Array:
	return ["en", "zh"]

## Get language display name
func get_language_display_name(lang_code: String) -> String:
	match lang_code:
		"en": return "English"
		"zh": return "简体中文"
		_: return "Unknown"

## Reset to defaults
func reset_to_defaults():
	var default_config = ConfigData.new()
	save_config(default_config)
	print("[ConfigSystem] Reset to default settings")
