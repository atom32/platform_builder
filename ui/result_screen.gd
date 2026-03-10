extends CanvasLayer

## Result Screen - Shows victory or game over with statistics

@onready var result_title_label = $Control/CenterContainer/Panel/VBoxContainer/ResultTitleLabel
@onready var days_survived_label = $Control/CenterContainer/Panel/VBoxContainer/StatisticsGroup/DaysSurvivedLabel
@onready var platforms_built_label = $Control/CenterContainer/Panel/VBoxContainer/StatisticsGroup/PlatformsBuiltLabel
@onready var staff_recruited_label = $Control/CenterContainer/Panel/VBoxContainer/StatisticsGroup/StaffRecruitedLabel
@onready var expeditions_sent_label = $Control/CenterContainer/Panel/VBoxContainer/StatisticsGroup/ExpeditionsSentLabel
@onready var message_label = $Control/CenterContainer/Panel/VBoxContainer/MessageLabel
@onready var restart_button = $Control/CenterContainer/Panel/VBoxContainer/ButtonContainer/RestartButton
@onready var main_menu_button = $Control/CenterContainer/Panel/VBoxContainer/ButtonContainer/MainMenuButton

## Labels for title styling
const TITLE_FONT_SIZE: int = 48
const STATS_FONT_SIZE: int = 20
const BUTTON_FONT_SIZE: int = 24

func _ready():
	# Ensure signals are connected programmatically
	# This is more reliable than scene file connections
	call_deferred("_connect_signals")

	# Configure labels
	_configure_labels()

	print("Result screen initialized")

func _connect_signals():
	# Find buttons by traversing the scene tree
	var restart_btn = $Control/CenterContainer/Panel/VBoxContainer/ButtonContainer/RestartButton
	var main_menu_btn = $Control/CenterContainer/Panel/VBoxContainer/ButtonContainer/MainMenuButton

	print("Result screen: Attempting to connect button signals...")

	if restart_btn:
		if not restart_btn.pressed.is_connected(_on_restart_pressed):
			restart_btn.pressed.connect(_on_restart_pressed)
			print("Result screen: ✓ Restart button signal connected")
		else:
			print("Result screen: ! Restart button already connected")

		# Verify pause mode
		print("Result screen: RestartButton pause_mode = %d" % restart_btn.pause_mode)
	else:
		print("Result screen: ✗ ERROR - RestartButton not found!")

	if main_menu_btn:
		if not main_menu_btn.pressed.is_connected(_on_main_menu_pressed):
			main_menu_btn.pressed.connect(_on_main_menu_pressed)
			print("Result screen: ✓ Main menu button signal connected")
		else:
			print("Result screen: ! Main menu button already connected")

		# Verify pause mode
		print("Result screen: MainMenuButton pause_mode = %d" % main_menu_btn.pause_mode)
	else:
		print("Result screen: ✗ ERROR - MainMenuButton not found!")

## Configure label fonts and sizes
func _configure_labels():
	# Create label settings for title
	var title_settings = LabelSettings.new()
	title_settings.font_size = TITLE_FONT_SIZE
	if result_title_label:
		result_title_label.label_settings = title_settings

	# Create label settings for statistics
	var stats_settings = LabelSettings.new()
	stats_settings.font_size = STATS_FONT_SIZE
	if days_survived_label:
		days_survived_label.label_settings = stats_settings
	if platforms_built_label:
		platforms_built_label.label_settings = stats_settings
	if staff_recruited_label:
		staff_recruited_label.label_settings = stats_settings
	if expeditions_sent_label:
		expeditions_sent_label.label_settings = stats_settings

	# Note: Buttons don't support label_settings, they use theme overrides instead
	# The button text size can be set in the scene editor or via theme

## Show result screen with victory/defeat info
func show_result(victory: bool, stats: Dictionary, reason: String = ""):
	# Update statistics
	if days_survived_label:
		days_survived_label.text = "Days Survived: %d" % stats.get("days_survived", 0)
	if platforms_built_label:
		platforms_built_label.text = "Platforms Built: %d" % stats.get("platforms_built", 0)
	if staff_recruited_label:
		staff_recruited_label.text = "Staff Recruited: %d" % stats.get("staff_recruited", 0)
	if expeditions_sent_label:
		expeditions_sent_label.text = "Expeditions Sent: %d" % stats.get("expeditions_sent", 0)

	# Set title and colors based on victory/defeat
	if result_title_label:
		if victory:
			result_title_label.text = "VICTORY"
			result_title_label.modulate = Color(0.0, 1.0, 0.0)  # Green
		else:
			result_title_label.text = "GAME OVER"
			result_title_label.modulate = Color(1.0, 0.0, 0.0)  # Red

	# Set message based on result
	if message_label:
		if victory:
			message_label.text = "Congratulations! You completed all objectives!"
		else:
			if reason.is_empty():
				message_label.text = "Your base has been lost."
			else:
				message_label.text = "Reason: %s" % reason

	visible = true

## Handle restart button
func _on_restart_pressed():
	print("Restart button pressed - changing scene to main.tscn")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

## Handle main menu button
func _on_main_menu_pressed():
	print("Main menu button pressed - changing scene to main_menu.tscn")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
