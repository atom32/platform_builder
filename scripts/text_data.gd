extends Node
## Text data system for internationalization (i18n)
## All game text is centralized here for easy translation

## Get formatted text with parameters
static func format(key: String, args: Array = []) -> String:
	var text = _get_raw_text(key)

	if args.size() > 0:
		text = text % args

	return text

## Get raw text without formatting
static func get_raw(key: String) -> String:
	return _get_raw_text(key)

## Internal helper to get text by key
static func _get_raw_text(key: String) -> String:
	match key:
		# UI - HUD
		"ui_materials": return "Materials: %d"
		"ui_fuel": return "Fuel: %d"
		"ui_base": return "Base: %d/%d"
		"ui_combos": return "Combos: %d"
		"ui_expeditions": return "Expeditions: %d (Press E)"
		"ui_combat": return "Combat: %d"

		# UI - Build Menu
		"ui_build_parent_full": return "%s (Parent Full)"
		"ui_build_cost_format": return "%s - %d Mat, %d Fuel"

		# UI - Expedition Menu
		"ui_expedition_title": return "Expeditions"
		"ui_expedition_combat_power": return "Combat Power: %d"
		"ui_expedition_in_progress": return "%s\nIn Progress (%ds)\nDifficulty: %s"
		"ui_expedition_available": return "%s\n%s\nPower: %d/%d | Duration: %ds | Difficulty: %s\nRewards: %d Mat, %d Fuel"
		"ui_expedition_locked": return "%s\nLOCKED - Need %d Combat Power (have %d)"
		"ui_expedition_close": return "X"

		# Messages - Platform Building
		"msg_build_success_title": return "BUILD SUCCESS"
		"msg_build_success_details": return "  Type: %s Platform\n  Parent: %s\n  Cost: %d Materials, %d Fuel\n  Parent Children: %d/%d\n  Base Size: %d/%d"
		"msg_build_failed_base_full": return "Base has reached maximum platform count (%d)"
		"msg_build_failed_parent_full": return "Parent platform is full (6/6 children)"
		"msg_build_failed_materials": return "Not enough resources: Need %d Materials (have %d)"
		"msg_build_failed_fuel": return "Not enough resources: Need %d Fuel (have %d)"

		# Messages - Platform Production
		"msg_production_rates": return "%s: Production rates set - Materials: %d, Fuel: %d, Tags: %s"
		"msg_platform_upgraded": return "%s upgraded to Level %d"

		# Messages - Platform Slots
		"msg_slots_created": return "%s: Created %d build slots"
		"msg_child_added": return "%s: Added child %s (total children: %d/%d)"

		# Messages - System
		"msg_hq_spawned": return "HQ Platform spawned at center"
		"msg_combo_detected": return "Combo detected: %s (%s)"
		"msg_combo_removed": return "Combo removed: %s"
		"msg_expedition_started": return "Expedition started: %s"
		"msg_expedition_completed": return "Expedition completed: %s - Rewards: %d Materials, %d Fuel"
		"msg_expedition_failed": return "Expedition failed: %s - Insufficient combat power"

		# Expedition Missions
		"expedition_gather_resources_name": return "Gather Resources"
		"expedition_gather_resources_desc": return "Send team to collect materials"
		"expedition_scout_territory_name": return "Scout Territory"
		"expedition_scout_territory_desc": return "Explore nearby areas"
		"expedition_raid_enemy_outpost_name": return "Raid Enemy Outpost"
		"expedition_raid_enemy_outpost_desc": return "Attack enemy base for resources"
		"expedition_defend_base_name": return "Defend Base"
		"expedition_defend_base_desc": return "Repel incoming enemy attack"

		# Difficulty
		"difficulty_easy": return "Easy"
		"difficulty_medium": return "Medium"
		"difficulty_hard": return "Hard"
		"difficulty_expert": return "Expert"

		_: return "MISSING_TEXT: %s" % key

## Platform type name helper
static func platform_type_name(type: String) -> String:
	match type:
		"HQ": return "HQ"
		"R&D": return "R&D"
		"Support": return "Support"
		"Combat": return "Combat"
		"Intel": return "Intel"
		"Medical": return "Medical"
		_: return type

## Difficulty name helper
static func difficulty_name(difficulty: String) -> String:
	match difficulty:
		"easy": return "Easy"
		"medium": return "Medium"
		"hard": return "Hard"
		"expert": return "Expert"
		_: return difficulty.capitalize()
