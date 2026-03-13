extends Control
class_name InternalAffairsPanel

## Internal Affairs Panel
## Unified panel wrapper for Staff and Expedition management
## Shows/hides the appropriate menu based on selected tab

enum Tab {
	STAFF,
	EXPEDITION
}

@onready var header_title = $Panel/VBoxContainer/Header/HeaderTitle
@onready var close_button = $Panel/VBoxContainer/Header/CloseButton
@onready var prev_button = $Panel/VBoxContainer/Navigation/PrevButton
@onready var next_button = $Panel/VBoxContainer/Navigation/NextButton
@onready var current_tab_label = $Panel/VBoxContainer/Navigation/CurrentTabLabel

## Current tab
var current_tab: Tab = Tab.STAFF

## Tab names
const TAB_NAMES = ["STAFF", "EXPEDITION"]

## Reference to staff menu and expedition menu
var staff_menu: Node = null
var expedition_menu: Control = null

func _ready():
	hide()

	# Connect buttons
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if prev_button:
		prev_button.pressed.connect(_on_prev_tab)
	if next_button:
		next_button.pressed.connect(_on_next_tab)

	# Create staff and expedition menus
	_create_menus()

## Create staff and expedition menus
func _create_menus():
	# Load staff menu
	var staff_menu_scene = load("res://ui/staff_menu.tscn")
	if staff_menu_scene:
		staff_menu = staff_menu_scene.instantiate()
		# Add as sibling to InternalAffairsPanel, not as child
		# Use call_deferred to avoid "parent is busy" error
		get_parent().call_deferred("add_child", staff_menu)

	# Load expedition menu
	var expedition_menu_scene = load("res://ui/expedition_menu.tscn")
	if expedition_menu_scene:
		expedition_menu = expedition_menu_scene.instantiate()
		# Add as sibling to InternalAffairsPanel, not as child
		# Use call_deferred to avoid "parent is busy" error
		get_parent().call_deferred("add_child", expedition_menu)

	# Defer finalization until after menus are added and ready
	call_deferred("_finalize_menu_setup")

## Show the panel
func show_panel():
	show()
	_update_tab_display()

## Hide the panel
func hide_panel():
	hide()
	# Also hide the menus
	if staff_menu and is_instance_valid(staff_menu):
		staff_menu.visible = false
	if expedition_menu and is_instance_valid(expedition_menu):
		expedition_menu.visible = false

## Toggle panel visibility
func toggle_panel():
	if visible:
		hide_panel()
	else:
		show_panel()

## Update tab display
func _update_tab_display():
	current_tab_label.text = TAB_NAMES[current_tab]

	# Hide both menus first
	if staff_menu and is_instance_valid(staff_menu):
		staff_menu.visible = false
	if expedition_menu and is_instance_valid(expedition_menu):
		expedition_menu.visible = false

	# Show appropriate menu based on current tab
	match current_tab:
		Tab.STAFF:
			if staff_menu and is_instance_valid(staff_menu):
				staff_menu.visible = true
				if staff_menu.has_method("refresh_lists"):
					staff_menu.refresh_lists()
		Tab.EXPEDITION:
			if expedition_menu and is_instance_valid(expedition_menu):
				expedition_menu.visible = true
				if expedition_menu.has_method("refresh_menu"):
					expedition_menu.refresh_menu()

## Navigate to previous tab
func _on_prev_tab():
	current_tab = (current_tab + 1) % 2  # Wrap around
	_update_tab_display()

## Navigate to next tab
func _on_next_tab():
	current_tab = (current_tab + 1) % 2
	_update_tab_display()

## Handle close button
func _on_close_pressed():
	hide_panel()

## Handle input for keyboard shortcuts
func _input(event):
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		hide_panel()

## Cleanup menus when panel is destroyed
func _exit_tree():
	# Free the menu instances since they're siblings, not children
	if staff_menu and is_instance_valid(staff_menu):
		staff_menu.queue_free()
	if expedition_menu and is_instance_valid(expedition_menu):
		expedition_menu.queue_free()

## Finalize menu setup after they're added to scene tree
func _finalize_menu_setup():
	# Initially hide both
	if staff_menu and is_instance_valid(staff_menu):
		staff_menu.visible = false
	if expedition_menu and is_instance_valid(expedition_menu):
		expedition_menu.visible = false

	# Now update tab display (menus are fully set up)
	_update_tab_display()
