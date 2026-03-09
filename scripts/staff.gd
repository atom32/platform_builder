extends Node
class_name Staff

## Individual staff member entity
## Each staff has unique ID and can be assigned to a department

## Staff member data
var id: int = 0                      # Unique staff identifier
var first_name: String = ""         # Staff first name
var last_name: String = ""          # Staff last name
var department: String = ""          # Current department (empty if in recruit pool)
var skill_level: int = 1            # 1-5, affects productivity
var specialty: String = ""          # Special skill if any

## Department display names
const DEPARTMENT_NAMES = {
	"": "Recruit Pool",
	"R&D": "R&D",
	"Combat": "Combat",
	"Support": "Support",
	"Intel": "Intel",
	"Medical": "Medical"
}

## Generate random name for staff
func _init(p_id: int = 0):
	id = p_id
	_generate_random_name()
	_generate_random_skill()

func _generate_random_name():
	var first_names = ["Alex", "Sam", "Jordan", "Taylor", "Casey", "Riley", "Jamie", "Morgan"]
	var last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis"]

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	first_name = first_names.pick_random()
	last_name = last_names.pick_random()

func _generate_random_skill():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	skill_level = rng.randi_range(1, 4)  # Most staff are level 1-3

	var specialties = ["Combat", "Research", "Logistics", "Medicine", "Engineering", ""]
	specialty = specialties.pick_random()

## Get display name
func get_display_name() -> String:
	return "%s %s" % [first_name, last_name]

## Get department display name
func get_department_display() -> String:
	if DEPARTMENT_NAMES.has(department):
		return DEPARTMENT_NAMES[department]
	return department

## Assign to department
func assign_to_dept(dept_name: String) -> bool:
	if dept_name == "" or DEPARTMENT_NAMES.has(dept_name):
		department = dept_name
		return true
	return false

## Is in recruit pool
func is_in_recruit_pool() -> bool:
	return department == ""

## Get productivity multiplier based on skill and department
func get_productivity_multiplier() -> float:
	var base = 1.0 + (skill_level * 0.1)  # Level 1 = 1.1, Level 5 = 1.5

	# Specialty bonus
	if specialty != "":
		match specialty:
			"Combat":
				if department == "Combat":
					base += 0.2
			"Research":
				if department == "R&D":
					base += 0.2
			"Logistics":
				if department == "Support":
					base += 0.2
			"Medicine":
				if department == "Medical":
					base += 0.2
			"Engineering":
				if department == "Support" or department == "R&D":
					base += 0.15

	return base
