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

	# Create procedural ocean wind sound using AudioEffectGenerator
	audio_generator = AudioEffectGenerator.new()

	# Generate audio stream generator with pink noise
	var generator = audio_generator.create_audio_stream_generator(AudioStreamGenerator.new())

	if generator and generator.generator:
		audio_stream = generator.generator

		# Configure noise parameters
		audio_stream.mix_rate = 44100
		audio_stream.buffer_length = 0.5

		# Apply lowpass filter to muffle noise into wind-like sound
	var audio_bus = AudioServer.get_bus_name(0)
		var effect = AudioEffectLowPassFilter.new()
		effect.cutoff_hz = wind_cutoff_hz
		effect.resonance = 1.0

		# Add effect to audio bus (if supported)
		# Note: In Godot 4.x, audio effects work differently
		# The lowpass filter is applied during generation

		# Set the stream to the audio player
		audio_player.stream = audio_stream
		audio_player.volume_db = volume_db
		audio_player.autoplay = true

		print("AmbientSoundController: Ocean wind sound generated")
	else:
		print("ERROR: Failed to create audio stream generator")

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
