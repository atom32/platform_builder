extends Node
class_name ComboSystem

## Manages combo detection and bonuses between platforms

## Active combos dictionary
var active_combos: Dictionary = {}

## Check all platforms for active combos
func check_combos(all_platforms: Array[Platform]) -> Dictionary:
	active_combos.clear()

	for platform in all_platforms:
		var neighbors = platform.get_neighbors(all_platforms)
		var platform_tags = platform.get_tags()

		for neighbor in neighbors:
			var neighbor_tags = neighbor.get_tags()

			# Check if this pair creates a combo
			var combo = PlatformData.check_combo(platform_tags, neighbor_tags)
			if not combo.is_empty():
				var combo_id = _generate_combo_id(platform, neighbor)

				# Avoid duplicate combos (A-B same as B-A)
				if not active_combos.has(combo_id):
					active_combos[combo_id] = {
						"platform_a": platform,
						"platform_b": neighbor,
						"combo_data": combo
					}

	return active_combos

## Generate unique ID for a combo pair
func _generate_combo_id(platform_a: Platform, platform_b: Platform) -> String:
	var name_a = platform_a.name
	var name_b = platform_b.name

	# Sort alphabetically to ensure A-B and B-A generate same ID
	if name_a < name_b:
		return "%s_%s" % [name_a, name_b]
	else:
		return "%s_%s" % [name_b, name_a]

## Get all active combos
func get_active_combos() -> Dictionary:
	return active_combos

## Get combo count
func get_combo_count() -> int:
	return active_combos.size()

## Get total bonus for a specific effect type
func get_total_bonus(effect_type: String) -> float:
	var total_bonus: float = 0.0

	for combo_id in active_combos:
		var combo = active_combos[combo_id]
		if combo["combo_data"]["effect_type"] == effect_type:
			total_bonus += combo["combo_data"]["bonus"]

	return total_bonus

## Print all active combos (for debugging)
func print_active_combos():
	if active_combos.is_empty():
		print("No active combos")
		return

	print("=== Active Combos (%d) ===" % active_combos.size())
	for combo_id in active_combos:
		var combo = active_combos[combo_id]
		var platform_a = combo["platform_a"]
		var platform_b = combo["combo_data"]["description"]
		print("  %s + %s: %s (+%.0f%%)" % [
			platform_a.platform_type,
			combo["platform_b"].platform_type,
			combo["combo_data"]["description"],
			combo["combo_data"]["bonus"] * 100
		])
	print("==========================")
