extends Control

## Main Menu Controller
## Handles navigation from the main menu to the game

@onready var start_button = $CanvasLayer/CenterContainer/VBoxContainer/StartButton
@onready var quit_button = $CanvasLayer/CenterContainer/VBoxContainer/QuitButton

func _ready():
	# Reset all game systems when returning to main menu
	_reset_game_state()

	# Connect button signals
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)

	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

	print("Main Menu loaded")
	print("Press 'Start Game' to begin")

## Reset all game state when returning to main menu
func _reset_game_state():
	var resource_system = get_node_or_null("/root/ResourceSystem")
	if resource_system:
		resource_system.reset_resources()

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system and dept_system.has_method("reset_department_system"):
		dept_system.reset_department_system()

	var objective_system = get_node_or_null("/root/ObjectiveSystem")
	if objective_system and objective_system.has_method("reset_objectives"):
		objective_system.reset_objectives()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()
