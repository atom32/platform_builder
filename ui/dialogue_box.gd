extends Panel
class_name DialogueBox

## Dialogue Box
## Displays character dialogue with typewriter effect and choices
## Pauses the game while active

@onready var speaker_name = $VBoxContainer/HBoxContainer/SpeakerName
@onready var dialogue_text = $VBoxContainer/DialogueText
@onready var choices_container = $VBoxContainer/ChoicesContainer
@onready var continue_prompt = $VBoxContainer/ContinuePrompt
@onready var typewriter_timer = $TypewriterTimer

## Dialogue data
var current_dialogue: Dictionary = {}
var current_text: String = ""
var typewriter_index: int = 0
var typewriter_active: bool = false
var typewriter_speed: float = 0.03  # Seconds per character

## Callbacks
var dialogue_closed_callback: Callable = Callable()
var choice_made_callback: Callable = Callable()

## Is dialogue box active
var is_active: bool = false

## Pause state before dialogue
var was_paused: bool = false

func _ready():
	add_to_group("dialogue_box")
	hide()
	set_process_input(false)

	# Connect typewriter timer
	typewriter_timer.timeout.connect(_on_typewriter_tick)

## Show dialogue
func show_dialogue(speaker: String, text: String, choices: Array = [], on_close: Callable = Callable(), on_choice: Callable = Callable()):
	# Store current state
	was_paused = get_tree().paused
	print("[DialogueBox] Opening dialogue - was_paused: ", was_paused)

	# Setup dialogue
	speaker_name.text = speaker
	current_text = text
	dialogue_text.text = ""
	typewriter_index = 0
	typewriter_active = true

	# Store callbacks
	dialogue_closed_callback = on_close
	choice_made_callback = on_choice

	# Clear and create choices
	_clear_choices()
	for choice in choices:
		_add_choice_button(choice)

	# Hide continue prompt if there are choices
	if choices.size() > 0:
		continue_prompt.hide()
	else:
		continue_prompt.show()

	# Show dialogue box and pause game
	show()
	is_active = true
	set_process_input(true)

	# Pause game (but keep this node processing)
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[DialogueBox] Game paused - get_tree().paused: ", get_tree().paused)

	# Start typewriter effect
	typewriter_timer.start(typewriter_speed)

## Add a choice button
func _add_choice_button(choice_data):
	var button = Button.new()
	button.text = choice_data.get("text", TextData.get_raw("ui_choice_default"))
	button.add_theme_constant_override("font_size", 16)
	button.custom_minimum_size = Vector2(0, 40)

	# Connect button press
	var choice_index = choices_container.get_child_count()
	button.pressed.connect(_on_choice_pressed.bind(choice_index, choice_data))

	choices_container.add_child(button)

## Clear all choice buttons
func _clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

## Handle choice pressed
func _on_choice_pressed(index: int, choice_data: Dictionary):
	print("[DialogueBox] Choice selected: ", index)

	# Call choice callback
	if choice_made_callback.is_valid():
		choice_made_callback.call(index, choice_data)

	# Check if there's a next dialogue
	if choice_data.has("next_dialogue"):
		var next_dialogue_id = choice_data["next_dialogue"]
		_load_next_dialogue(next_dialogue_id)
	else:
		close_dialogue()

## Load next dialogue from StorySystem
func _load_next_dialogue(dialogue_id: String):
	var story_system = get_node_or_null("/root/StorySystem")
	if story_system and story_system.has_method("get_dialogue"):
		var next_dialogue = story_system.get_dialogue(dialogue_id)
		if not next_dialogue.is_empty():
			var speaker = next_dialogue.get("speaker", TextData.get_raw("ui_speaker_unknown"))
			var text = next_dialogue.get("text", "")
			var choices = next_dialogue.get("choices", [])
			show_dialogue(speaker, text, choices, dialogue_closed_callback, choice_made_callback)
		else:
			close_dialogue()
	else:
		close_dialogue()

## Close dialogue box
func close_dialogue():
	print("[DialogueBox] Closing dialogue - was_paused: ", was_paused)

	# Hide dialogue box
	hide()
	is_active = false
	set_process_input(false)

	# Stop typewriter
	typewriter_timer.stop()
	typewriter_active = false

	# Restore game state - ALWAYS unpause when dialogue closes
	# This prevents the game from getting stuck in paused state
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	print("[DialogueBox] Game unpaused - get_tree().paused: ", get_tree().paused)

	# Call closed callback
	if dialogue_closed_callback.is_valid():
		dialogue_closed_callback.call()

## Handle input
func _input(event):
	if not is_active:
		return

	# Skip typewriter effect on space or click
	if typewriter_active:
		if event.is_action_pressed("ui_accept") or event is InputEventMouseButton and event.pressed:
			# Skip to end of text
			typewriter_active = false
			typewriter_timer.stop()
			dialogue_text.text = current_text
			return

	# Continue on space or click (if no choices)
	if not typewriter_active and choices_container.get_child_count() == 0:
		if event.is_action_pressed("ui_accept") or event is InputEventMouseButton and event.pressed:
			close_dialogue()

## Typewriter effect tick
func _on_typewriter_tick():
	if not typewriter_active or typewriter_index >= current_text.length():
		typewriter_active = false
		typewriter_timer.stop()
		return

	# Add next character
	typewriter_index += 1
	dialogue_text.text = current_text.substr(0, typewriter_index)

## Check if dialogue is active
func get_is_active() -> bool:
	return is_active
