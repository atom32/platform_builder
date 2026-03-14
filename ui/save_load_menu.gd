extends Control
class_name SaveLoadMenu

## Save/Load Menu
## Allows players to save, load, and delete game saves

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var mode_label = $Panel/VBoxContainer/ModeLabel
@onready var close_button = $Panel/VBoxContainer/CloseButton

## Save slot references
var slots: Array[Dictionary] = []

## Current game mode
var current_mode: int = 0  # 0 = FREE_SANDBOX, 1 = STORY_MODE

func _ready():
	hide()

	# Setup save slots
	_setup_slots()

	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

## Setup save slots
func _setup_slots():
	var save_slots_container = $Panel/VBoxContainer/SaveSlots

	for i in range(3):
		var slot_panel = save_slots_container.get_child(i)
		var slot_name = slot_panel.get_node("HBoxContainer/SlotInfo/SlotName")
		var slot_details = slot_panel.get_node("HBoxContainer/SlotInfo/SlotDetails")
		var save_button = slot_panel.get_node("HBoxContainer/Buttons/SaveButton")
		var load_button = slot_panel.get_node("HBoxContainer/Buttons/LoadButton")
		var delete_button = slot_panel.get_node("HBoxContainer/Buttons/DeleteButton")

		slots.append({
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
		save_button.pressed.connect(_on_save_pressed.bind(slot_index))
		load_button.pressed.connect(_on_load_pressed.bind(slot_index))
		delete_button.pressed.connect(_on_delete_pressed.bind(slot_index))

## Show save/load menu
func show_menu():
	# Get current game mode
	var game_mode_manager = get_node_or_null("/root/GameModeManager")
	if game_mode_manager:
		current_mode = game_mode_manager.current_mode

	# Update title
	mode_label.text = TextData.get_raw("ui_story_mode" if current_mode == 1 else "ui_sandbox_mode")

	# Refresh save slots
	_refresh_slots()

	# Show menu
	show()

	# Pause game
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

## Hide save/load menu
func hide_menu():
	hide()

	# Resume game
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT

## Refresh save slot display
func _refresh_slots():
	for slot in slots:
		var slot_index = slot["index"]
		var save_system = get_node_or_null("/root/SaveSystem")

		if save_system and save_system.has_save(slot_index, current_mode):
			# Slot has data
			var info = save_system.get_save_info(slot_index, current_mode)
			var chapter_name = info.get("chapter_name", "")
			var save_time = info.get("save_time", "")

			slot["name_label"].text = TextData.format("ui_save_slot_format", [slot_index + 1, chapter_name])
			slot["details_label"].text = save_time
			slot["load_button"].disabled = false
			slot["delete_button"].disabled = false
		else:
			# Slot is empty
			slot["name_label"].text = TextData.format("ui_save_slot_empty", [slot_index + 1])
			slot["details_label"].text = ""
			slot["load_button"].disabled = true
			slot["delete_button"].disabled = true

## Handle save button pressed
func _on_save_pressed(slot_index: int):
	print("[SaveLoadMenu] Save to slot %d" % slot_index)

	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		if save_system.save_game(slot_index, current_mode):
			print("[SaveLoadMenu] Game saved successfully")
			_refresh_slots()
		else:
			push_error("[SaveLoadMenu] Failed to save game")

## Handle load button pressed
func _on_load_pressed(slot_index: int):
	print("[SaveLoadMenu] Load from slot %d" % slot_index)

	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		if save_system.load_game(slot_index, current_mode):
			print("[SaveLoadMenu] Game loaded successfully")
			hide_menu()

			# Reload scene to apply changes
			get_tree().reload_current_scene()
		else:
			push_error("[SaveLoadMenu] Failed to load game")

## Handle delete button pressed
func _on_delete_pressed(slot_index: int):
	print("[SaveLoadMenu] Delete slot %d" % slot_index)

	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		if save_system.delete_save(slot_index, current_mode):
			print("[SaveLoadMenu] Save deleted successfully")
			_refresh_slots()
		else:
			push_error("[SaveLoadMenu] Failed to delete save")

## Handle close button pressed
func _on_close_pressed():
	hide_menu()

## Handle input
func _input(event):
	if visible:
		if event.is_action_pressed("ui_cancel"):
			hide_menu()
