# 资源系统回合制改造计划

## 📋 当前状态：实时制（Real-time）

### 资源生产
- **频率**：每秒（1.0s Timer tick）
- **位置**：`Base._on_production_tick()` → `Platform.produce_resources()`
- **计算**：`per_second_production × level × bonus`

### 员工维护
- **频率**：每60秒
- **位置**：`ResourceSystem._on_upkeep_timeout()`
- **成本**：1 Materials/员工/分钟 + 1 GMP/员工/天

---

## 🎯 目标状态：回合制（Turn-based）

### 改造要点

### 1. 时间系统
```
现在：Timer(1.0s) → 每秒触发
将来：TurnManager → 回合结束触发
```

### 2. 资源生产
```
现在：R&D Level 1 → +2 Materials/秒
将来：R&D Level 1 → +120 Materials/回合 (假设1回合=1分钟)
```

**计算公式**：
```gdscript
// 每回合生产 = 每秒生产 × 回合时长（分钟）
turn_production = per_second_production × turn_duration_minutes
```

### 3. 员工维护
```
现在：每60秒扣除维护费
将来：每回合结束扣除维护费
```

**两种方案**：
- **方案A**：按回合时长计算（如1回合=1分钟，则维护费不变）
- **方案B**：固定每回合维护费（如1 Materials/员工/回合）

---

## 📝 迁移步骤

### Phase 1: 添加TurnManager（1周）
```gdscript
# scripts/turn_manager.gd
extends Node
class_name TurnManager

signal turn_started(turn_number: int)
signal turn_ended(turn_number: int, duration_minutes: int)

var current_turn: int = 0
var turn_duration_minutes: int = 1  # Configurable

func next_turn():
    current_turn += 1
    turn_started.emit(current_turn)
    # ... player actions ...
    # Simulate time passing
    await get_tree().create_timer(1.0).timeout  # Or wait for player input
    turn_ended.emit(current_turn, turn_duration_minutes)
```

### Phase 2: 修改Base系统（2天）
```gdscript
# scripts/base.gd

# 移除：
# - _setup_production_timer()
# - _on_production_tick()

# 改为：
func _ready():
    var turn_manager = get_node_or_null("/root/TurnManager")
    if turn_manager:
        turn_manager.turn_ended.connect(_on_turn_ended)

func _on_turn_ended(turn_number: int, duration_minutes: int):
    _produce_resources_for_turn(duration_minutes)
    _pay_upkeep_for_turn(duration_minutes)

func _produce_resources_for_turn(duration_minutes: int):
    for platform in get_all_platforms():
        if platform.is_operational():
            var per_second = platform.materials_production * platform.level
            var turn_total = per_second * duration_minutes * 60  # Convert to seconds
            ResourceSystem.add_materials(turn_total)
```

### Phase 3: 更新UI（3天）
```gdscript
# ui/hud.gd

# 显示：
# "Turn: 5" 代替 "Production: +X/s"
# "Last turn: +120 Materials" 代替 "+2/s"
```

### Phase 4: 平衡调整（持续）
- 调整平台生产率（因为是每回合而非每秒）
- 调整维护成本
- 测试游戏节奏

---

## 🔧 配置文件调整

### data/core/game_constants.json
```json
{
  "game_timing": {
    "mode": "turn_based",  // or "real_time"
    "turn_duration_minutes": 1,
    "upkeep_per_turn": 1,
    "upkeep_per_minute": 1
  }
}
```

---

## ⚠️ 注意事项

### 1. 向后兼容
- 保留Timer作为可选项
- 添加配置开关切换实时/回合模式

### 2. 保存/加载
- 实时制：保存资源数量即可
- 回合制：还需保存回合数、回合进度等

### 3. AI行为
- 远征系统需要适配回合制（持续时间改为回合数）
- 平台建造时间改为回合数

---

## 📚 相关文件

### 需要修改的文件
- ✅ `scripts/resource_system.gd` - 已添加注释
- ✅ `scripts/platform.gd` - 已添加注释
- ✅ `scripts/base.gd` - 已添加注释
- ⏳ `scripts/turn_manager.gd` - 待创建
- ⏳ `scripts/expedition_system.gd` - 待适配
- ⏳ `ui/hud.gd` - 待更新

### 配置文件
- ⏳ `data/core/game_constants.json` - 添加timing配置
- ⏳ `data/platforms/platform_types.json` - 调整production数值

---

## 🎮 参考游戏

- **XCOM系列**：回合制战斗+基地管理
- **文明系列**：回合制资源生产
- **缺氧（ONI）**：实时制但可暂停

---

**文档创建时间**：2026-03-16
**状态**：规划阶段，尚未实施
