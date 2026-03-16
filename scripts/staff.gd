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

## Combat attributes
var hp: int = 100                   # Current health points
var max_hp: int = 100               # Maximum health points
var attack: int = 10                # Attack power
var defense: int = 5                 # Defense power
var speed: int = 10                 # Speed (determines action order)
var status_effects: Array[Dictionary] = []  # Active debuffs/buffs
var is_wounded: bool = false        # Is currently wounded
var is_available: bool = true       # Available for missions (false=incapacitated)

## Skills
var unlocked_skills: Array[Dictionary] = []  # Skills unlocked by level
var active_skills_cooldown: Dictionary = {}  # Skill cooldown counters

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

	# Initialize combat stats based on skill level
	recalculate_combat_stats()

	# Initialize skills (will be empty until assigned to department)
	unlock_skills()

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
		# Unlock skills for the new department
		unlock_skills()
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

## ===== COMBAT SYSTEM =====

## Recalculate combat stats based on skill level and status effects
func recalculate_combat_stats():
	max_hp = 100 + (skill_level * 20)  # Level 1 = 120, Level 5 = 200
	attack = 10 + (skill_level * 5)     # Level 1 = 15, Level 5 = 35
	defense = 5 + (skill_level * 3)      # Level 1 = 8, Level 5 = 20
	speed = 10 + (skill_level * 2)       # Level 1 = 12, Level 5 = 20

	# Cap HP at max_hp
	if hp > max_hp:
		hp = max_hp

	# Apply status effect penalties
	_apply_stat_penalties()

## Apply wound penalty (reduces stats by percentage)
func apply_wound(penalty: float = 0.3):
	is_wounded = true
	is_available = false

	var wound_debuff = {
		"id": "injury_penalty",
		"name": "受伤惩罚",
		"type": "injury",
		"stat_penalty": {"attack": penalty, "defense": penalty},
		"is_permanent": true
	}
	apply_status_effect(wound_debuff)

	# Reduce HP by penalty amount
	var hp_loss = int(max_hp * penalty)
	hp = max(1, hp - hp_loss)

## Heal staff member
func heal(amount: int):
	hp = min(hp + amount, max_hp)

	# Recover from wound if HP is above 80%
	if hp >= max_hp * 0.8:
		is_wounded = false
		is_available = true
		remove_status_effect("injury_penalty")

## Apply status effect (debuff or buff)
func apply_status_effect(effect: Dictionary):
	# Remove existing effect with same ID
	remove_status_effect(effect["id"])

	status_effects.append(effect)
	_apply_effect_stats(effect)

## Remove status effect by ID
func remove_status_effect(effect_id: String):
	for i in range(status_effects.size() - 1, -1, -1):
		if status_effects[i]["id"] == effect_id:
			status_effects.remove_at(i)
			break

	# Recalculate stats without the removed effect
	recalculate_combat_stats()

## Apply stat penalties from all status effects
func _apply_stat_penalties():
	for effect in status_effects:
		_apply_effect_stats(effect)

## Apply a single status effect's stat changes
func _apply_effect_stats(effect: Dictionary):
	if effect.has("stat_penalty"):
		var penalty = effect["stat_penalty"]
		if penalty.has("attack"):
			attack = int(attack * (1.0 - penalty["attack"]))
		if penalty.has("defense"):
			defense = int(defense * (1.0 - penalty["defense"]))
		if penalty.has("speed"):
			speed = int(speed * (1.0 - penalty["speed"]))

## Get effective attack (considering wounds and debuffs)
func get_effective_attack() -> int:
	var effective_atk = attack
	if is_wounded:
		effective_atk = int(effective_atk * 0.7)  # 30% penalty when wounded
	return effective_atk

## Get effective defense (considering wounds and debuffs)
func get_effective_defense() -> int:
	var effective_def = defense
	if is_wounded:
		effective_def = int(effective_def * 0.7)  # 30% penalty when wounded
	return effective_def

## ===== SKILL SYSTEM =====

## Unlock skills based on current level and department
func unlock_skills():
	unlocked_skills.clear()
	var all_skills = _get_all_skills_data()

	if all_skills.has("skills") and all_skills["skills"].has(department):
		for skill in all_skills["skills"][department]:
			if skill["required_level"] <= skill_level:
				unlocked_skills.append(skill)

## Get available skills (not on cooldown)
func get_available_skills() -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for skill in unlocked_skills:
		if skill["type"] == "passive" or skill["type"] == "aura":
			available.append(skill)
		elif active_skills_cooldown.has(skill["id"]):
			if active_skills_cooldown[skill["id"]] <= 0:
				available.append(skill)
		else:
			available.append(skill)
	return available

## Use a skill (returns true if successful)
func use_skill(skill_id: String) -> bool:
	for skill in unlocked_skills:
		if skill["id"] == skill_id:
			if skill["type"] == "active" or skill["type"] == "ultimate":
				if active_skills_cooldown.get(skill_id, 0) > 0:
					return false  # Still on cooldown

				active_skills_cooldown[skill_id] = skill.get("cooldown", 1)
				return true
	return false

## Reduce cooldowns at end of turn
func reduce_cooldowns():
	for skill_id in active_skills_cooldown:
		if active_skills_cooldown[skill_id] > 0:
			active_skills_cooldown[skill_id] -= 1

## Get cooldown remaining for a skill
func get_skill_cooldown(skill_id: String) -> int:
	return active_skills_cooldown.get(skill_id, 0)

## Load skills data (placeholder for now)
func _get_all_skills_data() -> Dictionary:
	var loader = SkillDataLoader.new()
	return loader.load_skills()
