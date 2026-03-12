extends Node3D
class_name Base

## Base manages the entire Mother Base structure
## HQ is the root, platforms expand in a tree structure

signal build_failed(reason: String)

var hq_platform: Platform = null

var platform_scene = preload("res://scenes/platform.tscn")
var build_menu_scene = preload("res://ui/build_menu.tscn")
var expedition_menu_scene = preload("res://ui/expedition_menu.tscn")

var build_menu: BuildMenu = null
var department_system: Node = null
var combo_system: ComboSystem = null
var expedition_system: ExpeditionManager = null
var expedition_menu: ExpeditionMenu = null
var base_overview: BaseOverview = null

## Base size limit
const MAX_PLATFORMS: int = 100

## Camera dragging
var is_dragging_camera: bool = false
var last_mouse_position: Vector2

## Construction jobs (managed centrally)
var construction_jobs: Array[Dictionary] = []

## Construction timer for unified tick
var construction_timer: Timer = null

## Production timer for unified tick (all platforms)
var production_timer: Timer = null

func _ready():
	_spawn_hq()
	_create_department_system()
	_create_combo_system()
	_create_expedition_system()
	_create_build_menu()
	_create_expedition_menu()
	_create_base_overview()
	_setup_construction_timer()
	_setup_production_timer()
	_setup_click_detection()
	_connect_input_manager()

	ResourceSystem.debug_print("=== Mother Base Tree System ===")
	ResourceSystem.debug_print("HQ with 6 expansion slots created")
	ResourceSystem.debug_print("Each platform can have 6 children")
	ResourceSystem.debug_print("Click yellow circles to expand!")

func _connect_input_manager():
	var input_manager = get_node_or_null("/root/InputManager")
	if input_manager:
		input_manager.expedition_key_pressed.connect(_on_expedition_key_pressed)

func _on_expedition_key_pressed():
	if expedition_menu:
		if expedition_menu.visible:
			expedition_menu.hide_menu()
		else:
			open_expedition_menu()

func _create_department_system():
	# Use the autoload instance
	department_system = get_node_or_null("/root/DepartmentSystem")
	if department_system:
		# Connect combo system reference
		if combo_system:
			department_system.combo_system = combo_system

func _create_combo_system():
	combo_system = ComboSystem.new()
	add_child(combo_system)

func _create_expedition_system():
	# Use the autoload instance
	expedition_system = get_node("/root/ExpeditionSystem")
	expedition_system.set_base_system(self)

	# Connect expedition signals for notifications
	if expedition_system:
		expedition_system.expedition_started.connect(_on_expedition_started)
		expedition_system.expedition_completed.connect(_on_expedition_completed)
		expedition_system.expedition_failed.connect(_on_expedition_failed)
		# Connect combo system reference
		if combo_system:
			expedition_system.combo_system = combo_system

func _create_expedition_menu():
	expedition_menu = expedition_menu_scene.instantiate() as ExpeditionMenu
	add_child(expedition_menu)
	expedition_menu.expedition_launched.connect(_on_expedition_launched)

func _create_base_overview():
	# Get reference to BaseOverview from Main
	base_overview = get_node_or_null("../BaseOverview") as BaseOverview

func _setup_construction_timer():
	# Unified construction tick (updates all construction jobs every second)
	construction_timer = Timer.new()
	construction_timer.wait_time = 1.0
	construction_timer.autostart = true
	construction_timer.timeout.connect(_on_construction_tick)
	add_child(construction_timer)

func _setup_production_timer():
	# Unified production tick (updates all operational platforms every second)
	production_timer = Timer.new()
	production_timer.wait_time = 1.0
	production_timer.autostart = true
	production_timer.timeout.connect(_on_production_tick)
	add_child(production_timer)

func _on_production_tick():
	# Produce resources for all operational platforms
	var all_platforms = get_all_platforms()
	for platform in all_platforms:
		if platform.is_operational():
			platform.produce_resources()

