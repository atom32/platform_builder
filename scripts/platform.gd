extends Node3D
class_name Platform

## Platform represents a base building module
## Each platform has a type, level, production value, and can have child platforms

@export var platform_type: String = "HQ"
@export var level: int = 1
@export var production_value: int = 10

@onready var production_timer = $ProductionTimer
@onready var mesh_node = $Mesh

## Production rates per second (base values, multiplied by level)
var materials_production: int = 0
var fuel_production: int = 0

## Production bonus from adjacency combos (multiplier, 1.0 = no bonus)
var production_bonus: float = 1.0

## Flag to track if production is active
var production_active: bool = false

## Build slots for this platform (empty slots where children can be built)
var build_slots: Array[BuildSlot] = []

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

	# Validate timer node exists
	if not production_timer:
		push_error("ProductionTimer not found in platform scene for type: %s" % platform_type)
		return

	# Set production rates based on platform type
	_set_production_rates()

	# Apply hexagon shape and color tint
	if mesh_node:
		PlatformVisuals.apply_hexagon_visuals(mesh_node, platform_type)

	# Generate procedural modules using template-based system
	if platform_type == "HQ":
		PlatformGenerator.generate_hq_castle(self)
	else:
		PlatformGenerator.generate_platform(self, platform_type)

	# Connect production timer and start it
	production_timer.timeout.connect(_on_production_timeout)
	production_timer.start()
	production_active = true

	# Create build slots for this platform (ALL platforms get slots!)
	_create_build_slots()

	# Hide all build slots initially
	_hide_all_build_slots()

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

## Called every second by the ProductionTimer
func _on_production_timeout():
	if not production_active:
		return

	var materials_to_add = int(materials_production * level * production_bonus)
	var fuel_to_add = int(fuel_production * level * production_bonus)

	if materials_to_add > 0:
		ResourceSystem.add_materials(materials_to_add)

	if fuel_to_add > 0:
		ResourceSystem.add_fuel(fuel_to_add)

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
	print(TextData.format("msg_platform_upgraded", [platform_type, level]))

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
