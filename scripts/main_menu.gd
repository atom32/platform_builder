extends Control

## Main Menu Controller
## Handles navigation from the main menu to the game

@onready var start_button = $CanvasLayer/CenterContainer/VBoxContainer/StartButton
@onready var quit_button = $CanvasLayer/CenterContainer/VBoxContainer/QuitButton

func _ready():
	# Connect button signals
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)

	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

	print("Main Menu loaded")
	print("Press 'Start Game' to begin")

func _on_start_button_pressed():
	print("Starting game...")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()
