extends Node

## FeedbackSystem - 统一的即时反馈管理器
## 提供浮动文字、闪光、粒子等瞬时反馈效果

## 单例模式
static var instance: FeedbackSystem = null

## 配置
const MAX_FLOATING_TEXTS: int = 5  # 同时显示的最大数量
const FLOAT_DURATION: float = 1.2  # 浮动持续时间
const FLOAT_DISTANCE: float = 2.5  # 向上浮动距离

## 资源合并（防止spam）
var pending_gains: Dictionary = {}  # 累积待显示的资源变化
var merge_timer: Timer = null
const MERGE_WINDOW: float = 0.3  # 合并窗口（秒）

## 活跃的浮动文字
var active_texts: Array = []

func _ready():
	# 设置为单例（只设置一次）
	if not instance:
		instance = self
		print("[FeedbackSystem] Instance set to: ", self.get_path())
	else:
		print("[FeedbackSystem] Instance already exists at: ", instance.get_path())
		print("[FeedbackSystem] Current node: ", self.get_path())

	print("[FeedbackSystem] Initialized and ready")

	# 设置合并计时器
	merge_timer = Timer.new()
	merge_timer.wait_time = MERGE_WINDOW
	merge_timer.one_shot = true
	merge_timer.timeout.connect(_flush_pending_gains)
	add_child(merge_timer)

## ===== 公共API =====

## 测试函数 - 手动触发所有反馈类型
static func test_all_feedback():
	if not instance:
		print("[FeedbackSystem] ERROR: Instance not initialized!")
		return

	print("[FeedbackSystem] === Testing all feedback types ===")

	# 测试1: 固定在屏幕中央的文字（不需要坐标转换）
	instance._test_center_text()

	# 测试资源浮动文字（在相机前方）
	var camera = instance.get_viewport().get_camera_3d()
	if camera:
		var test_pos = camera.global_position + camera.global_transform.basis.z * -20
		show_resource_gain(100, "Materials", test_pos)
		show_resource_gain(50, "Fuel", test_pos + Vector3(2, 0, 0))

	# 测试建造闪光（需要实际的 platform 对象，测试时跳过）
	# show_build_flash(platform, "R&D")

	# 测试Combo反馈
	show_combo_activated("Test Combo", 0.5, Vector3(0, 0, 0))

	# 测试远征反馈
	show_expedition_result(true, {"materials": 99, "fuel": 88}, Vector3(0, 0, 0))

	print("[FeedbackSystem] === Test feedback created ===")

