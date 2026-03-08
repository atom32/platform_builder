extends Node

## Global resource management system
## Tracks Materials and Fuel for the entire base

## Resource totals
var materials: int = 0
var fuel: int = 0

## Production statistics (for debugging)
var materials_produced: int = 0
var fuel_produced: int = 0

## Reference to debug print timer
var debug_timer: Timer

func _ready():
	_setup_debug_timer()

## Add materials to the resource pool
func add_materials(amount: int):
	materials += amount
	materials_produced += amount

## Add fuel to the resource pool
func add_fuel(amount: int):
	fuel += amount
	fuel_produced += amount

## Get current resource values
func get_materials() -> int:
	return materials

func get_fuel() -> int:
	return fuel

## Spend resources (for future use)
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

## Setup debug timer to print resources every 5 seconds
func _setup_debug_timer():
	debug_timer = Timer.new()
	debug_timer.wait_time = 5.0
	debug_timer.autostart = true
	debug_timer.timeout.connect(_on_debug_timeout)
	add_child(debug_timer)

func _on_debug_timeout():
	print("Materials: %d | Fuel: %d" % [materials, fuel])
