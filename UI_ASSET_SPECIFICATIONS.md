# Dungeon Crawler UI - 素材规格建议

## 概述

战斗UI现在包含了角色头像和敌人头像的显示区域，您可以从Gemini或其他AI工具生成相应的素材。

## UI布局说明

```
┌─────────────────────────────────────────────────────────┐
│  队伍详情  │     战斗区域     │    战斗统计    │
│  (左侧栏)  │     (中央)       │    (右侧栏)    │
│           │                  │                │
│  [HP条]   │   第1/3层       │   回合: 1      │
│  [HP条]   │   变异鱼群       │   本回合: 45   │
│  [HP条]   │                  │   总伤害: 120  │
│  [HP条]   │  ┌───────────┐   │                │
│           │  │           │   │    战斗日志    │
│           │  │  敌人头像  │   │   (底部)       │
│           │  │  150x150  │   │                │
│           │  │           │   │   [日志...]    │
│           │  └───────────┘   │                │
│           │      VS          │                │
│           │  ┌──┐┌──┐┌──┐┌──┐│                │
│           │  │1││2││3││4││                │
│           │  └──┘└──┘└──┘└──┘│                │
│           │  90x90 x4       │                │
│           │                  │                │
├─────────────────────────────────────────────────────────┤
│                  [撤退]          [跳过]                  │
└─────────────────────────────────────────────────────────┘
```

## 素材规格清单

### 1. 敌人头像

**规格：**
- **尺寸：** 150x150 像素（推荐）
- **格式：** PNG（支持透明背景）
- **风格：** 像素艺术或卡通风格
- **背景：** 透明PNG（推荐）或纯色背景
- **数量：** 5个敌人

**敌人列表：**

1. **变异鱼群** (Mutated Fish)
   - 描述：深海变异鱼，成群结队
   - 色调：青绿色、病态
   - 姿势：张嘴露出尖牙
   - 建议提示词：`pixel art mutant deep sea fish, glowing green eyes, sharp teeth, horror style, 150x150`

2. **珊瑚守卫** (Coral Guardian)
   - 描述：珊瑚礁的守护者
   - 色调：粉色、橙色、珊瑚色
   - 姿势：防御姿态
   - 建议提示词：`pixel art coral guardian, protective stance, pink and orange colors, 150x150`

3. **深海巨兽** (Deep Sea Giant)
   - 描述：巨型深海怪物
   - 色调：深蓝色、紫色
   - 姿势：威严站立
   - 建议提示词：`pixel art deep sea giant monster, tentacles, dark blue and purple, menacing, 150x150`

4. **虚空潜行者** (Void Stalker)
   - 描述：来自虚空的阴影生物
   - 色调：黑色、紫色、暗影
   - 姿势：潜行/攻击
   - 建议提示词：`pixel art void stalker shadow monster, black and purple, stealthy, 150x150`

5. **深渊恐惧** (Abyssal Horror)
   - 描述：最强大的深渊BOSS
   - 色调：红色、黑色、恐怖
   - 姿势：恐怖咆哮
   - 建议提示词：`pixel art abyssal horror boss, eldritch tentacle monster, red and black, terrifying, 150x150`

### 2. 员工头像

**规格：**
- **尺寸：** 90x90 像素（推荐）
- **格式：** PNG（支持透明背景）
- **风格：** 卡通风格、简洁
- **背景：** 透明PNG（推荐）
- **数量：** 至少5个（建议10个以上以增加多样性）

**部门分类：**

#### Combat部门（战斗人员）
- **Combat Male:** `pixel art soldier man, combat gear, helmet, determined expression, 90x90`
- **Combat Female:** `pixel art soldier woman, combat gear, ponytail, fierce, 90x90`

#### Medical部门（医务人员）
- **Medic Male:** `pixel art medic man, white coat, medical cross, gentle, 90x90`
- **Medic Female:** `pixel art medic woman, nurse outfit, red cross, caring, 90x90`

#### R&D部门（研究人员）
- **Researcher Male:** `pixel art scientist man, lab coat, glasses, intelligent, 90x90`
- **Researcher Female:** `pixel art scientist woman, lab coat, clipboard, focused, 90x90`

#### Intel部门（情报人员）
- **Intel Male:** `pixel art spy man, sunglasses, earpiece, mysterious, 90x90`
- **Intel Female:** `pixel art spy woman, headset, tablet, tactical, 90x90`

#### Support部门（后勤人员）
- **Support Male:** `pixel art engineer man, tool belt, hard hat, practical, 90x90`
- **Support Female:** `pixel art engineer woman, tablet, safety vest, organized, 90x90`

