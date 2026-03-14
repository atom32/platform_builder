extends Node

## Test script for ConfigSystem
## Run this script to verify configuration system functionality

func _ready():
	print("=== ConfigSystem Test Script ===")
	_test_config_system()
	print("=== Test Complete ===")

## Test ConfigSystem functionality
func _test_config_system():
	var config_system = get_node_or_null("/root/ConfigSystem")
	if not config_system:
		push_error("ConfigSystem not found!")
		return

	# Test 1: Verify default values
	print("\n[Test 1] Default Values")
	print("Language: ", config_system.language)
	print("Debug Mode: ", config_system.debug_mode)
	assert(config_system.language == "en", "Default language should be 'en'")
	assert(config_system.debug_mode == false, "Default debug_mode should be false")
	print("✓ Default values correct")

	# Test 2: Change settings using ConfigData
	print("\n[Test 2] Change Settings with ConfigData")
	var test_config = ConfigData.new("zh", true, 0.8, 0.9)
	config_system.save_config(test_config)
	print("Language changed to: ", config_system.language)
	print("Debug mode changed to: ", config_system.debug_mode)
	assert(config_system.language == "zh", "Language should be 'zh'")
	assert(config_system.debug_mode == true, "Debug mode should be true")
	print("✓ Settings changed successfully")

	# Test 3: Verify TextData was updated
	print("\n[Test 3] TextData Integration")
	var text_data = get_node_or_null("/root/TextData")
	if text_data:
		print("TextData language: ", text_data.get_current_language())
		assert(text_data.get_current_language() == "zh", "TextData should be updated to 'zh'")
		print("✓ TextData updated correctly")
	else:
		push_error("TextData not found!")

	# Test 4: Verify ResourceSystem was updated
	print("\n[Test 4] ResourceSystem Integration")
	var resource_system = get_node_or_null("/root/ResourceSystem")
	if resource_system:
		print("ResourceSystem debug_mode: ", resource_system.debug_mode)
		assert(resource_system.debug_mode == true, "ResourceSystem should have debug_mode=true")
		print("✓ ResourceSystem updated correctly")
	else:
		push_error("ResourceSystem not found!")

	# Test 5: Reset to defaults
	print("\n[Test 5] Reset to Defaults")
	config_system.reset_to_defaults()
	print("Language reset to: ", config_system.language)
	print("Debug mode reset to: ", config_system.debug_mode)
	assert(config_system.language == "en", "Language should reset to 'en'")
	assert(config_system.debug_mode == false, "Debug mode should reset to false")
	print("✓ Reset successful")

	# Test 6: Verify file persistence
	print("\n[Test 6] File Persistence")
	var persist_config = ConfigData.new("zh", true)
	config_system.save_config(persist_config)
	print("Settings saved. Check user://settings.cfg file.")
	var config_file = ConfigFile.new()
	var err = config_file.load("user://settings.cfg")
	if err == OK:
		var saved_lang = config_file.get_value("general", "language", "")
		var saved_debug = config_file.get_value("general", "debug_mode", false)
		print("Saved language: ", saved_lang)
		print("Saved debug_mode: ", saved_debug)
		assert(saved_lang == "zh", "Saved language should be 'zh'")
		assert(saved_debug == true, "Saved debug_mode should be true")
		print("✓ File persistence working")
	else:
		push_error("Failed to load config file!")

	# Test 7: Test get_config() and clone()
	print("\n[Test 7] ConfigData Cloning")
	var config1 = config_system.get_config()
	var config2 = config_system.get_config()
	print("Config1: ", config1.get_as_string())
	print("Config2: ", config2.get_as_string())
	# Modify config1
	config1.language = "en"
	# Config2 should be unchanged (they are separate objects)
	assert(config2.language == "zh", "Config2 should not be affected by config1 changes")
	print("✓ ConfigData cloning works correctly")

	# Test 8: Test apply_config() without saving
	print("\n[Test 8] Apply Config Without Saving")
	var temp_config = ConfigData.new("en", false, 0.5, 0.5)
	config_system.apply_config(temp_config)
	print("Applied temporary config (not saved)")
	# Reload from file to verify it wasn't saved
	var config_file2 = ConfigFile.new()
	var err2 = config_file2.load("user://settings.cfg")
	if err2 == OK:
		var saved_lang = config_file2.get_value("general", "language", "")
		assert(saved_lang == "zh", "File should still have 'zh' from Test 6")
		print("✓ apply_config() doesn't save to file")
	else:
		push_error("Failed to load config file!")

	print("\n=== All Tests Passed! ===")
