# Platform Builder - 数据结构审计报告

**审计日期**: 2025-03-10
**项目状态**: 原型阶段
**审计人**: Claude Sonnet 4.6

---

## 执行摘要

### 关键发现

1. ✅ **已修复**: 平台数据结构重构（单一数据源 - Godot Node Tree）
2. ⚠️ **需要关注**: 基础过度耦合（承担过多职责）
3. ⚠️ **需要关注**: 全局状态管理混乱
4. ❌ **严重问题**: 数据分散在多个单例中，缺少统一访问层

### 健康度评分

| 维度 | 评分 | 说明 |
|------|------|------|
| 数据一致性 | 8/10 | 平台结构已统一，但其他数据分散 |
| 耦合度 | 4/10 | Base类职责过多，系统间紧密耦合 |
| 可测试性 | 3/10 | 大量使用全局单例，难以隔离测试 |
| 可维护性 | 5/10 | 部分系统清晰，但整体架构混乱 |
| 性能 | 7/10 | 递归遍历可能成为瓶颈 |

**总体评分**: 5.4/10 - 需要架构重构

---

## 1. 数据存储位置分析

### 1.1 全局单例（Autoload Singletons）

| 单例 | 职责 | 数据类型 | 评估 |
|------|------|----------|------|
| **ResourceSystem** | 资源管理 | 全局变量 | ⚠️ 简单但有效 |
| **DepartmentSystem** | 员工管理 | 数组 + 字典 | ⚠️ 数据结构合理 |
| **ObjectiveSystem** | 目标管理 | 数组 | ⚠️ 可以接受 |
| **ExpeditionSystem** | 远征管理 | 字典 | ✅ 封装良好 |
| **GameSession** | 会话管理 | 整数变量 | ✅ 职责单一 |
| **NotificationSystem** | 通知显示 | 无状态 | ✅ 合理 |
| **PlatformData** | 平台数据 | 静态数据 | ✅ 只读，良好 |
| **TextData** | 文本数据 | 静态数据 | ✅ 只读，良好 |

**问题**: 8个全局单例太多，造成全局状态污染

### 1.2 场景节点数据

#### Base (Node3D)
```gdscript
var hq_platform: Platform = null
var build_menu: BuildMenu = null
var department_system: Node = null  # ← 冗余！已有全局单例
var combo_system: ComboSystem = null
var expedition_system: ExpeditionManager = null  # ← 冗余！
```

**问题**:
- 存储全局单例的引用（冗余）
- 混合了UI、输入、业务逻辑
- 承担了过多职责

#### Platform (Node3D)
```gdscript
var platform_type: String
var level: int
var production_value: int
var parent_platform: Platform  # ← 已移除，使用 get_parent()
var child_platforms: Array[Platform]  # ← 已移除，使用 get_children()
var build_slots: Array[BuildSlot]
```

**状态**: ✅ 已修复 - 使用Godot Node Tree作为唯一数据源

---

## 2. 数据访问模式分析

### 2.1 获取所有平台

**当前方式** (Base.gd):
```gdscript
func get_all_platforms() -> Array[Platform]:
    var platforms: Array[Platform] = []
    if hq_platform:
        _collect_platforms_recursive(hq_platform, platforms)
    return platforms
```

**问题**:
- ❌ 每次调用都递归遍历整棵树
- ❌ 时间复杂度 O(n)，n = 平台总数
- ❌ 频繁调用时性能开销大

**建议优化**:
```gdscript
# 缓存机制
var _platform_cache: Array[Platform] = []
var _cache_dirty: bool = true

func get_all_platforms() -> Array[Platform]:
    if _cache_dirty:
        _rebuild_cache()
        _cache_dirty = false
    return _platform_cache
```

### 2.2 查找所属平台

**当前方式** (Base.gd):
```gdscript
func _find_platform_with_slot(slot: BuildSlot) -> Platform:
    for platform in get_all_platforms():
        if slot in platform.build_slots:
            return platform
    return null
```

**问题**:
- ❌ 线性搜索，时间复杂度 O(n)
- ❌ 每次点击slot都要遍历所有平台

**建议优化**:
```gdscript
# 在slot上存储父平台引用
class_name BuildSlot
var parent_platform: Platform  # ← 直接访问，无需搜索
```

### 2.3 员工总数计算

**当前方式** (DepartmentSystem.gd):
```gdscript
func get_total_staff() -> int:
    var total = 0
    for count in department_staff.values():
        total += count
    total += get_recruit_pool().size()  # ← 每次都遍历！
    return total
```

**问题**:
- ❌ 每次调用都重新计算
- ❌ `get_recruit_pool()` 遍历staff_list

**建议优化**:
```gdscript
var total_staff_count: int = 0
var _staff_count_dirty: bool = false

func add_staff():
    staff_list.append(new_staff)
    total_staff_count += 1  # ← O(1) 更新

func get_total_staff() -> int:
    return total_staff_count  # ← O(1) 查询
```

---

## 3. 数据一致性问题

### 3.1 资源状态同步

