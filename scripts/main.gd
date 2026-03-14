extends Node3D

# Main game controller
# The Base system now handles platform and slot management

@onready var base = $Base
@onready var camera = $Camera3D
@onready var base_management_panel: BaseManagementPanel = $BaseManagementPanel as BaseManagementPanel

# Camera zoom settings
var zoom_min_distance: float = 15.0
var zoom_max_distance: float = 80.0
var zoom_speed: float = 5.0

# Camera position tracking
var camera_offset: Vector3
var camera_target_position: Vector3

# Camera rotation (fixed for RTS-style view)
var camera_tilt: float = -30.0  # Downward tilt angle in degrees

# Focus point marker (visualization)
var focus_marker: MeshInstance3D = null

# Debug mode - controlled by ConfigSystem
var debug_mode: bool = false

func _ready():
	# Load debug mode from ConfigSystem FIRST
	var config_system = get_node_or_null("/root/ConfigSystem")
	if config_system:
		debug_mode = config_system.debug_mode
		print("[Main] Debug mode loaded from ConfigSystem: ", debug_mode)
	else:
		print("[Main] WARNING: ConfigSystem not found, using default debug_mode: ", debug_mode)

	# Apply debug mode to ResourceSystem
	var resource_system = get_node_or_null("/root/ResourceSystem")
	if resource_system:
		resource_system.debug_mode = debug_mode

	# Initialize game session (resets everything to clean state)
	var game_session = get_node_or_null("/root/GameSession")
	var game_mode_manager = get_node_or_null("/root/GameModeManager")
	var story_system = get_node_or_null("/root/StorySystem")

	if game_session:
		var mode = 0  # Default to FREE_SANDBOX
		if game_mode_manager:
			mode = game_mode_manager.current_mode
		game_session.start_session(mode)
		game_session.game_over.connect(_on_game_over)

	# Initialize StorySystem if in Story Mode
	if story_system and game_mode_manager:
		if game_mode_manager.current_mode == 1:  # STORY_MODE
			story_system.initialize_story_mode()

	# Give player starting resources (after reset)
	ResourceSystem.add_materials(200)
	ResourceSystem.add_fuel(100)
	ResourceSystem.add_gmp(300)  # Starting GMP for recruiting
	# Beds are provided by platforms (HQ provides 5)

	# Register starting objectives
	_register_starting_objectives()

	# Store initial camera offset from origin
	camera_offset = camera.position

	# Create focus point marker (debug mode only)
	if debug_mode:
		_create_focus_marker()

	# Connect to build failure events for feedback
	if base:
		base.build_failed.connect(_on_build_failed)

	# Connect to staff recruitment signal
	ResourceSystem.staff_recruited.connect(_on_staff_recruited)

	# Connect to input manager signals for keyboard shortcuts
	var input_manager = get_node_or_null("/root/InputManager")
	if input_manager:
		input_manager.recruit_key_pressed.connect(_recruit_staff)
		input_manager.base_management_key_pressed.connect(_toggle_base_management)
		# Debug mode is now controlled only through settings menu, not keyboard toggle
		input_manager.debug_mode_key_pressed.connect(_on_debug_mode_key)

func _input(event):
	# Camera zoom is now handled by CameraController
	# TODO: Remove this after confirming everything works
	# if event is InputEventMouseButton:
	# 	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
	# 		_zoom_in()
	# 	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
	# 		_zoom_out()
	pass


func _on_debug_info():
	if debug_mode:
		_print_focus_debug()

func _process(delta):
	# Update focus marker position to follow camera view (debug mode only)
	if debug_mode:
		_update_focus_marker_position()

func _zoom_in():
	# Move camera closer to focus point along view direction
	if not focus_marker:
		return

	var current_distance = camera.position.distance_to(focus_marker.position)
	if current_distance > zoom_min_distance:
		var new_distance = max(current_distance - zoom_speed, zoom_min_distance)
		var direction = (focus_marker.position - camera.position).normalized()
		camera.position = focus_marker.position - direction * new_distance
		if debug_mode:
			_update_focus_marker_size()

func _zoom_out():
	# Move camera away from focus point along view direction
	if not focus_marker:
		return

	var current_distance = camera.position.distance_to(focus_marker.position)
	if current_distance < zoom_max_distance:
		var new_distance = min(current_distance + zoom_speed, zoom_max_distance)
		var direction = (focus_marker.position - camera.position).normalized()
		camera.position = focus_marker.position - direction * new_distance
		if debug_mode:
			_update_focus_marker_size()

func _on_build_failed(reason: String):
	# Build failure is already logged in base.gd, no need to duplicate
	pass

