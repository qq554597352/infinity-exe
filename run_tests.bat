@echo off
REM ============================================
REM  ∞.exe - 本地测试运行脚本
REM ============================================

echo Starting Godot Headless Tests...

REM 获取 Godot 可执行文件路径
SET GODOT_EXE=godot

REM 检查 Godot 是否可用
where %GODOT_EXE% >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Godot not found in PATH!
    echo Please install Godot and add to PATH
    echo Download: https://godotengine.org/download
    pause
    exit /b 1
)

REM 检查 GUT 插件是否存在
if not exist "addons\gut\gut_cmdln.gd" (
    echo WARNING: GUT plugin not found!
    echo Please install GUT to addons/gut/
    echo Download: https://github.com/bitwes/Gut
)

echo.
echo Running tests...
echo.

REM 运行 GUT 测试
%GODOT_EXE% --headless -s res://addons/gut/gut_cmdln.gd -gexit

echo.
echo Tests completed!
pause
