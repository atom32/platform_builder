extends CanvasLayer
class_name BaseManagementPanel

## Base Management Panel
## Unified panel for Staff and Expedition management

signal expedition_launched(mission_id: String)

## UI References
@onready var title_label = $Panel/VBoxContainer/Header/TitleLabel
@onready var close_button = $Panel/VBoxContainer/Header/CloseButton
@onready var tab_container = $Panel/VBoxContainer/TabContainer

## Staff Tab References
@onready var recruit_list = $Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitList
@onready var dept_list = $Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Departments/DeptList
@onready var dismiss_list = $Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Dismiss/DismissList
@onready var recruit_info = $Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitInfo

## Expeditions Tab References
@onready var combat_power_label = $Panel/VBoxContainer/TabContainer/Expeditions/CombatPowerLabel
@onready var success_chance_label = $Panel/VBoxContainer/TabContainer/Expeditions/DepartmentBonuses/SuccessChanceLabel
@onready var resource_bonus_label = $Panel/VBoxContainer/TabContainer/Expeditions/DepartmentBonuses/ResourceBonusLabel
@onready var casualty_reduction_label = $Panel/VBoxContainer/TabContainer/Expeditions/DepartmentBonuses/CasualtyReductionLabel
@onready var duration_reduction_label = $Panel/VBoxContainer/TabContainer/Expeditions/DepartmentBonuses/DurationReductionLabel
@onready var mission_list = $Panel/VBoxContainer/TabContainer/Expeditions/ScrollContainer/MissionList

## Overview Tab References
@onready var overview_tree = $Panel/VBoxContainer/TabContainer/Overview/Tree
@onready var overview_stats = $Panel/VBoxContainer/TabContainer/Overview/StatsLabel

## Save/Load Tab References
@onready var save_load_slots = $Panel/VBoxContainer/TabContainer/SaveLoad/SaveSlots
@onready var save_mode_label = $Panel/VBoxContainer/TabContainer/SaveLoad/Header/ModeLabel
@onready var return_to_title_button = $Panel/VBoxContainer/TabContainer/SaveLoad/ActionButtons/ReturnToTitleButton

## Self-reference for backward compatibility with base.gd
var expedition_menu: BaseManagementPanel

## Current selected tab (for persistence)
var _current_tab_index: int = 0

## Staff selection tracking
var selected_recruit_index = -1
var selected_dismiss_index = -1

## Expedition system reference
var expedition_system: ExpeditionManager = null
var mission_buttons: Dictionary = {}

## Overview system references
var base_system: Base = null
var platform_tree_items: Dictionary = {}
var _last_click_time: float = 0.0
var _last_clicked_item: TreeItem = null
const DOUBLE_CLICK_TIME: float = 0.5

## Save/Load system references
var save_slots: Array[Dictionary] = []
var current_mode: int = 0

func _ready():
	# Set up self-reference for backward compatibility
	expedition_menu = self

	# Hide initially
	visible = false

	# Get expedition system reference
	expedition_system = get_node_or_null("/root/ExpeditionSystem")

	# Connect signals
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	# Connect tab changed signal for persistence
	if tab_container:
		tab_container.tab_changed.connect(_on_tab_changed)

	# Connect staff button signals
	_connect_staff_buttons()

	# Create mission buttons
	_create_mission_buttons()

	# Setup save slots
	_setup_save_slots()

	# Connect return to title button
	if return_to_title_button:
		return_to_title_button.pressed.connect(_on_return_to_title_pressed)

	# Setup localized UI text
	_setup_localized_ui_text()

