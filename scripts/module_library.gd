extends Node

## Library of available modules for platform generation
## Each module defines its visual properties and placement rules

## Module categories for organization
enum ModuleCategory {
	TOP,        # Modules placed on top of platform
	MIDDLE,     # Modules placed in middle area
	EDGE,       # Modules attached to platform edges
	FLOOR       # Modules placed on platform floor
}

## Mesh types for modules
enum MeshType {
	CYLINDER,
	BOX,
	DISH,
	ANTENNA,
	CRANE,
	PIPE_CLUSTER,
	CONTAINER,
	SOLAR_PANEL,
	VENT,
	SATELLITE_DISH,
	HELIPAD,
	TURRET,
	COMMS_ARRAY
}

## Color palettes (loaded from JSON)
var color_palettes: Dictionary = {}

## Module registry
var _modules: Dictionary = {}

func _ready():
	_load_color_palettes()
	_load_modules()

## Load color palettes from JSON file
func _load_color_palettes():
	var loader = load("res://scripts/module_library_loader.gd").new()
	var data = loader.load_color_palettes()

	if data.is_empty() or not data.has("palettes"):
		print("[ModuleLibrary] WARNING: Failed to load color palettes, using fallback")
		_load_fallback_colors()
		return

	# Convert array to dictionary by palette name
	for palette in data["palettes"]:
		if palette.has("name"):
			var name = palette["name"]
			color_palettes[name] = palette

	print("[ModuleLibrary] Color palettes loaded from JSON")

## Load modules from JSON file
func _load_modules():
	var loader = load("res://scripts/module_library_loader.gd").new()
	var data = loader.load_module_library()

	if data.is_empty() or not data.has("modules"):
		print("[ModuleLibrary] WARNING: Failed to load modules, using fallback")
		return

	# Convert array to dictionary by module ID
	for module in data["modules"]:
		if module.has("id"):
			var id = module["id"]
			_modules[id] = module

	print("[ModuleLibrary] Modules loaded from JSON: %d modules" % _modules.size())

## Fallback colors if JSON loading fails
func _load_fallback_colors():
	color_palettes = {
		"Industrial": {
			"name": "Industrial",
			"colors": {
				"primary": Color(0.6, 0.6, 0.6),
				"secondary": Color(0.5, 0.5, 0.5)
			}
		}
	}

