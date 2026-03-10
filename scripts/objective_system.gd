extends Node

## Global objective tracking system
## Manages game objectives and onboarding tasks

signal objective_completed(objective_id: String)
signal all_objectives_completed()

## Objectives storage
## Dictionary: {id: {description: String, completed: bool, progress: int}}
var objectives: Dictionary = {}

## Track if this is the first expedition
var first_expedition_launched: bool = false

func _ready():
	pass

## Add a new objective to track
func add_objective(id: String, description: String) -> void:
	if objectives.has(id):
		push_warning("Objective %s already exists, skipping" % id)
		return

	objectives[id] = {
		"description": description,
		"completed": false,
		"progress": 0
	}

## Mark an objective as complete
func complete_objective(id: String) -> void:
	if not objectives.has(id):
		push_warning("Objective %s does not exist" % id)
		return

	if objectives[id]["completed"]:
		return

	objectives[id]["completed"] = true

	# Emit signal
	objective_completed.emit(id)

	# Show notification
	var notification_system = get_node_or_null("/root/NotificationSystem")
	if notification_system:
		notification_system.show_objective_completed(objectives[id]["description"])

	# Check if all objectives are complete
	_check_all_objectives_completed()

## Check if an objective is complete
func is_objective_complete(id: String) -> bool:
	if not objectives.has(id):
		return false
	return objectives[id]["completed"]

## Get all incomplete objectives
func get_active_objectives() -> Array:
	var active: Array = []
	for id in objectives:
		if not objectives[id]["completed"]:
			active.append({
				"id": id,
				"description": objectives[id]["description"]
			})
	return active

## Get all objectives (including completed)
func get_all_objectives() -> Dictionary:
	return objectives.duplicate()

## Get objective count
func get_objective_count() -> Dictionary:
	var completed: int = 0
	var total: int = objectives.size()

	for id in objectives:
		if objectives[id]["completed"]:
			completed += 1

	return {
		"completed": completed,
		"total": total,
		"active": total - completed
	}

## Check if all objectives are complete
func _check_all_objectives_completed() -> void:
	var all_complete: bool = true
	for id in objectives:
		if not objectives[id]["completed"]:
			all_complete = false
			break

	if all_complete and objectives.size() > 0:
		all_objectives_completed.emit()

		# Show notification
		var notification_system = get_node_or_null("/root/NotificationSystem")
		if notification_system:
			notification_system.show_all_objectives_completed()

## Mark first expedition as launched
func mark_first_expedition() -> void:
	if not first_expedition_launched:
		first_expedition_launched = true
		complete_objective("first_expedition")

## Reset all objectives (for new game)
func reset_objectives() -> void:
	objectives.clear()
	first_expedition_launched = false
