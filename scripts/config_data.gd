class_name ConfigData extends RefCounted

## Configuration data structure
## All game settings in one place for easy extension

var language: String = "en"
var debug_mode: bool = false
var audio_volume: float = 1.0
var music_volume: float = 1.0

func _init(p_language: String = "en", p_debug_mode: bool = false, \
		   p_audio_volume: float = 1.0, p_music_volume: float = 1.0):
	language = p_language
	debug_mode = p_debug_mode
	audio_volume = p_audio_volume
	music_volume = p_music_volume

## Create a copy of this config
func clone() -> ConfigData:
	return ConfigData.new(language, debug_mode, audio_volume, music_volume)

## String representation for debugging
func get_as_string() -> String:
	return "ConfigData(lang=%s, debug=%s, audio=%.2f, music=%.2f)" % \
		   [language, debug_mode, audio_volume, music_volume]
