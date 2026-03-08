extends Control
class_name BuildMenu

## Build menu for selecting platform type

signal platform_selected(platform_type: String, slot: BuildSlot)

var current_slot: BuildSlot = null
var base_system: Base = null

@onready var rd_button = $Panel/VBoxContainer/RD
@onready var support_button = $Panel/VBoxContainer/Support
@onready var combat_button = $Panel/VBoxContainer/Combat
@onready var intel_button = $Panel/VBoxContainer/Intel
@onready var medical_button = $Panel/VBoxContainer/Medical

func _ready():
	# Connect all buttons
	rd_button.pressed.connect(_on_rd_selected)
	support_button.pressed.connect(_on_support_selected)
	combat_button.pressed.connect(_on_combat_selected)
	intel_button.pressed.connect(_on_intel_selected)
	medical_button.pressed.connect(_on_medical_selected)

	# Hide menu initially
	hide()

func show_menu(slot: BuildSlot):
	current_slot = slot
	visible = true

	# Position menu near center of screen
	position = get_viewport_rect().size / 2 - size / 2

	# Update button states based on department AND parent capacity
	_update_button_states()

func _update_button_states():
	if not base_system or not base_system.department_system:
		return

	var dept_system = base_system.department_system

	# Find the parent platform that owns this slot
	var parent_platform = base_system.find_platform_with_slot(current_slot)
	var parent_full = false
	if parent_platform:
		parent_full = not parent_platform.can_accept_child()

	# Update R&D button
	var rd_full = dept_system.is_department_full("R&D") or parent_full
	rd_button.disabled = rd_full
	if rd_full:
		if parent_full:
			rd_button.text = "R&D (Parent Full)"
		else:
			rd_button.text = "R&D (Dept Full - 6/6)"
	else:
		var rd_count = dept_system.get_department_count("R&D")
		rd_button.text = "R&D (%d/6) - 50 Mat, 10 Fuel" % rd_count

	# Update Support button
	var support_full = dept_system.is_department_full("Support") or parent_full
	support_button.disabled = support_full
	if support_full:
		if parent_full:
			support_button.text = "Support (Parent Full)"
		else:
			support_button.text = "Support (Dept Full - 6/6)"
	else:
		var support_count = dept_system.get_department_count("Support")
		support_button.text = "Support (%d/6) - 30 Mat, 40 Fuel" % support_count

	# Update Combat button
	var combat_full = dept_system.is_department_full("Combat") or parent_full
	combat_button.disabled = combat_full
	if combat_full:
		if parent_full:
			combat_button.text = "Combat (Parent Full)"
		else:
			combat_button.text = "Combat (Dept Full - 6/6)"
	else:
		var combat_count = dept_system.get_department_count("Combat")
		combat_button.text = "Combat (%d/6) - 40 Mat, 30 Fuel" % combat_count

	# Update Intel button
	var intel_full = dept_system.is_department_full("Intel") or parent_full
	intel_button.disabled = intel_full
	if intel_full:
		if parent_full:
			intel_button.text = "Intel (Parent Full)"
		else:
			intel_button.text = "Intel (Dept Full - 6/6)"
	else:
		var intel_count = dept_system.get_department_count("Intel")
		intel_button.text = "Intel (%d/6) - 35 Mat, 25 Fuel" % intel_count

	# Update Medical button
	var medical_full = dept_system.is_department_full("Medical") or parent_full
	medical_button.disabled = medical_full
	if medical_full:
		if parent_full:
			medical_button.text = "Medical (Parent Full)"
		else:
			medical_button.text = "Medical (Dept Full - 6/6)"
	else:
		var medical_count = dept_system.get_department_count("Medical")
		medical_button.text = "Medical (%d/6) - 25 Mat, 25 Fuel" % medical_count

func hide_menu():
	visible = false
	current_slot = null

func _on_rd_selected():
	platform_selected.emit("R&D", current_slot)
	hide_menu()

func _on_support_selected():
	platform_selected.emit("Support", current_slot)
	hide_menu()

func _on_combat_selected():
	platform_selected.emit("Combat", current_slot)
	hide_menu()

func _on_intel_selected():
	platform_selected.emit("Intel", current_slot)
	hide_menu()

func _on_medical_selected():
	platform_selected.emit("Medical", current_slot)
	hide_menu()
