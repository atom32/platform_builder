class_name ConfigData extends RefCounted

## Configuration data structure
## All game settings in one place for easy extension

var language: String = "en"
var debug_mode: bool = false
var audio_volume: float = 1.0
var music_volume: float = 1.0
var resolution_x: int = 1920
var resolution_y: int = 1080
var fullscreen_mode: int = 0
var vsync_enabled: bool = true
var borderless_window: bool = false

func _init(p_language: String = "en", p_debug_mode: bool = false, \
		   p_audio_volume: float = 1.0, p_music_volume: float = 1.0, \
		   p_resolution_x: int = 1920, p_resolution_y: int = 1080, \
		   p_fullscreen_mode: int = 0, p_vsync_enabled: bool = true, \
		   p_borderless_window: bool = false):
	language = p_language
	debug_mode = p_debug_mode
	audio_volume = p_audio_volume
	music_volume = p_music_volume
	resolution_x = p_resolution_x
	resolution_y = p_resolution_y
	fullscreen_mode = p_fullscreen_mode
	vsync_enabled = p_vsync_enabled
	borderless_window = p_borderless_window

## Create a copy of this config
func clone() -> ConfigData:
	return ConfigData.new(language, debug_mode, audio_volume, music_volume, \
						 resolution_x, resolution_y, fullscreen_mode, \
						 vsync_enabled, borderless_window)

## String representation for debugging
func get_as_string() -> String:
	return "ConfigData(lang=%s, debug=%s, res=%dx%d, mode=%d, vsync=%s)" % \
		   [language, debug_mode, resolution_x, resolution_y, \
			fullscreen_mode, vsync_enabled]
