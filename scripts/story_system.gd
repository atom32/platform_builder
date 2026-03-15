extends Node

## Story System
## Manages story chapters, objectives, and dialogue progression
## This is an autoload singleton that handles all story-related content

# Preload loader classes for safe initialization
const StoryLoader = preload("res://scripts/story_loader.gd")

## Current chapter data
var current_chapter_id: String = ""
var chapter_data: Dictionary = {}
var completed_chapters: Array[String] = []
var story_flags: Dictionary = {}

## Current story language (from ConfigSystem)
var current_language: String = "en"

## Chapter completed signal
signal chapter_completed(chapter_id: String)
signal chapter_loaded(chapter_id: String)  # New signal for when chapter data is loaded
signal objective_completed(objective_id: String)
signal dialogue_requested(dialogue_data: Dictionary)

## Set language for story chapters
func set_story_language(language: String):
	current_language = language
	print("[StorySystem] Story language set to: ", language)

## Get current story language
func get_story_language() -> String:
	return current_language

func _ready():
	print("[StorySystem] Initialized")

## Initialize StorySystem when game starts (called from main.gd)
func initialize_story_mode():
	print("[StorySystem] Initializing Story Mode")

	# Load language setting from ConfigSystem
	var config_system = get_node_or_null("/root/ConfigSystem")
	if config_system:
		current_language = config_system.language
		print("[StorySystem] Loaded language from ConfigSystem: ", current_language)

	# Subscribe to game events (signal-driven architecture)
	# Note: We subscribe to existing signals without modifying the source

	# Wait for scene tree to be ready before connecting
	await get_tree().process_frame

	# Connect to Base system platform_built signal
	var base = get_tree().get_first_node_in_group("base")
	if base and base.has_signal("platform_built"):
		base.platform_built.connect(_on_platform_built)
		print("[StorySystem] Connected to Base.platform_built signal")

	# Connect to ResourceSystem staff_recruited signal
	var resource_system = get_node_or_null("/root/ResourceSystem")
	if resource_system and resource_system.has_signal("staff_recruited"):
		resource_system.staff_recruited.connect(_on_staff_recruited)
		print("[StorySystem] Connected to ResourceSystem.staff_recruited signal")

	# Connect to ExpeditionSystem signals
	var expedition_system = get_node_or_null("/root/ExpeditionSystem")
	if expedition_system:
		if expedition_system.has_signal("expedition_completed"):
			expedition_system.expedition_completed.connect(_on_expedition_completed)
			print("[StorySystem] Connected to ExpeditionSystem.expedition_completed signal")

	# Connect to DepartmentSystem signals
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		if dept_system.has_signal("staff_assigned"):
			dept_system.staff_assigned.connect(_on_staff_assigned)
			print("[StorySystem] Connected to DepartmentSystem.staff_assigned signal")

	# Load first chapter
	load_chapter("chapter_01")

## Handle platform built event
func _on_platform_built(platform_type: String):
	print("[StorySystem] Platform built: ", platform_type)

	# Check if this completes any objectives
	var objectives = get_chapter_objectives()
	for obj in objectives:
		if obj.get("type") == "build_platform":
			if obj.get("target") == platform_type:
				complete_objective(obj.get("id", ""))

	# Check other objective types (total_platforms, all_departments, etc.)
	_check_all_objectives()

## Handle staff recruited event
func _on_staff_recruited():
	print("[StorySystem] Staff recruited")

	# Check if this completes any objectives
	var objectives = get_chapter_objectives()
	for obj in objectives:
		if obj.get("type") == "recruit_staff":
			complete_objective(obj.get("id", ""))

	# Check other objective types
	_check_all_objectives()

## Handle staff assigned event
func _on_staff_assigned(staff_id: int, department: String):
	print("[StorySystem] Staff assigned: ", staff_id, " to ", department)

	# Check if this completes any objectives
	var objectives = get_chapter_objectives()
	for obj in objectives:
		if obj.get("type") == "assign_staff":
			complete_objective(obj.get("id", ""))

	# Check other objective types
	_check_all_objectives()

## Handle expedition completed event
func _on_expedition_completed(mission_id: String, result_data: Dictionary = {}):
	print("[StorySystem] Expedition completed: ", mission_id)

	# Check if this completes any objectives
	var objectives = get_chapter_objectives()
	for obj in objectives:
		if obj.get("type") == "send_expedition":
			complete_objective(obj.get("id", ""))

	# Check other objective types that may be satisfied
	_check_all_objectives()

