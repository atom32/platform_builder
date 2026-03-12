extends Camera3D
class_name CameraController

## Camera controller - handles zoom, pan, and smooth movement
## Separated from Main.gd and Base.gd for better code organization

# ========== ZOOM SETTINGS ==========
var zoom_min_distance: float = 15.0
var zoom_max_distance: float = 80.0
var zoom_speed: float = 5.0

# ========== PAN SETTINGS ==========
var base_pan_speed: float = 1.0  # Base speed at reference height
var pan_speed: float = 1.0
var is_panning: bool = false
var last_mouse_position: Vector2

# ========== SMOOTH MOVEMENT ==========
var target_position: Vector3
var smooth_speed: float = 10.0

# ========== FOCUS MARKER (DEBUG) ==========
var focus_marker: MeshInstance3D = null
var debug_mode: bool = false

func _ready():
	# Initialize target position to current position
	target_position = position

	# Create focus marker at origin (same as Main.gd)
	_create_focus_marker()

	# Enable processing
	set_process(true)
	set_process_input(true)

func _input(event):
	# Handle mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()
		# Handle right mouse button for panning
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_panning = true
				last_mouse_position = event.position
			else:
				is_panning = false

	# Handle mouse motion for panning
	if event is InputEventMouseMotion and is_panning:
		var delta = event.position - last_mouse_position
		_pan_camera(delta)
		last_mouse_position = event.position

func _process(delta):
	# Direct position updates for responsiveness (no smoothing lag)
	var distance_to_target = position.distance_to(target_position)
	if distance_to_target > 0.1:
		# Faster movement to reduce lag
		position = position.move_toward(target_position, distance_to_target * 0.5)
	else:
		# Snap to target when close enough
		position = target_position

	# Update focus marker position (debug mode only)
	if debug_mode and focus_marker:
		_update_focus_marker_position()

## Check if currently panning (for external code to query)
func is_panning_active() -> bool:
	return is_panning

# ========== ZOOM ==========

func _zoom_in():
	# Move camera closer to focus point along view direction
	if not focus_marker:
		return

	var current_distance = position.distance_to(focus_marker.position)
	if current_distance > zoom_min_distance:
		var new_distance = max(current_distance - zoom_speed, zoom_min_distance)
		var direction = (focus_marker.position - position).normalized()
		target_position = focus_marker.position - direction * new_distance

func _zoom_out():
	# Move camera away from focus point along view direction
	if not focus_marker:
		return

	var current_distance = position.distance_to(focus_marker.position)
	if current_distance < zoom_max_distance:
		var new_distance = min(current_distance + zoom_speed, zoom_max_distance)
		var direction = (focus_marker.position - position).normalized()
		target_position = focus_marker.position - direction * new_distance

# ========== PAN ==========

func _pan_camera(delta: Vector2):
	# Adjust pan speed based on camera height (zoom level)
	# Higher camera = faster pan, Lower camera = slower pan
	var camera_height = position.y
	var reference_height = 40.0  # Starting height from main.tscn
	var zoom_factor = camera_height / reference_height
	pan_speed = base_pan_speed * zoom_factor

	# Move camera opposite to mouse drag (pan effect)
	target_position.x -= delta.x * pan_speed
	target_position.z -= delta.y * pan_speed

# ========== FOCUS MARKER (DEBUG) ==========

func _create_focus_marker():
	# Create a visual marker at the focus point (origin)
	var sphere = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0, 0.5)  # Red, semi-transparent
	sphere.surface_set_material(0, material)

	focus_marker = MeshInstance3D.new()
	focus_marker.mesh = sphere
	focus_marker.position = Vector3.ZERO

	# Add to scene (as sibling of camera)
	get_parent().add_child(focus_marker)

	if not debug_mode:
		focus_marker.visible = false

func _update_focus_marker_position():
	# Update marker to follow camera focus point (currently at origin)
	if focus_marker:
		focus_marker.position = Vector3.ZERO

func set_debug_mode(enabled: bool):
	debug_mode = enabled
	if focus_marker:
		focus_marker.visible = enabled

# ========== PUBLIC API FOR EXTERNAL CONTROL ==========

## Focus camera on a specific platform (can be overridden for smooth animation)
func focus_on_position(target: Vector3):
	# Maintain current height and offset
	target_position.x = target.x
	target_position.z = target.z + 40  # Keep the offset from main.tscn
