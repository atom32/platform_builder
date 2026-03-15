# scripts/story_loader.gd
# Loads story chapter data with multi-language support.
# Automatically selects story file based on ConfigSystem.language.
# Falls back to English if translated file is missing.

extends DataLoader

const STORY_DIR = "story/"
const STORY_FILE_PATTERN = "story_chapters_%s.json"
const DEFAULT_LANGUAGE = "en"

## Load story chapters for the current language (or specified language)
## Automatically falls back to English if translation is missing
func load_story_chapters(language: String = "") -> Dictionary:
	# Determine which language to use
	if language.is_empty():
		var config = get_node_or_null("/root/ConfigSystem")
		if config:
			language = config.language
		else:
			language = DEFAULT_LANGUAGE

	var filename = STORY_DIR + STORY_FILE_PATTERN % language
	var data = load_json_file(filename)

	# Fallback to English if translation is missing
	if data.is_empty() and language != DEFAULT_LANGUAGE:
		push_warning("[StoryLoader] Translation for '%s' not found, falling back to English" % language)
		return load_story_chapters(DEFAULT_LANGUAGE)

	return data

## Load a specific chapter by ID
## Returns empty Dictionary if chapter not found
func load_chapter_by_id(chapter_id: String, language: String = "") -> Dictionary:
	var all_data = load_story_chapters(language)

	if not all_data.has("chapters"):
		push_error("[StoryLoader] Invalid story data format: missing 'chapters' array")
		return {}

	for chapter in all_data["chapters"]:
		if chapter.has("id") and chapter["id"] == chapter_id:
			return chapter

	push_error("[StoryLoader] Chapter not found: %s" % chapter_id)
	return {}

## Get list of all chapter IDs
func get_chapter_list(language: String = "") -> Array:
	var all_data = load_story_chapters(language)
	var chapter_ids: Array = []

	if all_data.has("chapters"):
		for chapter in all_data["chapters"]:
			if chapter.has("id"):
				chapter_ids.append(chapter["id"])

	return chapter_ids

## Check if a chapter exists
func chapter_exists(chapter_id: String, language: String = "") -> bool:
	var chapter = load_chapter_by_id(chapter_id, language)
	return not chapter.is_empty()

## Get available languages for story data
## Returns array of language codes that have story files
func get_available_languages() -> Array[String]:
	var languages: Array[String] = []
	var config_languages = ["en", "zh"]  # Supported languages

	for lang in config_languages:
		var filename = STORY_DIR + STORY_FILE_PATTERN % lang
		if file_exists(filename):
			languages.append(lang)

	return languages