## Check all objectives (called after any game event)
func _check_all_objectives():
	var objectives = get_chapter_objectives()
	var base = get_tree().get_first_node_in_group("base")
	var dept_system = get_node_or_null("/root/DepartmentSystem")

	for obj in objectives:
		var obj_id = obj.get("id", "")
		var obj_type = obj.get("type", "")

		# Skip already completed objectives
		if is_objective_complete(obj_id):
			continue

		match obj_type:
			"total_platforms":
				if base and base.has_method("get_total_platform_count"):
					var count = base.get_total_platform_count()
					var required = obj.get("count", 0)
					if count >= required:
						complete_objective(obj_id)

			"all_departments":
				if base and base.has_method("get_all_platforms"):
					var platforms = base.get_all_platforms()
					var department_types = {}
					for platform in platforms:
						var ptype = platform.platform_type
						if ptype in ["R&D", "Support", "Combat", "Intel", "Medical"]:
							department_types[ptype] = true
					if department_types.size() >= 5:  # All 5 department types
						complete_objective(obj_id)

			"staff_count":
				var count = ResourceSystem.get_staff_count()
				var required = obj.get("count", 0)
				if count >= required:
					complete_objective(obj_id)

			"assign_staff":
				# This is handled by a separate signal (to be implemented)
				pass

			"platform_level":
				# Check if any platform is at the required depth
				if base and base.has_method("get_all_platforms"):
					var platforms = base.get_all_platforms()
					var required_depth = obj.get("count", 2)
					for platform in platforms:
						# Check platform depth (distance from HQ)
						var depth = _get_platform_depth(platform)
						if depth >= required_depth:
							complete_objective(obj_id)
							break

## Get platform depth (distance from HQ in tree)
func _get_platform_depth(platform: Platform) -> int:
	var depth = 0
	var current = platform

	# Walk up the tree to HQ
	while current and current.platform_type != "HQ":
		if current.has_method("get_parent_platform"):
			current = current.get_parent_platform()
			if current:
				depth += 1
			else:
				break
		else:
			break

	return depth

## Load chapter data from JSON (multi-language support)
func load_chapter(chapter_id: String) -> bool:
	print("[StorySystem] Loading chapter: ", chapter_id, " (language: ", current_language, ")")

	# Use StoryLoader to load chapter data for current language
	var loader = StoryLoader.new()
	var all_data = loader.load_story_chapters(current_language)

	if all_data.is_empty():
		push_error("[StorySystem] Failed to load story data for language: " + current_language)
		return false

	if not all_data.has("chapters"):
		push_error("[StorySystem] Invalid story data format: missing 'chapters' array")
		return false

	# Find the requested chapter
	for chapter in all_data["chapters"]:
		if chapter["id"] == chapter_id:
			current_chapter_id = chapter_id
			chapter_data = chapter
			print("[StorySystem] Chapter loaded: ", chapter.get("name", "Unknown"))

			# Emit signal that chapter is loaded (for UI updates)
			chapter_loaded.emit(chapter_id)

			# Trigger chapter start dialogues
			_trigger_dialogues_by_type("chapter_start")

			return true

	push_error("[StorySystem] Chapter not found: " + chapter_id)
	return false

## Get current chapter data
func get_current_chapter() -> Dictionary:
	return chapter_data

## Get chapter name
func get_chapter_name() -> String:
	if chapter_data.is_empty():
		return "No Chapter Loaded"
	return chapter_data.get("name", "Unknown Chapter")

## Get chapter description
func get_chapter_description() -> String:
	if chapter_data.is_empty():
		return ""
	return chapter_data.get("description", "")

## Get chapter objectives
func get_chapter_objectives() -> Array:
	if chapter_data.is_empty():
		return []
	return chapter_data.get("objectives", [])

## Check if objective is complete
func is_objective_complete(objective_id: String) -> bool:
	return story_flags.get("obj_complete_" + objective_id, false)

## Mark objective as complete
func complete_objective(objective_id: String):
	if not story_flags.get("obj_complete_" + objective_id, false):
		story_flags["obj_complete_" + objective_id] = true
		print("[StorySystem] Objective completed: ", objective_id)
		objective_completed.emit(objective_id)

		# Trigger objective complete dialogues
		_trigger_objective_dialogues(objective_id)

		# Check if chapter is complete
		_check_chapter_completion()

## Check if all chapter objectives are complete
func _check_chapter_completion():
	var objectives = get_chapter_objectives()
	if objectives.is_empty():
		return

	var all_complete = true
	for obj in objectives:
		if not is_objective_complete(obj.get("id", "")):
			all_complete = false
			break

	if all_complete:
		_complete_chapter()

