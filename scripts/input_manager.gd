extends Node

## InputManager - Centralized key binding management
## All keyboard shortcuts should be registered and handled here

## Signals for each action
signal recruit_key_pressed()
signal base_management_key_pressed()
signal sidebar_toggle_key_pressed()
signal debug_mode_key_pressed()

func _ready():
	set_process_input(true)

func _input(event):
	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	match event.keycode:
		KEY_R:
			recruit_key_pressed.emit()
		KEY_TAB:
			base_management_key_pressed.emit()
		KEY_H:
			sidebar_toggle_key_pressed.emit()
		KEY_F:
			debug_mode_key_pressed.emit()
