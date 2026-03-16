extends Control

## Dungeon combat UI - displays turn-based combat

signal retreat_pressed()
signal skip_pressed()

## Translation keys
const TRANS = {
	"COMBAT_START": "战斗开始！",
	"TURN_COUNT": "回合: %d",
	"TURN_DAMAGE": "本回合伤害: %d",
	"TOTAL_DAMAGE": "总伤害: %d",
	"LAYER_COMPLETE": "第%d层完成！击败了 %s",
	"MISSION_FAILED": "========== 任务失败 ==========",
	"ALL_DIED": "小队全军覆没...",
	"STAFF_DIED": "%s 牺牲！",
	"CANNOT_RETREAT": "========== 无法撤退 ==========",
	"RETREAT": "========== 撤退 ==========",
	"REWARDS": "保留奖励：",
	"SKIP_TURN": "跳过当前回合...",
	"GMP_REWARD": "GMP: +%d",
	"MATERIALS_REWARD": "Materials: +%d",
	"FUEL_REWARD": "Fuel: +%d",
	"ALL_COMPLETE": "========== 全部通关！==========",
	"GET_REWARDS": "获得奖励："
}

var party_title: Label
var party_hp_bars: VBoxContainer
var layer_label: Label
var enemy_avatar: TextureRect
var enemy_hp_bar: ProgressBar
var enemy_hp_label: Label
var party_avatars: HBoxContainer
var combat_log: TextEdit
var turn_label: Label
var damage_label: Label
var total_damage_label: Label
var retreat_button: Button
var skip_button: Button

var dungeon_system: Node = null
var log_entries: Array[String] = []
var turn_count: int = 1
var total_damage: int = 0

## Asset paths
const ENEMY_ASSETS = {
	"mutated_fish": "res://assets/textures/fish.png",
	"coral_guardian": "res://assets/textures/fish.png",
	"deep_sea_giant": "res://assets/textures/fish.png",
	"void_stalker": "res://assets/textures/fish.png",
	"abyssal_horror": "res://assets/textures/fish.png"
}

const STAFF_ASSETS = {
	"Combat": "res://assets/textures/soldier.png",
	"Medical": "res://assets/textures/soldier.png",
	"R&D": "res://assets/textures/soldier.png",
	"Intel": "res://assets/textures/soldier.png",
	"Support": "res://assets/textures/soldier.png",
	"": "res://assets/textures/soldier.png"
}

func _ready():
	# Manually find all nodes
	var panel = get_node_or_null("Panel")
	if not panel:
		push_error("[DungeonCombatUI] Panel not found!")
		return

	var main_container = panel.get_node_or_null("MainContainer")
	if not main_container:
		push_error("[DungeonCombatUI] MainContainer not found!")
		return

	var left_panel = main_container.get_node_or_null("LeftPanel")
	var center_panel = main_container.get_node_or_null("CenterPanel")
	var right_panel = main_container.get_node_or_null("RightPanel")

	if left_panel:
		party_title = left_panel.get_node_or_null("PartyTitle")
		party_hp_bars = left_panel.get_node_or_null("PartyHPBars")

	if center_panel:
		layer_label = center_panel.get_node_or_null("LayerLabel")
		var battle_area = center_panel.get_node_or_null("BattleArea")
		if battle_area:
			var battle_content = battle_area.get_node_or_null("BattleContent")
			if battle_content:
				var enemy_section = battle_content.get_node_or_null("EnemySection")
				var party_section = battle_content.get_node_or_null("PartySection")
				if enemy_section:
					enemy_avatar = enemy_section.get_node_or_null("EnemyAvatar")
					enemy_hp_bar = enemy_section.get_node_or_null("EnemyHPBar")
					enemy_hp_label = enemy_section.get_node_or_null("EnemyHPLabel")
				if party_section:
					party_avatars = party_section.get_node_or_null("PartyAvatars")
		var combat_log_panel = center_panel.get_node_or_null("CombatLogPanel")
		if combat_log_panel:
			combat_log = combat_log_panel.get_node_or_null("CombatLog")

	if right_panel:
		var stats_container = right_panel.get_node_or_null("StatsContainer")
		if stats_container:
			turn_label = stats_container.get_node_or_null("TurnLabel")
			damage_label = stats_container.get_node_or_null("DamageLabel")
			total_damage_label = stats_container.get_node_or_null("TotalDamageLabel")

	var button_container = panel.get_node_or_null("ButtonContainer")
	if button_container:
		retreat_button = button_container.get_node_or_null("RetreatButton")
		skip_button = button_container.get_node_or_null("SkipButton")

	# Verify all critical nodes were found
	if not turn_label:
		push_error("[DungeonCombatUI] Failed to find TurnLabel!")
	if not damage_label:
		push_error("[DungeonCombatUI] Failed to find DamageLabel!")
	if not total_damage_label:
		push_error("[DungeonCombatUI] Failed to find TotalDamageLabel!")

	# Get dungeon system reference
	dungeon_system = get_node_or_null("/root/DungeonCrawlerSystem")

	if dungeon_system:
		dungeon_system.layer_completed.connect(_on_layer_completed)
		dungeon_system.dungeon_victory.connect(_on_dungeon_victory)
		dungeon_system.dungeon_defeat.connect(_on_dungeon_defeat)
		dungeon_system.staff_death.connect(_on_staff_death)

	# NOTE: Button signals are already connected in .tscn file
	# Do NOT connect them again here to avoid double-calling

	# Hide initially
	hide()

