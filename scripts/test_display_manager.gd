extends SceneTree

## Test script for DisplayManager
## Run with: godot --script test_display_manager.gd

func _init():
	print("=== DisplayManager Test Suite ===\n")

	_test_screen_size()
	_test_available_resolutions()
	_test_validation()
	# Note: Skipping resolution application test in headless mode
	# _test_resolution_application()

	print("\n=== All Tests Completed ===")
	quit()

func _test_screen_size():
	print("Test 1: Get Screen Size")
	var size = DisplayManager.get_screen_size()
	print("  Screen size: %dx%d" % [size.x, size.y])
	assert(size.x > 0 and size.y > 0, "Invalid screen size")
	print("  PASS\n")

func _test_available_resolutions():
	print("Test 2: Get Available Resolutions")
	var resolutions = DisplayManager.get_available_resolutions()
	print("  Available resolutions: %d" % resolutions.size())
	for res in resolutions:
		print("    - %dx%d" % [res.x, res.y])
	assert(resolutions.size() > 0, "No available resolutions")
	print("  PASS\n")

func _test_validation():
	print("Test 3: Resolution Validation")
	var screen_size = DisplayManager.get_screen_size()
	var tests = [
		[Vector2i(100, 100), Vector2i(800, 600), "Too small"],
		[Vector2i(10000, 10000), screen_size, "Too large"],
		[Vector2i(1920, 1080), Vector2i(1920, 1080), "Valid"]
	]

	for test in tests:
		var input = test[0]
		var expected = test[1]
		var desc = test[2]
		var result = DisplayManager.validate_resolution(input)
		print("  %s: %dx%d -> %dx%d (expected %dx%d)" % \
			  [desc, input.x, input.y, result.x, result.y, expected.x, expected.y])
		assert(result == expected, "Validation failed for %s" % desc)

	print("  PASS\n")
