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
	print("R - Recruit staff (50 GMP, requires bed)")
	print("")

	# Give player starting resources
	ResourceSystem.add_materials(200)
	ResourceSystem.add_fuel(100)
	ResourceSystem.add_gmp(300)  # Starting GMP for recruiting
	ResourceSystem.add_beds(10)  # Starting beds for staff

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

	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			_recruit_staff()
		elif event.keycode == KEY_1:
			_assign_staff_to_rd()
		elif event.keycode == KEY_2:
			_assign_staff_to_combat()
		elif event.keycode == KEY_3:
			_assign_staff_to_support()
		elif event.keycode == KEY_4:
			_assign_staff_to_intel()
		elif event.keycode == KEY_5:
			_assign_staff_to_medical()

func _zoom_in():
	# Move camera closer - scale down the position vector
	var current_distance = camera.position.length()
	if current_distance > zoom_min_distance:
		var new_distance = max(current_distance - zoom_speed, zoom_min_distance)
		var scale_factor = new_distance / current_distance
		camera.position = camera.position * scale_factor

func _zoom_out():
	# Move camera away - scale up the position vector
	var current_distance = camera.position.length()
	if current_distance < zoom_max_distance:
		var new_distance = min(current_distance + zoom_speed, zoom_max_distance)
		var scale_factor = new_distance / current_distance
		camera.position = camera.position * scale_factor

func _on_build_failed(reason: String):
	# Build failure is already logged in base.gd, no need to duplicate
	pass

## Recruit a staff member
func _recruit_staff():
	if ResourceSystem.recruit_staff():
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_recruited()
		_print_staff_info()

## Assign staff to R&D department
func _assign_staff_to_rd():
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system and dept_system.assign_staff("R&D", 1):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_assigned("R&D")
		_print_staff_info()

## Assign staff to Combat department
func _assign_staff_to_combat():
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system and dept_system.assign_staff("Combat", 1):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_assigned("Combat")
		_print_staff_info()

## Assign staff to Support department
func _assign_staff_to_support():
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system and dept_system.assign_staff("Support", 1):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_assigned("Support")
		_print_staff_info()

## Assign staff to Intel department
func _assign_staff_to_intel():
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system and dept_system.assign_staff("Intel", 1):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_assigned("Intel")
		_print_staff_info()

## Assign staff to Medical department
func _assign_staff_to_medical():
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system and dept_system.assign_staff("Medical", 1):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_assigned("Medical")
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
