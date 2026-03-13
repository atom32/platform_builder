extends Node

## Manages platform departments with capacity limits and staff assignments

## Signals
signal staff_assigned(staff_id: int, department: String)

## Maximum platforms per department
const MAX_PLATFORMS_PER_DEPT: int = 6

## Reference to combo system for adjacency bonuses
var combo_system: ComboSystem = null

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

## Staff assignments per department (for quick lookup)
var department_staff = {
	"R&D": 0,
	"Combat": 0,
	"Support": 0,
	"Intel": 0,
	"Medical": 0
}

## Individual staff tracking
var staff_list: Array = []  # All staff in the base
var next_staff_id: int = 1  # Auto-incrementing ID for new staff

## Department bonuses
const RESEARCH_SPEED_BONUS_PER_STAFF: float = 0.1  # 10% per staff
const COMBAT_POWER_BONUS_PER_STAFF: float = 0.5   # 0.5 per staff

func _ready():
	pass

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

## Add a new staff member (recruitment)
func add_staff():
	var StaffClass = load("res://scripts/staff.gd")
	var new_staff = StaffClass.new(next_staff_id)
	next_staff_id += 1
	staff_list.append(new_staff)
	print("Recruited new staff: %s (ID: %d)" % [new_staff.get_display_name(), new_staff.id])
	return new_staff

## Get all staff in recruit pool (department is empty string)
func get_recruit_pool() -> Array:
	var pool: Array = []
	for staff in staff_list:
		if staff.is_in_recruit_pool():
			pool.append(staff)
	return pool

## Get all staff assigned to a specific department
func get_staff_in_department(department_type: String) -> Array:
	var dept_staff: Array = []
	for staff in staff_list:
		if staff.department == department_type:
			dept_staff.append(staff)
	return dept_staff

## Assign a specific staff member to a department
func assign_staff_member(staff_member, department_type: String) -> bool:
	if not department_staff.has(department_type):
		push_error("Unknown department type: %s" % department_type)
		return false

	# Update staff's department
	staff_member.assign_to_dept(department_type)

	# Update counts
	department_staff[department_type] += 1

	# Emit signal for StorySystem
	staff_assigned.emit(staff_member.id, department_type)

	return true

## Assign staff from recruit pool to a department (by count)
func assign_staff(department_type: String, count: int) -> bool:
	if not department_staff.has(department_type):
		push_error("Unknown department type: %s" % department_type)
		return false

	# Get unassigned staff
	var pool = get_recruit_pool()
	if pool.size() < count:
		print("Cannot assign %d staff to %s: Only %d unassigned staff available" % [count, department_type, pool.size()])
		return false

	# Assign the specified number of staff
	for i in range(count):
		assign_staff_member(pool[i], department_type)

	return true

## Remove a specific staff member from their department (return to pool)
func unassign_staff_member(staff_member) -> bool:
	var old_dept = staff_member.department
	if old_dept == "":
		return false  # Already in pool

	if not department_staff.has(old_dept):
		push_error("Unknown department type: %s" % old_dept)
		return false

	# Update staff's department
	staff_member.assign_to_dept("")

	# Update counts
	department_staff[old_dept] -= 1

	print("Returned %s to recruit pool from %s" % [staff_member.get_display_name(), old_dept])
	return true

## Dismiss a staff member entirely
func dismiss_staff(staff_member) -> bool:
	if not staff_member in staff_list:
		return false

	# If assigned to a department, update counts first
	if not staff_member.is_in_recruit_pool():
		var dept = staff_member.department
		if department_staff.has(dept):
			department_staff[dept] -= 1

	# Remove from staff list
	staff_list.erase(staff_member)

	# Update resource system
	ResourceSystem.add_staff(-1)

	return true

## Remove a staff member due to casualties (same as dismiss but different message)
func remove_staff(staff_member) -> bool:
	if not staff_member in staff_list:
		return false

	# If assigned to a department, update counts first
	if not staff_member.is_in_recruit_pool():
		var dept = staff_member.department
		if department_staff.has(dept):
			department_staff[dept] -= 1

	# Remove from staff list
	staff_list.erase(staff_member)

	# Update resource system
	ResourceSystem.add_staff(-1)

	print("Staff member %s was killed in action" % staff_member.get_display_name())
	return true

## Get staff count for a specific department
func get_department_staff(department_type: String) -> int:
	if department_staff.has(department_type):
		return department_staff[department_type]
	return 0

## Get total staff across all departments and recruit pool
func get_total_staff() -> int:
	var total = 0
	for count in department_staff.values():
		total += count
	# Add unassigned staff in recruit pool
	total += get_recruit_pool().size()
	return total

## Get unassigned staff (in recruit pool)
func get_unassigned_staff() -> int:
	return get_recruit_pool().size()

## Get all staff in the base
func get_all_staff() -> Array:
	return staff_list

## ===== DEPARTMENT BONUSES =====

## Calculate research speed bonus from R&D staff
## Returns multiplier (1.0 = no bonus, 1.5 = 50% bonus)
func get_research_speed_multiplier() -> float:
	var rd_staff = get_department_staff("R&D")
	var bonus = rd_staff * RESEARCH_SPEED_BONUS_PER_STAFF

	# Apply efficiency penalty if upkeep wasn't paid
	if ResourceSystem.efficiency_penalty:
		bonus *= 0.5  # 50% penalty

	var multiplier = 1.0 + bonus

	# Add combo bonuses if available
	if combo_system:
		var combo_bonus = combo_system.get_total_bonus("research_speed")
		multiplier += combo_bonus

	return multiplier

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

## Reset department system for new game
func reset_department_system():
	# Clear all staff
	staff_list.clear()
	next_staff_id = 1

	# Clear all department assignments
	for dept in department_staff:
		department_staff[dept] = 0

	# Clear all platform registrations
	for dept in departments:
		departments[dept].clear()
		department_counts[dept] = 0
