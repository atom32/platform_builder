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
		"ui_resources_header": return "RESOURCES"
		"ui_gmp_format": return "GMP: %d"
		"ui_staff_count_format": return "Staff: %d/%d"
		"ui_base_status_header": return "BASE STATUS"
		"ui_combos_header": return "Combos"
		"ui_combos_format": return "Combos: %d\n"
		"ui_combos_none": return "Combos: 0"
		"ui_objectives_header": return "OBJECTIVES"
		"ui_objective_complete_prefix": return "[X] "
		"ui_objective_incomplete_prefix": return "[ ] "
		"ui_all_objectives_complete": return "All objectives complete!"
		"ui_hide_sidebar": return "Hide (H)"
		"ui_show_sidebar": return "Show (H)"

		# UI - Base Management Panel
		"ui_base_management_title": return "BASE MANAGEMENT"
		"ui_close": return "X"
		"ui_recruit_pool": return "Recruit Pool - Available Staff"
		"ui_recruit_pool_format": return "Recruit Pool - %d Available Staff"
		"ui_assign_to_rd": return "Assign to R&D"
		"ui_assign_to_combat": return "Assign to Combat"
		"ui_assign_to_support": return "Assign to Support"
		"ui_assign_to_intel": return "Assign to Intel"
		"ui_assign_to_medical": return "Assign to Medical"
		"ui_department_assignments": return "Department Assignments"
		"ui_dismiss_staff": return "Dismiss Staff - Reduce Upkeep Costs"
		"ui_dismiss_selected": return "Dismiss Selected"
		"ui_no_specialty": return "No Specialty"
		"ui_staff_display_format": return "%s | Skill: %d | %s"
		"ui_department_header_format": return "%s Department - %d Staff"
		"ui_staff_dismissed": return "Staff dismissed: %s"

		# UI - Expeditions
		"ui_expedition_success_chance": return "Success Chance: %d%%"
		"ui_expedition_resource_yield": return "Resource Yield: %d%%"
		"ui_expedition_casualty_reduction": return "Casualty Reduction: %d%%"
		"ui_expedition_duration_reduction": return "Duration: %d%%"

		# UI - Overview
		"ui_overview_stats": return "Total Platforms: %d | Tree Depth: %d"

		# UI - Save/Load
		"ui_save_load": return "SAVE / LOAD"
		"ui_story_mode": return "Story Mode"
		"ui_sandbox_mode": return "Sandbox Mode"
		"ui_save_slot_format": return "Slot %d: %s"
		"ui_save_slot_empty": return "Slot %d: Empty"
		"ui_save": return "Save"
		"ui_load": return "Load"
		"ui_delete": return "Delete"
		"ui_return_to_title": return "Return to Title Menu"

		# UI - Result Screen
		"ui_result_victory": return "VICTORY"
		"ui_result_game_over": return "GAME OVER"
		"ui_days_survived": return "Days Survived: %d"
		"ui_platforms_built": return "Platforms Built: %d"
		"ui_staff_recruited_count": return "Staff Recruited: %d"
		"ui_expeditions_sent_count": return "Expeditions Sent: %d"
		"ui_victory_message": return "Congratulations! You completed all objectives!"
		"ui_defeat_message": return "Your base has been lost."
		"ui_defeat_reason": return "Reason: %s"

		# UI - Story Objectives
		"ui_chapter_loading": return "CHAPTER 1: Loading..."
		"ui_chapter_format": return "CHAPTER %s: %s"
		"ui_missions_complete": return "✓ ALL MISSIONS COMPLETE ✓"
		"ui_continue_sandbox": return "Continue building your base in Sandbox Mode"
		"ui_chapter_end": return "END"

		# UI - Dialogue
		"ui_choice_default": return "Choice"
		"ui_speaker_unknown": return "Unknown"

		# UI - Build Menu
		"ui_select_platform_type": return "Select Platform Type"
		"ui_build_button_rd": return "R&D (%d Mat, %d Fuel)"
		"ui_build_button_support": return "Support (%d Mat, %d Fuel)"
		"ui_build_button_combat": return "Combat (%d Mat, %d Fuel)"
		"ui_build_button_intel": return "Intel (%d Mat, %d Fuel)"
		"ui_build_button_medical": return "Medical (%d Mat, %d Fuel)"

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

## Expedition mission name helper (maps mission_id to display name)
static func expedition_name(mission_id: String) -> String:
	match mission_id:
		"supply_raid": return "Supply Raid"
		"resource_scavenge": return "Resource Scavenge"
		"intel_gathering": return "Intel Gathering"
		"heavy_assault": return "Heavy Assault"
		_: return mission_id.capitalize().replace("_", " ")
		_: return mission_id.capitalize()