## Setup localized UI text
func _setup_localized_ui_text():
	# Title and close button
	if title_label:
		title_label.text = TextData.get_raw("ui_base_management_title")
	if close_button:
		close_button.text = TextData.get_raw("ui_close")

	# Recruit tab initial text (will be updated dynamically)
	if recruit_info:
		recruit_info.text = TextData.get_raw("ui_recruit_pool")

	# Assignment buttons
	_set_button_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToRD", "ui_assign_to_rd")
	_set_button_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToCombat", "ui_assign_to_combat")
	_set_button_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToSupport", "ui_assign_to_support")
	_set_button_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToIntel", "ui_assign_to_intel")
	_set_button_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToMedical", "ui_assign_to_medical")

	# Department tab
	_set_label_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Departments/DeptLabel", "ui_department_assignments")

	# Dismiss tab
	_set_label_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Dismiss/DismissInfo", "ui_dismiss_staff")
	_set_button_text("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Dismiss/DismissButtons/DismissSelected", "ui_dismiss_selected")

	# Save/Load tab
	_set_label_text("Panel/VBoxContainer/TabContainer/SaveLoad/Header/TitleLabel", "ui_save_load")
	_set_button_text("Panel/VBoxContainer/TabContainer/SaveLoad/ActionButtons/ReturnToTitleButton", "ui_return_to_title")

	# Save slot buttons
	_setup_save_slot_buttons()

## Helper to set button text from TextData key
func _set_button_text(node_path: String, text_key: String):
	if has_node(node_path):
		get_node(node_path).text = TextData.get_raw(text_key)

## Helper to set label text from TextData key
func _set_label_text(node_path: String, text_key: String):
	if has_node(node_path):
		get_node(node_path).text = TextData.get_raw(text_key)

## Setup save slot button texts
func _setup_save_slot_buttons():
	if not save_load_slots:
		return

	for i in range(3):
		var slot_panel = save_load_slots.get_child(i)
		if not slot_panel:
			continue

		var save_button = slot_panel.get_node("HBoxContainer/Buttons/SaveButton")
		var load_button = slot_panel.get_node("HBoxContainer/Buttons/LoadButton")
		var delete_button = slot_panel.get_node("HBoxContainer/Buttons/DeleteButton")

		if save_button:
			save_button.text = TextData.get_raw("ui_save")
		if load_button:
			load_button.text = TextData.get_raw("ui_load")
		if delete_button:
			delete_button.text = TextData.get_raw("ui_delete")

## Show the panel
func show_panel():
	visible = true
	# Restore previous tab selection
	if tab_container:
		tab_container.current_tab = _current_tab_index
		# Refresh based on active tab
		_refresh_current_tab()

## Hide the panel
func hide_panel():
	visible = false

## Toggle panel visibility
func toggle_panel():
	if visible:
		hide_panel()
	else:
		show_panel()

## Refresh the current active tab
func _refresh_current_tab():
	if not tab_container:
		return

	var current_tab = tab_container.current_tab
	match current_tab:
		0:  # Staff tab
			refresh_lists()
		1:  # Expeditions tab
			_refresh_expedition_tab()
		2:  # Overview tab
			_refresh_overview()
		3:  # Save/Load tab
			_refresh_save_slots()

## Handle close button pressed
func _on_close_pressed():
	hide_panel()

## Handle tab changed
func _on_tab_changed(index: int):
	_current_tab_index = index
	_refresh_current_tab()

## Connect staff button signals manually
func _connect_staff_buttons():
	# Assign buttons
	if has_node("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToRD"):
		$Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToRD.pressed.connect(_on_assign_to_rd)
	if has_node("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToCombat"):
		$Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToCombat.pressed.connect(_on_assign_to_combat)
	if has_node("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToSupport"):
		$Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToSupport.pressed.connect(_on_assign_to_support)
	if has_node("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToIntel"):
		$Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToIntel.pressed.connect(_on_assign_to_intel)
	if has_node("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToMedical"):
		$Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Recruits/RecruitButtons/AssignToMedical.pressed.connect(_on_assign_to_medical)

	# Dismiss button
	if has_node("Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Dismiss/DismissButtons/DismissSelected"):
		$Panel/VBoxContainer/TabContainer/Staff/StaffTabContainer/Dismiss/DismissButtons/DismissSelected.pressed.connect(_on_dismiss_selected)

## Refresh all lists with current data
func refresh_lists():
	_refresh_recruit_list()
	_refresh_department_list()
	_refresh_dismiss_list()

## Refresh the recruit pool list
func _refresh_recruit_list():
	if not recruit_list:
		return

	recruit_list.clear()
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		return

	var pool = dept_system.get_recruit_pool()
	if recruit_info:
		recruit_info.text = TextData.format("ui_recruit_pool_format", [pool.size()])

	for staff in pool:
		var display_text = TextData.format("ui_staff_display_format", [
			staff.get_display_name(),
			staff.skill_level,
			staff.specialty if staff.specialty != "" else TextData.get_raw("ui_no_specialty")
		])
		recruit_list.add_item(display_text)

