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
		story_system.chapter_completed.connect(_on_chapter_completed)
		story_system.objective_completed.connect(_on_objective_completed)

		# Load initial objectives
		refresh_objectives()
	else:
		# Hide in sandbox mode
		hide()

## Refresh objectives display from StorySystem
func refresh_objectives():
	var story_system = get_node_or_null("/root/StorySystem")
	if not story_system:
		return

	# Update chapter header
	var chapter_name = story_system.get_chapter_name()
	var chapter_num = _extract_chapter_number(chapter_name)
	chapter_header.text = "CHAPTER %s: %s" % [chapter_num, _extract_chapter_title(chapter_name)]

	# Clear existing objective labels
	for label in objectives_list.get_children():
		label.queue_free()
	objective_labels.clear()

	# Add new objective labels
	var objectives = story_system.get_chapter_objectives()
	for obj in objectives:
		var label = Label.new()
		label.theme_override_font_sizes.font_size = 12

		var obj_id = obj.get("id", "")
		var description = obj.get("description", "")

		# Check if objective is complete
		var is_complete = story_system.is_objective_complete(obj_id)
		var status = "[X]" if is_complete else "[ ]"

		label.text = "%s %s" % [status, description]
		objectives_list.add_child(label)
		objective_labels.append(label)

## Extract chapter number from chapter ID
func _extract_chapter_number(chapter_name: String) -> String:
	if chapter_name.contains("Chapter"):
		var parts = chapter_name.split(" ")
		if parts.size() > 1:
			return parts[1]
	return "1"

## Extract chapter title from chapter name
func _extract_chapter_title(chapter_name: String) -> String:
	if chapter_name.contains(":"):
		var parts = chapter_name.split(":")
		if parts.size() > 1:
			return parts[1].strip_edges()
	return chapter_name

## Handle chapter completed
func _on_chapter_completed(chapter_id: String):
	print("[StoryObjectivesPanel] Chapter completed: ", chapter_id)
	refresh_objectives()

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