## 测试函数 - 在屏幕中央显示文字
func _test_center_text():
	var canvas = CanvasLayer.new()
	canvas.layer = 100

	var label = Label.new()
	label.text = "TEST TEXT - Can you see this?"
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 5)
	label.add_theme_constant_override("shadow_offset_y", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_CENTER
	label.position = Vector2(100, 300)  # 屏幕中央附近

	label.modulate.a = 1.0

	canvas.add_child(label)
	get_tree().current_scene.add_child(canvas)

	print("[FeedbackSystem] Test text created at center of screen")

	# 5秒后清理
	await get_tree().create_timer(5.0).timeout
	canvas.queue_free()

## 显示资源获得浮动文字
## amount: 数量（正数为获得，负数为消耗）
## type: 资源类型 ("Materials", "Fuel", "GMP", "Staff")
## world_position: 3D世界坐标
static func show_resource_gain(amount: int, type: String, world_position: Vector3):
	if not instance:
		print("[FeedbackSystem] ERROR: Instance not initialized!")
		return

	print("[FeedbackSystem] show_resource_gain: ", amount, " ", type, " at ", world_position)
	instance._add_resource_gain(amount, type, world_position)

## 显示建造完成反馈（2D文本）
## platform_position: 平台的3D位置
## platform_type: 平台类型（用于颜色和文字）
static func show_build_flash(platform_position: Vector3, platform_type: String):
	if not instance:
		return

	# 使用2D浮动文字代替3D闪光
	var text = "%s PLATFORM BUILT!" % platform_type
	instance._create_build_text(text, platform_position, platform_type)

## 显示Combo激活提示
## combo_name: Combo名称
## bonus: 加成百分比
## position: 激活位置
static func show_combo_activated(combo_name: String, bonus: float, position: Vector3):
	if not instance:
		return

	instance._create_combo_feedback(combo_name, bonus, position)

## 显示远征结果浮动文字
## success: 是否成功
## rewards: 奖励字典 {materials, fuel}
## position: 3D位置
static func show_expedition_result(success: bool, rewards: Dictionary, position: Vector3):
	if not instance:
		return

	instance._create_expedition_feedback(success, rewards, position)

## ===== 内部实现 =====

## 添加资源变化（带合并）
func _add_resource_gain(amount: int, type: String, world_position: Vector3):
	var key = type

	# 累积变化
	if not pending_gains.has(key):
		pending_gains[key] = {"amount": 0, "position": world_position}

	pending_gains[key]["amount"] += amount
	pending_gains[key]["position"] = world_position

	# 重置合并计时器
	merge_timer.stop()
	merge_timer.start()

## 刷新待显示的累积资源
func _flush_pending_gains():
	for type in pending_gains:
		var data = pending_gains[type]
		var amount = data["amount"]
		var position = data["position"]

		# 如果累积为0，跳过
		if amount == 0:
			continue

		# 限制活跃文字数量
		if active_texts.size() >= MAX_FLOATING_TEXTS:
			# 移除最老的
			_remove_oldest_text()

		_create_floating_text(amount, type, position)

	pending_gains.clear()

## 创建浮动文字（改用2D UI）
func _create_floating_text(amount: int, type: String, position: Vector3):
	print("[FeedbackSystem] Creating floating text: ", amount, " ", type)

	# 确定颜色和符号
	var color: Color
	var prefix: String

	if amount > 0:
		prefix = "+"
		match type:
			"Materials":
				color = Color(0.2, 0.8, 0.2)  # 绿色
			"Fuel":
				color = Color(0.2, 0.6, 1.0)  # 蓝色
			"GMP":
				color = Color(1.0, 0.8, 0.2)  # 金色
			"Staff":
				color = Color(0.2, 1.0, 0.6)  # 青绿色
			_:
				color = Color.WHITE
	else:
		prefix = ""
		color = Color(1.0, 0.3, 0.3)  # 红色（消耗）

	# 获取相机
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# 将3D位置转换为2D屏幕位置
	var screen_pos_3d = camera.unproject_position(position)

	# 提取2D坐标（假设点在视野内）
	var screen_pos_2d = Vector2(screen_pos_3d.x, screen_pos_3d.y)

	# 创建CanvasLayer和Label
	var canvas = CanvasLayer.new()
	canvas.layer = 100  # 确保在所有UI之上
	var label = Label.new()
	label.text = "%s%d %s" % [prefix, amount, type]
	label.anchors_preset = Control.PRESET_CENTER
	# 使用屏幕中心作为参考点，计算安全的偏移
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_center = viewport_size / 2
	var offset_from_center = screen_pos_2d - screen_center

	# 限制偏移，确保不超出屏幕边界（留120px边距）
	var safe_offset_x = clamp(offset_from_center.x, -screen_center.x + 140, screen_center.x - 140)
	var safe_offset_y = clamp(offset_from_center.y, -screen_center.y + 140, screen_center.y - 140)
	label.position = Vector2(safe_offset_x, safe_offset_y)
	label.z_index = 100

	# 设置样式
	label.add_theme_font_size_override("font_size", 40)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)

	label.modulate = color

	print("[FeedbackSystem] Floating text created at: ", screen_pos_2d, " color: ", color)

	# 添加到场景
	canvas.add_child(label)
	var main_scene = get_tree().current_scene
	if main_scene:
		main_scene.add_child(canvas)
		print("[FeedbackSystem] Added floating text at screen pos: ", screen_pos_2d)
		print("[FeedbackSystem] Label text: ", label.text)
		print("[FeedbackSystem] Label modulate: ", label.modulate)
		print("[FeedbackSystem] Canvas layer: ", canvas.layer)
	else:
		print("[FeedbackSystem] ERROR: No current scene found!")
		return
	active_texts.append(label)

	# 动画：弹出→向上浮动→淡出
	var tween = create_tween()
	tween.set_parallel(false)

	# 阶段1：弹出（0.15秒）
	label.scale = Vector2.ZERO
	tween.tween_property(label, "scale", Vector2.ONE * 1.2, 0.15)
	tween.tween_interval(0.05)

	# 阶段2：向上浮动（剩余时间）
	var float_time = FLOAT_DURATION - 0.2
	tween.set_parallel(true)
	tween.tween_property(label, "position", Vector2(screen_pos_3d.x, screen_pos_3d.y - 100), float_time)
	tween.tween_property(label, "modulate:a", 0.0, float_time)

	# 完成后清理
	tween.tween_callback(_remove_2d_text.bind(label, canvas))