## Refresh the department assignments list
func _refresh_department_list():
	if not dept_list:
		return

	dept_list.clear()
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		return

	var departments = ["R&D", "Combat", "Support", "Intel", "Medical"]
	for dept in departments:
		var count = dept_system.get_department_staff(dept)
		var dept_staff = dept_system.get_staff_in_department(dept)

		dept_list.add_item(TextData.format("ui_department_header_format", [dept, count]))
		for staff in dept_staff:
			var display_text = "  " + TextData.format("ui_staff_display_format", [
				staff.get_display_name(),
				staff.skill_level,
				staff.specialty if staff.specialty != "" else TextData.get_raw("ui_no_specialty")
			])
			dept_list.add_item(display_text)

## Refresh the dismiss list (all staff)
func _refresh_dismiss_list():
	if not dismiss_list:
		return

	dismiss_list.clear()
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		return

	var all_staff = dept_system.get_all_staff()
	for staff in all_staff:
		var dept_display = staff.get_department_display()
		var display_text = "%s | %s | Skill: %d" % [
			staff.get_display_name(),
			dept_display,
			staff.skill_level
		]
		dismiss_list.add_item(display_text)

## Handle input for keyboard shortcuts and mouse interactions
func _input(event):
	if not visible:
		return

	# ESC closes panel
	if event.is_action_pressed("ui_cancel"):
		hide_panel()
		return

	# Handle mouse clicks on Overview Tree
	if tab_container and tab_container.current_tab == 2:  # Overview tab
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if overview_tree:
					# Convert screen position to Tree's local coordinate system
					var local_pos = overview_tree.get_local_mouse_position()

					# Get item at local position
					var clicked_item = overview_tree.get_item_at_position(local_pos)
					if clicked_item:
						_check_overview_double_click(clicked_item)

## Public method for expedition menu compatibility
## Called by base.gd through expedition_menu reference
func show_menu():
	show_panel()

## Public method for expedition menu compatibility
func hide_menu():
	hide_panel()

## Public method for expedition menu compatibility
## Called by ExpeditionSystem when missions update
func refresh_menu():
	_refresh_current_tab()

## Refresh expedition tab
func _refresh_expedition_tab():
	_update_mission_list()
	_update_combat_power()
	_update_department_bonuses()

## Create mission buttons
func _create_mission_buttons():
	if not mission_list or not expedition_system:
		return

	# Clear existing buttons
	for button in mission_list.get_children():
		button.queue_free()
	mission_buttons.clear()

	# Create button for each mission
	for mission_id in expedition_system.mission_data:
		var mission = expedition_system.mission_data[mission_id]

		var button = Button.new()
		button.custom_minimum_size = Vector2(0, 80)
		button.text = "%s\n%s" % [mission["display_name"], mission["description"]]

		# Store mission_id in button's metadata
		button.set_meta("mission_id", mission_id)
		button.pressed.connect(_on_mission_button_clicked.bind(button))

		mission_list.add_child(button)
		mission_buttons[mission_id] = button

## Update mission list with current status
func _update_mission_list():
	if not expedition_system:
		return

	var available_missions = expedition_system.get_available_missions()
	var current_combat_power = expedition_system.get_combat_power()

	for mission_id in mission_buttons:
		var button = mission_buttons[mission_id]
		if not button or not is_instance_valid(button):
			continue

		var mission = expedition_system.mission_data[mission_id]

		if available_missions.has(mission_id):
			# Mission is available
			button.disabled = false

			# Check if already active
			if expedition_system.active_expeditions.has(mission_id):
				var time_remaining = expedition_system.get_expedition_time_remaining(mission_id)
				button.text = "%s\nIn Progress: %ds remaining\nDifficulty: %s" % [
					mission["display_name"],
					time_remaining,
					mission["difficulty"]
				]
				button.disabled = true
			else:
				button.text = "%s\n%s\nCombat Power: %d/%d | Duration: %ds\nDifficulty: %s | Rewards: %d Materials, %d Fuel" % [
					mission["display_name"],
					mission["description"],
					current_combat_power,
					mission["required_combat_power"],
					mission["duration"],
					mission["difficulty"],
					mission["materials_reward"],
					mission["fuel_reward"]
				]
		else:
			# Mission not available (insufficient combat power)
			button.disabled = true
			button.text = "%s\nLOCKED - Requires %d Combat Power (Current: %d)" % [
				mission["display_name"],
				mission["required_combat_power"],
				current_combat_power
			]

