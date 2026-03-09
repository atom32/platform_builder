extends CanvasLayer

## HUD displays current resources and base status

@onready var materials_label = $VBoxContainer/MaterialsLabel
@onready var fuel_label = $VBoxContainer/FuelLabel
@onready var base_size_label = $VBoxContainer/BaseSizeLabel
@onready var combo_label = $VBoxContainer/ComboLabel
@onready var expedition_label = $VBoxContainer/ExpeditionLabel
@onready var combat_power_label = $VBoxContainer/CombatPowerLabel

## Update interval for resource display
var update_timer: float = 0.0
var update_interval: float = 0.5  # Update twice per second

## Reference to base system
var base_system: Base = null

func _ready():
	# Validate that label nodes exist
	if not materials_label:
		push_error("MaterialsLabel not found in HUD scene!")
	if not fuel_label:
		push_error("FuelLabel not found in HUD scene!")
	if not base_size_label:
		push_error("BaseSizeLabel not found in HUD scene!")
	if not combo_label:
		push_error("ComboLabel not found in HUD scene!")
	if not expedition_label:
		push_error("ExpeditionLabel not found in HUD scene!")
	if not combat_power_label:
		push_error("CombatPowerLabel not found in HUD scene!")

	# Get reference to base system
	base_system = get_node("/root/Main/Base")

func _process(delta):
	update_timer += delta
	if update_timer >= update_interval:
		update_resource_display()
		update_base_info()
		update_expedition_info()
		update_timer = 0.0

## Update the resource labels with current values
func update_resource_display():
	if materials_label and fuel_label:
		var mats = ResourceSystem.get_materials()
		var fuel = ResourceSystem.get_fuel()
		materials_label.text = TextData.get("ui_materials", [mats])
		fuel_label.text = TextData.get("ui_fuel", [fuel])

## Update base information (size and combos)
func update_base_info():
	if base_system:
		# Update base size
		if base_size_label:
			var current_size = base_system.get_total_platform_count()
			base_size_label.text = TextData.get("ui_base", [current_size, base_system.MAX_PLATFORMS])

		# Update combo count
		if combo_label and base_system.combo_system:
			var combo_count = base_system.combo_system.get_combo_count()
			combo_label.text = TextData.get("ui_combos", [combo_count])

## Update expedition information
func update_expedition_info():
	if base_system and base_system.expedition_system:
		var expedition_count = base_system.expedition_system.get_active_expedition_count()
		expedition_label.text = TextData.get("ui_expeditions", [expedition_count])

		# Update combat power
		if combat_power_label:
			var combat_power = base_system.expedition_system.get_combat_power()
			combat_power_label.text = TextData.get("ui_combat", [combat_power])
