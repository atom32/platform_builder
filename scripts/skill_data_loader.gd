extends Node
class_name SkillDataLoader

## Loads staff skills from JSON files

## Load all skills data
func load_skills() -> Dictionary:
	return _load_json_file("res://data/staff/skills.json")

## Get department skills
func get_department_skills(department: String) -> Array:
	var skills = load_skills()

	if skills.is_empty() or not skills.has("skills"):
		return []

	if not skills["skills"].has(department):
		return []

	return skills["skills"][department]

## Get skills at specific level for a department
func get_skills_at_level(department: String, level: int) -> Array:
	var all_skills = get_department_skills(department)
	var unlocked: Array = []

	for skill in all_skills:
		if skill["required_level"] <= level:
			unlocked.append(skill)

	return unlocked

## Get skill by ID
func get_skill_by_id(skill_id: String) -> Dictionary:
	var skills = load_skills()

	if skills.is_empty() or not skills.has("skills"):
		return {}

	for department in skills["skills"]:
		for skill in skills["skills"][department]:
			if skill["id"] == skill_id:
				return skill

	return {}

## Load JSON file safely
func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		print("[SkillDataLoader] WARNING: File not found: %s" % path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("[SkillDataLoader] WARNING: Failed to open file: %s" % path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		print("[SkillDataLoader] ERROR: Failed to parse JSON from %s" % path)
		print("  Error: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return {}

	var data = json.data
	if not data is Dictionary:
		print("[SkillDataLoader] ERROR: JSON data is not a Dictionary")
		return {}

	return data