## Mission button clicked handler
func _on_mission_button_clicked(button: Button):
	if not expedition_system:
		return

	var mission_id = button.get_meta("mission_id")

	# Launch expedition
	if expedition_system.launch_expedition(mission_id):
		expedition_launched.emit(mission_id)
		_update_mission_list()

## Update combat power display
func _update_combat_power():
	if not combat_power_label or not expedition_system:
		return

	var combat_power = expedition_system.get_combat_power()
	combat_power_label.text = TextData.format("ui_expedition_combat_power", [combat_power])

## Update department bonuses display
func _update_department_bonuses():
	if not expedition_system:
		return

	var bonuses = expedition_system.get_department_bonuses()

	if success_chance_label:
		var chance_percent = int(bonuses["success_chance"] * 100)
		success_chance_label.text = TextData.format("ui_expedition_success_chance", [chance_percent])

	if resource_bonus_label:
		var resource_percent = int(bonuses["resource_multiplier"] * 100)
		resource_bonus_label.text = TextData.format("ui_expedition_resource_yield", [resource_percent])

	if casualty_reduction_label:
		var casualty_percent = int(bonuses["casualty_reduction"] * 100)
		casualty_reduction_label.text = TextData.format("ui_expedition_casualty_reduction", [casualty_percent])

	if duration_reduction_label:
		var duration_percent = int((1.0 - bonuses["duration_reduction"]) * 100)
		duration_reduction_label.text = TextData.format("ui_expedition_duration_reduction", [duration_percent])

## Staff assignment handlers
func _on_assign_to_rd():
	_assign_selected_to_department("R&D")

func _on_assign_to_combat():
	_assign_selected_to_department("Combat")

func _on_assign_to_support():
	_assign_selected_to_department("Support")

func _on_assign_to_intel():
	_assign_selected_to_department("Intel")

func _on_assign_to_medical():
	_assign_selected_to_department("Medical")

## Assign the selected recruit to a department
func _assign_selected_to_department(dept_name: String):
	if not recruit_list:
		ResourceSystem.debug_print("[BaseManagementPanel] RecruitList not found")
		return

	var selected_items = recruit_list.get_selected_items()
	if selected_items.is_empty():
		ResourceSystem.debug_print("[BaseManagementPanel] No staff selected for assignment to %s" % dept_name)
		return

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		ResourceSystem.debug_print("[BaseManagementPanel] DepartmentSystem not found")
		return

	var pool = dept_system.get_recruit_pool()
	var index = selected_items[0]

	if index >= pool.size():
		ResourceSystem.debug_print("[BaseManagementPanel] Invalid index: %d, pool size: %d" % [index, pool.size()])
		return

	var staff_member = pool[index]
	if dept_system.assign_staff_member(staff_member, dept_name):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_assigned(dept_name)
		refresh_lists()
	else:
		ResourceSystem.debug_print("[BaseManagementPanel] Failed to assign staff to %s" % dept_name)

## Staff dismissal handler
func _on_dismiss_selected():
	if not dismiss_list:
		ResourceSystem.debug_print("[BaseManagementPanel] DismissList not found")
		return

	var selected_items = dismiss_list.get_selected_items()
	if selected_items.is_empty():
		ResourceSystem.debug_print("[BaseManagementPanel] No staff selected for dismissal")
		return

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		ResourceSystem.debug_print("[BaseManagementPanel] DepartmentSystem not found")
		return

	var all_staff = dept_system.get_all_staff()
	var index = selected_items[0]

	if index >= all_staff.size():
		ResourceSystem.debug_print("[BaseManagementPanel] Invalid index: %d, staff count: %d" % [index, all_staff.size()])
		return

	var staff_member = all_staff[index]
	if dept_system.dismiss_staff(staff_member):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show(TextData.format("ui_staff_dismissed", [staff_member.get_display_name()]))
		refresh_lists()
	else:
		ResourceSystem.debug_print("[BaseManagementPanel] Failed to dismiss staff")