**问题场景**:
```gdscript
# ResourceSystem
var staff_count: int = 0

# DepartmentSystem
var staff_list: Array[Staff] = []

# 两个数据需要手动同步！
ResourceSystem.add_staff(1)
DepartmentSystem.add_staff()
```

**风险**: 容易出现不一致

### 3.2 平台容量检查

**三处都有容量逻辑**:
1. `Platform.can_accept_child()` - 最大6个子平台
2. `DepartmentSystem.can_build()` - 每个部门最多6个平台
3. `Base.get_total_platform_count()` - 全局最多100个平台

**问题**: 业务规则分散，难以维护

---

## 4. 架构问题

### 4.1 上帝类（God Object）: Base

**职责清单**:
- ✅ 平台管理
- ✅ 建造逻辑
- ✅ UI管理（BuildMenu, ExpeditionMenu）
- ✅ 输入处理（鼠标、键盘）
- ✅ 相机控制
- ✅ 点击检测
- ✅ 系统连接
- ❌ **职责过多！**

**影响**:
- 难以测试
- 难以维护
- 难以扩展

### 4.2 循环依赖

```
Base → BuildMenu → Base (base_system)
Base → ExpeditionSystem → Base (set_base_system)
Base → DepartmentSystem → ComboSystem
```

**问题**: 系统间紧密耦合

---

## 5. 性能问题

### 5.1 递归遍历

**高频操作**:
- `get_all_platforms()` - 每次建造、查询、UI更新
- `get_total_staff()` - 每次检查失败条件
- `get_all_descendants()` - Base Overview显示

**影响**: 当平台数量增加时（>50），性能下降明显

### 5.2 字符串比较

```gdscript
# 低效的字符串比较
for platform in get_all_platforms():
    if platform.platform_type == "Combat":  # ← 字符串比较
        count += 1
```

**建议**: 使用枚举或整数ID

### 5.3 重复计算

**场景**: 检查失败条件时
```gdscript
# GameSession.check_lose_conditions() 每秒调用
func check_lose_conditions():
    # 每次都重新计算
    var gmp = ResourceSystem.get_gmp()
    var dept_system = get_node_or_null("/root/DepartmentSystem")
    if dept_system and dept_system.get_total_staff() == 0:  # ← O(n)
```

---

## 6. 关键数据结构

### 6.1 Platform（已优化）✅

```gdscript
# 之前（三重数据结构）
var parent_platform: Platform  # 逻辑引用
var child_platforms: Array[Platform]  # 逻辑数组
# + Godot Node Tree
# + Base.all_platforms: Array[Platform]  # 全局数组

# 现在（单一数据源）✅
# 仅使用 Godot Node Tree
get_parent()  # 获取父平台
get_children()  # 获取子节点
```

### 6.2 Staff（合理）✅

```gdscript
class_name Staff
var id: int
var first_name: String
var last_name: String
var department: String
var skill_level: int
var specialty: String
```

**评估**: 数据结构清晰，职责单一

### 6.3 Resources（简单）⚠️

```gdscript
var materials: int
var fuel: int
var gmp: int
var staff_count: int  # ← 与 DepartmentSystem 重复！
var bed_capacity: int
```

**建议**: 移除 `staff_count`，统一从 `DepartmentSystem` 获取

---

## 7. 访问模式分析

### 7.1 直接全局访问 ❌

```gdscript
# 任何地方都可以直接访问
ResourceSystem.add_materials(100)
DepartmentSystem.assign_staff(staff, "R&D")
GameSession.increment_platforms_built()
```

**问题**:
- 隐式依赖
- 难以追踪数据流
- 难以测试

### 7.2 信号连接 ✅

```gdscript
build_menu.platform_selected.connect(_on_platform_selected)
expedition_system.expedition_completed.connect(_on_expedition_completed)
```

**评估**: 良好的解耦方式

---

## 8. 内存管理

### 8.1 对象生命周期

**平台**:
- ✅ 由场景树管理
- ✅ 删除时自动清理

**员工**:
- ⚠️ 存储在数组中
- ⚠️ 解雇后从数组删除，但对象可能未释放

### 8.2 内存泄漏风险

```gdscript
# ComboSystem
var active_combos: Array[Dictionary] = []  # ← 可能累积

# NotificationSystem
# 飞入的notification对象是否正确清理？
```

---

## 9. 并发安全

### 9.1 竞态条件

**场景**: 建造平台时
```gdscript
# Thread A: 检查容量
if get_total_platform_count() < MAX_PLATFORMS:
    # Thread B: 也在这里检查
    # Thread A: 继续建造
    # Thread B: 也建造
    # 结果: 超过限制！
```

**当前**: 单线程，无问题
**风险**: 如果添加多线程/异步操作

---

## 10. 优先级建议

### 🔴 高优先级（立即修复）

1. **添加平台缓存**
   - 影响: 性能
   - 复杂度: 低
   - 收益: 大

2. **优化slot查找**
   - 在slot上存储parent引用
   - 影响: 性能
   - 复杂度: 低

3. **移除ResourceSystem.staff_count**
   - 统一员工计数
   - 影响: 数据一致性
   - 复杂度: 低

### 🟡 中优先级（下个版本）

