extends Node3D

# Main game controller
# The Base system now handles platform and slot management

@onready var base = $Base
@onready var camera = $Camera3D

# Camera zoom settings
var zoom_min_distance: float = 15.0
var zoom_max_distance: float = 80.0
var zoom_speed: float = 5.0

# Camera position tracking
var camera_offset: Vector3
var camera_target_position: Vector3

func _ready():
	print("=== Mother Base Tree System ===")
	print("Click yellow circles to build platforms")
	print("Right-click + drag to move camera")
	print("Scroll to zoom in/out")
	print("Each platform can have up to 6 child platforms")
	print("")

	# Give player starting resources
	ResourceSystem.add_materials(200)
	ResourceSystem.add_fuel(100)

	# Store initial camera offset from origin
	camera_offset = camera.position

	# Connect to build failure events for feedback
	if base:
		base.build_failed.connect(_on_build_failed)

func _input(event):
	# Handle camera zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()

func _zoom_in():
	# Move camera closer along its offset direction
	var current_distance = camera_offset.length()
	if current_distance > zoom_min_distance:
		var new_distance = max(current_distance - zoom_speed, zoom_min_distance)
		camera_offset = camera_offset.normalized() * new_distance
		_update_camera_position()

func _zoom_out():
	# Move camera away along its offset direction
	var current_distance = camera_offset.length()
	if current_distance < zoom_max_distance:
		var new_distance = min(current_distance + zoom_speed, zoom_max_distance)
		camera_offset = camera_offset.normalized() * new_distance
		_update_camera_position()

func _update_camera_position():
	camera.position = camera_offset

func _on_build_failed(reason: String):
	# Build failure is already logged in base.gd, no need to duplicate
	pass
