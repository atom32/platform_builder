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

# Focus point marker (visualization)
var focus_marker: MeshInstance3D = null

func _ready():
	print("=== Mother Base Tree System ===")
	print("Click yellow circles to build platforms")
	print("Right-click + drag to move camera")
	print("Scroll to zoom in/out")
	print("Each platform can have up to 6 child platforms")
	print("R - Recruit staff (50 GMP, requires bed)")
	print("U - Open Staff Management Menu")
	print("")

	# Give player starting resources
	ResourceSystem.add_materials(200)
	ResourceSystem.add_fuel(100)
	ResourceSystem.add_gmp(300)  # Starting GMP for recruiting
	# Beds are provided by platforms (HQ provides 5)

	# Store initial camera offset from origin
	camera_offset = camera.position

	# Create focus point marker (visualization)
	_create_focus_marker()

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

	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_recruit_staff()

func _process(delta):
	# Update focus marker position to follow camera view
	_update_focus_marker_position()

func _zoom_in():
	# Move camera closer to focus point
	if not focus_marker:
		return

	var focus_pos = focus_marker.position
	var current_distance = camera.position.distance_to(focus_pos)

	if current_distance > zoom_min_distance:
		var new_distance = max(current_distance - zoom_speed, zoom_min_distance)
		var direction = (focus_pos - camera.position).normalized()
		camera.position = focus_pos - direction * new_distance
		_update_focus_marker_size()

func _zoom_out():
	# Move camera away from focus point
	if not focus_marker:
		return

	var focus_pos = focus_marker.position
	var current_distance = camera.position.distance_to(focus_pos)

	if current_distance < zoom_max_distance:
		var new_distance = min(current_distance + zoom_speed, zoom_max_distance)
		var direction = (focus_pos - camera.position).normalized()
		camera.position = focus_pos - direction * new_distance
		_update_focus_marker_size()

func _on_build_failed(reason: String):
	# Build failure is already logged in base.gd, no need to duplicate
	pass

## Create focus point marker for visualization
func _create_focus_marker():
	focus_marker = MeshInstance3D.new()
	var marker_mesh = SphereMesh.new()
	marker_mesh.radius = 0.5
	marker_mesh.height = 0.5
	marker_mesh.radial_segments = 16
	focus_marker.mesh = marker_mesh

	# Set initial position (at origin, on ocean surface)
	focus_marker.position = Vector3(0, -3.0, 0)

	# Create wireframe material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.0, 0.0)  # Red
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.3
	focus_marker.set_surface_override_material(0, material)

	add_child(focus_marker)

	# Make focus marker look at camera
	focus_marker.look_at(camera.position, Vector3(0, 1, 0))

## Update focus marker position based on camera
func _update_focus_marker_position():
	if not focus_marker or not camera:
		return

	# Project ray from camera center to find ground point
	var from = camera.project_ray_origin(Vector2(0.5, 0.5))  # Center of screen
	var to = from + camera.project_ray_normal(Vector2(0.5, 0.5)) * 200

	# Calculate intersection with ocean plane (y = -3.0)
	var ray_dir = (to - from).normalized()
	if abs(ray_dir.y) > 0.01:  # Avoid division by zero
		var ocean_y = -3.0
		var distance_to_surface = (ocean_y - from.y) / ray_dir.y
		if distance_to_surface > 0:
			focus_marker.position = from + ray_dir * distance_to_surface
		else:
			# Camera is below ocean, clamp to ocean surface
			focus_marker.position = Vector3(from.x, ocean_y, from.z)

	_update_focus_marker_size()

## Update focus marker size based on camera distance
func _update_focus_marker_size():
	if not focus_marker or not camera:
		return

	var distance = camera.position.distance_to(focus_marker.position)
	var scale_factor = distance / 50.0  # Scale based on distance
	focus_marker.scale = Vector3(scale_factor, scale_factor, scale_factor)

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
