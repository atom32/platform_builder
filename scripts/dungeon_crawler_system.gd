extends Node

## Manages dungeon crawler expeditions (turn-based combat)
## Completely separate from ExpeditionSystem
## This is an autoload singleton, accessed via DungeonCrawlerSystem global

# Preload required classes
const DungeonDataLoaderClass = preload("res://scripts/dungeon_data_loader.gd")

## Signals
signal dungeon_started(dungeon_id: String, layers: int)
signal layer_completed(layer: int, enemy_name: String)
signal dungeon_victory(rewards: Dictionary)
signal dungeon_defeat()
signal dungeon_retreated(rewards: Dictionary)
signal staff_death(staff_name: String)

## Active dungeon data
var active_dungeon: Dictionary = {}

## Combat timer
var combat_timer: Timer = null

## Data loader
var data_loader: Node = null

## Combat constants
const TURN_DURATION: float = 2.0  # Seconds per combat turn
const RETREAT_REWARD_MULTIPLIER: float = 0.5  # Keep 50% rewards when retreating

func _ready():
	# Initialize data loader
	data_loader = DungeonDataLoaderClass.new()
	add_child(data_loader)

	# Create combat timer
	combat_timer = Timer.new()
	combat_timer.wait_time = TURN_DURATION
	combat_timer.timeout.connect(_on_combat_turn)
	combat_timer.one_shot = false
	add_child(combat_timer)

	print("[DungeonCrawlerSystem] Initialized")

## Start a dungeon expedition
func start_dungeon(target_platform: Platform, party: Array[Staff]) -> bool:
	if not target_platform or party.is_empty():
		push_error("Invalid dungeon start parameters")
		return false

	# Calculate path and difficulty
	var path = DungeonPathfinder.get_path_to_hq(target_platform)
	var difficulty_info = DungeonPathfinder.calculate_difficulty(path)

	if difficulty_info["layers"] <= 0:
		print("[DungeonCrawlerSystem] Cannot start dungeon at HQ")
		return false

	# Initialize dungeon data
	var dungeon_id = "dungeon_%d" % Time.get_unix_time_from_system()
	active_dungeon = {
		"id": dungeon_id,
		"target_platform": target_platform,
		"path": path,
		"current_layer": 0,
		"total_layers": difficulty_info["layers"],
		"difficulty": difficulty_info["difficulty"],
		"party": party,  # Array of Staff
		"party_hp": [],
		"enemy": null,
		"enemy_hp": 0,
		"enemy_max_hp": 0,
		"rewards_earned": 0,
		"is_active": true
	}

	# Initialize party HP tracking
	for staff in party:
		active_dungeon["party_hp"].append(staff.hp)

	print("[DungeonCrawlerSystem] Started %s dungeon with %d layers" % [
		difficulty_info["difficulty"], difficulty_info["layers"]
	])

	dungeon_started.emit(dungeon_id, difficulty_info["layers"])

	# Start first layer combat
	_start_layer_combat()

	return true

## Start combat for current layer
func _start_layer_combat():
	if active_dungeon.is_empty() or not active_dungeon.get("is_active", false):
		return

	var current_layer = active_dungeon["current_layer"] + 1
	active_dungeon["current_layer"] = current_layer

	# Get random enemy for this layer
	var enemy_entry = data_loader.get_random_enemy(
		current_layer,
		active_dungeon["difficulty"]
	)
	var enemy_data = data_loader.get_enemy_data(enemy_entry["enemy_id"])

	# Scale enemy based on layer
	var hp_multiplier = 1.0 + (current_layer * 0.2)  # +20% HP per layer
	var atk_multiplier = 1.0 + (current_layer * 0.1)  # +10% ATK per layer

	active_dungeon["enemy"] = enemy_data
	active_dungeon["enemy_max_hp"] = int(enemy_data["base_hp"] * hp_multiplier)
	active_dungeon["enemy_hp"] = active_dungeon["enemy_max_hp"]

	# Store multipliers for damage calculations
	active_dungeon["enemy_atk_multiplier"] = atk_multiplier

	print("[DungeonCrawlerSystem] Layer %d: VS %s (HP: %d)" % [
		current_layer, enemy_data["name"], active_dungeon["enemy_hp"]
	])

	# Start combat timer
	combat_timer.start()

