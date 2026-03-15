# scripts/data_loader.gd
# Base class for all data loaders in the unified data architecture.
# Provides common JSON loading functionality with error handling and fallback support.

extends Node
class_name DataLoader

const DATA_PATH = "res://data/"
const VERSION_KEY = "version"

## Load a JSON file from the data directory with error handling
## Returns empty Dictionary if file not found or parsing fails
func load_json_file(relative_path: String) -> Dictionary:
	var full_path = DATA_PATH + relative_path
	var file = FileAccess.open(full_path, FileAccess.READ)

	if not file:
		push_error("[DataLoader] Failed to open file: %s" % full_path)
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("[DataLoader] JSON parse error in %s: %s at line %d" % [full_path, json.get_error_message(), json.get_error_line()])
		return {}

	return json.data

## Check if a data file exists
func file_exists(relative_path: String) -> bool:
	var full_path = DATA_PATH + relative_path
	return FileAccess.file_exists(full_path)

## Validate required fields in loaded data
## Returns true if all required fields are present
func validate_required_fields(data: Dictionary, required_fields: Array[String]) -> bool:
	for field in required_fields:
		if not data.has(field):
			push_error("[DataLoader] Missing required field: %s" % field)
			return false
	return true

## Get data version from JSON file
## Returns empty string if version not specified
func get_data_version(relative_path: String) -> String:
	var data = load_json_file(relative_path)
	if data.has(VERSION_KEY):
		return data[VERSION_KEY]
	return ""
