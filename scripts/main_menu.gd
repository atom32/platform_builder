extends Control

## Main Menu Controller
## Handles navigation from the main menu to the game

@onready var start_button = $CanvasLayer/CenterContainer/VBoxContainer/StartButton
@onready var quit_button = $CanvasLayer/CenterContainer/VBoxContainer/QuitButton

func _ready():
	print("MainMenu: _ready() called")
	print("Start button node: ", start_button)
	print("Quit button node: ", quit_button)

	# Reset all game systems when returning to main menu
	_reset_game_state()

	# Connect button signals
	if start_button:
		print("Connecting start button signal...")
		start_button.pressed.connect(_on_start_button_pressed)
		print("Start button signal connected")
	else:
		print("ERROR: Start button is null!")

	if quit_button:
		print("Connecting quit button signal...")
		quit_button.pressed.connect(_on_quit_button_pressed)
		print("Quit button signal connected")
	else:
		print("ERROR: Quit button is null!")

	print("Main Menu loaded")

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
