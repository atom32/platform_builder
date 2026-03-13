extends Node

## Save System
## Manages game save/load functionality with support for both Story Mode and Sandbox Mode

## Save file paths
const SAVE_DIR = "user://saves/"
const STORY_MODE_DIR = "story/"
const SANDBOX_MODE_DIR = "sandbox/"

## Save file version
const SAVE_VERSION = 1

## Maximum save slots per mode
const MAX_SAVE_SLOTS = 3

func _ready():
	print("[SaveSystem] Initialized")

	# Create save directories if they don't exist
	_ensure_save_directories()

## Ensure save directories exist
func _ensure_save_directories():
	DirAccess.make_dir_absolute(SAVE_DIR)
	DirAccess.make_dir_absolute(SAVE_DIR + STORY_MODE_DIR)
	DirAccess.make_dir_absolute(SAVE_DIR + SANDBOX_MODE_DIR)

## Get save file path for a slot
func _get_save_path(slot: int, mode: int) -> String:  # mode: 0 = SANDBOX, 1 = STORY
	var mode_dir = STORY_MODE_DIR if mode == 1 else SANDBOX_MODE_DIR
	return SAVE_DIR + mode_dir + "save_%d.json" % slot

## Check if a save slot exists
func has_save(slot: int, mode: int) -> bool:
	var save_path = _get_save_path(slot, mode)
	return FileAccess.file_exists(save_path)

## Get save metadata for a slot
func get_save_info(slot: int, mode: int) -> Dictionary:
	if not has_save(slot, mode):
		return {}

	var save_path = _get_save_path(slot, mode)
	var json_file = FileAccess.open(save_path, FileAccess.READ)
	if not json_file:
		return {}

	var json_text = json_file.get_as_text()
	json_file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		return {}

	var data = json.data
	if data.has("metadata"):
		return data["metadata"]

	return {}

## Save game to slot
func save_game(slot: int, mode: int) -> bool:
	print("[SaveSystem] Saving game to slot %d (mode: %s)" % [slot, "Story" if mode == 1 else "Sandbox"])

	# Collect save data
	var save_data = _collect_save_data(mode)

	# Serialize to JSON
	var json_string = JSON.stringify(save_data, "\t")

	# Write to file
	var save_path = _get_save_path(slot, mode)
	var json_file = FileAccess.open(save_path, FileAccess.WRITE)
	if not json_file:
		push_error("[SaveSystem] Failed to open save file for writing: " + save_path)
		return false

	json_file.store_string(json_string)
	json_file.close()

	print("[SaveSystem] Game saved successfully to: " + save_path)
	return true

## Load game from slot
func load_game(slot: int, mode: int) -> bool:
	print("[SaveSystem] Loading game from slot %d (mode: %s)" % [slot, "Story" if mode == 1 else "Sandbox"])

	if not has_save(slot, mode):
		push_error("[SaveSystem] No save file found for slot %d" % slot)
		return false

	var save_path = _get_save_path(slot, mode)
	var json_file = FileAccess.open(save_path, FileAccess.READ)
	if not json_file:
		push_error("[SaveSystem] Failed to open save file for reading: " + save_path)
		return false

	var json_text = json_file.get_as_text()
	json_file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("[SaveSystem] Failed to parse save file JSON")
		return false

	var save_data = json.data

	# Migrate save data if needed
	save_data = _migrate_save(save_data)

	# Apply save data to game systems
	_apply_save_data(save_data)

	print("[SaveSystem] Game loaded successfully from: " + save_path)
	return true

## Delete save slot
func delete_save(slot: int, mode: int) -> bool:
	print("[SaveSystem] Deleting save slot %d (mode: %s)" % [slot, "Story" if mode == 1 else "Sandbox"])

	if not has_save(slot, mode):
		return false

	var save_path = _get_save_path(slot, mode)
	var error = DirAccess.remove_absolute(save_path)
	if error != OK:
		push_error("[SaveSystem] Failed to delete save file: " + save_path)
		return false

	print("[SaveSystem] Save file deleted: " + save_path)
	return true

