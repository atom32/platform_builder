extends Node

## Display Manager
## Handles all display-related operations
## Singleton autoload - independent module for display settings

## Common gaming resolutions
const COMMON_RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

## Display mode constants
const MODE_WINDOWED = 0
const MODE_FULLSCREEN = 1
const MODE_EXCLUSIVE_FULLSCREEN = 2

## Get current screen size
static func get_screen_size() -> Vector2i:
	return DisplayServer.screen_get_size()

## Get available resolutions for current screen
static func get_available_resolutions() -> Array[Vector2i]:
	var screen_size = get_screen_size()
	var available: Array[Vector2i] = []

	for res in COMMON_RESOLUTIONS:
		if res.x <= screen_size.x and res.y <= screen_size.y:
			available.append(res)

	return available

## Validate and clamp resolution to safe bounds
static func validate_resolution(res: Vector2i) -> Vector2i:
	var screen_size = get_screen_size()
	var min_size = Vector2i(800, 600)

	return Vector2i(
		clamp(res.x, min_size.x, screen_size.x),
		clamp(res.y, min_size.y, screen_size.y)
	)

## Apply resolution change
static func apply_resolution(width: int, height: int) -> bool:
	if OS.has_feature("mobile"):
		print("[DisplayManager] Mobile detected, ignoring resolution change")
		return false

	var target_size = validate_resolution(Vector2i(width, height))
	DisplayServer.window_set_size(target_size)
	print("[DisplayManager] Resolution set to %dx%d" % [target_size.x, target_size.y])
	return true

## Apply fullscreen mode
static func apply_fullscreen_mode(mode: int) -> bool:
	if OS.has_feature("mobile"):
		print("[DisplayManager] Mobile detected, ignoring fullscreen mode")
		return false

	DisplayServer.window_set_mode(mode)
	print("[DisplayManager] Fullscreen mode set to %d" % mode)
	return true

## Apply vsync
static func apply_vsync(enabled: bool) -> bool:
	if OS.has_feature("mobile"):
		print("[DisplayManager] Mobile detected, ignoring VSync change")
		return false

	var vsync_mode = DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)
	print("[DisplayManager] VSync %s" % ("enabled" if enabled else "disabled"))
	return true

## Apply borderless window
static func apply_borderless(enabled: bool) -> bool:
	if OS.has_feature("mobile"):
		print("[DisplayManager] Mobile detected, ignoring borderless change")
		return false

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, enabled)
	print("[DisplayManager] Borderless %s" % ("enabled" if enabled else "disabled"))
	return true

## Get current window mode
static func get_current_mode() -> int:
	return DisplayServer.window_get_mode()

## Is mobile platform?
static func is_mobile() -> bool:
	return OS.has_feature("mobile")
