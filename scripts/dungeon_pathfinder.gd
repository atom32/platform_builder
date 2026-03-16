extends Node
class_name DungeonPathfinder

## Helper class for calculating dungeon paths and difficulty

## Get path from HQ to target platform
static func get_path_to_hq(target_platform: Platform) -> Array[Platform]:
	var path: Array[Platform] = []
	var current: Platform = target_platform

	# Walk up the tree to HQ
	while current != null:
		path.push_front(current)
		current = current.get_parent_platform()

	return path

## Calculate dungeon difficulty based on path
static func calculate_difficulty(path: Array[Platform]) -> Dictionary:
	var layers = path.size() - 1  # Exclude HQ itself
	var difficulty = "easy"

	# Determine difficulty based on depth
	if layers >= 5:
		difficulty = "hard"
	elif layers >= 3:
		difficulty = "medium"

	return {
		"layers": layers,
		"difficulty": difficulty,
		"estimated_time": 15 * layers  # 15 seconds per layer
	}

## Get path as readable string
static func get_path_string(path: Array[Platform]) -> String:
	var path_names: Array[String] = []
	for platform in path:
		path_names.append(platform.platform_type)
	return " -> ".join(path_names)

## Calculate recommended staff count based on difficulty
static func get_recommended_staff(difficulty: String) -> int:
	match difficulty:
		"easy":
			return 2
		"medium":
			return 3
		"hard":
			return 4
		_:
			return 2
