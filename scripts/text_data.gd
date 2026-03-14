extends Node
## Text data system for internationalization (i18n)
## All game text is centralized here for easy translation

## Language management
var current_language: String = "en"
var translations: Dictionary = {}

## Language constants
const LANG_ENGLISH: String = "en"
const LANG_CHINESE: String = "zh"

## Initialize translations on creation
func _init():
	_load_english_translations()
	_load_chinese_translations()

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
	# Use instance method to access current_language
	return TextData._get_translated_text(key)

func _get_translated_text(key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(key):
		return translations[current_language][key]

	# Fallback to English
	if translations.has(LANG_ENGLISH) and translations[LANG_ENGLISH].has(key):
		return translations[LANG_ENGLISH][key]

	return "MISSING_TEXT: %s" % key

## Available languages
func get_available_languages() -> Array:
	return [LANG_ENGLISH, LANG_CHINESE]

## Language display names
func get_language_name(lang_code: String) -> String:
	match lang_code:
		LANG_ENGLISH: return "English"
		LANG_CHINESE: return "简体中文"
		_: return "Unknown"

## Set current language
func set_language(lang: String) -> bool:
	if translations.has(lang):
		current_language = lang
		return true
	return false

## Get current language
func get_current_language() -> String:
	return current_language

## Load English translations (current strings)
func _load_english_translations():
	translations[LANG_ENGLISH] = {
		# UI - HUD
		"ui_materials": "Materials: %d",
		"ui_fuel": "Fuel: %d",
		"ui_base": "Base: %d/%d",
		"ui_combos": "Combos: %d",
		"ui_expeditions": "Expeditions: %d (Press E)",
		"ui_combat": "Combat: %d",
		"ui_resources_header": "RESOURCES",
		"ui_gmp_format": "GMP: %d",
		"ui_staff_count_format": "Staff: %d/%d",
		"ui_base_status_header": "BASE STATUS",
		"ui_combos_header": "Combos",
		"ui_combos_format": "Combos: %d\n",
		"ui_combos_none": "Combos: 0",
		"ui_objectives_header": "OBJECTIVES",
		"ui_objective_complete_prefix": "[X] ",
		"ui_objective_incomplete_prefix": "[ ] ",
		"ui_all_objectives_complete": "All objectives complete!",
		"ui_hide_sidebar": "Hide (H)",
		"ui_show_sidebar": "Show (H)",

		# UI - Key Bindings
		"ui_keybinding_recruit": "R: Recruit",
		"ui_keybinding_management": "TAB: Management",
		"ui_keybinding_sidebar": "H: Sidebar",
		"ui_keybinding_debug_info": "F: Debug Info (when enabled)",

		# UI - Base Management Panel
		"ui_base_management_title": "BASE MANAGEMENT",
		"ui_close": "X",
		"ui_recruit_pool": "Recruit Pool - Available Staff",
		"ui_recruit_pool_format": "Recruit Pool - %d Available Staff",
		"ui_assign_to_rd": "Assign to R&D",
		"ui_assign_to_combat": "Assign to Combat",
		"ui_assign_to_support": "Assign to Support",
		"ui_assign_to_intel": "Assign to Intel",
		"ui_assign_to_medical": "Assign to Medical",
		"ui_department_assignments": "Department Assignments",
		"ui_dismiss_staff": "Dismiss Staff - Reduce Upkeep Costs",
		"ui_dismiss_selected": "Dismiss Selected",
		"ui_no_specialty": "No Specialty",
		"ui_staff_display_format": "%s | Skill: %d | %s",
		"ui_department_header_format": "%s Department - %d Staff",
		"ui_staff_dismissed": "Staff dismissed: %s",

		# UI - Expeditions
		"ui_expedition_success_chance": "Success Chance: %d%%",
		"ui_expedition_resource_yield": "Resource Yield: %d%%",
		"ui_expedition_casualty_reduction": "Casualty Reduction: %d%%",
		"ui_expedition_duration_reduction": "Duration: %d%%",

		# UI - Overview
		"ui_overview_stats": "Total Platforms: %d | Tree Depth: %d",

		# UI - Save/Load
		"ui_save_load": "SAVE / LOAD",
		"ui_story_mode": "Story Mode",
		"ui_sandbox_mode": "Sandbox Mode",
		"ui_save_slot_format": "Slot %d: %s",
		"ui_save_slot_empty": "Slot %d: Empty",
		"ui_save": "Save",
		"ui_load": "Load",
		"ui_delete": "Delete",
		"ui_return_to_title": "Return to Title Menu",

		# UI - Result Screen
		"ui_result_victory": "VICTORY",
		"ui_result_game_over": "GAME OVER",
		"ui_days_survived": "Days Survived: %d",
		"ui_platforms_built": "Platforms Built: %d",
		"ui_staff_recruited_count": "Staff Recruited: %d",
		"ui_expeditions_sent_count": "Expeditions Sent: %d",
		"ui_victory_message": "Congratulations! You completed all objectives!",
		"ui_defeat_message": "Your base has been lost.",
		"ui_defeat_reason": "Reason: %s",

		# UI - Story Objectives
		"ui_chapter_loading": "CHAPTER 1: Loading...",
		"ui_chapter_format": "CHAPTER %s: %s",
		"ui_missions_complete": "✓ ALL MISSIONS COMPLETE ✓",
		"ui_continue_sandbox": "Continue building your base in Sandbox Mode",
		"ui_chapter_end": "END",

		# UI - Dialogue
		"ui_choice_default": "Choice",
		"ui_speaker_unknown": "Unknown",

		# UI - Build Menu
		"ui_select_platform_type": "Select Platform Type",
		"ui_build_button_rd": "R&D (%d Mat, %d Fuel)",
		"ui_build_button_support": "Support (%d Mat, %d Fuel)",
		"ui_build_button_combat": "Combat (%d Mat, %d Fuel)",
		"ui_build_button_intel": "Intel (%d Mat, %d Fuel)",
		"ui_build_button_medical": "Medical (%d Mat, %d Fuel)",

		# UI - Build Menu
		"ui_build_parent_full": "%s (Parent Full)",
		"ui_build_cost_format": "%s - %d Mat, %d Fuel",

		# UI - Expedition Menu
		"ui_expedition_title": "Expeditions",
		"ui_expedition_combat_power": "Combat Power: %d",
		"ui_expedition_in_progress": "%s\nIn Progress (%ds)\nDifficulty: %s",
		"ui_expedition_available": "%s\n%s\nPower: %d/%d | Duration: %ds | Difficulty: %s\nRewards: %d Mat, %d Fuel",
		"ui_expedition_locked": "%s\nLOCKED - Need %d Combat Power (have %d)",
		"ui_expedition_close": "X",

		# Messages - Platform Building
		"msg_build_success_title": "BUILD SUCCESS",
		"msg_build_success_details": "  Type: %s Platform\n  Parent: %s\n  Cost: %d Materials, %d Fuel\n  Parent Children: %d/%d\n  Base Size: %d/%d",
		"msg_build_failed_base_full": "Base has reached maximum platform count (%d)",
		"msg_build_failed_parent_full": "Parent platform is full (6/6 children)",
		"msg_build_failed_materials": "Not enough resources: Need %d Materials (have %d)",
		"msg_build_failed_fuel": "Not enough resources: Need %d Fuel (have %d)",

		# Messages - Platform Production
		"msg_production_rates": "%s: Production rates set - Materials: %d, Fuel: %d, Tags: %s",
		"msg_platform_upgraded": "%s upgraded to Level %d",

		# Messages - Platform Slots
		"msg_slots_created": "%s: Created %d build slots",
		"msg_child_added": "%s: Added child %s (total children: %d/%d)",

		# Messages - System
		"msg_hq_spawned": "HQ Platform spawned at center",
		"msg_combo_detected": "Combo detected: %s (%s)",
		"msg_combo_removed": "Combo removed: %s",
		"msg_expedition_started": "Expedition started: %s",
		"msg_expedition_completed": "Expedition completed: %s - Rewards: %d Materials, %d Fuel",
		"msg_expedition_failed": "Expedition failed: %s - Insufficient combat power",

		# Expedition Missions
		"expedition_gather_resources_name": "Gather Resources",
		"expedition_gather_resources_desc": "Send team to collect materials",
		"expedition_scout_territory_name": "Scout Territory",
		"expedition_scout_territory_desc": "Explore nearby areas",
		"expedition_raid_enemy_outpost_name": "Raid Enemy Outpost",
		"expedition_raid_enemy_outpost_desc": "Attack enemy base for resources",
		"expedition_defend_base_name": "Defend Base",
		"expedition_defend_base_desc": "Repel incoming enemy attack",

		# Difficulty
		"difficulty_easy": "Easy",
		"difficulty_medium": "Medium",
		"difficulty_hard": "Hard",
		"difficulty_expert": "Expert",
	}

## Load Chinese translations (Simplified Chinese)
func _load_chinese_translations():
	translations[LANG_CHINESE] = {
		# UI - HUD
		"ui_materials": "材料: %d",
		"ui_fuel": "燃料: %d",
		"ui_base": "基地: %d/%d",
		"ui_combos": "连击: %d",
		"ui_expeditions": "远征: %d (按E键)",
		"ui_combat": "战斗力: %d",
		"ui_resources_header": "资源",
		"ui_gmp_format": "GMP: %d",
		"ui_staff_count_format": "人员: %d/%d",
		"ui_base_status_header": "基地状态",
		"ui_combos_header": "连击",
		"ui_combos_format": "连击: %d\n",
		"ui_combos_none": "连击: 0",
		"ui_objectives_header": "目标",
		"ui_objective_complete_prefix": "[完成] ",
		"ui_objective_incomplete_prefix": "[ ] ",
		"ui_all_objectives_complete": "所有目标已完成！",
		"ui_hide_sidebar": "隐藏 (H)",
		"ui_show_sidebar": "显示 (H)",

		# UI - Key Bindings
		"ui_keybinding_recruit": "R: 招募员工",
		"ui_keybinding_management": "TAB: 基地管理",
		"ui_keybinding_sidebar": "H: 侧边栏",
		"ui_keybinding_debug_info": "F: 调试信息 (开启时)",

		# UI - Base Management Panel
		"ui_base_management_title": "基地管理",
		"ui_close": "X",
		"ui_recruit_pool": "招募池 - 可用人员",
		"ui_recruit_pool_format": "招募池 - %d 可用人员",
		"ui_assign_to_rd": "分配到研发部",
		"ui_assign_to_combat": "分配到战斗部",
		"ui_assign_to_support": "分配到支援部",
		"ui_assign_to_intel": "分配到情报部",
		"ui_assign_to_medical": "分配到医疗部",
		"ui_department_assignments": "部门分配",
		"ui_dismiss_staff": "解雇人员 - 降低维护成本",
		"ui_dismiss_selected": "解雇选中人员",
		"ui_no_specialty": "无专长",
		"ui_staff_display_format": "%s | 技能: %d | %s",
		"ui_department_header_format": "%s 部门 - %d 人员",
		"ui_staff_dismissed": "人员已解雇: %s",

		# UI - Expeditions
		"ui_expedition_success_chance": "成功率: %d%%",
		"ui_expedition_resource_yield": "资源产量: %d%%",
		"ui_expedition_casualty_reduction": "伤亡减少: %d%%",
		"ui_expedition_duration_reduction": "持续时间: %d%%",

		# UI - Overview
		"ui_overview_stats": "总平台数: %d | 树深度: %d",

		# UI - Save/Load
		"ui_save_load": "保存 / 读取",
		"ui_story_mode": "故事模式",
		"ui_sandbox_mode": "沙盒模式",
		"ui_save_slot_format": "存档 %d: %s",
		"ui_save_slot_empty": "存档 %d: 空",
		"ui_save": "保存",
		"ui_load": "读取",
		"ui_delete": "删除",
		"ui_return_to_title": "返回主菜单",

		# UI - Result Screen
		"ui_result_victory": "胜利",
		"ui_result_game_over": "游戏结束",
		"ui_days_survived": "存活天数: %d",
		"ui_platforms_built": "建造平台: %d",
		"ui_staff_recruited_count": "招募人员: %d",
		"ui_expeditions_sent_count": "派遣远征: %d",
		"ui_victory_message": "恭喜！你完成了所有目标！",
		"ui_defeat_message": "你的基地已丢失。",
		"ui_defeat_reason": "原因: %s",

		# UI - Story Objectives
		"ui_chapter_loading": "第一章: 加载中...",
		"ui_chapter_format": "第%s章: %s",
		"ui_missions_complete": "✓ 所有任务已完成 ✓",
		"ui_continue_sandbox": "继续在沙盒模式下建设你的基地",
		"ui_chapter_end": "完结",

		# UI - Dialogue
		"ui_choice_default": "选择",
		"ui_speaker_unknown": "未知",

		# UI - Build Menu
		"ui_select_platform_type": "选择平台类型",
		"ui_build_button_rd": "研发 (%d 材料, %d 燃料)",
		"ui_build_button_support": "支援 (%d 材料, %d 燃料)",
		"ui_build_button_combat": "战斗 (%d 材料, %d 燃料)",
		"ui_build_button_intel": "情报 (%d 材料, %d 燃料)",
		"ui_build_button_medical": "医疗 (%d 材料, %d 燃料)",

		# UI - Build Menu
		"ui_build_parent_full": "%s (父平台已满)",
		"ui_build_cost_format": "%s - %d 材料, %d 燃料",

		# UI - Expedition Menu
		"ui_expedition_title": "远征",
		"ui_expedition_combat_power": "战斗力: %d",
		"ui_expedition_in_progress": "%s\n进行中 (%ds)\n难度: %s",
		"ui_expedition_available": "%s\n%s\n战力: %d/%d | 持续时间: %ds | 难度: %s\n奖励: %d 材料, %d 燃料",
		"ui_expedition_locked": "%s\n锁定 - 需要 %d 战力 (当前 %d)",
		"ui_expedition_close": "X",

		# Messages - Platform Building
		"msg_build_success_title": "建造成功",
		"msg_build_success_details": "  类型: %s 平台\n  父平台: %s\n  成本: %d 材料, %d 燃料\n  父平台子节点: %d/%d\n  基地规模: %d/%d",
		"msg_build_failed_base_full": "基地已达到最大平台数量 (%d)",
		"msg_build_failed_parent_full": "父平台已满 (6/6 子平台)",
		"msg_build_failed_materials": "资源不足: 需要 %d 材料 (现有 %d)",
		"msg_build_failed_fuel": "资源不足: 需要 %d 燃料 (现有 %d)",

		# Messages - Platform Production
		"msg_production_rates": "%s: 生产速率已设置 - 材料: %d, 燃料: %d, 标签: %s",
		"msg_platform_upgraded": "%s 已升级至等级 %d",

		# Messages - Platform Slots
		"msg_slots_created": "%s: 已创建 %d 个建造槽",
		"msg_child_added": "%s: 已添加子平台 %s (总计子节点: %d/%d)",

		# Messages - System
		"msg_hq_spawned": "总部平台已在中心生成",
		"msg_combo_detected": "检测到连击: %s (%s)",
		"msg_combo_removed": "连击已移除: %s",
		"msg_expedition_started": "远征开始: %s",
		"msg_expedition_completed": "远征完成: %s - 奖励: %d 材料, %d 燃料",
		"msg_expedition_failed": "远征失败: %s - 战斗力不足",

		# Expedition Missions
		"expedition_gather_resources_name": "资源收集",
		"expedition_gather_resources_desc": "派遣团队收集材料",
		"expedition_scout_territory_name": "领土侦察",
		"expedition_scout_territory_desc": "探索周边区域",
		"expedition_raid_enemy_outpost_name": "袭击敌方哨站",
		"expedition_raid_enemy_outpost_desc": "攻击敌方基地获取资源",
		"expedition_defend_base_name": "基地防御",
		"expedition_defend_base_desc": "击退来袭的敌方攻击",

		# Difficulty
		"difficulty_easy": "简单",
		"difficulty_medium": "普通",
		"difficulty_hard": "困难",
		"difficulty_expert": "专家",
	}

## Platform type name helper
static func platform_type_name(type: String) -> String:
	# Check current language and return appropriate translation
	var text_data = TextData
	if text_data.current_language == LANG_CHINESE:
		match type:
			"HQ": return "总部"
			"R&D": return "研发"
			"Support": return "支援"
			"Combat": return "战斗"
			"Intel": return "情报"
			"Medical": return "医疗"
			_: return type
	else:
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
	# Check current language and return appropriate translation
	var text_data = TextData
	if text_data.current_language == LANG_CHINESE:
		match difficulty:
			"easy": return "简单"
			"medium": return "普通"
			"hard": return "困难"
			"expert": return "专家"
			_: return difficulty.capitalize()
	else:
		match difficulty:
			"easy": return "Easy"
			"medium": return "Medium"
			"hard": return "Hard"
			"expert": return "Expert"
			_: return difficulty.capitalize()

## Expedition mission name helper (maps mission_id to display name)
static func expedition_name(mission_id: String) -> String:
	# Check current language and return appropriate translation
	var text_data = TextData
	if text_data.current_language == LANG_CHINESE:
		match mission_id:
			"supply_raid": return "补给突袭"
			"resource_scavenge": return "资源收集"
			"intel_gathering": return "情报收集"
			"heavy_assault": return "重兵突击"
			_: return mission_id.capitalize().replace("_", " ")
	else:
		match mission_id:
			"supply_raid": return "Supply Raid"
			"resource_scavenge": return "Resource Scavenge"
			"intel_gathering": return "Intel Gathering"
			"heavy_assault": return "Heavy Assault"
			_: return mission_id.capitalize().replace("_", " ")
