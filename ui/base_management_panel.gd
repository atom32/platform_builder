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
			pass

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
		recruit_info.text = "Recruit Pool - %d Available Staff" % pool.size()

	for staff in pool:
		var display_text = "%s | Skill: %d | %s" % [
			staff.get_display_name(),
			staff.skill_level,
			staff.specialty if staff.specialty != "" else "No Specialty"
		]
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

		dept_list.add_item("%s Department - %d Staff" % [dept, count])
		for staff in dept_staff:
			var display_text = "  %s | Skill: %d | %s" % [
				staff.get_display_name(),
				staff.skill_level,
				staff.specialty if staff.specialty != "" else "No Specialty"
			]
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

## Handle input for keyboard shortcuts
func _input(event):
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		hide_panel()

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
	combat_power_label.text = "Combat Power: %d" % combat_power

## Update department bonuses display
func _update_department_bonuses():
	if not expedition_system:
		return

	var bonuses = expedition_system.get_department_bonuses()

	if success_chance_label:
		var chance_percent = int(bonuses["success_chance"] * 100)
		success_chance_label.text = "Success Chance: %d%%" % chance_percent

	if resource_bonus_label:
		var resource_percent = int(bonuses["resource_multiplier"] * 100)
		resource_bonus_label.text = "Resource Yield: %d%%" % resource_percent

	if casualty_reduction_label:
		var casualty_percent = int(bonuses["casualty_reduction"] * 100)
		casualty_reduction_label.text = "Casualty Reduction: %d%%" % casualty_percent

	if duration_reduction_label:
		var duration_percent = int((1.0 - bonuses["duration_reduction"]) * 100)
		duration_reduction_label.text = "Duration: %d%%" % duration_percent

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
			notification_system.show("Staff dismissed: %s" % staff_member.get_display_name())
		refresh_lists()
	else:
		ResourceSystem.debug_print("[BaseManagementPanel] Failed to dismiss staff")
