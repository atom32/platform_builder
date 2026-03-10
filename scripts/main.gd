extends Node3D

# Main game controller
# The Base system now handles platform and slot management

@onready var base = $Base
@onready var camera = $Camera3D
@onready var base_overview: BaseOverview = $BaseOverview as BaseOverview

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

# Debug mode
var debug_mode: bool = true

func _ready():
	print("=== Mother Base Tree System ===")
	print("Click yellow circles to build platforms")
	print("Right-click + drag to move camera")
	print("Scroll to zoom in/out")
	print("Each platform can have up to 6 child platforms")
	print("R - Recruit staff (50 GMP, requires bed)")
	print("U - Open Staff Management Menu")
	print("TAB - Open/Close Base Overview")
	if debug_mode:
		print("D - Toggle debug mode (currently ON)")
		print("F - Print focus marker debug info")
	else:
		print("D - Toggle debug mode (currently OFF)")
	print("")

	# Give player starting resources
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
		if focus_marker:
			print("Focus marker created at ", focus_marker.position)
		print("Press D to toggle debug mode")

	# Connect to build failure events for feedback
	if base:
		base.build_failed.connect(_on_build_failed)

	# Connect to base overview signals
	if base_overview:
		base_overview.platform_selected.connect(_on_platform_selected)
		base_overview.overview_closed.connect(_on_overview_closed)
		# Pass base system reference to overview
		base_overview.base_system = base

	# Connect to staff recruitment signal
	ResourceSystem.staff_recruited.connect(_on_staff_recruited)

func _input(event):
	# Handle camera zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()

	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_recruit_staff()
		elif event.keycode == KEY_TAB:
			_toggle_base_overview()
		elif event.keycode == KEY_F:
			if debug_mode:
				_print_focus_debug()
		elif event.keycode == KEY_D:
			_toggle_debug_mode()

func _process(delta):
	# Update focus marker position to follow camera view (debug mode only)
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
		print("Focus marker or camera not available")
		return

	print("=== Focus Marker Debug ===")
	print("Camera position: ", camera.position)
	print("Focus marker position: ", focus_marker.position)
	print("Distance camera to focus: ", camera.position.distance_to(focus_marker.position))
	print("Focus marker scale: ", focus_marker.scale)
	print("Debug mode: ", debug_mode)
	print("")

## Toggle debug mode
func _toggle_debug_mode():
	debug_mode = !debug_mode
	print("Debug mode: ", debug_mode)

	if focus_marker:
		focus_marker.visible = debug_mode
		print("Focus marker visibility: ", focus_marker.visible)

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
	print("=== Staff Assignment ===")
	print("R&D: %d" % info["R&D"])
	print("Combat: %d" % info["Combat"])
	print("Support: %d" % info["Support"])
	print("Intel: %d" % info["Intel"])
	print("Medical: %d" % info["Medical"])
	print("Unassigned: %d" % info["Unassigned"])
	print("Research Bonus: %d%%" % int((dept_system.get_research_speed_multiplier() - 1.0) * 100))
	print("Combat Bonus: +%d" % dept_system.get_combat_power_bonus())

## Toggle base overview
func _toggle_base_overview():
	if not base_overview:
		return

	if base_overview.visible:
		base_overview.hide_overview()
	else:
		base_overview.show_overview()

## Handle platform selection from overview
func _on_platform_selected(platform: Platform):
	print("Platform selected from overview: %s" % platform.platform_type)

## Handle overview closed
func _on_overview_closed():
	print("Base overview closed")

## Register starting objectives
func _register_starting_objectives():
	var objective_system = get_node_or_null("/root/ObjectiveSystem")
	if objective_system:
		objective_system.add_objective("build_support", "Build a Support platform")
		objective_system.add_objective("recruit_staff", "Recruit a staff member")
		objective_system.add_objective("first_expedition", "Send first expedition")
		print("Starting objectives registered")
	else:
		push_error("ObjectiveSystem autoload not found!")

## Handle staff recruited (objective tracking)
func _on_staff_recruited():
	var objective_system = get_node_or_null("/root/ObjectiveSystem")
	if objective_system:
		objective_system.complete_objective("recruit_staff")
