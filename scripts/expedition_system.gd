extends Node
class_name ExpeditionSystem

## Manages expeditions and missions

signal expedition_started(mission_id: String)
signal expedition_completed(mission_id: String, rewards: Dictionary)
signal expedition_failed(mission_id: String, reason: String)

## Mission data (data-driven)
var mission_data: Dictionary = {
	"supply_raid": {
		"display_name": "Supply Raid",
		"description": "Raid enemy supply lines for resources",
		"duration": 60,  # seconds
		"materials_reward": 100,
		"fuel_reward": 40,
		"required_combat_power": 2,
		"difficulty": "Easy"
	},
	"resource_scavenge": {
		"display_name": "Resource Scavenge",
		"description": "Scavenge for resources in the area",
		"duration": 45,
		"materials_reward": 80,
		"fuel_reward": 30,
		"required_combat_power": 1,
		"difficulty": "Easy"
	},
	"intel_gathering": {
		"display_name": "Intel Gathering",
		"description": "Gather intelligence from the region",
		"duration": 90,
		"materials_reward": 50,
		"fuel_reward": 60,
		"required_combat_power": 3,
		"difficulty": "Medium"
	},
	"heavy_assault": {
		"display_name": "Heavy Assault",
		"description": "Launch a major assault operation",
		"duration": 120,
		"materials_reward": 200,
		"fuel_reward": 100,
		"required_combat_power": 5,
		"difficulty": "Hard"
	}
}

## Active expeditions
var active_expeditions: Dictionary = {}

## Reference to base system for combat power calculation
var base_system: Base = null

## Timer for checking expedition completion
var expedition_timer: Timer = null

func _ready():
	# Create timer for checking expedition completion
	expedition_timer = Timer.new()
	expedition_timer.wait_time = 1.0  # Check every second
	expedition_timer.timeout.connect(_on_expedition_timer)
	add_child(expedition_timer)
	expedition_timer.start()

## Set base system reference
func set_base_system(base: Base):
	base_system = base

## Calculate current combat power
func calculate_combat_power() -> int:
	if not base_system:
		return 0

	var combat_power: int = 0

	# Count Combat platforms
	for platform in base_system.all_platforms:
		if platform.platform_type == "Combat":
			combat_power += 1

	# Add combo bonuses
	if base_system.combo_system:
		var combat_bonus = base_system.combo_system.get_total_bonus("expedition_strength")
		var bonus_amount = int(combat_power * combat_bonus)
		combat_power += bonus_amount

	return combat_power

## Get all available missions
func get_available_missions() -> Dictionary:
	var available_missions: Dictionary = {}
	var current_combat_power = calculate_combat_power()

	for mission_id in mission_data:
		var mission = mission_data[mission_id]
		# Mission is available if combat power requirement is met
		if current_combat_power >= mission["required_combat_power"]:
			available_missions[mission_id] = mission

	return available_missions

## Launch an expedition
func launch_expedition(mission_id: String) -> bool:
	if not mission_data.has(mission_id):
		push_error("Invalid mission ID: %s" % mission_id)
		expedition_failed.emit(mission_id, "invalid_mission")
		return false

	var mission = mission_data[mission_id]
	var current_combat_power = calculate_combat_power()

	# Check combat power requirement
	if current_combat_power < mission["required_combat_power"]:
		print("Expedition failed: Not enough combat power (have %d, need %d)" % [
			current_combat_power, mission["required_combat_power"]
		])
		expedition_failed.emit(mission_id, "insufficient_combat_power")
		return false

	# Check if expedition is already active
	if active_expeditions.has(mission_id):
		print("Expedition failed: Mission %s is already active" % mission_id)
		expedition_failed.emit(mission_id, "already_active")
		return false

	# Start expedition
	var expedition_data = {
		"mission_id": mission_id,
		"start_time": Time.get_unix_time_from_system(),
		"duration": mission["duration"],
		"rewards": {
			"materials": mission["materials_reward"],
			"fuel": mission["fuel_reward"]
		}
	}

	active_expeditions[mission_id] = expedition_data

	print("==================================================")
	print("EXPEDITION LAUNCHED: %s" % mission["display_name"])
	print("  Duration: %d seconds" % mission["duration"])
	print("  Combat Power: %d (required: %d)" % [
		current_combat_power, mission["required_combat_power"]
	])
	print("  Rewards: %d Materials, %d Fuel" % [
		mission["materials_reward"], mission["fuel_reward"]
	])
	print("==================================================")

	expedition_started.emit(mission_id)
	return true

## Check expedition completion every second
func _on_expedition_timer():
	var current_time = Time.get_unix_time_from_system()
	var completed_missions: Array = []

	for mission_id in active_expeditions:
		var expedition = active_expeditions[mission_id]
		var elapsed_time = current_time - expedition["start_time"]

		if elapsed_time >= expedition["duration"]:
			# Mission complete!
			_complete_expedition(mission_id, expedition)
			completed_missions.append(mission_id)

	# Remove completed expeditions
	for mission_id in completed_missions:
		active_expeditions.erase(mission_id)

## Complete an expedition and give rewards
func _complete_expedition(mission_id: String, expedition: Dictionary):
	var rewards = expedition["rewards"]

	# Give rewards
	ResourceSystem.add_materials(rewards["materials"])
	ResourceSystem.add_fuel(rewards["fuel"])

	print("==================================================")
	print("EXPEDITION COMPLETED: %s" % mission_data[mission_id]["display_name"])
	print("  Rewards Received:")
	print("    Materials: +%d" % rewards["materials"])
	print("    Fuel: +%d" % rewards["fuel"])
	print("==================================================")

	expedition_completed.emit(mission_id, rewards)

## Get active expedition count
func get_active_expedition_count() -> int:
	return active_expeditions.size()

## Get time remaining for an expedition (in seconds)
func get_expedition_time_remaining(mission_id: String) -> int:
	if not active_expeditions.has(mission_id):
		return 0

	var expedition = active_expeditions[mission_id]
	var current_time = Time.get_unix_time_from_system()
	var elapsed_time = current_time - expedition["start_time"]
	var remaining = expedition["duration"] - elapsed_time

	return max(0, int(remaining))

## Get all active expeditions info
func get_active_expeditions_info() -> Array:
	var info: Array = []

	for mission_id in active_expeditions:
		var expedition = active_expeditions[mission_id]
		var mission = mission_data[mission_id]
		var time_remaining = get_expedition_time_remaining(mission_id)

		info.append({
			"mission_id": mission_id,
			"display_name": mission["display_name"],
			"time_remaining": time_remaining,
			"duration": expedition["duration"],
			"rewards": expedition["rewards"]
		})

	return info

## Get current combat power
func get_combat_power() -> int:
	return calculate_combat_power()

## Get mission data
func get_mission_data(mission_id: String) -> Dictionary:
	if mission_data.has(mission_id):
		return mission_data[mission_id]
	return {}
