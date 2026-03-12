extends Node
class_name AmbientSoundController

## Ambient sound controller for ocean/atmospheric effects
## Plays ocean wind audio file

## Sound settings
var volume_db: float = 20.0  # Background ambient level
var loop: bool = true  # Loop the sound

func _ready():
	_setup_ambient_wind_sound()

func _setup_ambient_wind_sound():
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer
	if not audio_player:
		print("WARNING: AmbientWind node not found")
		return

	# Load ocean wind audio file
	var wind_sound = load("res://assets/audio/sfx/0009056.wav")
	if not wind_sound:
		print("ERROR: Failed to load ocean wind audio file")
		return

	# Configure audio stream for looping
	if wind_sound is AudioStreamWAV:
		var stream: AudioStreamWAV = wind_sound
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = 0  # 0 means end of file

	audio_player.stream = wind_sound
	audio_player.volume_db = volume_db
	audio_player.play()

## Adjust ambient volume
func set_volume(volume: float):
	volume_db = volume
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer
	if audio_player:
		audio_player.volume_db = volume_db

## Stop ambient sound
func stop_ambient():
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer
	if audio_player:
		audio_player.stop()

## Start ambient sound
func start_ambient():
	var audio_player = get_node_or_null("../AmbientWind") as AudioStreamPlayer
	if audio_player:
		audio_player.play()