## Combat turn (called every 2 seconds)
func _on_combat_turn():
	if active_dungeon.is_empty() or not active_dungeon.get("is_active", false):
		combat_timer.stop()
		return

	# Party attacks
	var total_party_damage = 0
	var party = active_dungeon.get("party", [])
	for i in range(party.size()):
		var staff = party[i]
		if staff.hp > 0:
			var damage = _calculate_staff_damage(staff)
			total_party_damage += damage

			# Check for special ability
			if staff.specialty == "Combat" and randf() < 0.15:
				var crit_damage = int(damage * 1.5)
				total_party_damage += crit_damage - damage
				print("  %s CRITICAL HIT for %d damage!" % [staff.get_display_name(), crit_damage])

	active_dungeon["enemy_hp"] = max(0, active_dungeon.get("enemy_hp", 0) - total_party_damage)
	print("Party deals %d total damage! Enemy HP: %d/%d" % [
		total_party_damage,
		active_dungeon["enemy_hp"],
		active_dungeon.get("enemy_max_hp", 0)
	])

	# Check if enemy defeated
	if active_dungeon["enemy_hp"] <= 0:
		_end_layer_victory()
		return

	# Enemy attacks
	var enemy = active_dungeon.get("enemy", {})
	if enemy.is_empty():
		push_error("Enemy data is empty!")
		return

	var base_damage = enemy.get("base_attack", 0)
	var enemy_damage = int(base_damage * active_dungeon.get("enemy_atk_multiplier", 1.0))

	# Check for enemy special attack
	if enemy.has("special") and randf() < enemy.get("special_chance", 0.1):
		enemy_damage = int(enemy_damage * 1.5)
		print("  %s uses SPECIAL! %d damage!" % [enemy.get("name", "Unknown"), enemy_damage])

	# Apply damage to random party member
	var alive_party = []
	for i in range(party.size()):
		if party[i].hp > 0:
			alive_party.append(i)

	if not alive_party.is_empty():
		var target_index = alive_party.pick_random()
		var target_staff = party[target_index]
		var final_damage = max(1, enemy_damage - target_staff.get_effective_defense())
		target_staff.hp -= final_damage

		print("  %s attacks %s for %d damage! HP: %d/%d" % [
			enemy.get("name", "Unknown"),
			target_staff.get_display_name(),
			final_damage,
			max(0, target_staff.hp),
			target_staff.max_hp
		])

		# Check for staff death
		if target_staff.hp <= 0:
			print("  %s has died!" % target_staff.get_display_name())
			staff_death.emit(target_staff.get_display_name())

	# Check if all party members dead
	var all_dead = true
	for staff in party:
		if staff.hp > 0:
			all_dead = false
			break

	if all_dead:
		_end_dungeon_defeat()

## Calculate staff damage
func _calculate_staff_damage(staff: Staff) -> int:
	var base_damage = 10 + (staff.skill_level * 5)
	var atk = staff.get_effective_attack()

	# Department specialty bonus
	var damage = base_damage + atk

	if staff.specialty == "Combat":
		damage = int(damage * 1.3)
	elif staff.department == "Combat":
		damage = int(damage * 1.1)

	# Random variance
	damage += randi() % 5

	return max(1, damage)

## End layer with victory
func _end_layer_victory():
	combat_timer.stop()

	var current_layer = active_dungeon.get("current_layer", 0)
	var enemy = active_dungeon.get("enemy", {})
	var enemy_name = enemy.get("name", "Unknown")

	# Calculate reward for this layer
	var base_reward = 20 * current_layer  # More gold for deeper layers
	var bonus = 10 if active_dungeon.get("difficulty", "") == "hard" else 0
	var reward = base_reward + bonus

	active_dungeon["rewards_earned"] = active_dungeon.get("rewards_earned", 0) + reward

	print("[DungeonCrawlerSystem] Layer %d complete! Reward: %d GMP" % [current_layer, reward])
	layer_completed.emit(current_layer, enemy_name)

	# Check if dungeon complete
	if current_layer >= active_dungeon.get("total_layers", 0):
		_end_dungeon_victory()
	else:
		# Start next layer after brief delay
		await get_tree().create_timer(1.0).timeout
		_start_layer_combat()