func _on_construction_tick():
	# Update all construction jobs
	var completed_jobs: Array = []

	for i in range(construction_jobs.size()):
		var job = construction_jobs[i]
		job["remaining_time"] -= 1.0

		# Update construction progress for UI
		var platform = job["platform"]
		var total_time = job["total_time"]
		var remaining_time = job["remaining_time"]
		var progress = 1.0 - (remaining_time / total_time)
		platform.update_construction_progress(progress)

		# Check if construction completed
		if job["remaining_time"] <= 0.0:
			platform.set_operational()
			completed_jobs.append(i)

			# Notify systems
			ResourceSystem.debug_print("Platform constructed: %s" % platform.platform_type)

			# Check for new combos
			_check_combos()

			# Update bed capacity based on new platform
			_update_bed_capacity()

			# Show notification
			var notification_system = get_node_or_null("/root/NotificationSystem")
			if notification_system:
				notification_system.show_platform_built(platform.platform_type)

			# Check for Support platform objective
			var objective_system = get_node_or_null("/root/ObjectiveSystem")
			if objective_system and platform.platform_type == "Support":
				objective_system.complete_objective("build_support")

			# Track platform built for game session
			var game_session = get_node_or_null("/root/GameSession")
			if game_session:
				game_session.increment_platforms_built()

			# Refresh base overview if visible
			if base_overview and base_overview.visible:
				base_overview.refresh()

	# Remove completed jobs (in reverse order to maintain indices)
	for i in range(completed_jobs.size() - 1, -1, -1):
		construction_jobs.remove_at(completed_jobs[i])

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

	# HQ sets itself to operational in its _ready() method

	ResourceSystem.debug_print(TextData.format("msg_hq_spawned"))

func _setup_click_detection():
	set_process_input(true)

func _input(event):
	# Camera control is handled by CameraController
	# Base.gd handles slot/platform clicks and UI events

	# Handle left click for slot/platform interaction
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Check if menus are open
			if not (build_menu and build_menu.visible) and not (expedition_menu and expedition_menu.visible):
				_handle_click(event.position)

	# Handle menu cancellation with ESC
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if build_menu and build_menu.visible:
			build_menu.hide_menu()
		elif expedition_menu and expedition_menu.visible:
			expedition_menu.hide_menu()

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
	for platform in get_all_platforms():
		if slot in platform.build_slots:
			return platform
	return null

func _hide_all_slots():
	# Hide all build slots from all platforms
	for platform in get_all_platforms():
		platform._hide_all_build_slots()

func _show_platform_slots(platform: Platform):
	# First, hide all slots from all platforms
	_hide_all_slots()

	# Show only this platform's non-overlapping slots
	for slot in platform.build_slots:
		if not slot.get_occupied():
			# Use slot's global_position directly (Godot handles coordinate transformation)
			var slot_world_pos = slot.global_position
			if not _check_slot_overlap(slot_world_pos):
				slot.show_mesh()

func _check_slot_overlap(position: Vector3) -> bool:
	# Check if position overlaps with any existing platform
	for platform in get_all_platforms():
		# IMPORTANT: Use global_position for world space comparison
		# Since platforms are in a tree structure, position is local to parent
		var distance = platform.global_position.distance_to(position)
		# Platform is 10x10, so overlap if distance < 10 (center-to-center)
		# Slots are at distance 15, so they should not overlap with parent
		# Only hide slot if it's too close to another platform center
		if distance < 10.0:  # Less than platform size
			return true
	return false

func _on_platform_selected(platform_type: String, slot: BuildSlot):
	var parent_platform = _find_platform_with_slot(slot)
	if parent_platform:
		build_child_platform(parent_platform, slot, platform_type)

func build_child_platform(parent_platform: Platform, slot: BuildSlot, platform_type: String) -> Platform:
	var parent_ref = parent_platform  # Store reference before building

	# Check base size limit
	if get_total_platform_count() >= MAX_PLATFORMS:
		ResourceSystem.debug_print(TextData.format("msg_build_failed_base_full", [MAX_PLATFORMS]))
		build_failed.emit("base_full")
		return null

	# Check if parent can accept more children
	if not parent_platform.can_accept_child():
		ResourceSystem.debug_print(TextData.format("msg_build_failed_parent_full"))
		build_failed.emit("parent_full")
		return null

	# Check build costs (data-driven)
	var cost = PlatformData.get_build_cost(platform_type)
	var materials_cost = cost["materials"]
	var fuel_cost = cost["fuel"]

	# Check resources
	if not ResourceSystem.spend_materials(materials_cost):
		ResourceSystem.debug_print(TextData.format("msg_build_failed_materials", [materials_cost, ResourceSystem.get_materials()]))
		build_failed.emit("materials")
		return null

	if not ResourceSystem.spend_fuel(fuel_cost):
		ResourceSystem.add_materials(materials_cost)
		ResourceSystem.debug_print(TextData.format("msg_build_failed_fuel", [fuel_cost, ResourceSystem.get_fuel()]))
		build_failed.emit("fuel")
		return null

	# Create new platform
	var platform = platform_scene.instantiate() as Platform
	platform.platform_type = platform_type
	platform.level = 1
	platform.production_value = 10

	# Platform will start in CONSTRUCTING state (handled in _ready())
	# Get construction time for this platform type (data-driven)
	var construction_time = PlatformData.get_construction_time(platform_type)

	# Create construction job
	var construction_job = {
		"platform": platform,
		"remaining_time": construction_time,
		"total_time": construction_time
	}
	construction_jobs.append(construction_job)

	# Debug: print building info
	ResourceSystem.debug_print("Building platform debug:")
	ResourceSystem.debug_print("  Parent platform world pos: " + str(parent_platform.position))
	ResourceSystem.debug_print("  Slot local pos: " + str(slot.position))
	ResourceSystem.debug_print("  Slot world pos: " + str(slot.global_position))
	ResourceSystem.debug_print("  Construction time: %ds" % construction_time)

	# Position at the slot's location
	# Slot position is relative to parent_platform, so we use it directly
	platform.position = slot.position

	# Register to parent (this adds to scene tree)
	parent_platform.add_child_platform(platform, slot)

	# Debug: print new platform position
	ResourceSystem.debug_print("  New platform local pos: " + str(platform.position))
	ResourceSystem.debug_print("  New platform world pos: " + str(platform.global_position))

	# Create visual bridge between platforms
	BridgeGenerator.create_bridge(parent_platform, platform)

	ResourceSystem.debug_print("Started construction of %s platform at %s (Materials: %d, Fuel: %d, Time: %ds)" % [
		platform_type, parent_platform.platform_type, materials_cost, fuel_cost, construction_time
	])

	# NOTE: Bed capacity, combos, objectives, and notifications are updated when construction completes
	# See _on_construction_tick()

	return platform

