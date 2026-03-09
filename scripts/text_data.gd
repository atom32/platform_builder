extends Node
class_name TextData

## Text data system for internationalization (i18n)
## All game text is centralized here for easy translation

## UI Text
const UI = {
	# HUD
	hud_materials = "Materials: %d"
	hud_fuel = "Fuel: %d"
	hud_base = "Base: %d/%d"
	hud_combos = "Combos: %d"
	hud_expeditions = "Expeditions: %d (Press E)"
	hud_combat = "Combat: %d"

	# Build Menu
	build_parent_full = "%s (Parent Full)"
	build_cost_format = "%s - %d Mat, %d Fuel"

	# Expedition Menu
	expedition_title = "Expeditions"
	expedition_combat_power = "Combat Power: %d"
	expedition_in_progress = "%s\nIn Progress (%ds)\nDifficulty: %s"
	expedition_available = "%s\n%s\nPower: %d/%d | Duration: %ds | Difficulty: %s\nRewards: %d Mat, %d Fuel"
	expedition_locked = "%s\nLOCKED - Need %d Combat Power (have %d)"
	expedition_close = "X"
}

## Platform Type Names
const PLATFORM_TYPES = {
	hq = "HQ"
	rd = "R&D"
	support = "Support"
	combat = "Combat"
	intel = "Intel"
	medical = "Medical"
}

## Messages
const MESSAGES = {
	# Platform building
	build_success_title = "BUILD SUCCESS"
	build_success_details = "  Type: %s Platform\n  Parent: %s\n  Cost: %d Materials, %d Fuel\n  Parent Children: %d/%d\n  Base Size: %d/%d"
	build_failed_base_full = "Base has reached maximum platform count (%d)"
	build_failed_parent_full = "Parent platform is full (6/6 children)"
	build_failed_materials = "Not enough resources: Need %d Materials (have %d)"
	build_failed_fuel = "Not enough resources: Need %d Fuel (have %d)"

	# Platform production
	production_rates = "%s: Production rates set - Materials: %d, Fuel: %d, Tags: %s"
	platform_upgraded = "%s upgraded to Level %d"

	# Platform slots
	slots_created = "%s: Created %d build slots"
	child_added = "%s: Added child %s (total children: %d/%d)"

	# System messages
	hq_spawned = "HQ Platform spawned at center"
	combo_detected = "Combo detected: %s (%s)"
	combo_removed = "Combo removed: %s"
	expedition_started = "Expedition started: %s"
	expedition_completed = "Expedition completed: %s - Rewards: %d Materials, %d Fuel"
	expedition_failed = "Expedition failed: %s - Insufficient combat power"
}

## Expedition Missions
const EXPEDITIONS = {
	gather_resources_name = "Gather Resources"
	gather_resources_desc = "Send team to collect materials"

	scout_territory_name = "Scout Territory"
	scout_territory_desc = "Explore nearby areas"

	raid_enemy_outpost_name = "Raid Enemy Outpost"
	raid_enemy_outpost_desc = "Attack enemy base for resources"

	defend_base_name = "Defend Base"
	defend_base_desc = "Repel incoming enemy attack"
}

## Difficulty Names
const DIFFICULTY = {
	easy = "Easy"
	medium = "Medium"
	hard = "Hard"
	expert = "Expert"
}

## Get formatted text with parameters
static func get(key: String, args: Array = []) -> String:
	var text = _get_text_from_key(key)

	if args.size() > 0:
		text = text % args

	return text

## Get raw text without formatting
static func get_raw(key: String) -> String:
	return _get_text_from_key(key)

## Internal helper to traverse dictionary and get text
static func _get_text_from_key(key: String) -> String:
	var parts = key.split("_")
	var category = parts[0]
	var text_key = key.substr(category.length() + 1)

	match category:
		"ui":
			if UI.has(text_key):
				return UI[text_key]
		"platform":
			if PLATFORM_TYPES.has(text_key):
				return PLATFORM_TYPES[text_key]
		"msg":
			if MESSAGES.has(text_key):
				return MESSAGES[text_key]
		"expedition":
			if EXPEDITIONS.has(text_key):
				return EXPEDITIONS[text_key]
		"difficulty":
			if DIFFICULTY.has(text_key):
				return DIFFICULTY[text_key]

	# Fallback: return key if not found
	push_warning("Text key not found: %s" % key)
	return key

## Platform type name helper
static func platform_type_name(type: String) -> String:
	match type:
		"HQ": return PLATFORM_TYPES.hq
		"R&D": return PLATFORM_TYPES.rd
		"Support": return PLATFORM_TYPES.support
		"Combat": return PLATFORM_TYPES.combat
		"Intel": return PLATFORM_TYPES.intel
		"Medical": return PLATFORM_TYPES.medical
		_: return type

## Difficulty name helper
static func difficulty_name(difficulty: String) -> String:
	match difficulty:
		"easy": return DIFFICULTY.easy
		"medium": return DIFFICULTY.medium
		"hard": return DIFFICULTY.hard
		"expert": return DIFFICULTY.expert
		_: return difficulty.capitalize()