## 让平台本身闪烁（创建发光平面覆盖）
## 创建建造完成文本（2D反馈）
func _create_build_text(text: String, position: Vector3, platform_type: String):
	print("[FeedbackSystem] Creating build text: ", text, " at ", position)

	# 根据平台类型选择颜色
	var color: Color
	match platform_type:
		"R&D":
			color = Color(0.0, 0.8, 1.0)  # 蓝色
		"Combat":
			color = Color(1.0, 0.2, 0.2)  # 红色
		"Support":
			color = Color(0.2, 1.0, 0.4)  # 绿色
		"Intel":
			color = Color(0.8, 0.4, 1.0)  # 紫色
		"Medical":
			color = Color(1.0, 0.6, 0.8)  # 粉色
		_:
			color = Color(1.0, 1.0, 1.0)  # 白色

	# 获取相机
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# 将3D位置转换为2D屏幕位置（抬高显示，在平台上方）
	var screen_pos_3d = camera.unproject_position(position + Vector3(0, 8, 0))
	var screen_pos_2d = Vector2(screen_pos_3d.x, screen_pos_3d.y)

	# 创建CanvasLayer和Label
	var canvas = CanvasLayer.new()
	canvas.layer = 100  # 确保在所有UI之上

	var label = Label.new()
	label.text = text
	label.anchors_preset = Control.PRESET_CENTER

	# 使用屏幕中心作为参考点，计算安全的偏移
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_center = viewport_size / 2
	var offset_from_center = screen_pos_2d - screen_center

	# 限制偏移，确保不超出屏幕边界（留100px边距）
	var safe_offset_x = clamp(offset_from_center.x, -screen_center.x + 120, screen_center.x - 120)
	var safe_offset_y = clamp(offset_from_center.y, -screen_center.y + 120, screen_center.y - 120)
	label.position = Vector2(safe_offset_x, safe_offset_y)

	label.z_index = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	print("[FeedbackSystem] Build text at platform position: ", screen_pos_2d, " safe offset: ", Vector2(safe_offset_x, safe_offset_y))

	print("[FeedbackSystem] Build text at SCREEN CENTER for testing")

	# 设置样式
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 4)
	label.add_theme_constant_override("shadow_offset_y", 4)

	label.modulate = color

	print("[FeedbackSystem] Build text created at: ", screen_pos_2d, " color: ", color)

	# 添加到场景
	canvas.add_child(label)
	var main_scene = get_tree().current_scene
	if main_scene:
		main_scene.add_child(canvas)
	else:
		print("[FeedbackSystem] ERROR: No scene for build text!")
		return

	active_texts.append(label)

	# 动画：持续5秒，向上浮动
	var tween = create_tween()
	tween.set_parallel(true)
	label.scale = Vector2.ZERO
	tween.tween_property(label, "scale", Vector2.ONE * 1.5, 0.5)
	tween.tween_property(label, "position", Vector2(0, -200), 5.0)  # 从中央向上浮动
	tween.tween_property(label, "modulate:a", 0.0, 5.0)

	tween.tween_callback(_remove_2d_text.bind(label, canvas))

## 创建Combo反馈（改用2D UI）
func _create_combo_feedback(combo_name: String, bonus: float, position: Vector3):
	print("[FeedbackSystem] Creating combo feedback: ", combo_name, " +", bonus, " at ", position)

	# 限制数量
	if active_texts.size() >= MAX_FLOATING_TEXTS:
		_remove_oldest_text()

	# 获取相机
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# 将3D位置转换为2D屏幕位置
	var screen_pos_3d = camera.unproject_position(position + Vector3(0, 3, 0))

	# 提取2D坐标（假设点在视野内）
	var screen_pos_2d = Vector2(screen_pos_3d.x, screen_pos_3d.y)

	# 创建CanvasLayer和Label
	var canvas = CanvasLayer.new()
	canvas.layer = 100  # 确保在所有UI之上
	var label = Label.new()
	label.text = "COMBO!\n+%d%% %s" % [int(bonus * 100), combo_name]
	label.anchors_preset = Control.PRESET_CENTER
	# 使用相对于屏幕中心的偏移
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_center = viewport_size / 2
	label.position = (Vector2(screen_pos_3d.x, screen_pos_3d.y) - screen_center)
	label.z_index = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# 设置样式
	label.add_theme_font_size_override("font_size", 56)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 4)
	label.add_theme_constant_override("shadow_offset_y", 4)

	label.modulate = Color(1.0, 0.9, 0.3)  # 金色

	# 添加到场景
	canvas.add_child(label)
	var main_scene = get_tree().current_scene
	if main_scene:
		main_scene.add_child(canvas)
		print("[FeedbackSystem] Added combo feedback at screen pos: ", screen_pos_2d)
	else:
		print("[FeedbackSystem] ERROR: No current scene found!")
		return
	active_texts.append(label)

	# 动画：持续更长时间
	var tween = create_tween()
	tween.set_parallel(true)
	label.scale = Vector2.ZERO
	tween.tween_property(label, "scale", Vector2.ONE * 1.3, 0.2)
	tween.tween_property(label, "position", Vector2(screen_pos_3d.x, screen_pos_3d.y - 150), 2.0)
	tween.tween_property(label, "modulate:a", 0.0, 2.0)

	tween.tween_callback(_remove_2d_text.bind(label, canvas))

