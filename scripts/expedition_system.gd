extends Node
class_name ExpeditionManager

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
		"gmp_reward": 30,
		"recruit_reward": 0,
		"required_combat_power": 2,
		"difficulty": "Easy"
	},
	"resource_scavenge": {
		"display_name": "Resource Scavenge",
		"description": "Scavenge for resources in the area",
		"duration": 45,
		"materials_reward": 80,
		"fuel_reward": 30,
		"gmp_reward": 20,
		"recruit_reward": 0,
		"required_combat_power": 1,
		"difficulty": "Easy"
	},
	"intel_gathering": {
		"display_name": "Intel Gathering",
		"description": "Gather intelligence from the region",
		"duration": 90,
		"materials_reward": 50,
		"fuel_reward": 60,
		"gmp_reward": 40,
		"recruit_reward": 1,
		"required_combat_power": 3,
		"difficulty": "Medium"
	},
	"heavy_assault": {
		"display_name": "Heavy Assault",
		"description": "Launch a major assault operation",
		"duration": 120,
		"materials_reward": 200,
		"fuel_reward": 100,
		"gmp_reward": 80,
		"recruit_reward": 2,
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

	# Add department staff bonuses
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		var combat_staff = dept_system.get_department_staff("Combat")
		var staff_bonus = int(combat_staff * COMBAT_POWER_BONUS_PER_STAFF)
		combat_power += staff_bonus

	# Add combo bonuses
	if base_system.combo_system:
		var combat_bonus = base_system.combo_system.get_total_bonus("expedition_strength")
		var bonus_amount = int(combat_power * combat_bonus)
		combat_power += bonus_amount

	return combat_power

## Calculate expedition success chance (Intel department contribution)
func calculate_success_chance() -> float:
	var base_chance: float = 0.5  # 50% base chance

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		var intel_staff = dept_system.get_department_staff("Intel")
		var intel_bonus = intel_staff * 0.05  # 5% per Intel staff
		base_chance += intel_bonus

	return min(base_chance, 0.95)  # Max 95%

## Calculate resource yield bonus (Support department contribution)
func calculate_resource_yield_multiplier() -> float:
	var base_multiplier: float = 1.0

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		var support_staff = dept_system.get_department_staff("Support")
		var support_bonus = support_staff * 0.1  # 10% per Support staff
		base_multiplier += support_bonus

	return min(base_multiplier, 2.0)  # Max 200%

## Calculate casualty reduction (Medical department contribution)
func calculate_casualty_reduction_chance() -> float:
	var base_chance: float = 0.0

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		var medical_staff = dept_system.get_department_staff("Medical")
		base_chance = medical_staff * 0.15  # 15% per Medical staff

	return min(base_chance, 0.9)  # Max 90%

## Calculate duration reduction (R&D department contribution)
func calculate_duration_reduction() -> float:
	var base_reduction: float = 0.0

	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		var rd_staff = dept_system.get_department_staff("R&D")
		base_reduction = rd_staff * 0.02  # 2% per R&D staff

	return min(base_reduction, 0.5)  # Max 50% reduction

const COMBAT_POWER_BONUS_PER_STAFF: float = 0.5

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

	# Calculate modified duration (R&D bonus)
	var base_duration = mission["duration"]
	var duration_reduction = calculate_duration_reduction()
	var final_duration = int(base_duration * (1.0 - duration_reduction))

	# Start expedition
	var expedition_data = {
		"mission_id": mission_id,
		"start_time": Time.get_unix_time_from_system(),
		"duration": final_duration,
		"base_duration": base_duration,
		"rewards": {
			"materials": mission["materials_reward"],
			"fuel": mission["fuel_reward"],
			"gmp": mission.get("gmp_reward", 20),  # Default 20 GMP
			"recruits": mission.get("recruit_reward", 0)  # Optional recruits
		}
	}

	active_expeditions[mission_id] = expedition_data

	print("==================================================")
	print("EXPEDITION LAUNCHED: %s" % mission["display_name"])
	print("  Duration: %d seconds (R&D bonus: -%d%%)" % [
		final_duration, int(duration_reduction * 100)
	])
	print("  Combat Power: %d (required: %d)" % [
		current_combat_power, mission["required_combat_power"]
	])
	print("  Success Chance: %d%%" % int(calculate_success_chance() * 100))
	print("  Resource Yield: %d%%" % int(calculate_resource_yield_multiplier() * 100))
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
	var mission = mission_data[mission_id]
	var base_rewards = expedition["rewards"]

	# Roll for success/failure
	var success_chance = calculate_success_chance()
	var success_roll = randf()

	var result_type: String = "success"
	var reward_multiplier: float = 1.0
	var casualties: int = 0

	if success_roll < success_chance * 0.5:
		# Complete success
		result_type = "success"
		reward_multiplier = calculate_resource_yield_multiplier()
	elif success_roll < success_chance:
		# Partial success
		result_type = "partial_success"
		reward_multiplier = calculate_resource_yield_multiplier() * 0.5
	else:
		# Failure
		result_type = "failure"
		reward_multiplier = 0.0
		# Check for casualties
		var casualty_reduction = calculate_casualty_reduction_chance()
		var casualty_roll = randf()
		if casualty_roll > casualty_reduction:
			casualties = 1

	# Apply rewards
	var final_materials = int(base_rewards["materials"] * reward_multiplier)
	var final_fuel = int(base_rewards["fuel"] * reward_multiplier)
	var final_gmp = int(base_rewards.get("gmp", 20) * reward_multiplier)

	if result_type != "failure":
		ResourceSystem.add_materials(final_materials)
		ResourceSystem.add_fuel(final_fuel)
		ResourceSystem.add_gmp(final_gmp)

		# Award recruits if any
		var recruits = base_rewards.get("recruits", 0)
		if recruits > 0 and result_type == "success":
			var dept_system = get_node_or_null("/root/DepartmentSystem")
			if dept_system:
				for i in range(recruits):
					dept_system.add_staff()

	# Handle casualties
	if casualties > 0:
		_remove_random_staff()

	# Print results
	print("==================================================")
	print("EXPEDITION %s: %s" % [result_type.to_upper(), mission["display_name"]])

	if result_type == "success":
		print("  Rewards Received:")
		print("    Materials: +%d" % final_materials)
		print("    Fuel: +%d" % final_fuel)
		print("    GMP: +%d" % final_gmp)
		if base_rewards.get("recruits", 0) > 0:
			print("    Recruits: +%d" % base_rewards["recruits"])
	elif result_type == "partial_success":
		print("  Partial Rewards:")
		print("    Materials: +%d" % final_materials)
		print("    Fuel: +%d" % final_fuel)
		print("    GMP: +%d" % final_gmp)
	else:
		print("  Mission Failed!")
		print("  No resources recovered")

	if casualties > 0:
		print("  CASUALTIES: %d staff member(s) lost!" % casualties)

	print("==================================================")

	# Emit signal with full result data
	var result_data = {
		"materials": final_materials,
		"fuel": final_fuel,
		"gmp": final_gmp,
		"result_type": result_type,
		"casualties": casualties
	}
	expedition_completed.emit(mission_id, result_data)

## Get active expedition count
func get_active_expedition_count() -> int:
	return active_expeditions.size()

## Get mission display name
func get_mission_name(mission_id: String) -> String:
	if mission_data.has(mission_id):
		return mission_data[mission_id]["display_name"]
	return "Unknown Mission"

## Get time remaining for an expedition (in seconds)
func get_expedition_time_remaining(mission_id: String) -> int:
	if not active_expeditions.has(mission_id):
		return 0

	var expedition = active_expeditions[mission_id]
	var current_time = Time.get_unix_time_from_system()
	var elapsed_time = current_time - expedition["start_time"]
	var remaining = expedition["duration"] - elapsed_time
	return int(max(0, remaining))

## Remove a random staff member (casualties)
func _remove_random_staff():
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		return

	var staff_list = dept_system.get_all_staff()
	if staff_list.size() == 0:
		return

	# Prefer to remove from combat staff first, then others
	var combat_staff = dept_system.get_staff_in_department("Combat")
	var staff_to_remove = null

	if combat_staff.size() > 0:
		staff_to_remove = combat_staff[randi() % combat_staff.size()]
	else:
		staff_to_remove = staff_list[randi() % staff_list.size()]

	dept_system.remove_staff(staff_to_remove)
	print("Staff casualty: %s (ID: %d) lost in expedition" % [
		staff_to_remove.get_display_name(), staff_to_remove.id
	])

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
