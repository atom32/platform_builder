extends Node
class_name DungeonDataLoader

## Loads dungeon data from JSON files

## Load enemy definitions
func load_enemies() -> Dictionary:
	return _load_json_file("res://data/dungeons/enemies.json")

## Load dungeon templates
func load_dungeon_templates() -> Dictionary:
	return _load_json_file("res://data/dungeons/dungeon_templates.json")

## Load debuff types
func load_debuff_types() -> Dictionary:
	return _load_json_file("res://data/combat/debuff_types.json")

## Get enemy pool for specific layer and difficulty
func get_enemy_pool(layer: int, difficulty: String) -> Array:
	var templates = load_dungeon_templates()

	if templates.is_empty() or not templates.has("templates"):
		print("[DungeonDataLoader] WARNING: No dungeon templates found")
		return []

	if not templates["templates"].has(difficulty):
		print("[DungeonDataLoader] WARNING: Difficulty %s not found" % difficulty)
		return []

	return templates["templates"][difficulty]

## Get random enemy for layer
func get_random_enemy(layer: int, difficulty: String) -> Dictionary:
	var enemy_pool = get_enemy_pool(layer, difficulty)

	if enemy_pool.is_empty():
		# Fallback enemy
		return {
			"enemy_id": "mutated_fish",
			"weight": 1.0
		}

	# Weighted random selection
	var total_weight = 0.0
	for enemy_entry in enemy_pool:
		total_weight += enemy_entry.get("weight", 1.0)

	var random_value = randf() * total_weight
	var current_weight = 0.0

	for enemy_entry in enemy_pool:
		current_weight += enemy_entry.get("weight", 1.0)
		if random_value <= current_weight:
			return enemy_entry

	# Fallback to first enemy
	return enemy_pool[0]

## Get full enemy data by ID
func get_enemy_data(enemy_id: String) -> Dictionary:
	var enemies = load_enemies()

	if enemies.is_empty() or not enemies.has("enemies"):
		return {}

	for enemy in enemies["enemies"]:
		if enemy["id"] == enemy_id:
			return enemy

	return {}

## Load JSON file safely
func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		print("[DungeonDataLoader] WARNING: File not found: %s" % path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("[DungeonDataLoader] WARNING: Failed to open file: %s" % path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		print("[DungeonDataLoader] ERROR: Failed to parse JSON from %s" % path)
		print("  Error: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return {}

	var data = json.data
	if not data is Dictionary:
		print("[DungeonDataLoader] ERROR: JSON data is not a Dictionary")
		return {}

	return data
