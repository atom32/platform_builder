extends Node

## Platform generation templates for each platform type
## Defines which modules appear on which platforms and how they're arranged

## Template registry
var _templates: Dictionary = {}

func _ready():
	_register_all_templates()

## Register all platform templates
func _register_all_templates():
	# HQ Template - Command center with communications
	_templates["HQ"] = {
		"display_name": "Headquarters",
		"top_modules": ["radar_tower", "satellite_dish", "comms_array", "antenna_array"],
		"middle_modules": ["equipment_box", "cargo_container", "ventilation_unit"],
		"edge_modules": ["sensor_array", "crane"],
		"top_count": [2, 3],
		"middle_count": [3, 5],
		"edge_count": [2, 4],
		"base_color": Color(0.4, 0.4, 0.45),
		"theme": "tech"
	}

	# R&D Template - Research facility with antennas and sensors
	_templates["R&D"] = {
		"display_name": "Research & Development",
		"top_modules": ["antenna_array", "satellite_dish", "radar_tower", "comms_array"],
		"middle_modules": ["equipment_box", "solar_panel", "ventilation_unit"],
		"edge_modules": ["sensor_array", "pipe_cluster"],
		"top_count": [2, 4],
		"middle_count": [2, 4],
		"edge_count": [1, 3],
		"base_color": Color(0.35, 0.4, 0.45),
		"theme": "tech"
	}

	# Combat Template - Military platform with defenses
	_templates["Combat"] = {
		"display_name": "Combat Platform",
		"top_modules": ["turret", "radar_tower"],
		"middle_modules": ["equipment_box", "cargo_container"],
		"edge_modules": ["turret", "defenses_emplacement", "crane"],
		"top_count": [1, 2],
		"middle_count": [2, 4],
		"edge_count": [3, 6],
		"base_color": Color(0.35, 0.32, 0.28),
		"theme": "military"
	}

	# Support Template - Logistics with cranes and containers
	_templates["Support"] = {
		"display_name": "Support Platform",
		"top_modules": ["radar_tower", "antenna_array"],
		"middle_modules": ["cargo_container", "equipment_box", "fuel_tank"],
		"edge_modules": ["crane", "pipe_cluster", "crane"],
		"top_count": [1, 2],
		"middle_count": [3, 5],
		"edge_count": [2, 4],
		"base_color": Color(0.4, 0.38, 0.35),
		"theme": "industrial"
	}

	# Intel Template - Surveillance focused
	_templates["Intel"] = {
		"display_name": "Intelligence Platform",
		"top_modules": ["radar_tower", "satellite_dish", "comms_array", "antenna_array", "sensor_array"],
		"middle_modules": ["equipment_box", "ventilation_unit", "solar_panel"],
		"edge_modules": ["sensor_array", "sensor_array", "pipe_cluster"],
		"top_count": [3, 5],
		"middle_count": [2, 4],
		"edge_count": [2, 4],
		"base_color": Color(0.32, 0.38, 0.42),
		"theme": "tech"
	}

	# Medical Template - Medical bay with life support
	_templates["Medical"] = {
		"display_name": "Medical Platform",
		"top_modules": ["helipad", "antenna_array"],
		"middle_modules": ["equipment_box", "ventilation_unit", "fuel_tank"],
		"edge_modules": ["lifeboat", "sensor_array", "pipe_cluster"],
		"top_count": [1, 2],
		"middle_count": [2, 4],
		"edge_count": [2, 4],
		"base_color": Color(0.7, 0.75, 0.8),
		"theme": "medical"
	}

## Get template for platform type
func get_template(platform_type: String) -> Dictionary:
	return _templates.get(platform_type, {})

## Get all platform types
func get_all_platform_types() -> Array[String]:
	return _templates.keys()

## Check if template exists
func has_template(platform_type: String) -> bool:
	return _templates.has(platform_type)

