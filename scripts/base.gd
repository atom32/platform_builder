extends Node3D
class_name Base

## Base manages the entire Mother Base structure
## HQ is the root, platforms expand in a tree structure

signal build_failed(reason: String)

var hq_platform: Platform = null
var all_platforms: Array[Platform] = []

var platform_scene = preload("res://scenes/platform.tscn")
var build_menu_scene = preload("res://ui/build_menu.tscn")

var build_menu: BuildMenu = null
var department_system: DepartmentSystem = null

## Platform build costs
var build_costs = {
	"R&D": {"materials": 50, "fuel": 10},
	"Support": {"materials": 30, "fuel": 40},
	"Combat": {"materials": 40, "fuel": 30},
	"Intel": {"materials": 35, "fuel": 25},
	"Medical": {"materials": 25, "fuel": 25}
}

## Camera dragging
var is_dragging_camera: bool = false
var last_mouse_position: Vector2

func _ready():
	_spawn_hq()
	_create_department_system()
	_create_build_menu()
	_setup_click_detection()

	print("=== Mother Base Tree System ===")
	print("HQ with 6 expansion slots created")
	print("Each platform can have 6 children")
	print("Click yellow circles to expand!")

func _create_department_system():
	department_system = DepartmentSystem.new()
	add_child(department_system)

func _create_build_menu():
	build_menu = build_menu_scene.instantiate() as BuildMenu
	add_child(build_menu)
	build_menu.platform_selected.connect(_on_platform_selected)
	# Pass base system reference to build menu
	build_menu.base_system = self

func _spawn_hq():
	hq_platform = platform_scene.instantiate() as Platform
	hq_platform.platform_type = "HQ"
	hq_platform.position = Vector3.ZERO
	add_child(hq_platform)
	all_platforms.append(hq_platform)

	print("HQ Platform spawned at center")

func _setup_click_detection():
	set_process_input(true)

func _input(event):
	# Handle camera dragging with right mouse button
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging_camera = true
				last_mouse_position = event.position
			else:
				is_dragging_camera = false

	# Handle left click
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not is_dragging_camera:
				if not (build_menu and build_menu.visible):
					# Only handle click if menu is not open
					_handle_click(event.position)

	# Handle menu cancellation with ESC
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if build_menu and build_menu.visible:
			build_menu.hide_menu()

	# Handle camera drag movement
	if event is InputEventMouseMotion and is_dragging_camera:
		var delta = event.position - last_mouse_position
		_drag_camera(delta)
		last_mouse_position = event.position

func _drag_camera(delta: Vector2):
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# Move camera opposite to mouse drag (pan effect)
	var move_speed = 0.5
	camera.position.x -= delta.x * move_speed
	camera.position.z -= delta.y * move_speed

func _handle_click(mouse_pos: Vector2):
	var camera = get_viewport().get_camera_3d()
	if not camera:
		push_error("Camera not found in scene!")
		return

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space = get_world_3d().direct_space_state

	# First, check if clicked on a build slot (layer 2)
	var slot_query = PhysicsRayQueryParameters3D.new()
	slot_query.from = from
	slot_query.to = to
	slot_query.collision_mask = 2
	slot_query.collide_with_areas = true
	slot_query.collide_with_bodies = false

	var slot_result = space.intersect_ray(slot_query)

	# Check if clicked on a slot
	if slot_result and slot_result.collider:
		var slot_node = slot_result.collider
		# BuildSlot has Area3D as child, get parent BuildSlot
		var slot = null
		if slot_node is Area3D:
			slot = slot_node.get_parent() as BuildSlot

		if slot and not slot.get_occupied():
			var parent_platform = _find_platform_with_slot(slot)
			if parent_platform and parent_platform.can_accept_child():
				# Show build menu
				if build_menu:
					build_menu.show_menu(slot)
				return

	# If didn't click on a slot, check if clicked on a platform (layer 4)
	var platform_query = PhysicsRayQueryParameters3D.new()
	platform_query.from = from
	platform_query.to = to
	platform_query.collision_mask = 4
	platform_query.collide_with_areas = true
	platform_query.collide_with_bodies = false

	var platform_result = space.intersect_ray(platform_query)

	if platform_result and platform_result.collider:
		var platform = platform_result.collider.get_parent() as Platform
		if platform:
			_show_platform_slots(platform)
			return

	# If didn't click on slot or platform, hide all slots
	_hide_all_slots()

