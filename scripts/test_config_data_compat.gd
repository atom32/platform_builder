extends SceneTree

func _init():
	print("=== ConfigData Backward Compatibility Test ===\n")

	_test_old_construction()
	_test_new_construction()
	_test_clone()

	print("\n=== All Tests Passed ===")
	quit()

func _test_old_construction():
	print("Test 1: Old Construction (4 args)")
	var config = ConfigData.new("en", false, 1.0, 1.0)
	print("  Language: %s" % config.language)
	print("  Debug: %s" % config.debug_mode)
	print("  Resolution: %dx%d (should be 1920x1080 default)" % [config.resolution_x, config.resolution_y])
	assert(config.resolution_x == 1920, "Default resolution_x failed")
	assert(config.resolution_y == 1080, "Default resolution_y failed")
	print("  PASS\n")

func _test_new_construction():
	print("Test 2: New Construction (all args)")
	var config = ConfigData.new("zh", true, 0.8, 0.9, 1280, 720, 1, false, true)
	print("  Language: %s" % config.language)
	print("  Resolution: %dx%d" % [config.resolution_x, config.resolution_y])
	print("  Fullscreen Mode: %d" % config.fullscreen_mode)
	assert(config.resolution_x == 1280, "Custom resolution_x failed")
	assert(config.resolution_y == 720, "Custom resolution_y failed")
	print("  PASS\n")

func _test_clone():
	print("Test 3: Clone with Display Settings")
	var config = ConfigData.new("en", true, 1.0, 1.0, 2560, 1440, 2, true, false)
	var cloned = config.clone()
	print("  Original: %s" % config.get_as_string())
	print("  Cloned:  %s" % cloned.get_as_string())
	assert(cloned.resolution_x == 2560, "Clone resolution_x failed")
	assert(cloned.vsync_enabled == true, "Clone vsync failed")
	print("  PASS\n")
