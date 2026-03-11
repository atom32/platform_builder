extends CanvasLayer

## HUD displays current resources and base status (MGSV style)

## Resource Panel (bottom-right)
@onready var materials_label = $ResourcePanel/VBoxContainer/MaterialsLabel
@onready var fuel_label = $ResourcePanel/VBoxContainer/FuelLabel
@onready var gmp_label = $ResourcePanel/VBoxContainer/GMPLabel
@onready var staff_label = $ResourcePanel/VBoxContainer/StaffLabel

## Side Bar (left, collapsible)
@onready var side_bar = $SideBar
@onready var base_size_label = $SideBar/VBoxContainer/BaseSizeLabel
@onready var combat_power_label = $SideBar/VBoxContainer/CombatPowerLabel
@onready var combo_label = $SideBar/VBoxContainer/ComboLabel
@onready var objective1_label = $SideBar/VBoxContainer/Objective1Label
@onready var objective2_label = $SideBar/VBoxContainer/Objective2Label
@onready var objective3_label = $SideBar/VBoxContainer/Objective3Label
@onready var toggle_sidebar_button = $SideBar/VBoxContainer/ToggleSideBarButton

## Key Bindings (bottom-center)
@onready var key_bindings_panel = $KeyBindings

## Notifications (top-right)
@onready var notification_container = $NotificationContainer

## Update interval for resource display
var update_timer: float = 0.0
var update_interval: float = 0.5  # Update twice per second

## Reference to base system
var base_system: Base = null

## Reference to department system
var department_system: Node = null

## Reference to objective system
var objective_system: Node = null

## Objective labels for easy access
var objective_labels: Array[Label] = []

## Notification settings
const NOTIFICATION_LIFETIME: float = 5.0  # Seconds
var notifications: Array = []

## Side bar state
var side_bar_visible: bool = true

func _ready():
	# Validate that label nodes exist
	if not materials_label:
		push_error("MaterialsLabel not found in HUD scene!")
	if not fuel_label:
		push_error("FuelLabel not found in HUD scene!")
	if not gmp_label:
		push_error("GMPLabel not found in HUD scene!")
	if not staff_label:
		push_error("StaffLabel not found in HUD scene!")
	if not base_size_label:
		push_error("BaseSizeLabel not found in HUD scene!")
	if not combo_label:
		push_error("ComboLabel not found in HUD scene!")
	if not combat_power_label:
		push_error("CombatPowerLabel not found in HUD scene!")
	if not toggle_sidebar_button:
		push_error("ToggleSideBarButton not found in HUD scene!")

	# Get reference to base system
	base_system = get_node("/root/Main/Base")

	# Get reference to department system
	department_system = get_node_or_null("/root/DepartmentSystem")

	# Get reference to objective system
	objective_system = get_node_or_null("/root/ObjectiveSystem")

	# Initialize objective labels array
	if objective1_label:
		objective_labels.append(objective1_label)
	if objective2_label:
		objective_labels.append(objective2_label)
	if objective3_label:
		objective_labels.append(objective3_label)

	# Connect to objective completion signals
	if objective_system:
		objective_system.objective_completed.connect(_on_objective_completed)

	# Connect to GMP debt warning signal
	ResourceSystem.debt_warning_reached.connect(_on_debt_warning)

	# Connect toggle button
	if toggle_sidebar_button:
		toggle_sidebar_button.pressed.connect(_on_toggle_sidebar)

	# Set initial state
	side_bar_visible = true

func _input(event):
	# Handle TAB key to toggle sidebar
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		_toggle_sidebar()

func _process(delta):
	update_timer += delta
	if update_timer >= update_interval:
		update_resource_display()
		update_base_info()
		update_expedition_info()
		update_staff_info()
		update_objectives()
		update_timer = 0.0

	# Update notifications
	_update_notifications(delta)

## Update the resource labels with current values
func update_resource_display():
	if materials_label and fuel_label and gmp_label:
		var mats = ResourceSystem.get_materials()
		var fuel = ResourceSystem.get_fuel()
		var gmp = ResourceSystem.get_gmp()
		materials_label.text = TextData.format("ui_materials", [mats])
		fuel_label.text = TextData.format("ui_fuel", [fuel])

		# Red text if in debt
		if gmp < 0:
			gmp_label.text = "GMP: %d" % gmp
			gmp_label.modulate = Color(1.0, 0.0, 0.0)  # Red
		else:
			gmp_label.text = "GMP: %d" % gmp
			gmp_label.modulate = Color(1.0, 1.0, 1.0)  # White

