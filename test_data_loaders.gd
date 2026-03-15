# test_data_loaders.gd
# Simple test script to verify JSON loaders work correctly
# Run this script from the command line: godot --script test_data_loaders.gd

extends SceneTree

func _init():
	print("=== Testing Data Loaders ===")
	print("")

	# Test 1: DataLoader base class
	print("Test 1: DataLoader base class")
	var data_loader = load("res://scripts/data_loader.gd").new()
	print("DataLoader loaded successfully")
	print("")

	# Test 2: GameConstantsLoader
	print("Test 2: GameConstantsLoader")
	var game_constants = load("res://scripts/game_constants_loader.gd").new()
	var constants = game_constants.load_constants()
	if not constants.is_empty():
		print("Game constants loaded successfully")
		print("Max platforms per department: ", constants["platform_limits"]["max_platforms_per_department"])
		print("Recruit cost: ", constants["staff_economy"]["recruit_cost_gmp"])
	else:
		print("ERROR: Failed to load game constants")
	print("")

	# Test 3: Starting resources
	print("Test 3: Starting Resources")
	var starting_resources = game_constants.load_starting_resources()
	if not starting_resources.is_empty():
		print("Starting resources loaded successfully")
		print("Materials: ", starting_resources["resources"]["materials"])
		print("Fuel: ", starting_resources["resources"]["fuel"])
		print("GMP: ", starting_resources["resources"]["gmp"])
	else:
		print("ERROR: Failed to load starting resources")
	print("")

	# Test 4: Camera settings
	print("Test 4: Camera Settings")
	var camera_settings = game_constants.load_camera_settings()
	if not camera_settings.is_empty():
		print("Camera settings loaded successfully")
		print("Min distance: ", camera_settings["zoom"]["min_distance"])
		print("Max distance: ", camera_settings["zoom"]["max_distance"])
	else:
		print("ERROR: Failed to load camera settings")
	print("")

	# Test 5: StoryLoader
	print("Test 5: StoryLoader")
	var story_loader = load("res://scripts/story_loader.gd").new()
	var story_data = story_loader.load_story_chapters("en")
	if not story_data.is_empty():
		print("Story data loaded successfully")
		print("Number of chapters: ", story_data["chapters"].size() if story_data.has("chapters") else 0)
	else:
		print("WARNING: Story data not loaded (file may not exist yet)")
	print("")

	print("=== All Tests Complete ===")
	quit()
