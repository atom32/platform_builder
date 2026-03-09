extends Node
class_name PlatformDataSystem

## Data-driven platform configuration system
## Centralizes all platform stats and properties

## Platform type data dictionary
var platform_data: Dictionary = {
	"HQ": {
		"display_name": "Headquarters",
		"description": "Central command of the base",
		"materials_production": 0,
		"fuel_production": 0,
		"build_cost": {"materials": 0, "fuel": 0},
		"tags": ["hq", "command"]
	},

	"R&D": {
		"display_name": "Research & Development",
		"description": "Advanced technology research facility",
		"materials_production": 2,
		"fuel_production": 0,
		"build_cost": {"materials": 50, "fuel": 10},
		"tags": ["research"]
	},

	"Combat": {
		"display_name": "Combat Platform",
		"description": "Military operations and defense",
		"materials_production": 1,
		"fuel_production": 1,
		"build_cost": {"materials": 40, "fuel": 30},
		"tags": ["combat", "military"]
	},

	"Support": {
		"display_name": "Support Platform",
		"description": "Logistics and supply operations",
		"materials_production": 0,
		"fuel_production": 2,
		"build_cost": {"materials": 30, "fuel": 40},
		"tags": ["support", "logistics"]
	},

	"Intel": {
		"display_name": "Intel Platform",
		"description": "Intelligence gathering and analysis",
		"materials_production": 0,
		"fuel_production": 1,
		"build_cost": {"materials": 35, "fuel": 25},
		"tags": ["intel"]
	},

	"Medical": {
		"display_name": "Medical Platform",
		"description": "Medical treatment and research",
		"materials_production": 1,
		"fuel_production": 0,
		"build_cost": {"materials": 25, "fuel": 25},
		"tags": ["medical", "support"]
	}
}

## Combo rules: tag combinations and their effects
var combo_rules: Dictionary = {
	"research_intel": {
		"required_tags": ["research", "intel"],
		"effect_type": "research_speed",
		"bonus": 0.2,  # +20%
		"description": "Faster Research"
	},
	"combat_support": {
		"required_tags": ["combat", "support"],
		"effect_type": "expedition_strength",
		"bonus": 0.15,  # +15%
		"description": "Stronger Expeditions"
	},
	"medical_combat": {
		"required_tags": ["medical", "combat"],
		"effect_type": "casualty_reduction",
		"bonus": 0.25,  # +25%
		"description": "Reduced Casualties"
	},
	"intel_combat": {
		"required_tags": ["intel", "combat"],
		"effect_type": "expedition_strength",
		"bonus": 0.1,  # +10%
		"description": "Tactical Advantage"
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
	if data.has("materials_production"):
		return data["materials_production"]
	return 0

func get_fuel_production(platform_type: String) -> int:
	var data = get_platform_data(platform_type)
	if data.has("fuel_production"):
		return data["fuel_production"]
	return 0

## Get build cost for a platform type
func get_build_cost(platform_type: String) -> Dictionary:
	var data = get_platform_data(platform_type)
	if data.has("build_cost"):
		return data["build_cost"]
	return {"materials": 0, "fuel": 0}

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

## Check if a combo exists between two tag sets
func check_combo(tags_a: Array, tags_b: Array) -> Dictionary:
	for combo_id in combo_rules:
		var combo = combo_rules[combo_id]
		var required_tags = combo["required_tags"]

		# Check if both required tags are present across the two platforms
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
