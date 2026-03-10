# 简化重构计划 v2 - 拆分 Base 上帝类

**原则**: 保持简单、Godot惯用方式、只解决实际问题

---

## 修正：去掉 PlatformManager

**问题**: PlatformManager 只是在包装 Node API，多了一层跳转

**之前的设计**:
```
BuildSystem → PlatformManager → Base → Platform  # ❌ 3层跳转
```

**修正后**:
```
BuildSystem → Base → Platform  # ✅ 2层，直接访问
```

---

## 最终结构

```
Base (协调器, 30行)
├── CameraController (60行)
├── BuildSystem (120行)
├── GameState (20行, 新增)
└── Platforms
    └── HQ (Platform, 80行)
        └── Platform
            └── Platform
```

**总代码量**: ~310 行（健康的原型规模）

---

## 职责划分

### 1. Base (30行) - 协调器

**职责**:
- 初始化子系统
- 提供 root platform 访问
- 连接信号

```gdscript
extends Node3D
class_name Base

@onready var camera_controller = $CameraController
@onready var build_system = $BuildSystem
@onready var game_state = $GameState
@onready var hq = $Platforms/HQ

func _ready():
    build_system.initialize(self)

func get_hq() -> Platform:
    return hq

# 平台查询直接使用 Node API
func get_all_platforms() -> Array[Platform]:
    return hq.find_children("*", "Platform", true)

func get_platform_count() -> int:
    return get_all_platforms().size()
```

### 2. CameraController (60行) - 相机控制

**职责**:
- 右键拖动平移
- 滚轮缩放
- **不和 Base 交互**，只操作 Camera3D

### 3. BuildSystem (120行) - 建造逻辑

**职责**:
- 点击检测（slot）
- 资源检查
- 平台建造
- 桥接生成
- 建造UI交互

### 4. GameState (20行) - 游戏状态

**职责**:
- 存储游戏状态
- 避免状态散落在各处

```gdscript
extends Node
class_name GameState

var day: int = 1
var materials: int = 0
var fuel: int = 0
var gmp: int = 0
var staff_count: int = 0
var bed_capacity: int = 0
```

**注意**: 不需要 manager，只存储状态

### 5. Platform (80行) - 领域对象

**职责**:
- 平台数据（type, level, slots）
- 子平台管理
- 生产资源

---

## 场景结构

```
Base (Node3D)
├── Camera3D
├── CameraController (Node)
├── BuildSystem (Node)
├── GameState (Node)
├── ComboSystem (Node)
└── Platforms
    └── HQ (Platform)
        └── R&D (Platform)
            └── Support (Platform)
```

---

## 实施步骤

### Step 1: 创建 GameState (15分钟)
- [ ] 创建 `scripts/game_state.gd`
- [ ] 从 ResourceSystem/DepartmentSystem 移动状态变量
- [ ] 更新引用

### Step 2: 创建 CameraController (30分钟)
- [ ] 创建 `scripts/camera_controller.gd`
- [ ] 从 Base 移动相机代码
- [ ] 测试缩放和拖动

### Step 3: 创建 BuildSystem (45分钟)
- [ ] 创建 `scripts/build_system.gd`
- [ ] 从 Base 移动建造逻辑
- [ ] 保留平台遍历在 Base（使用 Node API）
- [ ] 测试建造流程

### Step 4: 简化 Base (30分钟)
- [ ] 移除已提取的代码
- [ ] 添加 @onready 引用
- [ ] 保留平台查询（使用 find_children）

### Step 5: 测试和清理 (30分钟)
- [ ] 测试完整游戏流程
- [ ] 移除未使用代码
- [ ] 更新注释

**总时间**: 约 2.5 小时

---

## 修正后的好处

**之前**:
```
BuildSystem → PlatformManager → Base → Platform  # 3层跳转
```

**现在**:
```
BuildSystem → Base → Platform  # 2层，直接使用 Node API
```

**优势**:
- ✅ 少一层抽象
- ✅ 直接使用 Godot Node Tree
- ✅ 更符合 Godot 惯用法
- ✅ 代码量更少（300行 vs 400行）

---

## 不做的事情

❌ 不创建 PlatformManager
❌ 不添加缓存
❌ 不添加 Repository
❌ 不添加事件总线
❌ 不过度抽象
❌ 不为"将来"做任何事

**只解决当前的实际问题**: Base 类太大、太复杂。

---

## 预期结果

```
Base.gd                 30行
CameraController.gd     60行
BuildSystem.gd         120行
GameState.gd            20行
Platform.gd             80行
────────────────────────────
总计                   ~310行
```

**这是一个极其健康的原型规模。**
