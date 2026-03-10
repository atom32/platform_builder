# 简化重构计划 - 拆分 Base 上帝类

**原则**: 保持简单、Godot惯用方式、只解决实际问题

---

## 问题：Base 类做了太多事情

当前 Base 类的职责：
- ✅ 平台管理（应该保留）
- ✅ 建造逻辑（应该保留）
- ❌ 相机拖动（应该独立）
- ❌ 输入处理（应该独立）
- ❌ UI 管理（BuildMenu, ExpeditionMenu）（应该独立）
- ❌ 系统连接（可以简化）

---

## 拆分方案

### 新结构

```
Base (简化版)
├── CameraController (新建)
├── BuildSystem (新建)
└── PlatformManager (新建)
```

---

## 1. CameraController (新建)

**职责**: 相机控制
- 鼠标滚轮缩放
- 右键拖动平移
- 聚焦到平台

```gdscript
# scripts/camera_controller.gd
extends Node
class_name CameraController

@onready var camera: Camera3D = get_parent().get_node("Camera3D")

var is_dragging: bool = false
var last_mouse_pos: Vector2

func _ready():
    set_process_input(true)

func _input(event):
    # 缩放
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _zoom_in()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _zoom_out()
    
    # 拖动
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT:
            is_dragging = event.pressed
            if event.pressed:
                last_mouse_pos = event.position
    
    if event is InputEventMouseMotion and is_dragging:
        _pan_camera(event.position - last_mouse_pos)
        last_mouse_pos = event.position

func _zoom_in():
    camera.position.z = max(camera.position.z - 5, 15)

func _zoom_out():
    camera.position.z = min(camera.position.z + 5, 80)

func _pan_camera(delta: Vector2):
    camera.position.x -= delta.x * 0.5
    camera.position.z -= delta.y * 0.5
```

---

## 2. PlatformManager (从 Base 提取)

**职责**: 平台数据管理
- HQ 生命周期
- 平台遍历
- 平台查询

```gdscript
# scripts/platform_manager.gd
extends Node
class_name PlatformManager

var hq_platform: Platform = null
var platform_scene = preload("res://scenes/platform.tscn")

func _ready():
    _spawn_hq()

func _spawn_hq():
    hq_platform = platform_scene.instantiate()
    hq_platform.platform_type = "HQ"
    get_parent().add_child(hq_platform)

func get_all_platforms() -> Array[Platform]:
    var platforms: Array[Platform] = []
    if hq_platform:
        _collect_recursive(hq_platform, platforms)
    return platforms

func _collect_recursive(platform: Platform, platforms: Array[Platform]):
    platforms.append(platform)
    for child in platform.get_children():
        if child is Platform:
            _collect_recursive(child, platforms)

func get_platform_count() -> int:
    return get_all_platforms().size()

func get_hq() -> Platform:
    return hq_platform
```

---

## 3. BuildSystem (从 Base 提取)

**职责**: 建造逻辑
- 点击检测
- Slot 查找
- 平台建造
- 桥接生成

```gdscript
# scripts/build_system.gd
extends Node
class_name BuildSystem

signal platform_built(platform: Platform)

var platform_scene = preload("res://scenes/platform.tscn")
var build_menu_scene = preload("res://ui/build_menu.tscn")

var platform_manager: PlatformManager = null
var build_menu: BuildMenu = null

func _ready():
    platform_manager = get_parent().get_node("PlatformManager")
    _create_build_menu()
    set_process_input(true)

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            _handle_click(event.position)

func _handle_click(mouse_pos: Vector2):
    # 射线检测
    var camera = get_viewport().get_camera_3d()
    var from = camera.project_ray_origin(mouse_pos)
    var to = from + camera.project_ray_normal(mouse_pos) * 1000
    var space = get_world_3d().direct_space_state
    
    # 检查 slot 点击
    var slot_query = PhysicsRayQueryParameters3D.new()
    slot_query.from = from
    slot_query.to = to
    slot_query.collision_mask = 2
    slot_query.collide_with_areas = true
    
    var result = space.intersect_ray(slot_query)
    if result and result.collider:
        var slot = result.collider.get_parent() as BuildSlot
        if slot and not slot.get_occupied():
            _show_build_menu(slot)

func build_platform(parent_platform: Platform, slot: BuildSlot, type: String) -> Platform:
    var platform = platform_scene.instantiate()
    platform.platform_type = type
    platform.position = slot.position
    
    get_parent().add_child(platform)
    parent_platform.add_child_platform(platform, slot)
    
    BridgeGenerator.create_bridge(parent_platform, platform)
    platform_built.emit(platform)
    
    return platform
```

---

## 4. Base (简化版)

**职责**: 协调器
- 初始化子系统
- 连接信号
- 管理生命周期

```gdscript
# scripts/base.gd (简化版)
extends Node3D
class_name Base

@onready var platform_manager = $PlatformManager
@onready var camera_controller = $CameraController
@onready var build_system = $BuildSystem

func _ready():
    # 子系统自动初始化
    print("Base initialized with subsystems")
```

---

## 场景结构

```
Base (Node3D)
├── Camera3D
├── PlatformManager (Node)
├── CameraController (Node)
├── BuildSystem (Node)
├── ComboSystem (Node)
└── HQ (Platform) - 由 PlatformManager 创建
```

---

## 实施步骤

### Step 1: 创建 CameraController (30分钟)
- [ ] 创建 `scripts/camera_controller.gd`
- [ ] 从 Base 移动相机相关代码
- [ ] 测试缩放和拖动

### Step 2: 创建 PlatformManager (30分钟)
- [ ] 创建 `scripts/platform_manager.gd`
- [ ] 从 Base 移动 HQ 和平台遍历代码
- [ ] 测试平台查询

### Step 3: 创建 BuildSystem (1小时)
- [ ] 创建 `scripts/build_system.gd`
- [ ] 从 Base 移动建造逻辑
- [ ] 测试平台建造

### Step 4: 更新 Base 场景 (15分钟)
- [ ] 添加子节点
- [ ] 移除旧代码
- [ ] 测试完整流程

### Step 5: 清理 (30分钟)
- [ ] 移除未使用的代码
- [ ] 更新注释
- [ ] 提交

---

## 预期结果

**之前**:
```gdscript
# Base.gd - 400+ 行
# 混合了相机、输入、建造、UI...
```

**之后**:
```gdscript
# Base.gd - ~20 行（协调器）
# CameraController.gd - ~60 行（单一职责）
# PlatformManager.gd - ~50 行（单一职责）
# BuildSystem.gd - ~150 行（单一职责）
```

**好处**:
- ✅ 每个类职责清晰
- ✅ 更容易理解
- ✅ 更容易测试
- ✅ 更容易修改
- ✅ 符合 Godot 惯用法

---

## 不做的事情

❌ 不添加缓存
❌ 不添加 Repository
❌ 不添加事件总线
❌ 不过度抽象
❌ 不为了"将来"做任何事

**只解决当前的实际问题**: Base 类太大、太复杂。
