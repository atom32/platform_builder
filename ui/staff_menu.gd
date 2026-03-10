extends CanvasLayer

## Staff Management Menu
## Allows players to view and assign staff to departments

@onready var recruit_list = $Panel/VBoxContainer/TabContainer/Recruits/RecruitList
@onready var dept_list = $Panel/VBoxContainer/TabContainer/Departments/DeptList
@onready var dismiss_list = $Panel/VBoxContainer/TabContainer/Dismiss/DismissList
@onready var recruit_info = $Panel/VBoxContainer/TabContainer/Recruits/RecruitInfo

var selected_recruit_index = -1
var selected_dismiss_index = -1

func _ready():
	visible = false
	_connect_signals()
	refresh_lists()

## Connect button signals manually
func _connect_signals():
	# Close button
	$Panel/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

	# Assign buttons
	$Panel/VBoxContainer/TabContainer/Recruits/RecruitButtons/AssignToRD.pressed.connect(_on_assign_to_rd)
	$Panel/VBoxContainer/TabContainer/Recruits/RecruitButtons/AssignToCombat.pressed.connect(_on_assign_to_combat)
	$Panel/VBoxContainer/TabContainer/Recruits/RecruitButtons/AssignToSupport.pressed.connect(_on_assign_to_support)
	$Panel/VBoxContainer/TabContainer/Recruits/RecruitButtons/AssignToIntel.pressed.connect(_on_assign_to_intel)
	$Panel/VBoxContainer/TabContainer/Recruits/RecruitButtons/AssignToMedical.pressed.connect(_on_assign_to_medical)

	# Dismiss button
	$Panel/VBoxContainer/TabContainer/Dismiss/DismissButtons/DismissSelected.pressed.connect(_on_dismiss_selected)

## Show the staff menu
func show_menu():
	visible = true
	refresh_lists()

## Close the staff menu
func close_menu():
	visible = false

## Refresh all lists with current data
func refresh_lists():
	_refresh_recruit_list()
	_refresh_department_list()
	_refresh_dismiss_list()

## Refresh the recruit pool list
func _refresh_recruit_list():
	recruit_list.clear()
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		return

	var pool = dept_system.get_recruit_pool()
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

## Close button pressed
func _on_close_pressed():
	close_menu()

## Assign selected recruit to R&D
func _on_assign_to_rd():
	_assign_selected_to_department("R&D")

## Assign selected recruit to Combat
func _on_assign_to_combat():
	_assign_selected_to_department("Combat")

## Assign selected recruit to Support
func _on_assign_to_support():
	_assign_selected_to_department("Support")

## Assign selected recruit to Intel
func _on_assign_to_intel():
	_assign_selected_to_department("Intel")

## Assign selected recruit to Medical
func _on_assign_to_medical():
	_assign_selected_to_department("Medical")

## Assign the selected recruit to a department
func _assign_selected_to_department(dept_name: String):
	var selected_items = recruit_list.get_selected_items()
	if selected_items.is_empty():
		print("[StaffMenu] No staff selected for assignment to %s" % dept_name)
		return

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		print("[StaffMenu] DepartmentSystem not found")
		return

	var pool = dept_system.get_recruit_pool()
	var index = selected_items[0]

	if index >= pool.size():
		print("[StaffMenu] Invalid index: %d, pool size: %d" % [index, pool.size()])
		return

	var staff_member = pool[index]
	if dept_system.assign_staff_member(staff_member, dept_name):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_assigned(dept_name)
		refresh_lists()
	else:
		print("[StaffMenu] Failed to assign staff to %s" % dept_name)

## Dismiss the selected staff member
func _on_dismiss_selected():
	var selected_items = dismiss_list.get_selected_items()
	if selected_items.is_empty():
		print("[StaffMenu] No staff selected for dismissal")
		return

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		print("[StaffMenu] DepartmentSystem not found")
		return

	var all_staff = dept_system.get_all_staff()
	var index = selected_items[0]

	if index >= all_staff.size():
		print("[StaffMenu] Invalid index: %d, staff count: %d" % [index, all_staff.size()])
		return

	var staff_member = all_staff[index]
	if dept_system.dismiss_staff(staff_member):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show("Staff dismissed: %s" % staff_member.get_display_name())
		refresh_lists()
	else:
		print("[StaffMenu] Failed to dismiss staff")

## Handle input for closing with U key
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_U:
			if visible:
				close_menu()
			else:
				show_menu()
