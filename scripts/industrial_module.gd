extends Node3D
class_name IndustrialModule

## Industrial module - can have behavior, interaction, and state
## Replaces static MeshInstance3D with dynamic game objects

## Module configuration
var module_id: String = ""
var module_type: String = ""  # radar, crane, turret, helipad, etc.
var module_level: int = 1

## Module state
var activity_state: String = "idle"  # idle, working, disabled, damaged
var rotation_speed: float = 30.0  # Degrees per second

## Visual components
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var interaction_area: Area3D = $InteractionArea

## Signals
signal module_clicked(module: IndustrialModule)
signal state_changed(new_state: String)

func _ready():
	# Setup interaction
	if interaction_area:
		interaction_area.input_event.connect(_on_input_event)

	# Start behavior based on type
	_start_module_behavior()

func _process(delta):
	# Update module behavior
	match module_type:
		"radar", "radar_tower", "satellite_dish":
			_update_radar_behavior(delta)
		"crane":
			_update_crane_behavior(delta)
		"antenna", "antenna_array", "comms_array":
			_update_antenna_behavior(delta)
		"turret":
			_update_turret_behavior(delta)

## Start module-specific behavior
func _start_module_behavior():
	match module_type:
		"radar", "radar_tower", "satellite_dish":
			activity_state = "working"
		"crane":
			activity_state = "working"
		_:
			activity_state = "idle"

## Radar behavior: rotating dish
func _update_radar_behavior(delta):
	if activity_state == "working" and mesh_instance:
		# Rotate radar dish
		mesh_instance.rotation_degrees.y += rotation_speed * delta

## Crane behavior: slow arm movement
func _update_crane_behavior(delta):
	if activity_state == "working" and mesh_instance:
		# Subtle swaying motion
		var sway = sin(Time.get_time_elapsed() * 0.5) * 2.0
		mesh_instance.rotation_degrees.y = sway

## Antenna behavior: gentle blinking
func _update_antenna_behavior(delta):
	if activity_state == "working" and mesh_instance:
		# Gentle pulse
		var pulse = (sin(Time.get_time_elapsed() * 2.0) + 1.0) * 0.5
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			var base_color = material.albedo_color
			material.emission_enabled = true
			material.emission = base_color * pulse * 0.3

## Turret behavior: scanning
func _update_turret_behavior(delta):
	if activity_state == "working" and mesh_instance:
		# Slow scanning motion
		var scan_angle = sin(Time.get_time_elapsed() * 0.3) * 45.0
		mesh_instance.rotation_degrees.y = scan_angle

## Handle interaction (click on module)
func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		module_clicked.emit(self)
		_on_module_clicked()

## Module clicked - override in subclasses or connect to signal
func _on_module_clicked():
	print("Module clicked: ", module_type)
	# Can show info, highlight, etc.

## Set module state
func set_state(new_state: String):
	if activity_state != new_state:
		activity_state = new_state
		state_changed.emit(new_state)
		_update_visuals_for_state()

## Update visuals based on state
func _update_visuals_for_state():
	match activity_state:
		"disabled":
			if mesh_instance:
				var material = mesh_instance.get_surface_override_material(0)
				if material:
					material.albedo_color = Color(0.3, 0.3, 0.3)  # Gray out
		"damaged":
			if mesh_instance:
				var material = mesh_instance.get_surface_override_material(0)
				if material:
					material.albedo_color = Color(0.5, 0.2, 0.2)  # Red tint

## Get module info for UI
func get_module_info() -> Dictionary:
	return {
		"type": module_type,
		"level": module_level,
		"state": activity_state
	}