## Complete current chapter
func _complete_chapter():
	if not current_chapter_id.is_empty() and current_chapter_id not in completed_chapters:
		completed_chapters.append(current_chapter_id)
		print("[StorySystem] Chapter completed: ", current_chapter_id)

		# Trigger chapter complete dialogues
		_trigger_dialogues_by_type("chapter_complete")

		# Grant completion rewards
		_grant_completion_rewards()

		chapter_completed.emit(current_chapter_id)

		# Move to next chapter
		_load_next_chapter()

## Grant completion rewards
func _grant_completion_rewards():
	if not chapter_data.has("completion"):
		return

	var completion = chapter_data["completion"]
	if completion.has("rewards"):
		var rewards = completion["rewards"]

		# Grant materials
		if rewards.has("materials"):
			ResourceSystem.add_materials(rewards["materials"])
			print("[StorySystem] Granted %d Materials" % rewards["materials"])

		# Grant fuel
		if rewards.has("fuel"):
			ResourceSystem.add_fuel(rewards["fuel"])
			print("[StorySystem] Granted %d Fuel" % rewards["fuel"])

		# Grant GMP
		if rewards.has("gmp"):
			ResourceSystem.add_gmp(rewards["gmp"])
			print("[StorySystem] Granted %d GMP" % rewards["gmp"])

## Load next chapter
func _load_next_chapter():
	if not chapter_data.has("completion"):
		return

	var completion = chapter_data["completion"]
	if completion.has("next_chapter"):
		var next_chapter = completion["next_chapter"]
		# Check if next_chapter is null (end of story) or a valid string
		if next_chapter == null or next_chapter == "":
			print("[StorySystem] Story complete - no next chapter")
			return
		print("[StorySystem] Loading next chapter: ", next_chapter)
		load_chapter(next_chapter)

## Get dialogue by ID
func get_dialogue(dialogue_id: String) -> Dictionary:
	if chapter_data.is_empty():
		return {}

	if not chapter_data.has("dialogues"):
		return {}

	for dialogue in chapter_data["dialogues"]:
		if dialogue["id"] == dialogue_id:
			return dialogue

	return {}

## Show dialogue
func show_dialogue(dialogue_id: String):
	var dialogue_data = get_dialogue(dialogue_id)
	if not dialogue_data.is_empty():
		_show_dialogue_with_data(dialogue_data)

## Show dialogue with data
func _show_dialogue_with_data(dialogue_data: Dictionary):
	# Find DialogueBox in scene
	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")
	if not dialogue_box:
		# Try to find it as a child of Main
		var main = get_tree().get_first_node_in_group("main")
		if main:
			dialogue_box = main.get_node_or_null("DialogueBox")

	if not dialogue_box:
		push_error("[StorySystem] DialogueBox not found in scene")
		return

	# Get dialogue data
	var speaker = dialogue_data.get("speaker", "Unknown")
	var text = dialogue_data.get("text", "")
	var choices = dialogue_data.get("choices", [])

	# Show dialogue
	dialogue_box.show_dialogue(speaker, text, choices, _on_dialogue_closed, _on_dialogue_choice)

## Handle dialogue closed
func _on_dialogue_closed():
	print("[StorySystem] Dialogue closed")

## Handle dialogue choice
func _on_dialogue_choice(index: int, choice_data: Dictionary):
	print("[StorySystem] Dialogue choice: ", index)

## Set story flag
func set_flag(flag_name: String, value: Variant):
	story_flags[flag_name] = value

## Get story flag
func get_flag(flag_name: String, default_value: Variant = null) -> Variant:
	return story_flags.get(flag_name, default_value)

## Check story flag
func has_flag(flag_name: String) -> bool:
	return story_flags.has(flag_name)

## Reset all story progress
func reset_story():
	current_chapter_id = ""
	chapter_data = {}
	completed_chapters = []
	story_flags = {}
	print("[StorySystem] Story progress reset")

## Trigger dialogues by type
func _trigger_dialogues_by_type(trigger_type: String):
	if chapter_data.is_empty():
		return

	if not chapter_data.has("dialogues"):
		return

	for dialogue in chapter_data["dialogues"]:
		if dialogue.get("trigger", "") == trigger_type:
			_show_dialogue_with_data(dialogue)

## Trigger dialogues for objective completion
func _trigger_objective_dialogues(objective_id: String):
	if chapter_data.is_empty():
		return

	if not chapter_data.has("dialogues"):
		return

	for dialogue in chapter_data["dialogues"]:
		if dialogue.get("trigger", "") == "objective_complete":
			if dialogue.get("trigger_objective", "") == objective_id:
				_show_dialogue_with_data(dialogue)
