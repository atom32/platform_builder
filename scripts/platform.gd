extends Node3D
class_name Platform

## Platform represents a base building module
## Each platform has a type, level, production value, and can have child platforms

## Platform states
enum PlatformState {
	CONSTRUCTING,
	OPERATIONAL,
	DAMAGED
}

@export var platform_type: String = "HQ"
@export var level: int = 1
@export var production_value: int = 10

@onready var mesh_node = $Mesh
@onready var construction_progress_label = $ConstructionProgress
@onready var dungeon_info_label = $DungeonInfoLabel

## Production rates per second (base values, multiplied by level)
var materials_production: int = 0
var fuel_production: int = 0

## Production bonus from adjacency combos (multiplier, 1.0 = no bonus)
var production_bonus: float = 1.0

## Flag to track if production is active
var production_active: bool = false

## Platform state (CONSTRUCTING, OPERATIONAL, DAMAGED)
var state: PlatformState = PlatformState.CONSTRUCTING

## Build slots for this platform (empty slots where children can be built)
var build_slots: Array[BuildSlot] = []

## Track procedural modules to restore later
var _procedural_modules: Array[Node] = []

## Maximum children per platform
const MAX_CHILDREN: int = 6

## Platform tags (from PlatformData)
var tags: Array = []

## Slot positions relative to this platform (radius = 15)
## Aligned with hexagon's 6 corners (rotated 30° to match platform hexagon)
var slot_positions: Array[Vector3] = [
	Vector3(15, 0, 0),           # 0° (right)
	Vector3(7.5, 0, 13),         # 60° (upper right)
	Vector3(-7.5, 0, 13),        # 120° (upper left)
	Vector3(-15, 0, 0),          # 180° (left)
	Vector3(-7.5, 0, -13),       # 240° (lower left)
	Vector3(7.5, 0, -13)         # 300° (lower right)
]

func _ready():
	name = "%s_Platform" % platform_type

	# Set production rates based on platform type
	_set_production_rates()

	# Production is now handled by unified BaseSystem production_timer
	production_active = true

	# Create build slots for this platform (ALL platforms get slots!)
	_create_build_slots()

	# Hide all build slots initially
	_hide_all_build_slots()

	# Set initial state (HQ is immediately operational, others start under construction)
	if platform_type == "HQ":
		set_operational()
	else:
		set_under_construction()

## Set production rates based on platform type (data-driven)
func _set_production_rates():
	materials_production = PlatformData.get_materials_production(platform_type)
	fuel_production = PlatformData.get_fuel_production(platform_type)
	tags = PlatformData.get_tags(platform_type)

## Create build slots around this platform
func _create_build_slots():
	var build_slot_scene = preload("res://scenes/build_slot.tscn")

	for i in range(slot_positions.size()):
		var slot = build_slot_scene.instantiate() as BuildSlot
		slot.slot_index = i
		# Position relative to this platform
		slot.position = slot_positions[i]
		add_child(slot)
		build_slots.append(slot)

## Called every second by the ProductionTimer (old system, DISABLED FOR TESTING)
## Produce resources (called by unified production system)
func produce_resources():
	# ⚠️ CURRENT: Called every second by Base._on_production_tick()
	# 🔄 FUTURE (Turn-based): Called once per turn by TurnManager
	#
	# Implementation notes for turn-based conversion:
	# 1. Remove Timer dependency, use turn event signals instead
	# 2. Multiply base production by turn duration (e.g., ×60 if 1 turn = 1 minute)
	# 3. Consider adding "Stored Resources" that accumulate until player collects them
	#
	# Example:
	#   NOW:  R&D Level 1 → +2 Materials every second → +120 Materials/minute
	#   THEN: R&D Level 1 → +120 Materials per turn (assuming 1 turn = 1 minute)

	# Only produce if operational and production is active
	if not production_active or state != PlatformState.OPERATIONAL:
		return

	var materials_to_add = int(materials_production * level * production_bonus)
	var fuel_to_add = int(fuel_production * level * production_bonus)

	if materials_to_add > 0:
		ResourceSystem.add_materials(materials_to_add)

	if fuel_to_add > 0:
		ResourceSystem.add_fuel(fuel_to_add)

## Check if platform is operational (not constructing or damaged)
func is_operational() -> bool:
	return state == PlatformState.OPERATIONAL

## Check if platform is under construction
func is_under_construction() -> bool:
	return state == PlatformState.CONSTRUCTING

## Set platform to operational state (construction complete)
func set_operational():
	state = PlatformState.OPERATIONAL
	_show_operational_visuals()

	# Hide construction progress
	if construction_progress_label:
		construction_progress_label.visible = false

## Set platform to under construction
func set_under_construction():
	state = PlatformState.CONSTRUCTING
	_show_construction_visuals()

	# Show construction progress
	if construction_progress_label:
		construction_progress_label.visible = true
		construction_progress_label.text = "0%"

## Update construction progress (called by BaseSystem)
func update_construction_progress(progress: float):
	# progress is 0.0 to 1.0
	if construction_progress_label and construction_progress_label.visible:
		var percentage = int(progress * 100)
		construction_progress_label.text = "%d%%" % percentage

