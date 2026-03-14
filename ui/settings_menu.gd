extends Control
class_name SettingsMenu

## Settings Menu
## Allows players to configure game options

## Settings state (pending changes, not yet applied)
var _pending_config: ConfigData

## Node references (will be set in _ready)
var title_label: Label
var close_button: Button
var language_option: OptionButton
var debug_check: CheckBox
var apply_button: Button

func _ready():
	hide()

	# Find nodes using get_node() to handle dynamic paths
	print("[SettingsMenu] Initializing settings menu...")

	var canvas_layer = get_node_or_null("CanvasLayer")
	if canvas_layer:
		var panel = canvas_layer.get_node_or_null("Panel")
		if panel:
			var vbox = panel.get_node_or_null("VBoxContainer")
			if vbox:
				var header = vbox.get_node_or_null("Header")
				if header:
					title_label = header.get_node_or_null("TitleLabel")
					close_button = header.get_node_or_null("CloseButton")

				var lang_section = vbox.get_node_or_null("LanguageSection")
				if lang_section:
					language_option = lang_section.get_node_or_null("LanguageOptionButton")

				var debug_section = vbox.get_node_or_null("DebugSection")
				if debug_section:
					debug_check = debug_section.get_node_or_null("DebugCheckButton")

				apply_button = vbox.get_node_or_null("ApplyButton")

	# Debug: Check if all nodes were found
	print("[SettingsMenu] Nodes found - Title: ", title_label != null, " Close: ", close_button != null, " Apply: ", apply_button != null, " Lang: ", language_option != null, " Debug: ", debug_check != null)

	# Load current settings
	_load_current_config()

	# Connect signals
	_connect_signals()

	# Populate language options
	_populate_language_options()
	print("[SettingsMenu] Settings menu initialized")

## Show settings menu
func show_menu():
	_load_current_config()
	_update_ui_labels()
	show()
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[SettingsMenu] Menu opened")

## Hide settings menu
func hide_menu():
	print("[SettingsMenu] Closing menu...")
	hide()
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT

	# Queue for deletion after current frame
	call_deferred("queue_free")
	print("[SettingsMenu] Menu closed and queued for deletion")

## Load current config into UI
func _load_current_config():
	var config_system = get_node_or_null("/root/ConfigSystem")
	if config_system:
		_pending_config = config_system.get_config()
		print("[SettingsMenu] Loaded config: ", _pending_config.get_as_string())
	else:
		print("[SettingsMenu] WARNING: ConfigSystem not found, using defaults")
		_pending_config = ConfigData.new()

	_update_ui()

## Update UI elements
func _update_ui():
	_update_language_option()
	_update_debug_check()

## Connect all signals
func _connect_signals():
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		print("[SettingsMenu] Close button connected")
	if apply_button:
		apply_button.pressed.connect(_on_apply_pressed)
		print("[SettingsMenu] Apply button connected")
	if language_option:
		language_option.item_selected.connect(_on_language_selected)
		print("[SettingsMenu] Language option connected")
	if debug_check:
		debug_check.toggled.connect(_on_debug_toggled)
		print("[SettingsMenu] Debug check connected")

## Update UI labels based on current language
func _update_ui_labels():
	var text_data = get_node_or_null("/root/TextData")
	if not text_data:
		return

	if title_label:
		title_label.text = "SETTINGS" if text_data.get_current_language() == "en" else "设置"

	if close_button:
		close_button.text = "X"

	# Find language and debug labels dynamically
	var canvas_layer = get_node_or_null("CanvasLayer")
	if canvas_layer:
		var panel = canvas_layer.get_node_or_null("Panel")
		if panel:
			var vbox = panel.get_node_or_null("VBoxContainer")
			if vbox:
				var lang_section = vbox.get_node_or_null("LanguageSection")
				if lang_section:
					var lang_label = lang_section.get_node_or_null("LanguageLabel")
					if lang_label:
						lang_label.text = "Language:" if text_data.get_current_language() == "en" else "语言:"

				var debug_section = vbox.get_node_or_null("DebugSection")
				if debug_section:
					var debug_label = debug_section.get_node_or_null("DebugLabel")
					if debug_label:
						debug_label.text = "Debug Mode:" if text_data.get_current_language() == "en" else "调试模式:"

	if debug_check:
		debug_check.text = "Enable Debug Mode" if text_data.get_current_language() == "en" else "启用调试模式"

	if apply_button:
		apply_button.text = "APPLY & RETURN" if text_data.get_current_language() == "en" else "应用并返回"

## Populate language dropdown
func _populate_language_options():
	if not language_option:
		return

	language_option.clear()

	var config_system = get_node_or_null("/root/ConfigSystem")
	if config_system:
		var languages = config_system.get_available_languages()
		for i in range(languages.size()):
			var lang_code = languages[i]
			var lang_name = config_system.get_language_display_name(lang_code)
			language_option.add_item(lang_name)
			if lang_code == _pending_config.language:
				language_option.selected = i
	else:
		# Fallback to TextData
		var text_data = get_node_or_null("/root/TextData")
		if text_data:
			var languages = text_data.get_available_languages()
			for i in range(languages.size()):
				var lang_code = languages[i]
				var lang_name = text_data.get_language_name(lang_code)
				language_option.add_item(lang_name)
				if lang_code == _pending_config.language:
					language_option.selected = i

## Update language selection
func _update_language_option():
	if language_option:
		var config_system = get_node_or_null("/root/ConfigSystem")
		if config_system:
			var languages = config_system.get_available_languages()
			for i in range(languages.size()):
				if languages[i] == _pending_config.language:
					language_option.selected = i
					break
		else:
			# Fallback to TextData
			var text_data = get_node_or_null("/root/TextData")
			if text_data:
				var languages = text_data.get_available_languages()
				for i in range(languages.size()):
					if languages[i] == _pending_config.language:
						language_option.selected = i
						break

## Update debug checkbox
func _update_debug_check():
	if debug_check:
		debug_check.button_pressed = _pending_config.debug_mode

## Handle language selection
func _on_language_selected(index: int):
	var config_system = get_node_or_null("/root/ConfigSystem")
	if config_system:
		var languages = config_system.get_available_languages()
		if index >= 0 and index < languages.size():
			_pending_config.language = languages[index]
	else:
		# Fallback to TextData
		var text_data = get_node_or_null("/root/TextData")
		if text_data:
			var languages = text_data.get_available_languages()
			if index >= 0 and index < languages.size():
				_pending_config.language = languages[index]

## Handle debug checkbox toggle
func _on_debug_toggled(toggled_on: bool):
	_pending_config.debug_mode = toggled_on

## Handle apply button
func _on_apply_pressed():
	print("[SettingsMenu] Apply button pressed")
	_apply_settings()
	hide_menu()

## Handle close button
func _on_close_pressed():
	print("[SettingsMenu] Close button pressed")
	hide_menu()

## Apply settings to ConfigSystem
func _apply_settings():
	var config_system = get_node_or_null("/root/ConfigSystem")
	if config_system:
		# Apply all settings through ConfigSystem
		config_system.save_config(_pending_config)
		print("[SettingsMenu] Settings saved to ConfigSystem: ", _pending_config.get_as_string())
	else:
		push_error("[SettingsMenu] ConfigSystem not found! Settings cannot be applied.")

		# Fallback: Apply language directly to TextData
		var text_data = get_node_or_null("/root/TextData")
		if text_data and text_data.has_method("set_language"):
			if _pending_config.language != text_data.get_current_language():
				text_data.set_language(_pending_config.language)
				print("[SettingsMenu] Language applied to TextData (fallback): ", _pending_config.language)
