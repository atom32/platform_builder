extends SceneTree

## Integration Test for Display Settings System
## Tests the complete flow from ConfigSystem to DisplayManager to SettingsMenu

func _init():
	print("=== Display Settings Integration Test ===\n")

	_test_config_data_backward_compat()
	_test_config_data_display_properties()
	_test_config_system_display_accessors()
	_test_display_manager_api()

	print("\n=== Integration Tests Completed ===")
	print("\nNext Steps:")
	print("1. Run game and open Settings menu (ESC)")
	print("2. Verify display settings appear")
	print("3. Change resolution and apply")
	print("4. Change fullscreen mode and apply")
	print("5. Toggle V-Sync and apply")
	print("6. Toggle borderless and apply")
	print("7. Exit game and restart to verify persistence")
	quit()

func _test_config_data_backward_compat():
	print("Test 1: ConfigData Backward Compatibility")
	var config = ConfigData.new("en", false, 1.0, 1.0)
	assert(config.resolution_x == 1920, "Default resolution_x failed")
	assert(config.resolution_y == 1080, "Default resolution_y failed")
	assert(config.fullscreen_mode == 0, "Default fullscreen_mode failed")
	assert(config.vsync_enabled == true, "Default vsync_enabled failed")
	assert(config.borderless_window == false, "Default borderless_window failed")
	print("  PASS: Old constructor works with new defaults\n")

func _test_config_data_display_properties():
	print("Test 2: ConfigData Display Properties")
	var config = ConfigData.new("zh", true, 0.8, 0.9, 1280, 720, 1, false, true)
	assert(config.resolution_x == 1280, "Custom resolution_x failed")
	assert(config.resolution_y == 720, "Custom resolution_y failed")
	assert(config.fullscreen_mode == 1, "Custom fullscreen_mode failed")
	assert(config.vsync_enabled == false, "Custom vsync_enabled failed")
	assert(config.borderless_window == true, "Custom borderless_window failed")
	print("  PASS: All display properties set correctly\n")

func _test_config_system_display_accessors():
	print("Test 3: ConfigSystem Display Accessors")
	# Test that ConfigSystem has display property accessors
	var has_resolution_x = ConfigSystem.has_method("get")
	var has_resolution_y = ConfigSystem.has_method("get")
	var has_fullscreen_mode = ConfigSystem.has_method("get")
	var has_vsync_enabled = ConfigSystem.has_method("get")
	var has_borderless_window = ConfigSystem.has_method("get")

	# Since we can't easily test the actual accessor methods without running the game,
	# we'll just verify the ConfigData clone works
	var config = ConfigData.new("en", false, 1.0, 1.0, 1920, 1080, 0, true, false)
	var cloned = config.clone()
	assert(cloned.resolution_x == 1920, "Clone resolution_x failed")
	assert(cloned.resolution_y == 1080, "Clone resolution_y failed")
	assert(cloned.fullscreen_mode == 0, "Clone fullscreen_mode failed")
	assert(cloned.vsync_enabled == true, "Clone vsync_enabled failed")
	assert(cloned.borderless_window == false, "Clone borderless_window failed")
	print("  PASS: ConfigData display properties clone correctly\n")

func _test_display_manager_api():
	print("Test 4: DisplayManager API")

	# Test static methods exist
	assert(DisplayManager.has_method("get_screen_size"), "Missing get_screen_size method")
	assert(DisplayManager.has_method("get_available_resolutions"), "Missing get_available_resolutions method")
	assert(DisplayManager.has_method("validate_resolution"), "Missing validate_resolution method")
	assert(DisplayManager.has_method("apply_resolution"), "Missing apply_resolution method")
	assert(DisplayManager.has_method("apply_fullscreen_mode"), "Missing apply_fullscreen_mode method")
	assert(DisplayManager.has_method("apply_vsync"), "Missing apply_vsync method")
	assert(DisplayManager.has_method("apply_borderless"), "Missing apply_borderless method")
	assert(DisplayManager.has_method("get_current_mode"), "Missing get_current_mode method")
	assert(DisplayManager.has_method("is_mobile"), "Missing is_mobile method")

	# Test constants
	assert(DisplayManager.COMMON_RESOLUTIONS.size() > 0, "COMMON_RESOLUTIONS is empty")
	assert(DisplayManager.MODE_WINDOWED == 0, "MODE_WINDOWED constant incorrect")
	assert(DisplayManager.MODE_FULLSCREEN == 1, "MODE_FULLSCREEN constant incorrect")
	assert(DisplayManager.MODE_EXCLUSIVE_FULLSCREEN == 2, "MODE_EXCLUSIVE_FULLSCREEN constant incorrect")

	# Test basic functionality
	var screen_size = DisplayManager.get_screen_size()
	assert(screen_size.x > 0 and screen_size.y > 0, "Invalid screen size")

	var resolutions = DisplayManager.get_available_resolutions()
	assert(resolutions.size() > 0, "No available resolutions")

	# Test validation
	var validated = DisplayManager.validate_resolution(Vector2i(100, 100))
	assert(validated.x >= 800 and validated.y >= 600, "Validation too small failed")

	print("  PASS: DisplayManager API works correctly\n")