## Register all modules
func _register_all_modules():
	# TOP MODULES - High visibility on platform top
	_register_module({
		"id": "radar_tower",
		"name": "Radar Tower",
		"category": ModuleCategory.TOP,
		"mesh_type": MeshType.DISH,
		"scale": Vector3(1, 2, 1),
		"height": 1.5,
		"can_rotate": true,
		"fixed_angles": [0, 45, 90, 135, 180, 225, 270, 315],
		"snap_to_edge": false,
		"color_options": COLORS_TECH
	})

	_register_module({
		"id": "antenna_array",
		"name": "Antenna Array",
		"category": ModuleCategory.TOP,
		"mesh_type": MeshType.ANTENNA,
		"scale": Vector3(0.5, 4, 0.5),
		"height": 2.0,
		"can_rotate": true,
		"fixed_angles": [],
		"snap_to_edge": false,
		"color_options": COLORS_TECH
	})

	_register_module({
		"id": "satellite_dish",
		"name": "Satellite Dish",
		"category": ModuleCategory.TOP,
		"mesh_type": MeshType.SATELLITE_DISH,
		"scale": Vector3(2, 0.5, 2),
		"height": 1.2,
		"can_rotate": true,
		"fixed_angles": [],
		"snap_to_edge": false,
		"color_options": COLORS_TECH
	})

	_register_module({
		"id": "comms_array",
		"name": "Communications Array",
		"category": ModuleCategory.TOP,
		"mesh_type": MeshType.COMMS_ARRAY,
		"scale": Vector3(1.5, 3, 1.5),
		"height": 1.8,
		"can_rotate": true,
		"fixed_angles": [],
		"snap_to_edge": false,
		"color_options": COLORS_TECH
	})

	_register_module({
		"id": "helipad",
		"name": "Helipad",
		"category": ModuleCategory.FLOOR,
		"mesh_type": MeshType.HELIPAD,
		"scale": Vector3(3, 0.1, 3),
		"height": 0.05,
		"can_rotate": false,
		"fixed_angles": [0],
		"snap_to_edge": false,
		"color_options": [Color(0.8, 0.2, 0.2)]
	})

	# MIDDLE MODULES - Mid-level structures
	_register_module({
		"id": "cargo_container",
		"name": "Cargo Container",
		"category": ModuleCategory.MIDDLE,
		"mesh_type": MeshType.CONTAINER,
		"scale": Vector3(1.5, 1.2, 1.5),
		"height": 0.6,
		"can_rotate": true,
		"fixed_angles": [0, 90],
		"snap_to_edge": false,
		"color_options": COLORS_INDUSTRIAL
	})

	_register_module({
		"id": "equipment_box",
		"name": "Equipment Box",
		"category": ModuleCategory.MIDDLE,
		"mesh_type": MeshType.BOX,
		"scale": Vector3(1, 0.8, 1),
		"height": 0.4,
		"can_rotate": true,
		"fixed_angles": [0, 45, 90],
		"snap_to_edge": false,
		"color_options": COLORS_INDUSTRIAL
	})

	_register_module({
		"id": "solar_panel",
		"name": "Solar Panel",
		"category": ModuleCategory.MIDDLE,
		"mesh_type": MeshType.SOLAR_PANEL,
		"scale": Vector3(2, 0.2, 1.5),
		"height": 0.5,
		"can_rotate": true,
		"fixed_angles": [0, 90, 180, 270],
		"snap_to_edge": false,
		"color_options": [Color(0.2, 0.3, 0.5)]
	})

	_register_module({
		"id": "ventilation_unit",
		"name": "Ventilation Unit",
		"category": ModuleCategory.MIDDLE,
		"mesh_type": MeshType.VENT,
		"scale": Vector3(0.8, 0.6, 0.8),
		"height": 0.3,
		"can_rotate": true,
		"fixed_angles": [],
		"snap_to_edge": false,
		"color_options": COLORS_INDUSTRIAL
	})

	_register_module({
		"id": "fuel_tank",
		"name": "Fuel Tank",
		"category": ModuleCategory.MIDDLE,
		"mesh_type": MeshType.CYLINDER,
		"scale": Vector3(1.2, 1.5, 1.2),
		"height": 0.75,
		"can_rotate": true,
		"fixed_angles": [],
		"snap_to_edge": false,
		"color_options": [Color(0.7, 0.5, 0.3)]
	})

	# EDGE MODULES - Attach to platform edges
	_register_module({
		"id": "crane",
		"name": "Crane",
		"category": ModuleCategory.EDGE,
		"mesh_type": MeshType.CRANE,
		"scale": Vector3(0.5, 5, 0.5),
		"height": 2.5,
		"can_rotate": false,
		"fixed_angles": [],
		"snap_to_edge": true,
		"color_options": COLORS_INDUSTRIAL
	})

	_register_module({
		"id": "pipe_cluster",
		"name": "Pipe Cluster",
		"category": ModuleCategory.EDGE,
		"mesh_type": MeshType.PIPE_CLUSTER,
		"scale": Vector3(0.4, 2, 0.4),
		"height": 1.0,
		"can_rotate": false,
		"fixed_angles": [],
		"snap_to_edge": true,
		"color_options": COLORS_INDUSTRIAL
	})

	_register_module({
		"id": "turret",
		"name": "Gun Turret",
		"category": ModuleCategory.EDGE,
		"mesh_type": MeshType.TURRET,
		"scale": Vector3(0.6, 1.2, 0.6),
		"height": 0.6,
		"can_rotate": true,
		"fixed_angles": [],
		"snap_to_edge": true,
		"color_options": COLORS_MILITARY
	})

	_register_module({
		"id": "defenses_emplacement",
		"name": "Defenses Emplacement",
		"category": ModuleCategory.EDGE,
		"mesh_type": MeshType.BOX,
		"scale": Vector3(1.5, 1, 1),
		"height": 0.5,
		"can_rotate": false,
		"fixed_angles": [],
		"snap_to_edge": true,
		"color_options": COLORS_MILITARY
	})

	_register_module({
		"id": "lifeboat",
		"name": "Lifeboat Station",
		"category": ModuleCategory.EDGE,
		"mesh_type": MeshType.BOX,
		"scale": Vector3(1, 0.8, 1.5),
		"height": 0.4,
		"can_rotate": false,
		"fixed_angles": [],
		"snap_to_edge": true,
		"color_options": COLORS_MEDICAL
	})

	_register_module({
		"id": "sensor_array",
		"name": "Sensor Array",
		"category": ModuleCategory.EDGE,
		"mesh_type": MeshType.ANTENNA,
		"scale": Vector3(0.3, 1.5, 0.3),
		"height": 0.75,
		"can_rotate": true,
		"fixed_angles": [],
		"snap_to_edge": true,
		"color_options": COLORS_TECH
	})

