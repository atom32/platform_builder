# 🎨 战斗UI素材集成快速指南

## 📋 当前状态

✅ **UI布局已优化**
- 增加了三栏布局（左侧队伍、中央战斗、右侧统计）
- 添加了敌人头像区域（150x150）
- 添加了4个员工头像位置（90x90 each）
- 添加了战斗统计显示（回合数、伤害等）

⏳ **素材待添加**
- 当前使用占位符（空TextureRect）
- 需要从Gemini生成并导入图片

## 🚀 快速开始

### 步骤1：生成素材（5-10分钟）

使用 `UI_ASSET_SPECIFICATIONS.md` 中的提示词在Gemini生成图片：

**必需素材：**
```
5个敌人 × 150×150 = 5张图片
6个部门员工 × 90×90 = 6张图片（每部门1张）
```

**推荐的Gemini提示词格式：**

敌人头像：
```
Create a pixel art sprite of a mutated deep sea fish for a video game.
Style: 16-bit RPG, horror theme
Size: 150x150 pixels
Background: Transparent PNG
Features: glowing green eyes, sharp teeth, dark colors
No text, no watermarks
```

员工头像：
```
Create a pixel art portrait of a combat soldier for an RPG game.
Style: Chibi anime style, cute
Size: 90x90 pixels
Gender: Female
Features: combat helmet, determined expression
Background: Transparent PNG
No text, no watermarks
```

### 步骤2：创建文件夹结构

```bash
# 在项目根目录执行
mkdir -p assets/art/combat/enemies
mkdir -p assets/art/combat/staff
```

### 步骤3：导入图片到Godot

1. 在Godot编辑器中，打开 **FileSystem** 标签
2. 找到 `assets/art/combat/` 文件夹
3. 将生成的图片拖拽到对应文件夹：
   - 敌人图片 → `enemies/` 文件夹
   - 员工图片 → `staff/` 文件夹

### 步骤4：重命名文件（重要！）

按照以下命名规范重命名图片：

**敌人：**
```
enemy_mutated_fish.png
enemy_coral_guardian.png
enemy_deep_sea_giant.png
enemy_void_stalker.png
enemy_abyssal_horror.png
```

**员工：**
```
staff_combat_male.png
staff_medical_female.png
staff_rd_male.png
staff_intel_male.png
staff_support_female.png
staff_recruit.png
```

### 步骤5：测试

1. 运行游戏（F5）
2. 建造一个平台
3. 点击平台开始战斗
4. 查看新的UI布局和头像显示

## 🎯 当前UI预览

```
┌──────────────────────────────────────────────────────┐
│ 队伍详情 │      战斗区域        │  战斗统计  │
│          │                      │            │
│ HP条列表 │  第1/3层 - 变异鱼群  │  回合: 1   │
│          │                      │  本回合: 45│
│          │  [敌人头像 150x150]  │  总伤害: 120│
│          │                      │            │
│          │         VS           │  战斗日志   │
│          │                      │  (滚动显示) │
│          │ [员工1][2][3][4]     │            │
│          │   90x90 each         │            │
└──────────────────────────────────────────────────────┘
       [撤退]                  [跳过]
```

## 🔧 故障排除

### 图片不显示？

**检查清单：**
1. ✅ 文件路径正确（`assets/art/combat/enemies/enemy_mutated_fish.png`）
2. ✅ 文件名完全匹配（区分大小写）
3. ✅ 文件是PNG格式
4. ✅ 文件已导入到Godot FileSystem

**调试方法：**
```gdscript
# 在 dungeon_combat_ui.gd 的 _load_enemy_avatar() 中添加：
print("尝试加载: ", asset_path)
print("文件存在: ", FileAccess.file_exists(asset_path))
```

### 图片显示变形？

**检查：**
- 敌人头像应该是 150x150 像素
- 员工头像应该是 90x90 像素
- TextureRect 的 `expand_mode` 应该设为 `1` (保持比例)

### 想改图片尺寸？

修改 `.tscn` 文件中的 `custom_minimum_size`：

```gdscript
# 敌人头像
[node name="EnemyAvatar" type="TextureRect" ...]
custom_minimum_size = Vector2(150, 170)  # 改成你想要的尺寸

# 员工头像
[node name="StaffAvatar1" type="TextureRect" ...]
custom_minimum_size = Vector2(90, 90)  # 改成你想要的尺寸
```

## 📝 下一步优化

素材导入后，可以考虑：

1. **添加动画效果**
   - 员工攻击动画
   - 敌人受击抖动
   - 暴击特效

2. **添加音效**
   - 攻击音效
   - 技能音效
   - 胜利/失败音效

3. **添加背景**
   - 海底场景背景图
   - 不同层级不同背景

4. **添加粒子效果**
   - 攻击命中特效
   - 治疗光效
   - 死亡特效

## 💡 提示

**批量生成技巧：**
```python
# 可以写个简单脚本批量调用Gemini API
enemies = [
    "mutated fish with glowing green eyes",
    "coral guardian with orange spikes",
    "deep sea giant with tentacles",
    "void stalker shadow monster",
    "abyssal horror eldritch beast"
]

for enemy in enemies:
    prompt = f"Pixel art {enemy}, RPG sprite, 150x150, transparent PNG"
    # 调用Gemini生成...
```

**颜色建议：**
- **Combat部门：** 绿色/军绿色
- **Medical部门：** 白色/红色
- **R&D部门：** 蓝色/灰色
- **Intel部门：** 紫色/黑色
- **Support部门：** 黄色/橙色

祝素材生成顺利！🎨
