extends Node3D
class_name BuildSlot

## BuildSlot represents an empty location where a platform can be built

signal slot_clicked(slot: BuildSlot)

@export var slot_index: int = -1
var is_occupied: bool = false

@onready var mesh_node = $Mesh

func _ready():
	# Validate that mesh node exists
	if not mesh_node:
		push_error("Mesh node not found in BuildSlot scene!")
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

func show_mesh():
	if mesh_node:
		mesh_node.visible = true
