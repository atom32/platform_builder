extends Control
class_name BaseOverview

signal platform_selected(platform: Platform)
signal overview_closed()

@onready var close_button = $Panel/VBoxContainer/Header/CloseButton
@onready var stats_label = $Panel/VBoxContainer/StatsLabel
@onready var tree = $Panel/VBoxContainer/TreeContainer/Tree

var base_system: Base = null
var platform_tree_items: Dictionary = {}  # Maps platform -> TreeItem

func _ready():
	close_button.pressed.connect(_on_close_clicked)
	tree.item_selected.connect(_on_tree_item_selected)
	tree.item_activated.connect(_on_tree_item_activated)

	# Enable input processing for double-click detection
	set_process_input(true)

	# Hide initially
	hide()

var _last_click_time: float = 0.0
var _last_clicked_item: TreeItem = null
const DOUBLE_CLICK_TIME: float = 0.5  # Seconds between clicks

func _input(event):
	if not visible:
		return

	# Handle mouse clicks on Tree
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var clicked_pos = event.position

			# Convert screen position to Tree's local coordinate system
			var local_pos = tree.get_local_mouse_position()
			print("Mouse clicked at screen: ", clicked_pos, " local: ", local_pos)

			# Get item at local position
			var clicked_item = tree.get_item_at_position(local_pos)
			if clicked_item:
				print("Item clicked: ", clicked_item.get_text(0))
				_check_double_click(clicked_item)
			else:
				print("No item found at local position")

func show_overview():
	visible = true
	# Set tree column widths
	tree.set_column_expand(0, true)
	tree.set_column_expand(1, false)
	tree.set_column_custom_minimum_width(1, 80)
	_build_tree()

func hide_overview():
	visible = false
	overview_closed.emit()

func _build_tree():
	if not base_system:
		base_system = get_node("/root/Main/Base") as Base
		if not base_system:
			push_error("Base system not found!")
			return

	# Clear existing tree
	tree.clear()
	platform_tree_items.clear()

	# Get HQ as root
	var hq = base_system.get_hq()
	if not hq:
		push_error("HQ not found!")
		return

	# Build tree recursively
	var root_item = tree.create_item()
	root_item.set_text(0, "HQ")
	root_item.set_text(1, "0")
	platform_tree_items[hq] = root_item

	# Add children recursively
	_add_platform_children(hq, root_item)

	# Update stats
	_update_stats(hq)

	# Expand all items
	_expand_all_items(root_item)

func _add_platform_children(platform: Platform, parent_item: TreeItem):
	var child_count = 0
	for child in platform.get_child_platforms():
		child_count += 1
		var child_item = tree.create_item(parent_item)
		child_item.set_text(0, child.platform_type)
		child_item.set_text(1, "0")
		child_item.set_metadata(0, child)  # Store platform reference
		platform_tree_items[child] = child_item

		# Recursively add children
		_add_platform_children(child, child_item)

	# Update parent's child count
	var current_count = parent_item.get_text(1).to_int()
	parent_item.set_text(1, str(current_count + child_count))

func _update_stats(hq: Platform):
	var total_platforms = base_system.get_total_platform_count()
	var max_depth = _calculate_tree_depth(hq)
	stats_label.text = "Total Platforms: %d | Tree Depth: %d" % [total_platforms, max_depth]

func _calculate_tree_depth(platform: Platform) -> int:
	var child_platforms = platform.get_child_platforms()
	if child_platforms.is_empty():
		return 1

	var max_child_depth = 0
	for child in child_platforms:
		var child_depth = _calculate_tree_depth(child)
		max_child_depth = max(max_child_depth, child_depth)

	return max_child_depth + 1

func _expand_all_items(item: TreeItem):
	item.collapsed = false
	for child in item.get_children():
		_expand_all_items(child)

func _check_double_click(clicked_item: TreeItem):
	var current_time = Time.get_ticks_msec() / 1000.0

	# Check if same item was clicked recently
	if clicked_item == _last_clicked_item and (current_time - _last_click_time) < DOUBLE_CLICK_TIME:
		# Double click detected
		var platform = clicked_item.get_metadata(0)
		if platform and platform is Platform:
			_navigate_to_platform(platform)
		_last_clicked_item = null  # Reset
	else:
		_last_clicked_item = clicked_item
		_last_click_time = current_time

func _on_tree_item_activated(item: TreeItem, mouse_button_index: int, mouse_position: Vector2):
	# Now handled by manual double-click detection in _input()
	pass

func _on_tree_item_selected():
	var selected = tree.get_selected()
	if selected and selected.has_method("get_metadata"):
		var platform = selected.get_metadata(0)
		if platform and platform is Platform:
			print("Selected platform: %s" % platform.platform_type)

func _navigate_to_platform(platform: Platform):
	# Move camera to platform
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# Calculate new camera position (keep same height and offset)
	var current_pos = camera.position
	var target_pos = platform.position

	# Maintain camera's height and viewing angle
	camera.position.x = target_pos.x
	camera.position.z = target_pos.z + 40  # Keep the offset from main.tscn

	print("Navigated to platform: %s at %s" % [platform.platform_type, platform.position])
	platform_selected.emit(platform)

func _on_close_clicked():
	hide_overview()

## Refresh the tree when platforms are added
func refresh():
	if visible:
		_build_tree()