## End dungeon with victory
func _end_dungeon_victory():
	active_dungeon["is_active"] = false

	var total_rewards = {
		"gmp": active_dungeon.get("rewards_earned", 0),
		"materials": active_dungeon.get("total_layers", 0) * 15,
		"fuel": active_dungeon.get("total_layers", 0) * 10
	}

	# Apply rewards
	ResourceSystem.add_gmp(total_rewards["gmp"])
	ResourceSystem.add_materials(total_rewards["materials"])
	ResourceSystem.add_fuel(total_rewards["fuel"])

	print("[DungeonCrawlerSystem] DUNGEON VICTORY!")
	print("  GMP: +%d" % total_rewards["gmp"])
	print("  Materials: +%d" % total_rewards["materials"])
	print("  Fuel: +%d" % total_rewards["fuel"])

	dungeon_victory.emit(total_rewards)

	# Clear active dungeon
	active_dungeon.clear()

## End dungeon with defeat
func _end_dungeon_defeat():
	combat_timer.stop()
	active_dungeon["is_active"] = false

	# All party members are permanently dead
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		var party = active_dungeon.get("party", [])
		for staff in party:
			if staff.hp <= 0:
				dept_system.dismiss_staff(staff)

	print("[DungeonCrawlerSystem] DUNGEON DEFEAT - Party wiped!")

	dungeon_defeat.emit()

	# Clear active dungeon
	active_dungeon.clear()

## Retreat from dungeon (keep 50% rewards)
func retreat_dungeon() -> Dictionary:
	if active_dungeon.is_empty() or not active_dungeon.get("is_active", false):
		return {}

	combat_timer.stop()
	active_dungeon["is_active"] = false

	# Calculate retreat rewards (50% of earned)
	var current_layer = active_dungeon.get("current_layer", 0)
	var rewards_earned = active_dungeon.get("rewards_earned", 0)
	var retreat_rewards = {
		"gmp": int(rewards_earned * RETREAT_REWARD_MULTIPLIER),
		"materials": int(current_layer * 15 * RETREAT_REWARD_MULTIPLIER),
		"fuel": int(current_layer * 10 * RETREAT_REWARD_MULTIPLIER)
	}

	# Apply rewards
	ResourceSystem.add_gmp(retreat_rewards["gmp"])
	ResourceSystem.add_materials(retreat_rewards["materials"])
	ResourceSystem.add_fuel(retreat_rewards["fuel"])

	print("[DungeonCrawlerSystem] Retreated from dungeon")
	print("  GMP: +%d" % retreat_rewards["gmp"])
	print("  Materials: +%d" % retreat_rewards["materials"])
	print("  Fuel: +%d" % retreat_rewards["fuel"])

	dungeon_retreated.emit(retreat_rewards)

	# Clear active dungeon
	var result = active_dungeon.duplicate()
	active_dungeon.clear()

	return result

## Check if dungeon is active
func is_dungeon_active() -> bool:
	return not active_dungeon.is_empty() and active_dungeon.get("is_active", false)

## Get active dungeon info
func get_active_dungeon_info() -> Dictionary:
	if not is_dungeon_active():
		return {}

	var enemy = active_dungeon.get("enemy", {})
	var party = active_dungeon.get("party", [])

	return {
		"current_layer": active_dungeon.get("current_layer", 0),
		"total_layers": active_dungeon.get("total_layers", 0),
		"difficulty": active_dungeon.get("difficulty", ""),
		"enemy_name": enemy.get("name", ""),
		"enemy_hp": max(0, active_dungeon.get("enemy_hp", 0)),
		"enemy_max_hp": active_dungeon.get("enemy_max_hp", 0),
		"party_size": party.size(),
		"party_alive": _count_alive_party()
	}

## Count alive party members
func _count_alive_party() -> int:
	var count = 0
	var party = active_dungeon.get("party", [])
	for staff in party:
		if staff.hp > 0:
			count += 1
	return count

## Get active party (safe accessor)
func get_active_party() -> Array[Staff]:
	if not is_dungeon_active():
		return []
	return active_dungeon.get("party", [])