## Get display name from template
func get_display_name(template: Dictionary) -> String:
	return template.get("display_name", "")

## Get top modules from template
func get_top_modules(template: Dictionary) -> Array[String]:
	if template.has("top_modules"):
		return _to_string_array(template["top_modules"])
	return []

## Get middle modules from template
func get_middle_modules(template: Dictionary) -> Array[String]:
	if template.has("middle_modules"):
		return _to_string_array(template["middle_modules"])
	return []

## Get edge modules from template
func get_edge_modules(template: Dictionary) -> Array[String]:
	if template.has("edge_modules"):
		return _to_string_array(template["edge_modules"])
	return []

## Get top count range from template
func get_top_count(template: Dictionary) -> Array[int]:
	if template.has("top_count"):
		return _to_int_array(template["top_count"])
	return [1, 2]

## Get middle count range from template
func get_middle_count(template: Dictionary) -> Array[int]:
	if template.has("middle_count"):
		return _to_int_array(template["middle_count"])
	return [2, 4]

## Get edge count range from template
func get_edge_count(template: Dictionary) -> Array[int]:
	if template.has("edge_count"):
		return _to_int_array(template["edge_count"])
	return [0, 3]

## Helper: Convert to typed String array
func _to_string_array(arr: Array) -> Array[String]:
	var result: Array[String] = []
	result.assign(arr)
	return result

## Helper: Convert to typed int array
func _to_int_array(arr: Array) -> Array[int]:
	var result: Array[int] = []
	result.assign(arr)
	return result

## Get base color from template
func get_base_color(template: Dictionary) -> Color:
	return template.get("base_color", Color(0.5, 0.5, 0.5))

## Get theme from template
func get_theme(template: Dictionary) -> String:
	return template.get("theme", "industrial")

## Edge slot positions for hexagonal platforms
## 6 slots positioned at regular intervals around the platform edge
func get_edge_slot_positions() -> Array[Vector3]:
	# Hexagon vertices at radius 3.5
	return [
		Vector3(3.5, 0, 0),        # East
		Vector3(1.75, 0, 3),       # Northeast
		Vector3(-1.75, 0, 3),      # Northwest
		Vector3(-3.5, 0, 0),       # West
		Vector3(-1.75, 0, -3),     # Southwest
		Vector3(1.75, 0, -3)       # Southeast
	]

## Get rotation for edge slot (facing outward from platform)
func get_edge_slot_rotation(slot_index: int) -> float:
	# Each slot is 60 degrees apart, facing outward
	return (slot_index * 60.0)

## Get random modules from template
func get_random_modules(
	template: Dictionary,
	layer: String,
	rng: RandomNumberGenerator
) -> Array[String]:
	var available_modules: Array[String] = []
	var count_range: Array[int] = []

	# Determine which layer to use
	match layer:
		"top":
			available_modules = get_top_modules(template)
			count_range = get_top_count(template)
		"middle":
			available_modules = get_middle_modules(template)
			count_range = get_middle_count(template)
		"edge":
			available_modules = get_edge_modules(template)
			count_range = get_edge_count(template)
		_:
			return []

	if available_modules.is_empty():
		return []

	# Random count within range
	var count = rng.randi_range(count_range[0], count_range[1])

	# Pick random modules
	var module_list: Array[String] = []
	for i in range(count):
		var module_id = available_modules.pick_random()
		if module_id != null:
			module_list.append(module_id)

	return module_list

## Get themed color based on platform template
func get_themed_color(template: Dictionary, rng: RandomNumberGenerator) -> Color:
	var colors: Array[Color] = []

	match get_theme(template):
		"tech":
			colors = ModuleLibrary.COLORS_TECH
		"military":
			colors = ModuleLibrary.COLORS_MILITARY
		"medical":
			colors = ModuleLibrary.COLORS_MEDICAL
		_:
			colors = ModuleLibrary.COLORS_INDUSTRIAL

	return colors.pick_random()