4. **拆分Base类**
   - 提取InputManager
   - 提取CameraController
   - 提取UIManager
   - 影响: 可维护性
   - 复杂度: 高

5. **统一业务规则**
   - 创建RuleValidationService
   - 集中管理容量检查
   - 影响: 可维护性
   - 复杂度: 中

6. **使用枚举替代字符串**
   - platform_type: String → enum
   - department: String → enum
   - 影响: 性能
   - 复杂度: 中

### 🟢 低优先级（未来优化）

7. **引入事件总线**
   - 减少全局单例
   - 统一事件流
   - 影响: 架构清晰度
   - 复杂度: 高

8. **数据持久化**
   - 添加Save/Load系统
   - 序列化游戏状态
   - 影响: 功能
   - 复杂度: 高

---

## 11. 推荐重构路线图

### Phase 1: 性能优化（1-2天）
- [ ] 添加平台缓存
- [ ] 优化slot查找（添加parent引用）
- [ ] 优化员工计数（增量更新）
- [ ] 使用枚举替代平台类型字符串

### Phase 2: 数据清理（2-3天）
- [ ] 移除ResourceSystem.staff_count
- [ ] 统一员工数据源
- [ ] 集中业务规则验证
- [ ] 清理循环依赖

### Phase 3: 架构重构（5-7天）
- [ ] 提取InputManager
- [ ] 提取CameraController
- [ ] 提取UIManager
- [ ] 创建GameDirector（协调器）
- [ ] 拆分Base类的职责

### Phase 4: 高级特性（按需）
- [ ] Save/Load系统
- [ ] 事件总线
- [ ] 依赖注入容器
- [ ] 单元测试框架

---

## 12. 具体代码示例

### 优化前: 平台遍历

```gdscript
# ❌ 每次都递归遍历
func get_all_platforms() -> Array[Platform]:
    var platforms: Array[Platform] = []
    _collect_platforms_recursive(hq_platform, platforms)
    return platforms

func _collect_platforms_recursive(platform, platforms):
    platforms.append(platform)
    for child in platform.get_children():
        if child is Platform:
            _collect_platforms_recursive(child, platforms)
```

### 优化后: 缓存机制

```gdscript
# ✅ 使用缓存，仅在脏标记时重建
var _platform_cache: Array[Platform] = []
var _cache_dirty: bool = true

func get_all_platforms() -> Array[Platform]:
    if _cache_dirty:
        _rebuild_cache()
        _cache_dirty = false
    return _platform_cache

func _rebuild_cache():
    _platform_cache.clear()
    if hq_platform:
        _collect_recursive(hq_platform, _platform_cache)

func mark_cache_dirty():
    _cache_dirty = true
```

---

## 13. 测试建议

### 13.1 性能测试

```gdscript
# 测试100个平台的性能
func test_large_base_performance():
    var start_time = Time.get_ticks_msec()

    # 建造100个平台
    for i in range(100):
        build_child_platform(...)

    var build_time = Time.get_ticks_msec() - start_time
    print("建造100个平台耗时: ", build_time, "ms")

    # 测试查询性能
    start_time = Time.get_ticks_msec()
    for i in range(1000):
        get_all_platforms()

    var query_time = Time.get_ticks_msec() - start_time
    print("查询1000次耗时: ", query_time, "ms")
```

### 13.2 一致性测试

```gdscript
func test_data_consistency():
    # 添加员工
    DepartmentSystem.add_staff()
    ResourceSystem.add_staff(1)

    # 检查一致性
    assert(DepartmentSystem.get_total_staff() == ResourceSystem.get_staff_count())
```

---

## 14. 结论

### 现状评估

| 方面 | 状态 | 说明 |
|------|------|------|
| 平台结构 | ✅ 优秀 | 已重构为单一数据源 |
| 全局状态 | ⚠️ 需改进 | 单例过多，全局污染 |
| 性能 | ⚠️ 可优化 | 递归遍历是瓶颈 |
| 架构 | ⚠️ 需重构 | Base类职责过多 |
| 可维护性 | ⚠️ 中等 | 部分清晰，整体混乱 |

### 关键成就

1. ✅ **平台数据结构重构成功**
   - 从三重结构简化为单一Godot Node Tree
   - 消除了数据同步问题
   - 提高了代码清晰度

2. ✅ **Result Screen工作正常**
   - 移除了engine pause
   - 实现了游戏状态重置
   - UI响应正常

### 关键风险

1. ❌ **性能问题未解决**
   - 递归遍历会随平台数量增加而变慢
   - 没有缓存机制
   - 字符串比较效率低

2. ❌ **架构债务累积**
   - Base类承担过多职责
   - 全局单例过多
   - 系统间紧密耦合

### 最终建议

**短期**（本周）:
1. 添加平台缓存
2. 优化slot查找
3. 统一员工计数

**中期**（下个迭代）:
1. 拆分Base类
2. 提取独立的管理器
3. 引入事件驱动架构

**长期**（原型完成后）:
1. 完整的Save/Load系统
2. 依赖注入框架
3. 单元测试覆盖

---

**审计结束**

*下次审计建议*: Phase 1重构完成后进行
