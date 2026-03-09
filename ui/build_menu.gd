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

	# Update button states based on parent capacity only
	_update_button_states()

func _update_button_states():
	if not base_system:
		return

	# Find the parent platform that owns this slot
	var parent_platform = base_system.find_platform_with_slot(current_slot)
	var parent_full = false
	if parent_platform:
		parent_full = not parent_platform.can_accept_child()

	# Update all buttons based on parent capacity
	# Buttons are only disabled if parent is full (6/6 children)
	rd_button.disabled = parent_full
	support_button.disabled = parent_full
	combat_button.disabled = parent_full
	intel_button.disabled = parent_full
	medical_button.disabled = parent_full

	# Update button text to show status
	if parent_full:
		rd_button.text = "R&D (Parent Full)"
		support_button.text = "Support (Parent Full)"
		combat_button.text = "Combat (Parent Full)"
		intel_button.text = "Intel (Parent Full)"
		medical_button.text = "Medical (Parent Full)"
	else:
		rd_button.text = "R&D - 50 Mat, 10 Fuel"
		support_button.text = "Support - 30 Mat, 40 Fuel"
		combat_button.text = "Combat - 40 Mat, 30 Fuel"
		intel_button.text = "Intel - 35 Mat, 25 Fuel"
		medical_button.text = "Medical - 25 Mat, 25 Fuel"

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
