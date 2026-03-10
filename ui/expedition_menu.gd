extends Control
class_name ExpeditionMenu

signal expedition_launched(mission_id: String)

@onready var close_button = $Panel/VBoxContainer/Header/CloseButton
@onready var mission_list = $Panel/VBoxContainer/ScrollContainer/MissionList
@onready var combat_power_label = $Panel/VBoxContainer/CombatPowerLabel
@onready var success_chance_label = $Panel/VBoxContainer/DepartmentBonuses/SuccessChanceLabel
@onready var resource_bonus_label = $Panel/VBoxContainer/DepartmentBonuses/ResourceBonusLabel
@onready var casualty_reduction_label = $Panel/VBoxContainer/DepartmentBonuses/CasualtyReductionLabel
@onready var duration_reduction_label = $Panel/VBoxContainer/DepartmentBonuses/DurationReductionLabel

var expedition_system: ExpeditionManager
var mission_buttons: Dictionary = {}

func _ready():
	# Get reference to ExpeditionSystem autoload singleton
	expedition_system = get_node("/root/ExpeditionSystem")

	close_button.pressed.connect(_on_close_clicked)

	# Create mission buttons
	_create_mission_buttons()

	# Hide menu initially
	hide()

func show_menu():
	visible = true
	_update_mission_list()
	_update_combat_power()
	_update_department_bonuses()

func hide_menu():
	visible = false

func _create_mission_buttons():
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

func _update_mission_list():
	var available_missions = expedition_system.get_available_missions()
	var current_combat_power = expedition_system.get_combat_power()

	for mission_id in mission_buttons:
		var button = mission_buttons[mission_id]
		var mission = expedition_system.mission_data[mission_id]

		if available_missions.has(mission_id):
			# Mission is available
			button.disabled = false

			# Check if already active
			if expedition_system.active_expeditions.has(mission_id):
				var time_remaining = expedition_system.get_expedition_time_remaining(mission_id)
				button.text = TextData.format("ui_expedition_in_progress", [
					mission["display_name"],
					time_remaining,
					TextData.difficulty_name(mission["difficulty"])
				])
				button.disabled = true
			else:
				button.text = TextData.format("ui_expedition_available", [
					mission["display_name"],
					mission["description"],
					current_combat_power,
					mission["required_combat_power"],
					mission["duration"],
					TextData.difficulty_name(mission["difficulty"]),
					mission["materials_reward"],
					mission["fuel_reward"]
				])
		else:
			# Mission not available (insufficient combat power)
			button.disabled = true
			button.text = TextData.format("ui_expedition_locked", [
				mission["display_name"],
				mission["required_combat_power"],
				current_combat_power
			])

func _update_combat_power():
	if combat_power_label:
		var combat_power = expedition_system.get_combat_power()
		combat_power_label.text = TextData.format("ui_expedition_combat_power", [combat_power])

func _update_department_bonuses():
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

func _on_mission_button_clicked(button: Button):
	var mission_id = button.get_meta("mission_id")

	# Launch expedition
	if expedition_system.launch_expedition(mission_id):
		expedition_launched.emit(mission_id)
		_update_mission_list()

func _on_close_clicked():
	hide_menu()

func _on_expedition_started(mission_id: String):
	_update_mission_list()

func _on_expedition_completed(mission_id: String, rewards: Dictionary):
	_update_mission_list()
	# Show completion message (could add a popup notification)
	print("Expedition %s completed! Rewards: %s" % [mission_id, rewards])
