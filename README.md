# ∞.exe - 类银河恶魔城 × 肉鸽游戏

> 在AI统治的世界，你是残留的人类代码碎片。无限循环中，探索真相。

![Godot](https://img.shields.io/badge/Godot-4.x-478cbf?style=flat-square&logo=godot-engine)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

---

## 🎮 游戏概述

**∞.exe** 是一款类银河恶魔城 + 肉鸽元素的横板2D游戏。

### 核心特色

- **技能改变玩法风格** - 随机技能组合，不锁通关
- **无限循环** - 每次循环解锁更多真相
- **碎片化叙事** - 环境讲述故事
- **Token经济** - AI时代的冰冷货币

### 开发目标

| 特性 | 状态 |
|------|------|
| 二段跳 | ✅ 完成 |
| 攀墙爬 | ✅ 完成 |
| 钩爪 | ✅ 完成 |
| 基础攻击 | ✅ 完成 |
| 敌人 AI | 🔨 开发中 |
| 技能系统 | 📋 计划中 |
| Boss 战 | 📋 计划中 |

---

## 🛠️ 开发环境

### 要求

- **Godot 4.2+** ([下载](https://godotengine.org/download))
- **Git** (用于版本控制)
- 可选: **GUT** 测试框架 ([安装指南](https://github.com/bitwes/Gut))

### 安装

```bash
# 克隆项目
git clone https://github.com/yourusername/infinity-exe.git
cd infinity-exe

# 用 Godot 打开
godot -e
```

---

## 🧪 测试

### 本地测试

```bash
# Windows
.\run_tests.bat

# Linux/macOS
chmod +x run_tests.sh
./run_tests.sh
```

### 安装 GUT 测试框架

1. 下载 [GUT](https://github.com/bitwes/Gut/releases)
2. 解压到 `addons/gut/` 文件夹
3. 在 Godot 中启用插件: `Project > Project Settings > Plugins`

### 编写测试

在 `tests/` 文件夹中创建测试文件:

```gdscript
extends GutTest

func test_example():
    assert_true(true, "This should pass")
```

---

## 🤖 自动化测试 (CI/CD)

项目配置了 GitHub Actions 自动化流程:

### 工作流

| 工作流 | 触发 | 功能 |
|--------|------|------|
| `test.yml` | push/PR | 运行单元测试 |
| `build.yml` | push/PR | 导出 Linux 版本 |
| `windows-build.yml` | push/PR | 导出 Windows 版本 |

### GitHub Actions 自动执行

1. **代码推送** → 自动运行测试
2. **Pull Request** → 自动构建并测试
3. **合并到 main** → 发布构建产物

### 查看 Actions

访问 GitHub 仓库的 `Actions` 标签页查看构建状态。

---

## 📁 项目结构

```
infinity-exe/
├── .github/
│   └── workflows/          # GitHub Actions 配置
│       └── test.yml
├── addons/
│   └── gut/                # 测试框架 (可选)
├── assets/                 # 资源文件
├── scenes/
│   ├── enemies/            # 敌人场景
│   ├── levels/            # 关卡
│   ├── player/             # 玩家
│   └── ui/                # UI
├── scripts/
│   ├── autoload/          # 全局脚本
│   ├── enemies/           # 敌人脚本
│   ├── player/            # 玩家脚本
│   └── ui/                # UI 脚本
├── tests/                  # 测试文件
├── project.godot           # Godot 项目配置
├── run_tests.bat          # Windows 测试脚本
└── run_tests.sh           # Linux/macOS 测试脚本
```

---

## 🎮 操作说明

| 按键 | 功能 |
|------|------|
| A/D 或 ←/→ | 移动 |
| Space | 跳跃 / 攀墙 |
| J | 攻击 |
| E | 钩爪 |
| S | 存档 |

---

## 📚 参考资料

- [Godot 文档](https://docs.godotengine.org/)
- [GUT 测试框架](https://github.com/bitwes/Gut)
- [Godot CI 模板](https://github.com/nicholas-maltbie/godot-actions)

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

*游戏还在开发中，欢迎贡献代码！*
