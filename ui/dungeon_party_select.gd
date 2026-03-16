extends Control

## Party selection UI for dungeon expeditions

signal party_selected(party: Array[Staff])
signal selection_cancelled()

const MAX_PARTY_SIZE: int = 4

@onready var available_list = $VBoxContainer/HSplitContainer/AvailablePanel/ScrollContainer/AvailableList
@onready var selected_list = $VBoxContainer/HSplitContainer/SelectedPanel/ScrollContainer/SelectedList
@onready var confirm_button = $ButtonContainer/ConfirmButton
@onready var cancel_button = $ButtonContainer/CancelButton
@onready var title_label = $VBoxContainer/TitleLabel

var available_staff: Array[Staff] = []
var selected_party: Array[Staff] = []
var staff_buttons: Dictionary = {}  # Staff -> Button

func _ready():
	# NOTE: Button signals are already connected in .tscn file
	# Do NOT connect them again here to avoid double-calling

	# Update button states
	_update_confirm_button()

	# Hide initially
	hide()

## Show party selection dialog
func show_party_selection(recommended_count: int = 2):
	# Get available staff
	var dept_system = get_node_or_null("/root/DepartmentSystem")
	if not dept_system:
		print("[DungeonPartySelect] ERROR: DepartmentSystem not found")
		return

	available_staff = dept_system.get_available_staff()
	selected_party.clear()

	# Update UI
	title_label.text = "选择出战人员 (0/%d)" % MAX_PARTY_SIZE
	_refresh_available_list()
	_refresh_selected_list()

	show()

## Refresh the available staff list
func _refresh_available_list():
	# Clear existing buttons
	for child in available_list.get_children():
		child.queue_free()

	staff_buttons.clear()

	# Add buttons for each available staff
	for staff in available_staff:
		if staff in selected_party:
			continue  # Skip already selected

		var button = Button.new()
		button.text = _get_staff_button_text(staff)
		button.pressed.connect(_on_staff_selected.bind(staff))

		available_list.add_child(button)
		staff_buttons[staff] = button

## Refresh the selected party list
func _refresh_selected_list():
	# Clear existing
	for child in selected_list.get_children():
		child.queue_free()

	# Add selected staff
	for staff in selected_party:
		var button = Button.new()
		button.text = _get_staff_button_text(staff) + " [移除]"
		button.pressed.connect(_on_staff_removed.bind(staff))

		selected_list.add_child(button)

	# Update title
	title_label.text = "选择出战人员 (%d/%d)" % [selected_party.size(), MAX_PARTY_SIZE]

	_update_confirm_button()

## Get staff button display text
func _get_staff_button_text(staff: Staff) -> String:
	var dept = staff.get_department_display()
	var status = ""

	if not staff.is_available:
		status = " [受伤]"
	elif staff.is_wounded:
		status = " [受伤]"

	return "%s %s | %s | HP %d/%d%s" % [
		staff.first_name,
		staff.last_name,
		dept,
		staff.hp,
		staff.max_hp,
		status
	]

## Handle staff selection
func _on_staff_selected(staff: Staff):
	if selected_party.size() >= MAX_PARTY_SIZE:
		return  # Party full

	if staff in selected_party:
		return  # Already selected

	selected_party.append(staff)
	_refresh_available_list()
	_refresh_selected_list()

## Handle staff removal
func _on_staff_removed(staff: Staff):
	selected_party.erase(staff)
	_refresh_available_list()
	_refresh_selected_list()

## Update confirm button state
func _update_confirm_button():
	var can_confirm = selected_party.size() > 0
	confirm_button.disabled = not can_confirm

	if can_confirm:
		confirm_button.text = "确认出征 (%d人)" % selected_party.size()
	else:
		confirm_button.text = "确认出征 (至少需要1人)"

func _on_confirm_pressed():
	party_selected.emit(selected_party)
	hide()

func _on_cancel_pressed():
	selection_cancelled.emit()
	hide()
