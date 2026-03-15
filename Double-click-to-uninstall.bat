@echo off
setlocal
cd /d "%~dp0"
echo Checking for Node.js...
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed. Please install Node.js to use this tool.
    pause
    exit /b 1
)
node index.js
pause
