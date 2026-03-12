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
@onready var visual: MeshInstance3D = $Visual
@onready var interaction_area: Area3D = $InteractionArea

## Radar scan effect (optional)
var radar_scan_effect: RadarScanEffect = null
var show_radar_scan: bool = true  # Can be toggled

## Behavior mapping - avoids match statement explosion
const BEHAVIOR_MAP = {
	# Radar-type modules
	"radar": "_update_radar_behavior",
	"radar_tower": "_update_radar_behavior",
	"satellite_dish": "_update_radar_behavior",
	"sensor_array": "_update_radar_behavior",

	# Crane modules
	"crane": "_update_crane_behavior",

	# Communication modules
	"antenna": "_update_antenna_behavior",
	"antenna_array": "_update_antenna_behavior",
	"comms_array": "_update_antenna_behavior",

	# Defense modules
	"turret": "_update_turret_behavior"
}

## Cached behavior function for performance
var _behavior_func: Callable

## Signals
signal module_clicked(module: IndustrialModule)
signal state_changed(new_state: String)

func _ready():
	# Setup interaction (handle internally, not in generator)
	if interaction_area:
		interaction_area.monitoring = false
		interaction_area.monitorable = false
		interaction_area.input_ray_pickable = true
		interaction_area.input_event.connect(_on_input_event)

	# Cache behavior function for performance
	_cache_behavior_function()

	# Create radar scan effect for radar-type modules
	if _is_radar_module():
		_create_radar_scan_effect()

	# Start behavior based on type
	_start_module_behavior()

func _process(delta):
	# Use cached behavior function instead of match
	if activity_state == "working" and _behavior_func.is_valid():
		_behavior_func.call(delta)

	# Note: Radar scan animation is handled by RadarScanEffect node


## Cache the behavior function for this module type
func _cache_behavior_function():
	var behavior_name = BEHAVIOR_MAP.get(module_type)
	if behavior_name != null and has_method(behavior_name):
		_behavior_func = Callable(self, behavior_name)
	else:
		# Create an invalid callable if no behavior found
		_behavior_func = Callable()

## Start module-specific behavior
func _start_module_behavior():
	if module_type in BEHAVIOR_MAP:
		activity_state = "working"
	else:
		activity_state = "idle"

## Radar behavior: rotating dish
func _update_radar_behavior(delta):
	if visual:
		visual.rotation_degrees.y += rotation_speed * delta

## Crane behavior: slow arm movement
func _update_crane_behavior(delta):
	if visual:
		var time_sec = Time.get_ticks_msec() / 1000.0
		var sway = sin(time_sec * 0.5) * 2.0
		visual.rotation_degrees.y = sway

## Antenna behavior: gentle blinking
func _update_antenna_behavior(delta):
	if visual:
		var time_sec = Time.get_ticks_msec() / 1000.0
		var pulse = (sin(time_sec * 2.0) + 1.0) * 0.5
		var material = visual.get_surface_override_material(0)
		if material:
			var base_color = material.albedo_color
			material.emission_enabled = true
			material.emission = base_color * pulse * 0.3

## Turret behavior: scanning
func _update_turret_behavior(delta):
	if visual:
		var time_sec = Time.get_ticks_msec() / 1000.0
		var scan_angle = sin(time_sec * 0.3) * 45.0
		visual.rotation_degrees.y = scan_angle

## Handle interaction (click on module) - handled internally
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
			if visual:
				var material = visual.get_surface_override_material(0)
				if material:
					material.albedo_color = Color(0.3, 0.3, 0.3)  # Gray out
		"damaged":
			if visual:
				var material = visual.get_surface_override_material(0)
				if material:
					material.albedo_color = Color(0.5, 0.2, 0.2)  # Red tint

## Get module info for UI
func get_module_info() -> Dictionary:
	return {
		"type": module_type,
		"level": module_level,
		"state": activity_state
	}

## ===== RADAR SCAN EFFECT =====

## Check if this is a radar-type module
func _is_radar_module() -> bool:
	return module_type in ["radar", "radar_tower", "satellite_dish", "sensor_array"]

## Create radar scan effect
func _create_radar_scan_effect():
	# Use RadarScanEffect node instead of shader approach
	radar_scan_effect = RadarScanEffect.new()
	add_child(radar_scan_effect)
	print("Radar scan effect created for module: ", module_type)
