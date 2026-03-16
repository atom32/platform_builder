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
var resolution_option: OptionButton
var display_mode_option: OptionButton
var vsync_check: CheckBox
var borderless_check: CheckBox
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

				var resolution_section = vbox.get_node_or_null("ResolutionSection")
				if resolution_section:
					resolution_option = resolution_section.get_node_or_null("ResolutionOptionButton")

				var display_mode_section = vbox.get_node_or_null("DisplayModeSection")
				if display_mode_section:
					display_mode_option = display_mode_section.get_node_or_null("DisplayModeOptionButton")

				var vsync_section = vbox.get_node_or_null("VSyncSection")
				if vsync_section:
					vsync_check = vsync_section.get_node_or_null("VSyncCheckButton")

				var borderless_section = vbox.get_node_or_null("BorderlessSection")
				if borderless_section:
					borderless_check = borderless_section.get_node_or_null("BorderlessCheckButton")

				apply_button = vbox.get_node_or_null("ApplyButton")

	# Debug: Check if all nodes were found
	print("[SettingsMenu] Nodes found - Title: ", title_label != null, " Close: ", close_button != null, " Apply: ", apply_button != null, " Lang: ", language_option != null, " Debug: ", debug_check != null, " Res: ", resolution_option != null, " Mode: ", display_mode_option != null, " VSync: ", vsync_check != null, " Borderless: ", borderless_check != null)

	# Load current settings
	_load_current_config()

	# Connect signals
	_connect_signals()

	# Populate language options
	_populate_language_options()

	# Initialize display options once (options don't change at runtime)
	_populate_resolution_options()
	_populate_display_mode_options()

	print("[SettingsMenu] Settings menu initialized")

## Show settings menu
func show_menu():
	_load_current_config()
	_update_ui_labels()
	_update_display_settings_ui()
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
	_update_display_settings_ui()

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
	if resolution_option:
		resolution_option.item_selected.connect(_on_resolution_selected)
		print("[SettingsMenu] Resolution option connected")
	if display_mode_option:
		display_mode_option.item_selected.connect(_on_display_mode_selected)
		print("[SettingsMenu] Display mode option connected")
	if vsync_check:
		vsync_check.toggled.connect(_on_vsync_toggled)
		print("[SettingsMenu] VSync check connected")
	if borderless_check:
		borderless_check.toggled.connect(_on_borderless_toggled)
		print("[SettingsMenu] Borderless check connected")

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

				var resolution_section = vbox.get_node_or_null("ResolutionSection")
				if resolution_section:
					var res_label = resolution_section.get_node_or_null("ResolutionLabel")
					if res_label:
						res_label.text = "Resolution:" if text_data.get_current_language() == "en" else "分辨率:"

				var display_mode_section = vbox.get_node_or_null("DisplayModeSection")
				if display_mode_section:
					var mode_label = display_mode_section.get_node_or_null("DisplayModeLabel")
					if mode_label:
						mode_label.text = "Display Mode:" if text_data.get_current_language() == "en" else "显示模式:"

				var vsync_section = vbox.get_node_or_null("VSyncSection")
				if vsync_section:
					var vsync_label = vsync_section.get_node_or_null("VSyncLabel")
					if vsync_label:
						vsync_label.text = "V-Sync:" if text_data.get_current_language() == "en" else "垂直同步:"

				var borderless_section = vbox.get_node_or_null("BorderlessSection")
				if borderless_section:
					var borderless_label = borderless_section.get_node_or_null("BorderlessLabel")
					if borderless_label:
						borderless_label.text = "Borderless:" if text_data.get_current_language() == "en" else "无边框:"

	if debug_check:
		debug_check.text = "Enable Debug Mode" if text_data.get_current_language() == "en" else "启用调试模式"

	if vsync_check:
		vsync_check.text = "Enable V-Sync" if text_data.get_current_language() == "en" else "启用垂直同步"

	if borderless_check:
		borderless_check.text = "Enable Borderless" if text_data.get_current_language() == "en" else "启用无边框"

	if display_mode_option:
		display_mode_option.set_item_text(0, "Windowed" if text_data.get_current_language() == "en" else "窗口模式")
		display_mode_option.set_item_text(1, "Fullscreen" if text_data.get_current_language() == "en" else "全屏模式")
		display_mode_option.set_item_text(2, "Exclusive Fullscreen" if text_data.get_current_language() == "en" else "独占全屏")

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

## Populate resolution dropdown
func _populate_resolution_options():
	if not resolution_option:
		return

	resolution_option.clear()

	# Use DisplayManager to get available resolutions
	var resolutions = DisplayManager.get_available_resolutions()
	for res in resolutions:
		var text = "%dx%d" % [res.x, res.y]
		resolution_option.add_item(text)

	# Select current resolution
	var current_index = _find_resolution_index(_pending_config.resolution_x, _pending_config.resolution_y)
	if current_index >= 0:
		resolution_option.selected = current_index

## Populate display mode dropdown
func _populate_display_mode_options():
	if not display_mode_option:
		return

	display_mode_option.clear()
	display_mode_option.add_item("Windowed")
	display_mode_option.add_item("Fullscreen")
	display_mode_option.add_item("Exclusive Fullscreen")

	display_mode_option.selected = _pending_config.fullscreen_mode

## Update display settings UI
func _update_display_settings_ui():
	if vsync_check:
		vsync_check.button_pressed = _pending_config.vsync_enabled
	if borderless_check:
		borderless_check.button_pressed = _pending_config.borderless_window

## Find resolution index in dropdown
func _find_resolution_index(x: int, y: int) -> int:
	if not resolution_option:
		return -1

	for i in range(resolution_option.item_count):
		var text = resolution_option.get_item_text(i)
		var parts = text.split("x")
		if parts.size() == 2:
			var res_x = parts[0].to_int()
			var res_y = parts[1].to_int()
			if res_x == x and res_y == y:
				return i
	return -1

## Handle resolution selection
func _on_resolution_selected(index: int):
	if resolution_option and index >= 0:
		var text = resolution_option.get_item_text(index)
		var parts = text.split("x")
		if parts.size() == 2:
			_pending_config.resolution_x = parts[0].to_int()
			_pending_config.resolution_y = parts[1].to_int()
			print("[SettingsMenu] Resolution selected: %dx%d" % [_pending_config.resolution_x, _pending_config.resolution_y])

## Handle display mode selection
func _on_display_mode_selected(index: int):
	if display_mode_option and index >= 0:
		_pending_config.fullscreen_mode = index
		print("[SettingsMenu] Display mode selected: %d" % index)

## Handle VSync toggle
func _on_vsync_toggled(toggled_on: bool):
	_pending_config.vsync_enabled = toggled_on
	print("[SettingsMenu] VSync toggled: %s" % toggled_on)

## Handle borderless toggle
func _on_borderless_toggled(toggled_on: bool):
	_pending_config.borderless_window = toggled_on
	print("[SettingsMenu] Borderless toggled: %s" % toggled_on)