## Update base information (size and combos)
func update_base_info():
	if base_system:
		# Update base size
		if base_size_label:
			var current_size = base_system.get_total_platform_count()
			base_size_label.text = TextData.format("ui_base", [current_size, base_system.MAX_PLATFORMS])

		# Update combo information
		if combo_label and base_system.combo_system:
			var combo_count = base_system.combo_system.get_combo_count()
			if combo_count > 0:
				# Show combo details
				var combo_text = "Combos: %d\n" % combo_count
				var active_combos = base_system.combo_system.get_active_combos()
				for combo_id in active_combos:
					var combo = active_combos[combo_id]
					var platform_a = combo["platform_a"]
					var platform_b = combo["platform_b"]
					var combo_data = combo["combo_data"]
					combo_text += "%s+%s: %s\n" % [
						platform_a.platform_type.substr(0, 3),
						platform_b.platform_type.substr(0, 3),
						combo_data["description"]
					]
				combo_label.text = combo_text
			else:
				combo_label.text = "Combos: 0"

## Update expedition information
func update_expedition_info():
	if base_system and base_system.expedition_system:
		var expedition_count = base_system.expedition_system.get_active_expedition_count()
		# Expedition info now only in sidebar

		# Update combat power
		if combat_power_label:
			var combat_power = base_system.expedition_system.get_combat_power()
			combat_power_label.text = TextData.format("ui_combat", [combat_power])

## Update staff information
func update_staff_info():
	if staff_label:
		var staff = ResourceSystem.get_staff_count()
		var beds = ResourceSystem.get_bed_capacity()
		staff_label.text = "Staff: %d/%d" % [staff, beds]

## Update objectives display
func update_objectives():
	if not objective_system:
		return

	var active_objectives = objective_system.get_active_objectives()
	var all_objectives = objective_system.get_all_objectives()

	# If all objectives complete, show completion message
	if active_objectives.size() == 0 and all_objectives.size() > 0:
		for i in range(objective_labels.size()):
			if i < objective_labels.size():
				objective_labels[i].text = ""
		if objective1_label:
			objective1_label.text = "All objectives complete!"
		return

	# Display up to 3 active objectives
	for i in range(3):
		if i < objective_labels.size():
			var label = objective_labels[i]
			if i < active_objectives.size():
				var objective = active_objectives[i]
				label.text = "[ ] " + objective["description"]
			else:
				# Check if this objective was completed
				var all_ids = all_objectives.keys()
				if i < all_ids.size():
					var obj_id = all_ids[i]
					if all_objectives[obj_id]["completed"]:
						label.text = "[X] " + all_objectives[obj_id]["description"]
					else:
						label.text = ""
				else:
					label.text = ""

## Handle objective completed
func _on_objective_completed(objective_id: String):
	# Update objectives immediately when completed
	update_objectives()

## Handle debt warning reached
func _on_debt_warning():
	var notification_system = get_node_or_null("/root/NotificationSystem")
	if notification_system and notification_system.has_method("show_debt_warning"):
		notification_system.show_debt_warning()

## Toggle sidebar visibility
func _on_toggle_sidebar():
	side_bar_visible = !side_bar_visible

	if side_bar:
		side_bar.visible = side_bar_visible

	if toggle_sidebar_button:
		if side_bar_visible:
			toggle_sidebar_button.text = "Hide (TAB)"
		else:
			toggle_sidebar_button.text = "Show (TAB)"

## ===== NOTIFICATION SYSTEM =====

## Show a temporary notification message
func show_notification(message: String, duration: float = NOTIFICATION_LIFETIME):
	var notification_label = Label.new()
	notification_label.text = message
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	# Create font settings for notification
	var settings = LabelSettings.new()
	settings.font_size = 18
	notification_label.label_settings = settings

	# Add to container
	notification_container.add_child(notification_label)

	# Track notification
	var notification_data = {
		"label": notification_label,
		"timer": duration,
		"max_time": duration
	}
	notifications.append(notification_data)

	print("[Notification] %s" % message)

## Update notifications (called every frame)
func _update_notifications(delta: float):
	var i = 0
	while i < notifications.size():
		var notif = notifications[i]
		notif["timer"] -= delta

		# Fade out effect
		var progress = notif["timer"] / notif["max_time"]
		var label = notif["label"]
		if label and label is Label:
			label.modulate.a = progress

		# Remove expired notifications
		if notif["timer"] <= 0:
			if label and label.get_parent():
				label.get_parent().remove_child(label)
				label.queue_free()
			notifications.remove_at(i)
		else:
			i += 1