## ===== OVERVIEW TAB METHODS =====

## Refresh overview tab
func _refresh_overview():
	_build_overview_tree()

## Build overview tree
func _build_overview_tree():
	if not base_system:
		base_system = get_node_or_null("/root/Main/Base") as Base
		if not base_system:
			push_error("Base system not found!")
			return

	if not overview_tree:
		return

	# Clear existing tree
	overview_tree.clear()
	platform_tree_items.clear()

	# Get HQ as root
	var hq = base_system.get_hq()
	if not hq:
		push_error("HQ not found!")
		return

	# Build tree recursively
	var root_item = overview_tree.create_item()
	root_item.set_text(0, "HQ")
	root_item.set_text(1, "0")
	root_item.set_metadata(0, hq)
	platform_tree_items[hq] = root_item

	# Add children recursively
	_add_platform_children_recursive(hq, root_item)

	# Update stats
	_update_overview_stats(hq)

	# Expand all items
	_expand_all_tree_items(root_item)

## Add platform children recursively
func _add_platform_children_recursive(platform: Platform, parent_item: TreeItem):
	var child_count = 0
	for child in platform.get_child_platforms():
		child_count += 1
		var child_item = overview_tree.create_item(parent_item)
		child_item.set_text(0, child.platform_type)
		child_item.set_text(1, "0")
		child_item.set_metadata(0, child)
		platform_tree_items[child] = child_item

		# Recursively add children
		_add_platform_children_recursive(child, child_item)

	# Update parent's child count
	var current_count = parent_item.get_text(1).to_int()
	parent_item.set_text(1, str(current_count + child_count))

## Update overview stats
func _update_overview_stats(hq: Platform):
	if not overview_stats or not base_system:
		return

	var total_platforms = base_system.get_total_platform_count()
	var max_depth = _calculate_tree_depth(hq)
	overview_stats.text = TextData.format("ui_overview_stats", [total_platforms, max_depth])

## Calculate tree depth
func _calculate_tree_depth(platform: Platform) -> int:
	var child_platforms = platform.get_child_platforms()
	if child_platforms.is_empty():
		return 1

	var max_child_depth = 0
	for child in child_platforms:
		var child_depth = _calculate_tree_depth(child)
		max_child_depth = max(max_child_depth, child_depth)

	return max_child_depth + 1

## Expand all tree items
func _expand_all_tree_items(item: TreeItem):
	item.collapsed = false
	for child in item.get_children():
		_expand_all_tree_items(child)

## Check for double-click on overview tree
func _check_overview_double_click(clicked_item: TreeItem):
	var current_time = Time.get_ticks_msec() / 1000.0

	# Check if same item was clicked recently
	if clicked_item == _last_clicked_item and (current_time - _last_click_time) < DOUBLE_CLICK_TIME:
		# Double click detected
		var platform = clicked_item.get_metadata(0)
		if platform and platform is Platform:
			_navigate_to_platform(platform)
		_last_clicked_item = null  # Reset
	else:
		_last_clicked_item = clicked_item
		_last_click_time = current_time

## Navigate camera to platform
func _navigate_to_platform(platform: Platform):
	# Move camera to platform
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# Check if camera has target_position (CameraController)
	if camera.has_method("get") and camera.has_method("set"):
		# Use CameraController's target_position system
		var current_pos = camera.position
		var target_pos = platform.position

		# Maintain camera's height and viewing angle
		var new_target = Vector3(target_pos.x, current_pos.y, target_pos.z + 40)
		camera.set("target_position", new_target)
		ResourceSystem.debug_print("Navigated to platform: %s (set CameraController target)" % platform.platform_type)
	else:
		# Fallback: direct position setting
		var current_pos = camera.position
		var target_pos = platform.position

		# Maintain camera's height and viewing angle
		camera.position.x = target_pos.x
		camera.position.z = target_pos.z + 40
		ResourceSystem.debug_print("Navigated to platform: %s (direct position set)" % platform.platform_type)

