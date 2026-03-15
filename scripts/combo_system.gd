extends Node
class_name ComboSystem

## Manages combo detection and bonuses between platforms

## Signals
signal combo_activated(combo_name: String, bonus: float, position: Vector3)

## Active combos dictionary
var active_combos: Dictionary = {}

## Check all platforms for active combos
func check_combos(all_platforms: Array[Platform]) -> Dictionary:
	var previous_combos = active_combos.duplicate()
	active_combos.clear()

	# Reset all platform production bonuses
	for platform in all_platforms:
		platform.production_bonus = 1.0

	# Use a set to track checked platform pairs and avoid duplicates
	var checked_pairs: Dictionary = {}

	for platform in all_platforms:
		var neighbors = platform.get_neighbors(all_platforms)

		for neighbor in neighbors:
			# Skip if we've already checked this pair
			var pair_id = _generate_combo_id(platform, neighbor)
			if checked_pairs.has(pair_id):
				continue
			checked_pairs[pair_id] = true

			# Check if this pair creates a combo (pass platform types, not tags)
			var combo = PlatformData.check_combo(platform.platform_type, neighbor.platform_type)
			if not combo.is_empty():
				active_combos[pair_id] = {
					"platform_a": platform,
					"platform_b": neighbor,
					"combo_data": combo
				}

				# Apply resource production bonus to both platforms
				if combo["effect_type"] == "resource_production":
					platform.production_bonus += combo["bonus"]
					neighbor.production_bonus += combo["bonus"]

				# Check if this is a new combo
				if not previous_combos.has(pair_id):
					var combo_name = combo["description"]
					var bonus = combo["bonus"]
					var position = (platform.global_position + neighbor.global_position) / 2.0
					combo_activated.emit(combo_name, bonus, position)

	return active_combos

## Generate unique ID for a combo pair
func _generate_combo_id(platform_a: Platform, platform_b: Platform) -> String:
	# Use instance ID for unique identification (guaranteed to be unique)
	var id_a = platform_a.get_instance_id()
	var id_b = platform_b.get_instance_id()

	# Sort to ensure A-B and B-A generate same ID
	if id_a < id_b:
		return "%d_%d" % [id_a, id_b]
	else:
		return "%d_%d" % [id_b, id_a]

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

## Get resource production bonus for a specific platform
func get_platform_production_bonus(platform: Platform, all_platforms: Array[Platform]) -> float:
	var bonus: float = 0.0
	var neighbors = platform.get_neighbors(all_platforms)

	for neighbor in neighbors:
		# Check if this pair creates a resource production combo (pass platform types, not tags)
		var combo = PlatformData.check_combo(platform.platform_type, neighbor.platform_type)
		if not combo.is_empty() and combo["effect_type"] == "resource_production":
			bonus += combo["bonus"]

	return bonus

## Print all active combos (for debugging)
func print_active_combos():
	if active_combos.is_empty():
		return

	var combo_list = []
	for combo_id in active_combos:
		var combo = active_combos[combo_id]
		combo_list.append("%s + %s (+%.0f%%)" % [
			combo["platform_a"].platform_type,
			combo["platform_b"].platform_type,
			combo["combo_data"]["bonus"] * 100
		])
	ResourceSystem.debug_print("Active combos: %s" % ", ".join(combo_list))
