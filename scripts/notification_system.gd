extends Node

## Global notification system for displaying temporary messages
## Access from anywhere: NotificationSystem.show("message")

## Reference to HUD
var hud: CanvasLayer = null

func _ready():
	# Find HUD when ready
	call_deferred("_find_hud")

func _find_hud():
	# Try Main/Camera3D path
	hud = get_node_or_null("/root/Main/Camera3D/HUD")
	if not hud:
		# Try direct Main path
		hud = get_node_or_null("/root/Main/HUD")
	if not hud:
		# Try without Main prefix
		hud = get_node_or_null("/root/Camera3D/HUD")
	if not hud:
		print("WARNING: HUD not found for notifications")

## Show a notification message
## duration: how long to show in seconds (default 5)
func show(message: String, duration: float = 5.0):
	if hud and hud.has_method("show_notification"):
		hud.show_notification(message, duration)
	else:
		print("[Notification] %s" % message)

## Convenience functions for common notifications

func show_staff_recruited():
	show("Staff recruited! (+1 staff)")

func show_staff_assigned(department: String):
	show("Staff assigned to %s!" % department)

func show_staff_recruit_failed_no_beds():
	show("Cannot recruit: No available beds")

func show_staff_recruit_failed_no_gmp():
	show("Cannot recruit: Not enough GMP (need 50)")

func show_expedition_started(mission_name: String):
	show("Expedition started: %s" % mission_name)

func show_expedition_completed(mission_name: String, materials: int, fuel: int):
	show("Expedition completed: %s (+%d Mat, +%d Fuel)" % [mission_name, materials, fuel])

func show_expedition_failed(mission_name: String):
	show("Expedition failed: %s" % mission_name)

func show_platform_built(platform_type: String):
	show("%s platform built!" % platform_type)

func show_upkeep_paid(cost: int):
	show("Staff upkeep paid: %d Materials" % cost)

func show_upkeep_failed(cost: int, have: int):
	show("WARNING: Cannot pay upkeep! Need %d, have %d. Efficiency penalty!" % [cost, have])

func show_combo_activated(combo_name: String):
	show("Combo activated: %s!" % combo_name)

func show_staff_casualty():
	show("WARNING: Staff member lost in expedition!")

func show_critical_success(mission_name: String):
	show("CRITICAL SUCCESS: %s! Bonus rewards!" % mission_name)
