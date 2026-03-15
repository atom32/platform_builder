extends Node
class_name PlatformDataSystem

## Data-driven platform configuration system
## Centralizes all platform stats and properties

# Preload loader classes for safe initialization
const PlatformDataLoader = preload("res://scripts/platform_data_loader.gd")

## Platform type data dictionary (loaded from JSON)
var platform_data: Dictionary = {}

## Combo rules: tag combinations and their effects (loaded from JSON)
var combo_rules: Dictionary = {}

func _ready():
	_load_platform_data()
	_load_combo_rules()

## Load platform data from JSON file
func _load_platform_data():
	var loader = PlatformDataLoader.new()
	var data = loader.load_platform_types()

	if data.is_empty() or not data.has("platform_types"):
		print("[PlatformDataSystem] WARNING: Failed to load platform data, using fallback")
		_load_fallback_data()
		return

	# Convert array to dictionary for easier lookup
	for platform in data["platform_types"]:
		if platform.has("type"):
			var type_key = platform["type"]
			platform_data[type_key] = platform

	print("[PlatformDataSystem] Platform data loaded from JSON")

## Load combo rules from JSON file
func _load_combo_rules():
	var loader = PlatformDataLoader.new()
	var data = loader.load_combo_rules()

	if data.is_empty() or not data.has("combo_rules"):
		print("[PlatformDataSystem] WARNING: Failed to load combo rules")
		return

	# Convert array to dictionary for easier lookup
	for rule in data["combo_rules"]:
		if rule.has("id"):
			var rule_id = rule["id"]
			combo_rules[rule_id] = rule

	print("[PlatformDataSystem] Combo rules loaded from JSON")

## Fallback data if JSON loading fails
func _load_fallback_data():
	platform_data = {
		"HQ": {
			"display_name": "Headquarters",
			"description": "Central command of the base",
			"production": {"materials": 0, "fuel": 0},
			"costs": {"materials": 0, "fuel": 0},
			"construction_time": 0.0,
			"tags": ["hq", "command"]
		}
	}

## Get platform data by type
func get_platform_data(platform_type: String) -> Dictionary:
	if platform_data.has(platform_type):
		return platform_data[platform_type]
	return {}

## Get production rates for a platform type
func get_materials_production(platform_type: String) -> int:
	var data = get_platform_data(platform_type)
	if data.has("production"):
		return data["production"].get("materials", 0)
	# Backward compatibility with old structure
	if data.has("materials_production"):
		return data["materials_production"]
	return 0

func get_fuel_production(platform_type: String) -> int:
	var data = get_platform_data(platform_type)
	if data.has("production"):
		return data["production"].get("fuel", 0)
	# Backward compatibility with old structure
	if data.has("fuel_production"):
		return data["fuel_production"]
	return 0

## Get build cost for a platform type
func get_build_cost(platform_type: String) -> Dictionary:
	var data = get_platform_data(platform_type)
	if data.has("costs"):
		return data["costs"]
	# Backward compatibility with old structure
	if data.has("build_cost"):
		return data["build_cost"]
	return {"materials": 0, "fuel": 0}

## Get construction time for a platform type (in seconds)
func get_construction_time(platform_type: String) -> float:
	var data = get_platform_data(platform_type)
	if data.has("construction_time"):
		return data["construction_time"]
	return 45.0  # Default construction time

## Get tags for a platform type
func get_tags(platform_type: String) -> Array:
	var data = get_platform_data(platform_type)
	if data.has("tags"):
		return data["tags"]
	return []

## Get display name
func get_display_name(platform_type: String) -> String:
	var data = get_platform_data(platform_type)
	if data.has("display_name"):
		return data["display_name"]
	return platform_type

## Get all available platform types
func get_all_platform_types() -> Array:
	return platform_data.keys()

## Check if a combo exists between two platform types
func check_combo(parent_type: String, child_type: String) -> Dictionary:
	for combo_id in combo_rules:
		var combo = combo_rules[combo_id]

		# New JSON structure uses parent/child
		if combo.has("parent") and combo.has("child"):
			if combo["parent"] == parent_type and combo["child"] == child_type:
				return combo
		# Backward compatibility with old tag-based structure
		elif combo.has("required_tags"):
			var parent_data = get_platform_data(parent_type)
			var child_data = get_platform_data(child_type)
			var parent_tags = parent_data.get("tags", [])
			var child_tags = child_data.get("tags", [])

			var required_tags = combo["required_tags"]
			var has_all_tags = true
			for tag in required_tags:
				if not (tag in parent_tags or tag in child_tags):
					has_all_tags = false
					break

			if has_all_tags:
				return combo

	return {}

## Backward compatibility: Check if a combo exists between two tag sets
func check_combo_by_tags(tags_a: Array, tags_b: Array) -> Dictionary:
	for combo_id in combo_rules:
		var combo = combo_rules[combo_id]

		if combo.has("required_tags"):
			var required_tags = combo["required_tags"]
			var has_all_tags = true
			for tag in required_tags:
				if not (tag in tags_a or tag in tags_b):
					has_all_tags = false
					break

			if has_all_tags:
				return combo

	return {}

## Get combo description
func get_combo_description(combo_id: String) -> String:
	if combo_rules.has(combo_id):
		return combo_rules[combo_id]["description"]
	return ""
