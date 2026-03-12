extends Node
class_name AmbientSoundController

## Ambient sound controller for ocean/atmospheric effects
## Handles procedural wind sound generation

var audio_generator: AudioEffectGenerator = null
var audio_stream: AudioStreamGenerator = null

## Sound settings
var volume_db: float = -20.0  # Background ambient level
var wind_cutoff_hz: float = 800.0  # Lowpass filter for wind-like sound

func _ready():
	_setup_ambient_wind_sound()

func _setup_ambient_wind_sound():
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer3D
	if not audio_player:
		print("WARNING: AmbientWind node not found")
		return

	# TEMPORARY: Disable procedural sound generation
	# AudioEffectGenerator is not available in Godot 4.6
	# TODO: Add actual wind sound file when available

	print("AmbientSoundController: Wind sound system ready (audio file needed)")
	print("  - Volume: %.1 dB" % volume_db)
	print("  - Lowpass filter: %.0 Hz" % wind_cutoff_hz)

	# For now, just set volume and autoplay
	# When you have a wind sound file, uncomment:
	# audio_player.stream = load("res://sounds/ocean_wind.ogg")
	# audio_player.autoplay = true

## Adjust ambient volume
func set_volume(volume: float):
	volume_db = volume
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer3D
	if audio_player:
		audio_player.volume_db = volume_db

## Stop ambient sound
func stop_ambient():
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer3D
	if audio_player:
		audio_player.stop()
		print("Ambient sound stopped")

## Start ambient sound
func start_ambient():
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer3D
	if audio_player:
		audio_player.play()
		print("Ambient sound started")
