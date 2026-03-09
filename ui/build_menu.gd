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
	# Button signals are already connected in build_menu.tscn

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

	# Get build costs from data (data-driven)
	var rd_cost = PlatformData.get_build_cost("R&D")
	var support_cost = PlatformData.get_build_cost("Support")
	var combat_cost = PlatformData.get_build_cost("Combat")
	var intel_cost = PlatformData.get_build_cost("Intel")
	var medical_cost = PlatformData.get_build_cost("Medical")

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
		rd_button.text = "R&D - %d Mat, %d Fuel" % [rd_cost["materials"], rd_cost["fuel"]]
		support_button.text = "Support - %d Mat, %d Fuel" % [support_cost["materials"], support_cost["fuel"]]
		combat_button.text = "Combat - %d Mat, %d Fuel" % [combat_cost["materials"], combat_cost["fuel"]]
		intel_button.text = "Intel - %d Mat, %d Fuel" % [intel_cost["materials"], intel_cost["fuel"]]
		medical_button.text = "Medical - %d Mat, %d Fuel" % [medical_cost["materials"], medical_cost["fuel"]]

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
