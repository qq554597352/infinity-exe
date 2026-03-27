# ∞.exe - Claude Code Game Studios Project

> **游戏类型**: Metroidvania × Roguelike
> **引擎**: Godot 4.6
> **语言**: GDScript

---

## 开发规则

### 1. Task 完成 → Commit
每个 Task 完成后必须进行 commit，不能跳过。

### 2. Commit 描述
每次 commit 需要附上简短的描述说明。

### 3. 验证
完成任务时需要验证，确保功能正确。

### 4. 自测
功能完成后需要自我测试，验证功能正常。

### 5. GitHub 推送
自测通过后必须推送到 GitHub。

### 6. 代码结构
写代码前必须先了解项目结构。

### 7. 测试
完成功能后必须运行测试。

### 8. 功能验证
验证功能正常后再提交。

### 9. PR
所有 Task 完成后提交 PR。

---

## 技术栈

| 项目 | 选择 |
|------|------|
| **Engine** | Godot 4.6 |
| **Language** | GDScript |
| **Version Control** | Git (trunk-based) |
| **Build** | Godot CLI / GitHub Actions |

---

## 项目结构

```
∞.exe/
├── scripts/              # 游戏脚本
│   ├── player/           # 玩家控制器
│   ├── enemies/          # 敌人 AI
│   ├── skills/           # 技能系统
│   ├── autoload/         # 全局管理器
│   └── ui/               # UI 组件
├── scenes/               # 场景文件
│   ├── player/           # 玩家场景
│   ├── enemies/          # 敌人场景
│   ├── items/            # 物品场景
│   └── ui/               # UI 场景
├── assets/               # 资源
│   ├── art/              # 美术资源
│   ├── audio/            # 音频资源
│   └── shaders/          # 着色器
├── tests/                # 测试
└── .github/
    └── workflows/        # CI/CD
```

---

## 核心系统

### 已实现
- [x] 玩家移动 (WASD, 跳跃, 攀墙)
- [x] 钩爪系统
- [x] 基础攻击
- [x] 4 个 MVP 技能
- [x] 技能碎片掉落/拾取
- [x] 技能仓库 UI
- [x] 存档系统
- [x] Patrol 敌人
- [x] Tracker 追踪敌人
- [x] Boss ARCHITECT

### 开发中
- [ ] HUD 完善
- [ ] 完整地图设计

---

## 协作协议

**User-driven collaboration, not autonomous execution.**

每个任务遵循: **Question → Options → Decision → Draft → Approval**

- 使用 Write/Edit 前必须询问 "May I write this to [filepath]?"
- 多文件修改需要明确批准
- 未经用户指示不能 commit

---

## 编码标准

- 所有公共 API 必须包含文档注释
- 每个系统必须有对应的架构决策记录
- 游戏数值必须数据驱动（外部配置），不能硬编码
- 所有公共方法必须可单元测试
- Commit 必须关联设计文档或任务 ID
- **验证驱动开发**: 添加游戏系统时先写测试

---

## 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | PascalCase | `PlayerController` |
| 变量 | snake_case | `current_health` |
| 常量 | UPPER_SNAKE | `MAX_SPEED` |
| 信号 | snake_case | `player_died` |
| 文件/场景 | snake_case | `player_controller.gd` |

---

## 控制说明

| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| 空格 / W | 跳跃 |
| J / Z | 攻击 |
| E | 钩爪 |
| 1-4 | 使用技能 |
| Tab | 打开技能仓库 |

---

## 下一阶段任务

1. **HUD 完善** - 血量条、Token 显示
2. **完整地图设计** - 根据设计文档完成关卡
3. **音效系统** - 背景音乐、打击音效
4. **粒子特效** - 攻击、环境特效

---

## GitHub

- **仓库**: https://github.com/qq554597352/infinity-exe
- **Actions**: Windows Godot 4.x 构建测试

---

*Last updated: 2026-03-27*
