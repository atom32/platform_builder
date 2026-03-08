extends Node3D
class_name Platform

## Platform represents a base building module
## Each platform has a type, level, production value, and can have child platforms

@export var platform_type: String = "HQ"
@export var level: int = 1
@export var production_value: int = 10

@onready var production_timer = $ProductionTimer

## Production rates per second (base values, multiplied by level)
var materials_production: int = 0
var fuel_production: int = 0

## Flag to track if production is active
var production_active: bool = false

## Parent platform (null for HQ)
var parent_platform: Platform = null

## Child platforms built on this platform's slots
var child_platforms: Array[Platform] = []

## Build slots for this platform (empty slots where children can be built)
var build_slots: Array[BuildSlot] = []

## Maximum children per platform
const MAX_CHILDREN: int = 6

## Slot positions relative to this platform (radius = 15)
var slot_positions: Array[Vector3] = [
	Vector3(15, 0, 0),
	Vector3(-15, 0, 0),
	Vector3(0, 0, 15),
	Vector3(0, 0, -15),
	Vector3(10.5, 0, 10.5),
	Vector3(-10.5, 0, -10.5)
]

func _ready():
	name = "%s_Platform" % platform_type

	# Validate timer node exists
	if not production_timer:
		push_error("ProductionTimer not found in platform scene for type: %s" % platform_type)
		return

	# Set production rates based on platform type
	_set_production_rates()

	# Generate procedural modules for non-HQ platforms
	if platform_type != "HQ":
		PlatformGenerator.generate_platform(self)

	# Connect production timer and start it
	production_timer.timeout.connect(_on_production_timeout)
	production_timer.start()
	production_active = true

	# Create build slots for this platform (ALL platforms get slots!)
	_create_build_slots()

	# Hide all build slots initially
	_hide_all_build_slots()

## Set production rates based on platform type
func _set_production_rates():
	match platform_type:
		"HQ":
			materials_production = 0
			fuel_production = 0
		"R&D":
			materials_production = 2
			fuel_production = 0
		"Support":
			materials_production = 0
			fuel_production = 2
		"Combat":
			materials_production = 1
			fuel_production = 1
		"Intel":
			materials_production = 0
			fuel_production = 1
		"Medical":
			materials_production = 1
			fuel_production = 0
		_:
			materials_production = 0
			fuel_production = 0

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

	print("%s: Created %d build slots" % [platform_type, build_slots.size()])

## Called every second by the ProductionTimer
func _on_production_timeout():
	if not production_active:
		return

	var materials_to_add = materials_production * level
	var fuel_to_add = fuel_production * level

	if materials_to_add > 0:
		ResourceSystem.add_materials(materials_to_add)

	if fuel_to_add > 0:
		ResourceSystem.add_fuel(fuel_to_add)

## Add a child platform to this platform
func add_child_platform(platform: Platform, slot: BuildSlot):
	if child_platforms.size() >= MAX_CHILDREN:
		push_error("Platform already has maximum children!")
		return

	child_platforms.append(platform)
	platform.parent_platform = self
	build_slots.erase(slot)

	print("%s: Added child %s (total children: %d/%d)" % [
		platform_type, platform.platform_type, child_platforms.size(), MAX_CHILDREN
	])

## Get number of child platforms
func get_child_platform_count() -> int:
	return child_platforms.size()

## Check if this platform can accept more children
func can_accept_child() -> bool:
	return child_platforms.size() < MAX_CHILDREN

## Get remaining child slots
func get_remaining_child_slots() -> int:
	return MAX_CHILDREN - child_platforms.size()

## Get all descendant platforms (recursively)
func get_all_descendants() -> Array[Platform]:
	var descendants: Array[Platform] = []
	for child in child_platforms:
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
	print("%s upgraded to Level %d" % [platform_type, level])

## Hide all build slots
func _hide_all_build_slots():
	for slot in build_slots:
		if slot:
			slot.hide_mesh()