## ===== SAVE/LOAD TAB METHODS =====

## Setup save slots
func _setup_save_slots():
	if not save_load_slots:
		return

	# Clear existing array
	save_slots.clear()

	for i in range(3):
		var slot_panel = save_load_slots.get_child(i)
		if not slot_panel:
			continue

		var slot_name = slot_panel.get_node("HBoxContainer/SlotInfo/SlotName")
		var slot_details = slot_panel.get_node("HBoxContainer/SlotInfo/SlotDetails")
		var save_button = slot_panel.get_node("HBoxContainer/Buttons/SaveButton")
		var load_button = slot_panel.get_node("HBoxContainer/Buttons/LoadButton")
		var delete_button = slot_panel.get_node("HBoxContainer/Buttons/DeleteButton")

		save_slots.append({
			"index": i,
			"panel": slot_panel,
			"name_label": slot_name,
			"details_label": slot_details,
			"save_button": save_button,
			"load_button": load_button,
			"delete_button": delete_button
		})

		# Connect button signals
		var slot_index = i
		if save_button:
			save_button.pressed.connect(_on_save_pressed.bind(slot_index))
		if load_button:
			load_button.pressed.connect(_on_load_pressed.bind(slot_index))
		if delete_button:
			delete_button.pressed.connect(_on_delete_pressed.bind(slot_index))

## Refresh save slots
func _refresh_save_slots():
	# Get current game mode
	var game_mode_manager = get_node_or_null("/root/GameModeManager")
	if game_mode_manager:
		current_mode = game_mode_manager.current_mode

	# Update mode label
	if save_mode_label:
		save_mode_label.text = TextData.get_raw("ui_story_mode" if current_mode == 1 else "ui_sandbox_mode")

	# Refresh save slot display
	for slot in save_slots:
		var slot_index = slot["index"]
		var save_system = get_node_or_null("/root/SaveSystem")

		if save_system and save_system.has_save(slot_index, current_mode):
			# Slot has data
			var info = save_system.get_save_info(slot_index, current_mode)
			var chapter_name = info.get("chapter_name", "")
			var save_time = info.get("save_time", "")

			if slot["name_label"]:
				slot["name_label"].text = TextData.format("ui_save_slot_format", [slot_index + 1, chapter_name])
			if slot["details_label"]:
				slot["details_label"].text = save_time
			if slot["load_button"]:
				slot["load_button"].disabled = false
			if slot["delete_button"]:
				slot["delete_button"].disabled = false
		else:
			# Slot is empty
			if slot["name_label"]:
				slot["name_label"].text = TextData.format("ui_save_slot_empty", [slot_index + 1])
			if slot["details_label"]:
				slot["details_label"].text = ""
			if slot["load_button"]:
				slot["load_button"].disabled = true
			if slot["delete_button"]:
				slot["delete_button"].disabled = true

## Handle save button pressed
func _on_save_pressed(slot_index: int):
	print("[BaseManagementPanel] Save to slot %d" % slot_index)

	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		if save_system.save_game(slot_index, current_mode):
			print("[BaseManagementPanel] Game saved successfully")
			_refresh_save_slots()
		else:
			push_error("[BaseManagementPanel] Failed to save game")

## Handle load button pressed
func _on_load_pressed(slot_index: int):
	print("[BaseManagementPanel] Load from slot %d" % slot_index)

	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		if save_system.load_game(slot_index, current_mode):
			print("[BaseManagementPanel] Game loaded successfully")

			# Reload scene to apply changes
			get_tree().reload_current_scene()
		else:
			push_error("[BaseManagementPanel] Failed to load game")

## Handle delete button pressed
func _on_delete_pressed(slot_index: int):
	print("[BaseManagementPanel] Delete slot %d" % slot_index)

	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		if save_system.delete_save(slot_index, current_mode):
			print("[BaseManagementPanel] Save deleted successfully")
			_refresh_save_slots()
		else:
			push_error("[BaseManagementPanel] Failed to delete save")

## Handle return to title button pressed
func _on_return_to_title_pressed():
	print("[BaseManagementPanel] Returning to title menu")

	# Unpause game
	get_tree().paused = false

	# Switch to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