func get_hq() -> Platform:
	return hq_platform

## Check all platforms for active combos
func _check_combos():
	if combo_system:
		combo_system.check_combos(get_all_platforms())
		print_combos()

## Print active combos (for debugging)
func print_combos():
	if combo_system:
		combo_system.print_active_combos()

## Handle expedition launch
func _on_expedition_launched(mission_id: String):
	pass

## Handle expedition started
func _on_expedition_started(mission_id: String):
	var mission_name = TextData.expedition_name(mission_id)
	var notification_system = get_node_or_null("/root/NotificationSystem")
	if notification_system:
		notification_system.show_expedition_started(mission_name)

	# Check for first expedition objective
	var objective_system = get_node_or_null("/root/ObjectiveSystem")
	if objective_system:
		objective_system.mark_first_expedition()

	# Track expedition sent for game session
	var game_session = get_node_or_null("/root/GameSession")
	if game_session:
		game_session.increment_expeditions_sent()

## Handle expedition completed
func _on_expedition_completed(mission_id: String, rewards: Dictionary):
	var mission_name = TextData.expedition_name(mission_id)
	var materials = rewards.get("materials", 0)
	var fuel = rewards.get("fuel", 0)
	var result_type = rewards.get("result_type", "success")
	var notification_system = get_node_or_null("/root/NotificationSystem")

	if notification_system:
		if result_type == "critical_success":
			notification_system.show_critical_success(mission_name)
		else:
			notification_system.show_expedition_completed(mission_name, materials, fuel)

## Handle expedition failed
func _on_expedition_failed(mission_id: String, reason: String):
	var mission_name = TextData.expedition_name(mission_id)
	var notification_system = get_node_or_null("/root/NotificationSystem")
	if notification_system:
		notification_system.show_expedition_failed(mission_name)

## Open expedition menu (called from UI or hotkey)
func open_expedition_menu():
	if expedition_menu:
		expedition_menu.show_menu()

## Update bed capacity based on all platforms
func _update_bed_capacity():
	ResourceSystem.calculate_bed_capacity(get_all_platforms())

## ===== PLATFORM TRAVERSAL UTILITIES =====

## Get all platforms in the base (using scene tree traversal)
func get_all_platforms() -> Array[Platform]:
	var platforms: Array[Platform] = []

	# Start from HQ and recursively collect all platforms
	if hq_platform:
		_collect_platforms_recursive(hq_platform, platforms)

	return platforms

## Recursively collect platforms starting from a root platform
func _collect_platforms_recursive(platform: Platform, platforms: Array[Platform]):
	platforms.append(platform)

	# Recursively collect child platforms
	for child in platform.get_children():
		if child is Platform:
			_collect_platforms_recursive(child, platforms)

## Get total platform count
func get_total_platform_count() -> int:
	return get_all_platforms().size()

## Get platforms by type
func get_platforms_by_type(type: String) -> Array[Platform]:
	var result: Array[Platform] = []
	for platform in get_all_platforms():
		if platform.platform_type == type:
			result.append(platform)
	return result

## Get platform count by type
func get_platform_count_by_type(type: String) -> int:
	return get_platforms_by_type(type).size()