## Show combat UI
func show_combat():
	show()
	_clear_log()
	_add_log(TRANS["COMBAT_START"])
	turn_count = 1
	total_damage = 0
	_update_stats()
	_update_party_avatars()

## Update combat display
func update_combat_info():
	if not dungeon_system or not dungeon_system.is_dungeon_active():
		return

	var info = dungeon_system.get_active_dungeon_info()

	# Update layer info
	layer_label.text = "第%d/%d层 - %s" % [
		info["current_layer"],
		info["total_layers"],
		info["enemy_name"]
	]

	# Update enemy HP and avatar
	enemy_hp_bar.max_value = info["enemy_max_hp"]
	enemy_hp_bar.value = info["enemy_hp"]
	enemy_hp_label.text = "HP: %d/%d" % [info["enemy_hp"], info["enemy_max_hp"]]

	# Load enemy avatar if available
	_load_enemy_avatar(info["enemy_name"])

	# Update party avatars
	_update_party_avatars()

## Load enemy avatar from assets
func _load_enemy_avatar(enemy_name: String):
	# Try to match enemy name to asset
	var enemy_id = _get_enemy_id_from_name(enemy_name)
	var asset_path = ENEMY_ASSETS.get(enemy_id, "")

	if not asset_path.is_empty() and FileAccess.file_exists(asset_path):
		var texture = load(asset_path)
		if texture:
			enemy_avatar.texture = texture
		else:
			enemy_avatar.texture = null
	else:
		# Fallback: use colored placeholder
		enemy_avatar.texture = null

## Get enemy ID from enemy name
func _get_enemy_id_from_name(enemy_name: String) -> String:
	var name_map = {
		"变异鱼群": "mutated_fish",
		"珊瑚守卫": "coral_guardian",
		"深海巨兽": "deep_sea_giant",
		"虚空潜行者": "void_stalker",
		"深渊恐惧": "abyssal_horror"
	}
	return name_map.get(enemy_name, "")

## Update party HP bars and avatars
func _update_party_avatars():
	if not dungeon_system or not dungeon_system.is_dungeon_active():
		return

	var party = dungeon_system.get_active_party()
	var avatar_textures = party_avatars.get_children()

	# Clear existing HP bars
	for child in party_hp_bars.get_children():
		child.queue_free()

	# Update avatars and create HP bars
	for i in range(4):  # Max 4 party members
		if i < party.size():
			var staff = party[i]
			if staff.hp > 0:
				# Show and update avatar
				if i < avatar_textures.size():
					var texture_rect = avatar_textures[i] as TextureRect
					texture_rect.visible = true
					_load_staff_avatar(texture_rect, staff)

				# Create HP bar
				var hp_bar = ProgressBar.new()
				hp_bar.custom_minimum_size = Vector2(0, 20)
				hp_bar.max_value = staff.max_hp
				hp_bar.value = staff.hp
				hp_bar.show_percentage = false

				var label = Label.new()
				label.text = "%s: HP %d/%d" % [staff.get_display_name(), staff.hp, staff.max_hp]
				label.size = Vector2(0, 20)

				var container = VBoxContainer.new()
				container.add_child(hp_bar)
				container.add_child(label)
				party_hp_bars.add_child(container)
			else:
				# Staff is dead
				if i < avatar_textures.size():
					var texture_rect = avatar_textures[i] as TextureRect
					texture_rect.visible = false
		else:
			# Empty slot
			if i < avatar_textures.size():
				var texture_rect = avatar_textures[i] as TextureRect
				texture_rect.visible = false

