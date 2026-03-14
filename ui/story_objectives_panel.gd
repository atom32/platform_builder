extends Panel
class_name StoryObjectivesPanel

## Story Objectives Panel
## Displays current chapter name and objectives in the HUD

@onready var chapter_header = $VBoxContainer/ChapterHeader
@onready var objectives_list = $VBoxContainer/ObjectivesList

var objective_labels: Array[Label] = []

func _ready():
	# Only connect to StorySystem in Story Mode
	var game_mode_manager = get_node_or_null("/root/GameModeManager")
	var story_system = get_node_or_null("/root/StorySystem")

	if game_mode_manager and game_mode_manager.current_mode == 1 and story_system:
		# Connect to StorySystem signals
		story_system.chapter_loaded.connect(_on_chapter_loaded)
		story_system.objective_completed.connect(_on_objective_completed)

		# Wait for chapter data to fully load before refreshing
		await get_tree().process_frame
		await get_tree().process_frame  # Double wait to ensure chapter is loaded
		refresh_objectives()
	else:
		# Hide in sandbox mode
		hide()

## Refresh objectives display from StorySystem
func refresh_objectives():
	var story_system = get_node_or_null("/root/StorySystem")
	if not story_system:
		return

	# Get chapter data for proper numbering
	var chapter_data = story_system.get_current_chapter()

	# Check if chapter data is loaded
	if chapter_data.is_empty():
		chapter_header.text = TextData.get_raw("ui_chapter_loading")
		return

	var chapter_id = chapter_data.get("id", "chapter_01")
	var chapter_name = story_system.get_chapter_name()

	# Extract chapter number from ID (chapter_01 -> 1, chapter_02 -> 2, etc.)
	var chapter_num = _extract_chapter_number_from_id(chapter_id)
	chapter_header.text = TextData.format("ui_chapter_format", [chapter_num, chapter_name])

	# Clear existing objective labels
	for label in objectives_list.get_children():
		label.queue_free()
	objective_labels.clear()

	# Add new objective labels
	var objectives = story_system.get_chapter_objectives()

	# Special handling for mission complete state
	if objectives.is_empty():
		var complete_label = Label.new()
		complete_label.add_theme_constant_override("font_size", 16)
		complete_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		complete_label.custom_minimum_size = Vector2(290, 0)
		complete_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		complete_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		complete_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))  # Green color
		complete_label.text = TextData.get_raw("ui_missions_complete")
		objectives_list.add_child(complete_label)
		objective_labels.append(complete_label)

		# Add second label with continuation message
		var continue_label = Label.new()
		continue_label.add_theme_constant_override("font_size", 12)
		continue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		continue_label.custom_minimum_size = Vector2(290, 0)
		continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		continue_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))  # Gray color
		continue_label.text = TextData.get_raw("ui_continue_sandbox")
		objectives_list.add_child(continue_label)
		objective_labels.append(continue_label)
		return

	for obj in objectives:
		var label = Label.new()
		label.add_theme_constant_override("font_size", 12)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # Enable auto-wrap
		label.custom_minimum_size = Vector2(290, 0)  # Set minimum width to match panel

		var obj_id = obj.get("id", "")
		var description = obj.get("description", "")

		# Check if objective is complete
		var is_complete = story_system.is_objective_complete(obj_id)
		var status = "[X]" if is_complete else "[ ]"

		label.text = "%s %s" % [status, description]
		objectives_list.add_child(label)
		objective_labels.append(label)

## Extract chapter number from chapter ID
func _extract_chapter_number_from_id(chapter_id: String) -> String:
	if chapter_id == "chapter_end":
		return TextData.get_raw("ui_chapter_end")  # Special case for final chapter

	if chapter_id.contains("chapter_"):
		var parts = chapter_id.split("_")
		if parts.size() > 1:
			# Remove leading zero (01 -> 1, 02 -> 2, etc.)
			var num = parts[1]
			if num.begins_with("0"):
				num = num.substr(1)
			return num
	return "1"

## Handle chapter loaded (new signal for proper UI updates)
func _on_chapter_loaded(chapter_id: String):
	print("[StoryObjectivesPanel] Chapter loaded: ", chapter_id)
	refresh_objectives()

## Handle chapter completed (legacy, kept for compatibility)
func _on_chapter_completed(chapter_id: String):
	print("[StoryObjectivesPanel] Chapter completed: ", chapter_id)
	# Don't refresh here - wait for chapter_loaded signal

## Handle objective completed
func _on_objective_completed(objective_id: String):
	print("[StoryObjectivesPanel] Objective completed: ", objective_id)
	refresh_objectives()

## Show/hide the panel
func show_panel():
	visible = true

func hide_panel():
	visible = false

## Toggle panel visibility
func toggle_panel():
	visible = not visible