## Collect save data from all systems
func _collect_save_data(mode: int) -> Dictionary:
	var data = {
		"version": SAVE_VERSION,
		"metadata": {
			"mode": "story" if mode == 1 else "sandbox",
			"save_time": Time.get_datetime_string_from_system(),
			"save_timestamp": Time.get_unix_time_from_system()
		}
	}

	# Collect resources
	data["resources"] = {
		"materials": ResourceSystem.get_materials(),
		"fuel": ResourceSystem.get_fuel(),
		"gmp": ResourceSystem.get_gmp(),
		"staff_count": ResourceSystem.get_staff_count(),
		"bed_capacity": ResourceSystem.get_bed_capacity()
	}

	# Collect GameSession data
	var game_session = get_node_or_null("/root/GameSession")
	if game_session:
		data["session"] = {
			"days_survived": game_session.days_survived,
			"platforms_built": game_session.platforms_built,
			"staff_recruited": game_session.staff_recruited,
			"expeditions_sent": game_session.expeditions_sent
		}

	# Collect StorySystem data (only in Story Mode)
	if mode == 1:
		var story_system = get_node_or_null("/root/StorySystem")
		if story_system:
			data["story_progress"] = {
				"current_chapter": story_system.current_chapter_id,
				"completed_chapters": story_system.completed_chapters,
				"story_flags": story_system.story_flags
			}
			data["metadata"]["chapter_id"] = story_system.current_chapter_id
			data["metadata"]["chapter_name"] = story_system.get_chapter_name()

	# Collect Base data (platform tree)
	var base = get_tree().get_first_node_in_group("base")
	if base:
		data["base"] = _serialize_base(base)

	# Collect DepartmentSystem data
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		data["departments"] = _serialize_departments(dept_system)

	return data

## Serialize Base system
func _serialize_base(base: Base) -> Dictionary:
	var data = {
		"platforms": []
	}

	var hq = base.hq_platform
	if hq:
		data["platforms"] = [_serialize_platform(hq)]

	return data

## Serialize a platform recursively
func _serialize_platform(platform: Platform) -> Dictionary:
	var data = {
		"type": platform.platform_type,
		"level": platform.level,
		"position": {
			"x": platform.global_position.x,
			"y": platform.global_position.y,
			"z": platform.global_position.z
		},
		"children": []
	}

	for child in platform.child_platforms:
		data["children"].append(_serialize_platform(child))

	return data

## Serialize DepartmentSystem
func _serialize_departments(dept_system: Node) -> Dictionary:
	var data = {
		"staff_list": []
	}

	for staff in dept_system.staff_list:
		data["staff_list"].append({
			"id": staff.id,
			"first_name": staff.first_name,
			"last_name": staff.last_name,
			"department": staff.department,
			"skill_level": staff.skill_level,
			"specialty": staff.specialty
		})

	data["next_staff_id"] = dept_system.next_staff_id

	return data

## Apply save data to game systems
func _apply_save_data(data: Dictionary):
	# Apply resources
	if data.has("resources"):
		var res = data["resources"]
		ResourceSystem.reset_resources()
		ResourceSystem.add_materials(res.get("materials", 0))
		ResourceSystem.add_fuel(res.get("fuel", 0))
		ResourceSystem.add_gmp(res.get("gmp", 0))

	# Apply GameSession data
	if data.has("session"):
		var game_session = get_node_or_null("/root/GameSession")
		if game_session:
			var sess = data["session"]
			game_session.days_survived = sess.get("days_survived", 0)
			game_session.platforms_built = sess.get("platforms_built", 0)
			game_session.staff_recruited = sess.get("staff_recruited", 0)
			game_session.expeditions_sent = sess.get("expeditions_sent", 0)

	# Apply StorySystem data
	if data.has("story_progress"):
		var story_system = get_node_or_null("/root/StorySystem")
		if story_system:
			var story = data["story_progress"]
			story_system.current_chapter_id = story.get("current_chapter", "")
			story_system.completed_chapters = story.get("completed_chapters", [])
			story_system.story_flags = story.get("story_flags", {})

			# Reload chapter data
			if not story_system.current_chapter_id.is_empty():
				story_system.load_chapter(story_system.current_chapter_id)

	# Note: Base and DepartmentSystem restoration would need to be implemented
	# This requires respawning platforms and recreating staff entities
	print("[SaveSystem] Save data applied (platform restoration not yet implemented)")

## Migrate save data to current version
func _migrate_save(data: Dictionary) -> Dictionary:
	var version = data.get("version", 0)

	if version < SAVE_VERSION:
		print("[SaveSystem] Migrating save from version %d to %d" % [version, SAVE_VERSION])
		# Add migration logic here when version changes

		data["version"] = SAVE_VERSION

	return data