## 创建远征反馈（改用2D UI）
func _create_expedition_feedback(success: bool, rewards: Dictionary, position: Vector3):
	var color = Color(0.2, 1.0, 0.4) if success else Color(1.0, 0.3, 0.3)
	var status_text = "SUCCESS" if success else "FAILED"

	var materials = rewards.get("materials", 0)
	var fuel = rewards.get("fuel", 0)

	# 获取相机
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	# 将3D位置转换为2D屏幕位置
	var screen_pos_3d = camera.unproject_position(position + Vector3(0, 2, 0))

	# 提取2D坐标（假设点在视野内）
	var screen_pos_2d = Vector2(screen_pos_3d.x, screen_pos_3d.y)

	# 创建CanvasLayer和Label
	var canvas = CanvasLayer.new()
	canvas.layer = 100  # 确保在所有UI之上
	var label = Label.new()
	label.text = "%s\n+%d Mat\n+%d Fuel" % [status_text, materials, fuel]
	label.anchors_preset = Control.PRESET_CENTER
	# 使用屏幕中心作为参考点，计算安全的偏移
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_center = viewport_size / 2
	var offset_from_center = screen_pos_2d - screen_center

	# 限制偏移，确保不超出屏幕边界（留120px边距）
	var safe_offset_x = clamp(offset_from_center.x, -screen_center.x + 140, screen_center.x - 140)
	var safe_offset_y = clamp(offset_from_center.y, -screen_center.y + 140, screen_center.y - 140)
	label.position = Vector2(safe_offset_x, safe_offset_y)
	label.z_index = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# 设置样式 - 使用 modulate 控制颜色
	label.add_theme_font_size_override("font_size", 40)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 4)
	label.add_theme_constant_override("shadow_offset_y", 4)

	label.modulate = color  # 使用变量中的颜色

	# 添加到场景
	canvas.add_child(label)
	var main_scene = get_tree().current_scene
	if main_scene:
		main_scene.add_child(canvas)
		print("[FeedbackSystem] Added expedition feedback at screen pos: ", screen_pos_2d)
	else:
		print("[FeedbackSystem] ERROR: No current scene found!")
		return

	var tween = create_tween()
	tween.set_parallel(true)
	label.scale = Vector2.ZERO
	tween.tween_property(label, "scale", Vector2.ONE * 1.2, 0.15)
	tween.tween_property(label, "position", Vector2(screen_pos_3d.x, screen_pos_3d.y - 120), 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)

	tween.tween_callback(_remove_2d_text.bind(label, canvas))

## 移除文字（支持3D和2D）
func _remove_text(label: Label):
	if label in active_texts:
		active_texts.erase(label)

	if label.get_parent():
		label.get_parent().remove_child(label)

	label.queue_free()

## 移除2D文字（同时清理CanvasLayer）
func _remove_2d_text(label: Label, canvas: CanvasLayer):
	if label in active_texts:
		active_texts.erase(label)

	label.queue_free()
	canvas.queue_free()

## 移除最老的文字
func _remove_oldest_text():
	if active_texts.is_empty():
		return

	var oldest = active_texts[0]
	# 如果是Label（2D）或Label3D（3D），都调用queue_free
	if oldest.get_parent():
		oldest.get_parent().remove_child(oldest)
	oldest.queue_free()

	active_texts.erase(oldest)
