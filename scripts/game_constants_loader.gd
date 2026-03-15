# scripts/game_constants_loader.gd
# Loads core game constants from external JSON files.
# Replaces hardcoded values across multiple systems.

extends DataLoader

## Load game constants (limits, costs, timers, etc.)
func load_constants() -> Dictionary:
	var data = load_json_file("core/game_constants.json")

	if data.is_empty():
		push_warning("[GameConstantsLoader] Using default game constants")
		return _get_default_constants()

	if not validate_required_fields(data, ["platform_limits", "staff_economy", "department_bonuses"]):
		return _get_default_constants()

	return data

## Load starting resources configuration
func load_starting_resources() -> Dictionary:
	var data = load_json_file("core/starting_resources.json")

	if data.is_empty():
		push_warning("[GameConstantsLoader] Using default starting resources")
		return {
			"materials": 200,
			"fuel": 100,
			"gmp": 300,
			"beds": 10
		}

	return data

## Load camera settings
func load_camera_settings() -> Dictionary:
	var data = load_json_file("core/camera_settings.json")

	if data.is_empty():
		push_warning("[GameConstantsLoader] Using default camera settings")
		return {
			"zoom": {
				"min_distance": 15.0,
				"max_distance": 80.0,
				"step": 5.0
			},
			"pan": {
				"enabled": true,
				"speed_multiplier": 1.0
			}
		}

	return data

## Default game constants (fallback if JSON file is missing)
func _get_default_constants() -> Dictionary:
	return {
		"version": "1.0",
		"platform_limits": {
			"max_platforms_per_department": 6,
			"max_children_per_platform": 6,
			"max_total_platforms": 100
		},
		"staff_economy": {
			"recruit_cost_gmp": 50,
			"upkeep_cost_materials_per_minute": 1,
			"salary_cost_gmp_per_day": 1
		},
		"department_bonuses": {
			"research_speed_per_staff": 0.1,
			"combat_power_per_staff": 0.5
		}
	}
