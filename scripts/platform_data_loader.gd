# scripts/platform_data_loader.gd
# Loads platform type definitions, combo rules, and bed capacity from JSON files.
# Externalizes hardcoded platform data for easier balance adjustments.

extends DataLoader

## Load all platform type definitions
func load_platform_types() -> Dictionary:
	var data = load_json_file("platforms/platform_types.json")

	if data.is_empty():
		push_error("[PlatformDataLoader] Failed to load platform types")
		return {}

	if not data.has("platform_types"):
		push_error("[PlatformDataLoader] Invalid platform types format: missing 'platform_types'")
		return {}

	return data

## Load platform combo rules for adjacent bonuses
func load_combo_rules() -> Dictionary:
	var data = load_json_file("platforms/combo_rules.json")

	if data.is_empty():
		push_warning("[PlatformDataLoader] No combo rules loaded")
		return {}

	if not data.has("combo_rules"):
		push_error("[PlatformDataLoader] Invalid combo rules format: missing 'combo_rules'")
		return {}

	return data

## Load bed capacity for each platform type
func load_bed_capacity() -> Dictionary:
	var data = load_json_file("platforms/bed_capacity.json")

	if data.is_empty():
		push_warning("[PlatformDataLoader] No bed capacity data loaded")
		return {}

	if not data.has("bed_capacity"):
		push_error("[PlatformDataLoader] Invalid bed capacity format: missing 'bed_capacity'")
		return {}

	return data

## Get specific platform type data by type name
func get_platform_type_data(platform_type: String) -> Dictionary:
	var all_data = load_platform_types()

	if all_data.is_empty():
		return {}

	for platform in all_data["platform_types"]:
		if platform.has("type") and platform["type"] == platform_type:
			return platform

	push_error("[PlatformDataLoader] Platform type not found: %s" % platform_type)
	return {}

## Get bed capacity for specific platform type
func get_bed_capacity(platform_type: String) -> int:
	var data = load_bed_capacity()

	if data.has("bed_capacity") and data["bed_capacity"].has(platform_type):
		return data["bed_capacity"][platform_type]

	return 0  # Default: no beds

## Get combo bonus for adjacent platforms
## Returns bonus multiplier (1.0 = no bonus, >1.0 = bonus)
func get_combo_bonus(parent_type: String, child_type: String) -> float:
	var data = load_combo_rules()

	if data.is_empty():
		return 1.0

	for rule in data["combo_rules"]:
		if rule.has("parent") and rule.has("child") and rule.has("bonus"):
			if rule["parent"] == parent_type and rule["child"] == child_type:
				return rule["bonus"]

	return 1.0  # No bonus

## Validate platform type data structure
func validate_platform_data(data: Dictionary) -> bool:
	var required_fields = ["type", "display_name", "description", "production", "costs"]
	return validate_required_fields(data, required_fields)
