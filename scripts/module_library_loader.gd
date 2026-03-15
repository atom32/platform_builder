# scripts/module_library_loader.gd
# Loads procedural module definitions and color palettes from JSON files.
# Externalizes hardcoded module data for visual variety adjustments.

extends DataLoader

## Load all module definitions
func load_module_library() -> Dictionary:
	var data = load_json_file("modules/module_library.json")

	if data.is_empty():
		push_error("[ModuleLibraryLoader] Failed to load module library")
		return {}

	if not data.has("modules"):
		push_error("[ModuleLibraryLoader] Invalid module library format: missing 'modules'")
		return {}

	return data

## Load color palettes for procedural generation
func load_color_palettes() -> Dictionary:
	var data = load_json_file("modules/color_palettes.json")

	if data.is_empty():
		push_error("[ModuleLibraryLoader] Failed to load color palettes")
		return {}

	if not data.has("palettes"):
		push_error("[ModuleLibraryLoader] Invalid color palettes format: missing 'palettes'")
		return {}

	return data

## Get specific module data by module name
func get_module_data(module_name: String) -> Dictionary:
	var all_data = load_module_library()

	if all_data.is_empty():
		return {}

	for module in all_data["modules"]:
		if module.has("name") and module["name"] == module_name:
			return module

	push_error("[ModuleLibraryLoader] Module not found: %s" % module_name)
	return {}

## Get all module names
func get_module_names() -> Array:
	var all_data = load_module_library()
	var names: Array = []

	if all_data.has("modules"):
		for module in all_data["modules"]:
			if module.has("name"):
				names.append(module["name"])

	return names

## Get a random color palette
func get_random_palette() -> Dictionary:
	var data = load_color_palettes()

	if data.is_empty():
		return _get_default_palette()

	if not data.has("palettes") or data["palettes"].is_empty():
		return _get_default_palette()

	var palettes = data["palettes"]
	return palettes.pick_random()

## Get color for module type from specific palette
func get_module_color(module_type: String, palette_name: String = "") -> Color:
	var data = load_color_palettes()

	if data.is_empty():
		return Color.WHITE

	if palette_name.is_empty():
		# Get random palette
		var palette = get_random_palette()
		if palette.has("colors") and palette["colors"].has(module_type):
			return Color(palette["colors"][module_type])
	else:
		# Get specific palette
		for palette in data["palettes"]:
			if palette.has("name") and palette["name"] == palette_name:
				if palette.has("colors") and palette["colors"].has(module_type):
					return Color(palette["colors"][module_type])

	return Color.WHITE  # Fallback

## Validate module data structure
func validate_module_data(data: Dictionary) -> bool:
	var required_fields = ["name", "type", "mesh_scale", "position_range"]
	return validate_required_fields(data, required_fields)

## Default color palette (fallback)
func _get_default_palette() -> Dictionary:
	return {
		"name": "Default",
		"description": "Fallback color palette",
		"colors": {
			"Radar": Color.WHITE.to_html(),
			"Antenna": Color.WHITE.to_html(),
			"Crane": Color.WHITE.to_html(),
			"Pipes": Color.WHITE.to_html(),
			"Container": Color.WHITE.to_html()
		}
	}