## Load staff avatar
func _load_staff_avatar(texture_rect: TextureRect, staff: Staff):
	var dept = staff.department
	var asset_path = STAFF_ASSETS.get(dept, STAFF_ASSETS[""])

	if not asset_path.is_empty() and FileAccess.file_exists(asset_path):
		var texture = load(asset_path)
		if texture:
			texture_rect.texture = texture

## Update stats display
func _update_stats():
	if not turn_label:
		push_error("[DungeonCombatUI] turn_label is null! Trying to find it...")
		turn_label = get_node_or_null("Panel/MainContainer/RightPanel/StatsContainer/TurnLabel")
		if not turn_label:
			push_error("[DungeonCombatUI] Still cannot find turn_label!")

	if not damage_label:
		push_error("[DungeonCombatUI] damage_label is null!")

	if not total_damage_label:
		push_error("[DungeonCombatUI] total_damage_label is null!")

	if turn_label:
		turn_label.text = TRANS["TURN_COUNT"] % turn_count
	if damage_label:
		damage_label.text = TRANS["TURN_DAMAGE"] % 0
	if total_damage_label:
		total_damage_label.text = TRANS["TOTAL_DAMAGE"] % total_damage

## Add combat log entry
func _add_log(message: String):
	var timestamp = "[%02d:%02d]" % [Time.get_ticks_msec() / 60000, (Time.get_ticks_msec() / 1000) % 60]
	var entry = timestamp + " " + message

	log_entries.append(entry)

	if combat_log:
		combat_log.text = "\n".join(log_entries)
		# Auto-scroll to bottom
		await get_tree().process_frame
		if combat_log:
			combat_log.scroll_vertical = 999999

## Clear combat log
func _clear_log():
	log_entries.clear()
	if combat_log:
		combat_log.text = ""

func _on_layer_completed(layer: int, enemy_name: String):
	_add_log(TRANS["LAYER_COMPLETE"] % [layer, enemy_name])

func _on_dungeon_victory(rewards: Dictionary):
	_add_log(TRANS["ALL_COMPLETE"])
	_add_log(TRANS["GET_REWARDS"])
	_add_log("  " + TRANS["GMP_REWARD"] % rewards.get("gmp", 0))
	_add_log("  " + TRANS["MATERIALS_REWARD"] % rewards.get("materials", 0))
	_add_log("  " + TRANS["FUEL_REWARD"] % rewards.get("fuel", 0))

	# Hide after delay
	await get_tree().create_timer(3.0).timeout
	hide()

func _on_dungeon_defeat():
	_add_log(TRANS["MISSION_FAILED"])
	_add_log(TRANS["ALL_DIED"])

	# Hide after delay
	await get_tree().create_timer(3.0).timeout
	hide()

func _on_staff_death(staff_name: String):
	_add_log(TRANS["STAFF_DIED"] % staff_name)
	_update_party_avatars()  # Update to hide dead member

func _on_retreat_pressed():
	if dungeon_system and dungeon_system.is_dungeon_active():
		var rewards = dungeon_system.retreat_dungeon()

		if rewards.is_empty():
			_add_log(TRANS["CANNOT_RETREAT"])
			_add_log("没有活动的地牢")
		else:
			_add_log(TRANS["RETREAT"])
			_add_log(TRANS["REWARDS"])
			_add_log("  " + TRANS["GMP_REWARD"] % rewards.get("gmp", 0))
			_add_log("  " + TRANS["MATERIALS_REWARD"] % rewards.get("materials", 0))
			_add_log("  " + TRANS["FUEL_REWARD"] % rewards.get("fuel", 0))

		# Hide after delay
		await get_tree().create_timer(2.0).timeout
		hide()

func _on_skip_pressed():
	# For now, just add a log entry
	_add_log(TRANS["SKIP_TURN"])

## Called every frame to update UI
func _process(_delta):
	if visible and dungeon_system and dungeon_system.is_dungeon_active():
		update_combat_info()