## Create focus point marker for visualization
func _create_focus_marker():
	focus_marker = MeshInstance3D.new()
	var marker_mesh = SphereMesh.new()
	marker_mesh.radius = 0.8  # Smaller size for debug
	marker_mesh.height = 1.6  # Height should be 2x radius
	marker_mesh.radial_segments = 16
	focus_marker.mesh = marker_mesh

	# Set initial position (at origin, on ocean surface)
	focus_marker.position = Vector3(0, -3.5, 0)  # Match ocean y-coordinate

	# Create bright red material for visibility
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.0, 0.0)  # Bright red
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.5  # More opaque for visibility
	material.emission_enabled = true  # Make it glow
	material.emission = Color(1.0, 0.0, 0.0)  # Red glow
	focus_marker.set_surface_override_material(0, material)

	add_child(focus_marker)

	# Make focus marker look at camera
	focus_marker.look_at(camera.position, Vector3(0, 1, 0))

## Update focus marker position based on camera
func _update_focus_marker_position():
	if not debug_mode or not focus_marker or not camera:
		return

	# For now, place focus marker at a fixed offset in front of camera
	# This is a simple RTS-style implementation
	var ocean_y = -3.5

	# Get camera's forward direction (negative Z in camera space)
	var camera_forward = -camera.basis.z  # Camera looks toward -Z
	camera_forward = camera_forward.normalized()

	# Project camera's forward direction onto the horizontal plane
	var horizontal_dir = Vector3(camera_forward.x, 0, camera_forward.z).normalized()

	# Place focus marker in front of camera on the ground
	# Distance depends on camera height to maintain viewing angle
	var camera_height = camera.position.y - ocean_y
	var forward_distance = camera_height * 1.5  # Adjust this multiplier for desired angle

	focus_marker.position = camera.position + horizontal_dir * forward_distance
	focus_marker.position.y = ocean_y  # Clamp to ocean surface

	_update_focus_marker_size()

## Update focus marker size based on camera distance
func _update_focus_marker_size():
	if not focus_marker or not camera:
		return

	var distance = camera.position.distance_to(focus_marker.position)
	# Keep marker at constant screen size by scaling up with distance
	# At distance 15, scale = 1.0 (base size 2.0)
	# At distance 80, scale = 5.0 (larger to compensate)
	var scale_factor = distance / 15.0
	focus_marker.scale = Vector3(scale_factor, scale_factor, scale_factor)

## Print focus marker debug info
func _print_focus_debug():
	if not focus_marker or not camera:
		ResourceSystem.debug_print("Focus marker or camera not available")
		return

	ResourceSystem.debug_print("=== Focus Marker Debug ===")
	ResourceSystem.debug_print("Camera position: " + str(camera.position))
	ResourceSystem.debug_print("Focus marker position: " + str(focus_marker.position))
	ResourceSystem.debug_print("Distance camera to focus: " + str(camera.position.distance_to(focus_marker.position)))
	ResourceSystem.debug_print("Focus marker scale: " + str(focus_marker.scale))
	ResourceSystem.debug_print("Debug mode: " + str(debug_mode))
	ResourceSystem.debug_print("")

## Set debug mode (called by ConfigSystem only)
## This applies the debug mode state from ConfigSystem to the main game
## NO sync back to ConfigSystem - prevents infinite loop
func set_debug_mode(enabled: bool):
	debug_mode = enabled

	# Update ResourceSystem
	var resource_system = get_node_or_null("/root/ResourceSystem")
	if resource_system:
		resource_system.debug_mode = debug_mode

	# Update focus marker visibility
	if focus_marker:
		focus_marker.visible = debug_mode

	# Always print debug mode status (not controlled by debug_mode)
	print("[Main] Debug mode set to: %s" % ("ON" if debug_mode else "OFF"))

## Handle debug mode key (F) - print debug info when in debug mode
func _on_debug_mode_key():
	if debug_mode:
		_print_focus_debug()

## Recruit a staff member
func _recruit_staff():
	if ResourceSystem.recruit_staff():
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_recruited()
		_print_staff_info()

## Print current staff info
func _print_staff_info():
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		return

	var info = dept_system.get_department_info()
	ResourceSystem.debug_print("Staff: %d unassigned (R&D:%d, Combat:%d, Support:%d, Intel:%d, Medical:%d)" % [
		info["Unassigned"], info["R&D"], info["Combat"], info["Support"], info["Intel"], info["Medical"]
	])

## Toggle base management panel
func _toggle_base_management():
	if base_management_panel:
		base_management_panel.toggle_panel()

## Handle game over
func _on_game_over(reason: String):
	var notification_system = get_node_or_null("/root/NotificationSystem")
	if notification_system:
		notification_system.show("Game Over: %s" % reason)

## Register starting objectives
func _register_starting_objectives():
	var objective_system = get_node_or_null("/root/ObjectiveSystem")
	if objective_system:
		objective_system.add_objective("build_support", "Build a Support platform")
		objective_system.add_objective("recruit_staff", "Recruit a staff member")
		objective_system.add_objective("first_expedition", "Send first expedition")
	else:
		push_error("ObjectiveSystem autoload not found!")

## Handle staff recruited (objective tracking)
func _on_staff_recruited():
	var objective_system = get_node_or_null("/root/ObjectiveSystem")
	if objective_system:
		objective_system.complete_objective("recruit_staff")

	# Track staff recruited for game session
	var game_session = get_node_or_null("/root/GameSession")
	if game_session:
		game_session.increment_staff_recruited()
