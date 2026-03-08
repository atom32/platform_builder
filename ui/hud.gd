extends CanvasLayer

## HUD displays current resources in the top-left corner

@onready var materials_label = $VBoxContainer/MaterialsLabel
@onready var fuel_label = $VBoxContainer/FuelLabel

## Update interval for resource display
var update_timer: float = 0.0
var update_interval: float = 0.5  # Update twice per second

func _ready():
	# Validate that label nodes exist
	if not materials_label:
		push_error("MaterialsLabel not found in HUD scene!")
	if not fuel_label:
		push_error("FuelLabel not found in HUD scene!")

func _process(delta):
	update_timer += delta
	if update_timer >= update_interval:
		update_resource_display()
		update_timer = 0.0

## Update the resource labels with current values
func update_resource_display():
	if materials_label and fuel_label:
		var mats = ResourceSystem.get_materials()
		var fuel = ResourceSystem.get_fuel()
		materials_label.text = "Materials: %d" % mats
		fuel_label.text = "Fuel: %d" % fuel
