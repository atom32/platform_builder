extends Node
class_name DepartmentSystem

## Manages platform departments with capacity limits

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
