#!/bin/bash
# ============================================
#  ∞.exe - 本地测试运行脚本 (Linux/macOS)
# ============================================

echo "Starting Godot Headless Tests..."

# 获取 Godot 可执行文件路径
GODOT_EXE=${GODOT_EXE:-godot}

# 检查 Godot 是否可用
if ! command -v $GODOT_EXE &> /dev/null; then
    echo "ERROR: Godot not found in PATH!"
    echo "Please install Godot and add to PATH"
    echo "Download: https://godotengine.org/download"
    exit 1
fi

# 检查 GUT 插件是否存在
if [ ! -f "addons/gut/gut_cmdln.gd" ]; then
    echo "WARNING: GUT plugin not found!"
    echo "Please install GUT to addons/gut/"
    echo "Download: https://github.com/bitwes/Gut"
fi

echo ""
echo "Running tests..."
echo ""

# 运行 GUT 测试
$GODOT_EXE --headless -s res://addons/gut/gut_cmdln.gd -gexit

echo ""
echo "Tests completed!"