## Find which platform owns a build slot (public for build_menu)
func find_platform_with_slot(slot: BuildSlot) -> Platform:
	return _find_platform_with_slot(slot)

func _find_platform_with_slot(slot: BuildSlot) -> Platform:
	# Search through all platforms to find which one owns this slot
	for platform in all_platforms:
		if slot in platform.build_slots:
			return platform
	return null

func _hide_all_slots():
	# Hide all build slots from all platforms
	for platform in all_platforms:
		platform._hide_all_build_slots()

func _show_platform_slots(platform: Platform):
	# First, hide all slots from all platforms
	_hide_all_slots()

	# Show only this platform's non-overlapping slots
	for slot in platform.build_slots:
		if not slot.get_occupied():
			var slot_world_pos = platform.position + slot.position
			if not _check_slot_overlap(slot_world_pos):
				slot.show_mesh()

func _check_slot_overlap(position: Vector3) -> bool:
	# Check if position overlaps with any existing platform
	for platform in all_platforms:
		var distance = platform.position.distance_to(position)
		if distance < 8.0:  # Platform size is 10x10, so < 8 means overlap
			return true
	return false

func _on_platform_selected(platform_type: String, slot: BuildSlot):
	var parent_platform = _find_platform_with_slot(slot)
	if parent_platform:
		build_child_platform(parent_platform, slot, platform_type)

func build_child_platform(parent_platform: Platform, slot: BuildSlot, platform_type: String) -> Platform:
	var parent_ref = parent_platform  # Store reference before building
	# Check department capacity FIRST
	if not department_system.can_build(platform_type):
		build_failed.emit("department_full")
		return null

	# Check if parent can accept more children
	if not parent_platform.can_accept_child():
		print("Parent platform is full (6/6 children)")
		build_failed.emit("parent_full")
		return null

	# Check build costs
	var cost = build_costs[platform_type]
	var materials_cost = cost["materials"]
	var fuel_cost = cost["fuel"]

	# Check resources
	if not ResourceSystem.spend_materials(materials_cost):
		print("Not enough resources: Need %d Materials (have %d)" % [materials_cost, ResourceSystem.get_materials()])
		build_failed.emit("materials")
		return null

	if not ResourceSystem.spend_fuel(fuel_cost):
		ResourceSystem.add_materials(materials_cost)
		print("Not enough resources: Need %d Fuel (have %d)" % [fuel_cost, ResourceSystem.get_fuel()])
		build_failed.emit("fuel")
		return null

	# Create new platform
	var platform = platform_scene.instantiate() as Platform
	platform.platform_type = platform_type
	platform.level = 1
	platform.production_value = 10

	# Position at the slot's location (relative to parent)
	var slot_local_position = slot.position
	platform.position = parent_platform.position + slot_local_position

	add_child(platform)
	all_platforms.append(platform)

	# Register to parent and department
	parent_platform.add_child_platform(platform, slot)
	department_system.register_platform(platform)

	print("==================================================")
	print("BUILD SUCCESS")
	print("  Type: %s Platform" % platform_type)
	print("  Parent: %s" % parent_platform.platform_type)
	print("  Cost: %d Materials, %d Fuel" % [materials_cost, fuel_cost])
	print("  Department: %s (%d/%d)" % [
		platform_type,
		department_system.get_department_count(platform_type),
		department_system.MAX_PLATFORMS_PER_DEPT
	])
	print("  Parent Children: %d/%d" % [
		parent_platform.get_child_platform_count(),
		Platform.MAX_CHILDREN
	])
	print("==================================================")

	return platform

func get_total_platform_count() -> int:
	return all_platforms.size()

func get_hq() -> Platform:
	return hq_platform
