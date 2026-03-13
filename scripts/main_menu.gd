extends Control

## Main Menu Controller
## Handles navigation from the main menu to the game

@onready var story_mode_button = $CanvasLayer/CenterContainer/VBoxContainer/StoryModeButton
@onready var sandbox_mode_button = $CanvasLayer/CenterContainer/VBoxContainer/SandboxModeButton
@onready var quit_button = $CanvasLayer/CenterContainer/VBoxContainer/QuitButton

func _ready():
	# Reset all game systems when returning to main menu
	_reset_game_state()

	# Connect button signals
	if story_mode_button:
		story_mode_button.pressed.connect(_on_story_mode_button_pressed)

	if sandbox_mode_button:
		sandbox_mode_button.pressed.connect(_on_sandbox_mode_button_pressed)

	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

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

func _on_story_mode_button_pressed():
	# Get GameModeManager and start story mode
	var game_mode_manager = get_node_or_null("/root/GameModeManager")
	if game_mode_manager:
		game_mode_manager.start_story_mode(0)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_sandbox_mode_button_pressed():
	# Get GameModeManager and start sandbox mode
	var game_mode_manager = get_node_or_null("/root/GameModeManager")
	if game_mode_manager:
		game_mode_manager.start_sandbox_mode()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