## Show construction visuals (bare white platform with pillars, no modules)
func _show_construction_visuals():
	# Clear any existing procedural modules (top/middle/edge modules only)
	_clear_procedural_modules()

	# Apply hexagon visuals (this creates pillars + base)
	if mesh_node:
		PlatformVisuals.apply_hexagon_visuals(mesh_node, platform_type)

	# Override base color to white
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 1.0)  # White
	mesh_node.set_surface_override_material(0, material)

## Clear procedural modules (top/middle/edge only, preserve pillars and build slots)
func _clear_procedural_modules():
	# Remove all modules generated by PlatformGenerator
	# Pillars are identified by being MeshInstance3D with position.y < -1.0
	# BuildSlots are preserved
	for child in get_children():
		if child is MeshInstance3D:
			# Don't remove the main mesh
			if child == mesh_node:
				continue
			# Don't remove pillars (they are below the platform)
			if child.position.y < -1.0:
				continue
			# Remove other modules (radar, antennas, etc.)
			child.queue_free()

## Show operational visuals (colored platform with modules)
func _show_operational_visuals():
	# Re-apply hexagon visuals to restore correct color and pillars
	if mesh_node:
		PlatformVisuals.apply_hexagon_visuals(mesh_node, platform_type)

	# Clear any existing modules before generating new ones
	_clear_procedural_modules()

	# Generate procedural modules based on platform type
	if platform_type == "HQ":
		PlatformGenerator.generate_hq_castle(self)
	else:
		PlatformGenerator.generate_platform(self, platform_type)

## Add a child platform to this platform
func add_child_platform(platform: Platform, slot: BuildSlot):
	if get_child_platform_count() >= MAX_CHILDREN:
		push_error("Platform already has maximum children!")
		return

	# Add to scene tree - this defines the parent-child relationship
	# Platform's position should already be set to slot.position (relative to this platform)
	add_child(platform)
	build_slots.erase(slot)

	# Mark slot as occupied and hide its mesh
	slot.occupy()
	slot.hide_mesh()

## Get number of child platforms
func get_child_platform_count() -> int:
	var count = 0
	for child in get_children():
		if child is Platform:
			count += 1
	return count

## Check if this platform can accept more children
func can_accept_child() -> bool:
	return get_child_platform_count() < MAX_CHILDREN

## Get remaining child slots
func get_remaining_child_slots() -> int:
	return MAX_CHILDREN - get_child_platform_count()

## Get parent platform (null for HQ)
func get_parent_platform() -> Platform:
	return get_parent() as Platform

## Get child platforms (only Platform nodes, not BuildSlots)
func get_child_platforms() -> Array:
	var children = []
	for child in get_children():
		if child is Platform:
			children.append(child)
	return children

## Get all descendant platforms (recursively)
func get_all_descendants() -> Array:
	var descendants = []
	for child in get_children():
		if child is Platform:
			descendants.append(child)
			descendants.append_array(child.get_all_descendants())
	return descendants

func get_type() -> String:
	return platform_type

func get_level() -> int:
	return level

func get_production() -> int:
	return production_value * level

func upgrade():
	level += 1
	ResourceSystem.debug_print(TextData.format("msg_platform_upgraded", [platform_type, level]))

## Apply color tinting based on platform type
func apply_platform_colors():
	if not mesh_node:
		return

	var material = mesh_node.mesh.surface_get_material(0)
	if not material:
		material = StandardMaterial3D.new()
		mesh_node.set_surface_override_material(0, material)

	# Get base color
	var base_color = Color(0.5, 0.5, 0.5)  # Default gray

	# Apply tint based on platform type
	match platform_type:
		"HQ":
			base_color = Color(0.3, 0.3, 0.35)  # Dark metal
		"R&D":
			base_color = Color(0.7, 0.7, 0.3)  # Yellow tint
		"Combat":
			base_color = Color(0.7, 0.3, 0.3)  # Red tint
		"Support":
			base_color = Color(0.3, 0.5, 0.7)  # Blue tint
		"Intel":
			base_color = Color(0.6, 0.3, 0.7)  # Purple tint
		"Medical":
			base_color = Color(0.3, 0.7, 0.4)  # Green tint
		_:
			base_color = Color(0.5, 0.5, 0.5)  # Default gray

	material.albedo_color = base_color

## Hide all build slots
func _hide_all_build_slots():
	for slot in build_slots:
		if slot:
			slot.hide_mesh()

## Get this platform's tags
func get_tags() -> Array:
	return tags

## Get neighboring platforms (same level, within range)
func get_neighbors(all_platforms: Array[Platform], range: float = 20.0) -> Array[Platform]:
	var neighbors: Array[Platform] = []

	for platform in all_platforms:
		if platform == self:
			continue

		var distance = platform.position.distance_to(self.position)
		if distance <= range and distance > 0:
			neighbors.append(platform)

	return neighbors

## Show dungeon deployment info as 3D label
func show_dungeon_info(info: Dictionary):
	if dungeon_info_label:
		var text = ""
		text += "[出征到 %s]\n" % get_type()
		text += "路径: %s\n" % info.get("path_str", "")
		text += "层数: %d\n" % info.get("layers", 0)
		text += "难度: %s" % info.get("difficulty", "")

		dungeon_info_label.text = text
		dungeon_info_label.visible = true

## Hide dungeon deployment info
func hide_dungeon_info():
	if dungeon_info_label:
		dungeon_info_label.visible = false