#### 新兵（通用）
- **Recruit:** `pixel art new recruit, casual clothes, nervous expression, civilian, 90x90`

### 3. 可选：战斗背景

**规格：**
- **尺寸：** 1920x1080 或更高
- **格式：** JPG或PNG
- **风格：** 海底/水下场景
- **数量：** 1-3个

**建议场景：**
1. **深海海底** - 黑暗、压抑的氛围
2. **珊瑚礁区域** - 稍明亮、多彩
3. **深渊裂谷** - 最深处、恐怖氛围

## Gemini AI 生成提示词模板

### 敌人头像提示词

```
Create a pixel art sprite sheet of a [ENEMY_NAME] for a video game.
Style: 16-bit RPG style, similar to Final Fantasy or Dragon Quest.
Size: 150x150 pixels.
Format: Square PNG with transparent background.
Description: [详细描述]
Color Palette: [色调说明]
Pose: [姿势说明]
Expression: [表情说明]
Background: Transparent.
No text, no watermarks, single sprite only.
```

### 员工头像提示词

```
Create a pixel art portrait of a [JOB_TITLE] for a video game.
Style: Chibi anime style or cute pixel art.
Size: 90x90 pixels.
Format: Square avatar with transparent background.
Character: [角色描述]
Outfit: [服装描述]
Expression: [表情说明]
Hair Style: [发型和颜色]
Gender: [性别]
Background: Transparent.
High quality, clean lines, suitable for RPG game UI.
```

## 批量生成建议

### 敌人生成脚本

```python
# 生成5个敌人
enemies = [
    "mutated fish with glowing eyes",
    "coral reef guardian with spikes",
    "giant deep sea monster with tentacles",
    "shadowy void stalker",
    "eldritch abyssal horror boss"
]

for enemy in enemies:
    prompt = f"pixel art {enemy}, RPG enemy sprite, 150x150, transparent background"
    # 发送到Gemini
```

### 员工生成脚本

```python
# 生成每个部门的员工
departments = {
    "Combat": ["soldier with helmet"],
    "Medical": ["medic with cross symbol"],
    "R&D": ["scientist with lab coat"],
    "Intel": ["spy with sunglasses"],
    "Support": ["engineer with tool belt"]
}

for dept, description in departments.items():
    for gender in ["male", "female"]:
        prompt = f"pixel art {description} {gender}, RPG character portrait, 90x90"
        # 发送到Gemini
```

## 文件命名规范

创建以下文件夹结构：

```
/assets/art/combat/
├── enemies/
│   ├── enemy_mutated_fish.png
│   ├── enemy_coral_guardian.png
│   ├── enemy_deep_sea_giant.png
│   ├── enemy_void_stalker.png
│   └── enemy_abyssal_horror.png
├── staff/
│   ├── staff_combat_male.png
│   ├── staff_combat_female.png
│   ├── staff_medical_male.png
│   ├── staff_medical_female.png
│   ├── staff_rd_male.png
│   ├── staff_rd_female.png
│   ├── staff_intel_male.png
│   ├── staff_intel_female.png
│   ├── staff_support_male.png
│   ├── staff_support_female.png
│   └── staff_recruit.png
└── backgrounds/
    ├── bg_deep_sea.png
    ├── bg_coral_reef.png
    └── bg_abyss.png
```

## 集成说明

素材准备好后，我会帮您：

1. 将图片导入到项目的 `assets/art/combat/` 文件夹
2. 修改 `dungeon_combat_ui.gd` 脚本来动态加载和显示图片
3. 根据员工部门和敌人类型自动选择对应的头像
4. 添加淡入淡出等视觉效果

## 临时占位符

在素材准备好之前，当前的UI使用：
- 敌人：灰色方块占位符
- 员工：蓝色方块占位符

这样您可以先测试功能，素材准备好后再替换。

## 生成优先级

**高优先级（必需）：**
1. 5个敌人头像（150x150）
2. 每个部门至少1个员工头像（90x90）

**中优先级（建议）：**
1. 每个部门2-3个员工头像（增加多样性）
2. 员工受伤状态头像（可选）

**低优先级（可选）：**
1. 战斗背景图片
2. 特效动画素材
3. 战斗UI装饰元素

## 下一步

1. 使用上述提示词在Gemini中生成素材
2. 按照文件命名规范保存图片
3. 创建 `assets/art/combat/` 文件夹
4. 告诉我素材已准备好，我会帮您集成到游戏中

祝生成顺利！🎨
