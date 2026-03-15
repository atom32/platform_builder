# scripts/expedition_data_loader.gd
# Loads expedition mission definitions from JSON files.
# Externalizes hardcoded mission data for balance adjustments.

extends DataLoader

## Load all expedition missions
func load_missions() -> Dictionary:
	var data = load_json_file("expeditions/missions.json")

	if data.is_empty():
		push_error("[ExpeditionDataLoader] Failed to load missions")
		return {}

	if not data.has("missions"):
		push_error("[ExpeditionDataLoader] Invalid missions format: missing 'missions'")
		return {}

	return data

## Get specific mission data by mission ID
func get_mission_data(mission_id: String) -> Dictionary:
	var all_data = load_missions()

	if all_data.is_empty():
		return {}

	for mission in all_data["missions"]:
		if mission.has("id") and mission["id"] == mission_id:
			return mission

	push_error("[ExpeditionDataLoader] Mission not found: %s" % mission_id)
	return {}

## Get all mission IDs
func get_mission_ids() -> Array:
	var all_data = load_missions()
	var ids: Array = []

	if all_data.has("missions"):
		for mission in all_data["missions"]:
			if mission.has("id"):
				ids.append(mission["id"])

	return ids

## Get available missions for specific combat power level
## Returns array of mission IDs that meet requirements
func get_available_missions(combat_power: int) -> Array:
	var all_data = load_missions()
	var available: Array = []

	if all_data.has("missions"):
		for mission in all_data["missions"]:
			if mission.has("id") and mission.has("required_combat_power"):
				if combat_power >= mission["required_combat_power"]:
					available.append(mission["id"])

	return available
