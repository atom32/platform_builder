extends Node

## Manages platform departments with capacity limits and staff assignments

## Maximum platforms per department
const MAX_PLATFORMS_PER_DEPT: int = 6

## Department tracking - stores platforms per department
var departments = {
	"R&D": [],
	"Combat": [],
	"Support": [],
	"Intel": [],
	"Medical": []
}

## Department platform counts for quick lookup
var department_counts = {
	"R&D": 0,
	"Combat": 0,
	"Support": 0,
	"Intel": 0,
	"Medical": 0
}

## Staff assignments per department
var department_staff = {
	"R&D": 0,
	"Combat": 0,
	"Support": 0,
	"Intel": 0,
	"Medical": 0
}

## Department bonuses
const RESEARCH_SPEED_BONUS_PER_STAFF: float = 0.1  # 10% per staff
const COMBAT_POWER_BONUS_PER_STAFF: float = 0.5   # 0.5 per staff

func _ready():
	print("Department System initialized")

## Check if a department can accept a new platform
func can_build(department_type: String) -> bool:
	if not departments.has(department_type):
		push_error("Unknown department type: %s" % department_type)
		return false

	var count = department_counts[department_type]
	if count >= MAX_PLATFORMS_PER_DEPT:
		print("%s department is full (%d/%d)" % [department_type, count, MAX_PLATFORMS_PER_DEPT])
		return false

	return true

## Register a platform to its department
func register_platform(platform: Platform):
	var dept_type = platform.get_type()
	if not departments.has(dept_type):
		push_error("Unknown department type: %s" % dept_type)
		return

	departments[dept_type].append(platform)
	department_counts[dept_type] += 1

	print("Registered %s platform to %s department (%d/%d)" % [
		dept_type, dept_type, department_counts[dept_type], MAX_PLATFORMS_PER_DEPT
	])

## Get current count for a department
func get_department_count(department_type: String) -> int:
	if department_counts.has(department_type):
		return department_counts[department_type]
	return 0

## Get all platforms in a department
func get_department_platforms(department_type: String) -> Array:
	if departments.has(department_type):
		return departments[department_type]
	return []

## Check if department is at capacity
func is_department_full(department_type: String) -> bool:
	return get_department_count(department_type) >= MAX_PLATFORMS_PER_DEPT

## Get remaining slots in a department
func get_remaining_slots(department_type: String) -> int:
	if not department_counts.has(department_type):
		return 0
	return MAX_PLATFORMS_PER_DEPT - department_counts[department_type]

## Get total platforms across all departments
func get_total_platform_count() -> int:
	var total = 0
	for count in department_counts.values():
		total += count
	return total

## ===== STAFF MANAGEMENT =====

## Assign staff to a department
func assign_staff(department_type: String, count: int) -> bool:
	if not department_staff.has(department_type):
		push_error("Unknown department type: %s" % department_type)
		return false

	# Check if we have enough unassigned staff
	var current_total = get_total_staff()
	var available = ResourceSystem.get_staff_count() - current_total

	if count > available:
		print("Cannot assign %d staff to %s: Only %d unassigned staff available" % [count, department_type, available])
		return false

	department_staff[department_type] += count
	print("Assigned %d staff to %s department (total: %d)" % [count, department_type, department_staff[department_type]])
	return true

## Remove staff from a department
func remove_staff(department_type: String, count: int) -> bool:
	if not department_staff.has(department_type):
		push_error("Unknown department type: %s" % department_type)
		return false

	if department_staff[department_type] < count:
		print("Cannot remove %d staff from %s: Only %d assigned" % [count, department_type, department_staff[department_type]])
		return false

	department_staff[department_type] -= count
	print("Removed %d staff from %s department (total: %d)" % [count, department_type, department_staff[department_type]])
	return true

## Get staff count for a specific department
func get_department_staff(department_type: String) -> int:
	if department_staff.has(department_type):
		return department_staff[department_type]
	return 0

## Get total assigned staff across all departments
func get_total_staff() -> int:
	var total = 0
	for count in department_staff.values():
		total += count
	return total

## Get unassigned staff
func get_unassigned_staff() -> int:
	return ResourceSystem.get_staff_count() - get_total_staff()

## ===== DEPARTMENT BONUSES =====

## Calculate research speed bonus from R&D staff
## Returns multiplier (1.0 = no bonus, 1.5 = 50% bonus)
func get_research_speed_multiplier() -> float:
	var rd_staff = get_department_staff("R&D")
	var bonus = rd_staff * RESEARCH_SPEED_BONUS_PER_STAFF

	# Apply efficiency penalty if upkeep wasn't paid
	if ResourceSystem.efficiency_penalty:
		bonus *= 0.5  # 50% penalty

	return 1.0 + bonus

## Calculate combat power bonus from Combat staff
## Returns additional combat power
func get_combat_power_bonus() -> int:
	var combat_staff = get_department_staff("Combat")
	var bonus = combat_staff * COMBAT_POWER_BONUS_PER_STAFF

	# Apply efficiency penalty if upkeep wasn't paid
	if ResourceSystem.efficiency_penalty:
		bonus *= 0.5  # 50% penalty

	return int(bonus)

## Get department info string for UI
func get_department_info() -> Dictionary:
	return {
		"R&D": department_staff["R&D"],
		"Combat": department_staff["Combat"],
		"Support": department_staff["Support"],
		"Intel": department_staff["Intel"],
		"Medical": department_staff["Medical"],
		"Unassigned": get_unassigned_staff()
	}
