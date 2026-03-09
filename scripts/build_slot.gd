extends Node3D
class_name BuildSlot

## BuildSlot represents an empty location where a platform can be built

signal slot_clicked(slot: BuildSlot)

@export var slot_index: int = -1
var is_occupied: bool = false

@onready var mesh_node = $Mesh
@onready var area_3d = $Area3D

func _ready():
	# Validate that mesh node exists
	if not mesh_node:
		push_error("Mesh node not found in BuildSlot scene!")
		return

	# Validate that Area3D exists
	if not area_3d:
		push_error("Area3D not found in BuildSlot scene!")
		return

func on_clicked():
	if not is_occupied:
		slot_clicked.emit(self)

func occupy():
	is_occupied = true

func vacate():
	is_occupied = false

func get_occupied() -> bool:
	return is_occupied

func hide_mesh():
	if mesh_node:
		mesh_node.visible = false
	# Disable collision detection when hidden
	if area_3d:
		area_3d.collision_layer = 0

func show_mesh():
	if mesh_node:
		mesh_node.visible = true
	# Enable collision detection when visible (layer 2 = build slots)
	if area_3d:
		area_3d.collision_layer = 2
