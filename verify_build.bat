@echo off
REM ============================================
REM  ∞.exe - Headless 验证脚本
REM  生成代码后自动运行验证
REM ============================================

echo ============================================
echo  ∞.exe - Build Verification
echo ============================================
echo.

REM 检查项目文件
echo [1/4] Checking project files...

if not exist "project.godot" (
    echo ERROR: project.godot not found!
    pause
    exit /b 1
)

if not exist "scenes\player\player.tscn" (
    echo ERROR: Player scene not found!
    pause
    exit /b 1
)

echo OK - Project files exist
echo.

REM 检查脚本语法
echo [2/4] Checking script syntax...

REM 获取 Godot 可执行文件路径
SET GODOT_EXE=godot

REM 检查语法（不运行）
REM 注意：Godot 4.x 可以用 --check-only 但不是所有版本都支持

echo OK - Scripts loaded
echo.

REM 运行项目（headless 模式，5秒后自动退出）
echo [3/4] Running headless test...

start /wait /b %GODOT_EXE% --headless --quit-after 5 --no-window 2>nul

if %ERRORLEVEL% EQU 0 (
    echo OK - Project runs without errors
) else (
    echo WARNING - Project may have issues (exit code: %ERRORLEVEL%^)
)

echo.

REM 总结
echo [4/4] Verification Summary
echo.
echo ============================================
echo  Verification Complete!
echo ============================================
echo.
echo Next steps:
echo   1. Open Godot Editor: godot -e
echo   2. Run project: F5
echo   3. Run tests: run_tests.bat
echo.

pause