## Register a module
func _register_module(module: Dictionary):
	_modules[module["id"]] = module

## Get module by ID
func get_module(id: String) -> Dictionary:
	return _modules.get(id, {})

## Helper functions to get module properties
func get_module_id(module: Dictionary) -> String:
	return module.get("id", "")

func get_mesh_type(module: Dictionary) -> int:
	return module.get("mesh_type", MeshType.BOX)

func get_scale(module: Dictionary) -> Vector3:
	var scale_data = module.get("scale", [1.0, 1.0, 1.0])
	if scale_data is Array:
		return Vector3(scale_data[0], scale_data[1], scale_data[2])
	return scale_data

func get_height(module: Dictionary) -> float:
	return module.get("height", 0.5)

func get_can_rotate(module: Dictionary) -> bool:
	return module.get("can_rotate", true)

func get_fixed_angles(module: Dictionary) -> Array[float]:
	if module.has("fixed_angles"):
		return _to_float_array(module["fixed_angles"])
	return []

func get_snap_to_edge(module: Dictionary) -> bool:
	return module.get("snap_to_edge", false)

func get_color_options(module: Dictionary) -> Array[Color]:
	# Try to get color palette from module
	var palette_name = module.get("color_palette", "")
	if not palette_name.is_empty() and color_palettes.has(palette_name):
		var palette = color_palettes[palette_name]
		if palette.has("colors"):
			return _hex_dict_to_color_array(palette["colors"])

	# Fallback to color_options array (backward compatibility)
	if module.has("color_options"):
		return _to_color_array(module["color_options"])

	return [Color(0.5, 0.5, 0.5)]

## Convert hex color dictionary to Color array
func _hex_dict_to_color_array(colors_dict: Dictionary) -> Array[Color]:
	var result: Array[Color] = []
	for color_key in colors_dict:
		var hex_color = colors_dict[color_key]
		if hex_color is String:
			result.append(Color(html_color=hex_color))
		elif hex_color is Color:
			result.append(hex_color)
	return result

## Helper: Convert to typed float array
func _to_float_array(arr: Array) -> Array[float]:
	var result: Array[float] = []
	result.assign(arr)
	return result

## Helper: Convert to typed Color array
func _to_color_array(arr: Array) -> Array[Color]:
	var result: Array[Color] = []
	result.assign(arr)
	return result

## Get all modules in category
func get_modules_by_category(category: ModuleCategory) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var category_string = _category_enum_to_string(category)

	for module in _modules.values():
		var module_category = module.get("category", "")
		if module_category == category_string:
			result.append(module)

	return result

## Convert category enum to string
func _category_enum_to_string(category: ModuleCategory) -> String:
	match category:
		ModuleCategory.TOP:
			return "TOP"
		ModuleCategory.MIDDLE:
			return "MIDDLE"
		ModuleCategory.EDGE:
			return "EDGE"
		ModuleCategory.FLOOR:
			return "FLOOR"
		_:
			return ""

## Get all module IDs
func get_all_ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(_modules.keys())
	return result

## Check if module exists
func has_module(id: String) -> bool:
	return _modules.has(id)
