extends Node

## Global resource management system
## Tracks Materials, Fuel, Staff, and GMP for the entire base

## Debug mode (global setting for all debug output)
var debug_mode: bool = false

## Signals
signal staff_recruited()
signal gmp_changed(new_amount: int)
signal debt_warning_reached()

## Resource totals
var materials: int = 0
var fuel: int = 0
var gmp: int = 0              # Global Money Points - currency for recruiting
var staff_count: int = 0      # Current number of staff
var bed_capacity: int = 0     # Maximum staff based on beds

## Production statistics (for debugging)
var materials_produced: int = 0
var fuel_produced: int = 0

## Staff upkeep
var upkeep_paid: bool = true  # Whether upkeep was paid this cycle
var efficiency_penalty: bool = false

## Reference to debug print timer
var debug_timer: Timer
var upkeep_timer: Timer

## Staff recruitment cost
const RECRUIT_COST: int = 50  # GMP cost per staff

## Staff upkeep per minute
const UPKEEP_COST: int = 1  # Materials per staff per minute

## GMP salary per staff per day (60 seconds)
const SALARY_COST: int = 1  # GMP per staff per day

func _ready():
	_setup_debug_timer()
	_setup_upkeep_timer()

## Add materials to the resource pool
func add_materials(amount: int):
	materials += amount
	materials_produced += amount

## Add fuel to the resource pool
func add_fuel(amount: int):
	fuel += amount
	fuel_produced += amount

## Add GMP to the resource pool
func add_gmp(amount: int):
	gmp += amount
	gmp_changed.emit(gmp)

## Add staff
func add_staff(amount: int):
	staff_count += amount

## Add bed capacity
func add_beds(amount: int):
	bed_capacity += amount

## Get current resource values
func get_materials() -> int:
	return materials

func get_fuel() -> int:
	return fuel

func get_gmp() -> int:
	return gmp

func get_staff_count() -> int:
	return staff_count

func get_bed_capacity() -> int:
	return bed_capacity

## Get available beds
func get_available_beds() -> int:
	return max(0, bed_capacity - staff_count)

## Check if more staff can be recruited
func can_recruit_staff() -> bool:
	return get_available_beds() > 0

## Spend resources
func spend_materials(amount: int) -> bool:
	if materials >= amount:
		materials -= amount
		return true
	return false

func spend_fuel(amount: int) -> bool:
	if fuel >= amount:
		fuel -= amount
		return true
	return false

func spend_gmp(amount: int) -> bool:
	if gmp >= amount:
		gmp -= amount
		gmp_changed.emit(gmp)
		return true
	return false

## Recruit staff - returns true if successful
func recruit_staff() -> bool:
	if not can_recruit_staff():
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_recruit_failed_no_beds()
		return false

	if not spend_gmp(RECRUIT_COST):
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_staff_recruit_failed_no_gmp()
		return false

	# Create the staff entity through DepartmentSystem
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if dept_system:
		dept_system.add_staff()
		# Also update the staff count
		add_staff(1)
		# Emit signal for objective tracking
		staff_recruited.emit()
		return true

	return false

## Calculate bed capacity from platforms
func calculate_bed_capacity(platforms: Array) -> int:
	var capacity: int = 0
	for platform in platforms:
		if platform.has_method("get_type"):
			var type = platform.get_type()
			match type:
				"HQ":
					capacity += 5  # HQ provides basic living quarters
				"Support":
					capacity += 5
				"Medical":
					capacity += 3
	bed_capacity = capacity
	return capacity

## Setup upkeep timer (runs every 60 seconds)
func _setup_upkeep_timer():
	upkeep_timer = Timer.new()
	upkeep_timer.wait_time = 60.0
	upkeep_timer.autostart = true
	upkeep_timer.timeout.connect(_on_upkeep_timeout)
	add_child(upkeep_timer)

## Pay staff upkeep
func _on_upkeep_timeout():
	# Pay materials upkeep (existing logic)
	var total_upkeep = staff_count * UPKEEP_COST

	if total_upkeep == 0:
		upkeep_paid = true
		efficiency_penalty = false
	else:
		if materials >= total_upkeep:
			spend_materials(total_upkeep)
			upkeep_paid = true
			efficiency_penalty = false
			var notification_system = get_node_or_null("/root/NotificationSystem")
			if notification_system:
				notification_system.show_upkeep_paid(total_upkeep)
		else:
			upkeep_paid = false
			efficiency_penalty = true
			var notification_system = get_node_or_null("/root/NotificationSystem")
			if notification_system:
				notification_system.show_upkeep_failed(total_upkeep, materials)

	# Pay GMP salary (allows debt)
	var total_salary = staff_count * SALARY_COST
	gmp -= total_salary  # Always deduct, even if negative
	gmp_changed.emit(gmp)

	# Check debt threshold for warning (only once, with tolerance)
	if gmp <= -200 and gmp > -210:
		debt_warning_reached.emit()

## Check if in debt
func is_in_debt() -> bool:
	return gmp < 0

## Get debt warning threshold
func get_debt_warning_threshold() -> int:
	return -200

## Get debt limit (game over threshold)
func get_debt_limit() -> int:
	return -500

## Setup debug timer to print resources every 5 seconds
func _setup_debug_timer():
	# Debug timer disabled - no longer needed, use HUD for monitoring
	pass

func _on_debug_timeout():
	# Debug output disabled - use HUD for resource monitoring
	# Only print resources when game session is running
	# var game_session = get_node_or_null("/root/GameSession")
	# if game_session and game_session.is_running():
	# 	print("Materials: %d | Fuel: %d | GMP: %d | Staff: %d / %d beds" % [materials, fuel, gmp, staff_count, bed_capacity])
	pass

## Debug print function - only prints when debug_mode is enabled
func debug_print(message: String):
	if debug_mode:
		print(message)

## Set debug mode (called by ConfigSystem)
func set_debug_mode(enabled: bool):
	debug_mode = enabled
	print("[ResourceSystem] Debug mode set to: ", "ON" if debug_mode else "OFF")

## Reset all resources to zero (for new game)
func reset_resources():
	materials = 0
	fuel = 0
	gmp = 0
	staff_count = 0
	bed_capacity = 0
	materials_produced = 0
	fuel_produced = 0
	upkeep_paid = true
	efficiency_penalty = false

	# Stop and restart upkeep timer
	if upkeep_timer:
		upkeep_timer.stop()
		upkeep_timer.start()
