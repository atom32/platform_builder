extends CanvasLayer
class_name DungeonDeploymentMenu

## Dungeon deployment menu - shows "Sortie" button at top of screen
## Info is displayed as 3D bubble on the target platform

signal deployment_confirmed(platform: Platform)
signal deployment_cancelled()

@onready var control_node = $Control
@onready var sortie_button = $Control/SortieButton

var target_platform: Platform = null

func _ready():
	print("[DungeonDeploymentMenu] _ready() called!")

	# Position sortie button at top center of screen
	var viewport_size = get_viewport().get_visible_rect().size
	var button_width = 200
	var button_height = 60

	sortie_button.position = Vector2(
		(viewport_size.x - button_width) / 2,  # Center horizontally
		20.0  # 20px from top
	)

	# Verify signal connection
	if sortie_button.pressed.is_connected(_on_confirm_pressed):
		print("[DungeonDeploymentMenu] ✓ Signal connected correctly!")
	else:
		print("[DungeonDeploymentMenu] ✗ Signal NOT connected! Connecting manually...")
		sortie_button.pressed.connect(_on_confirm_pressed)

	# Hide initially
	hide()

func _gui_input(event):
	# Check if Control receives input
	if event is InputEventMouseButton:
		print("[DungeonDeploymentMenu] Control received mouse event: ", event.button_index, " pressed: ", event.pressed)

## Show deployment menu for target platform
func show_for_platform(platform: Platform):
	if not platform or not is_instance_valid(platform):
		push_error("Invalid platform for dungeon deployment")
		return

	target_platform = platform

	# Calculate path and difficulty
	var path = DungeonPathfinder.get_path_to_hq(platform)
	var difficulty_info = DungeonPathfinder.calculate_difficulty(path)

	# Show info on platform as 3D label
	var info_dict = {
		"path_str": DungeonPathfinder.get_path_string(path),
		"layers": difficulty_info["layers"],
		"difficulty": _get_difficulty_text(difficulty_info["difficulty"]),
		"estimated_time": difficulty_info["estimated_time"]
	}
	target_platform.show_dungeon_info(info_dict)

	# Show sortie button at top of screen
	show()

## Hide deployment menu and clear platform info
func hide_menu():
	if target_platform and is_instance_valid(target_platform):
		target_platform.hide_dungeon_info()
	target_platform = null
	hide()

## Get difficulty display text
func _get_difficulty_text(difficulty: String) -> String:
	match difficulty:
		"easy":
			return "简单"
		"medium":
			return "中等"
		"hard":
			return "困难"
		_:
			return "未知"

func _on_confirm_pressed():
	print("[DungeonDeploymentMenu] Confirm button pressed!")
	print("[DungeonDeploymentMenu] Target platform: ", target_platform)

	if target_platform and is_instance_valid(target_platform):
		print("[DungeonDeploymentMenu] Hiding dungeon info and emitting signal")
		target_platform.hide_dungeon_info()
		deployment_confirmed.emit(target_platform)
		# Don't clear target_platform yet, it's needed in _on_party_selected
		hide()
	else:
		print("[DungeonDeploymentMenu] ERROR: Invalid target platform!")
