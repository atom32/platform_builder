extends Node

## Global game session management system
## Tracks game state, statistics, and win/lose conditions

## Game states
enum GameState { RUNNING, PAUSED, VICTORY, FAILURE }

## Current game state
var current_state: GameState = GameState.RUNNING

## Session statistics
var days_survived: int = 0
var platforms_built: int = 0
var staff_recruited: int = 0
var expeditions_sent: int = 0

## Day timer (60 seconds = 1 day)
var day_timer: Timer

## Debt warning flag (warn only once)
var debt_warning_shown: bool = false

## Signals
signal game_state_changed(new_state: GameState)
signal victory_achieved()
signal game_over(reason: String)
signal day_passed(day_number: int)

func _ready():
	_setup_day_timer()
	print("GameSession initialized")

## Setup day timer (60 seconds per day)
func _setup_day_timer():
	day_timer = Timer.new()
	day_timer.wait_time = 60.0
	day_timer.autostart = false  # Will be started in start_session()
	day_timer.timeout.connect(_on_day_passed)
	add_child(day_timer)

## Handle day passed
func _on_day_passed():
	days_survived += 1
	day_passed.emit(days_survived)

	# Check lose conditions every day
	check_lose_conditions()

## Start a new game session
func start_session():
	# Reset all statistics
	current_state = GameState.RUNNING
	days_survived = 0
	platforms_built = 0
	staff_recruited = 0
	expeditions_sent = 0
	debt_warning_shown = false

	# Reset and start day timer
	if day_timer:
		day_timer.stop()
		day_timer.start()

	# Connect to objective system for victory condition
	var objective_system = get_node_or_null("/root/ObjectiveSystem")
	if objective_system:
		if not objective_system.all_objectives_completed.is_connected(_on_all_objectives_completed):
			objective_system.all_objectives_completed.connect(_on_all_objectives_completed)

	print("Game session started")
	game_state_changed.emit(GameState.RUNNING)

## End game with victory
func end_victory():
	if current_state == GameState.VICTORY:
		return  # Already won

	current_state = GameState.VICTORY
	print("Victory achieved!")

	# Show result screen
	_show_result_screen(true)

	# Don't use engine pause - it blocks input!
	# Instead, game logic checks GameSession.is_running()
	print("Game state set to VICTORY (input still active)")

	victory_achieved.emit()
	game_state_changed.emit(GameState.VICTORY)

## End game with failure
func end_game_over(reason: String):
	if current_state == GameState.FAILURE:
		return  # Already lost

	current_state = GameState.FAILURE
	print("Game over: %s" % reason)

	# Show result screen
	_show_result_screen(false, reason)

	# Don't use engine pause - it blocks input!
	# Instead, game logic checks GameSession.is_running()
	print("Game state set to FAILURE (input still active)")

	game_over.emit(reason)
	game_state_changed.emit(GameState.FAILURE)

## Show result screen
func _show_result_screen(victory: bool, reason: String = ""):
	# Load result screen scene
	var result_screen_scene = load("res://ui/result_screen.tscn")
	if result_screen_scene:
		var result_screen = result_screen_scene.instantiate()
		get_tree().root.add_child(result_screen)

		if result_screen.has_method("show_result"):
			result_screen.show_result(victory, get_session_summary(), reason)

## Check lose conditions
func check_lose_conditions():
	# Check GMP debt
	var gmp = ResourceSystem.get_gmp()
	if gmp <= ResourceSystem.get_debt_limit():
		end_game_over("GMP debt exceeded -500")
		return

	# Check staff count
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system and dept_system.get_total_staff() == 0:
		end_game_over("All staff lost")
		return

	# Check for debt warning
	if gmp <= ResourceSystem.get_debt_warning_threshold() and not debt_warning_shown:
		debt_warning_shown = true
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system and notification_system.has_method("show_debt_warning"):
			notification_system.show_debt_warning()

## Handle all objectives completed
func _on_all_objectives_completed():
	# Give player time to see completion, then trigger victory
	await get_tree().create_timer(3.0).timeout
	end_victory()

## Get session summary
func get_session_summary() -> Dictionary:
	return {
		"days_survived": days_survived,
		"platforms_built": platforms_built,
		"staff_recruited": staff_recruited,
		"expeditions_sent": expeditions_sent
	}

## Statistics tracking methods

func increment_platforms_built():
	platforms_built += 1

func increment_staff_recruited():
	staff_recruited += 1

func increment_expeditions_sent():
	expeditions_sent += 1

## Get current state
func get_current_state() -> GameState:
	return current_state

## Check if game is running
func is_running() -> bool:
	return current_state == GameState.RUNNING
