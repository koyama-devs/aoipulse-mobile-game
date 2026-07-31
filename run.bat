@echo off
REM Launch AOIPulse with local/temp Godot 4.3 if available.
setlocal
set GODOT=%LOCALAPPDATA%\Temp\godot\Godot_v4.3-stable_win64.exe
if not exist "%GODOT%" set GODOT=%LOCALAPPDATA%\Temp\godot\Godot_v4.3-stable_win64_console.exe
if not exist "%GODOT%" (
  echo Godot 4.3 not found at %%LOCALAPPDATA%%\Temp\godot\
  echo Download from https://godotengine.org/download
  exit /b 1
)
cd /d "%~dp0"
start "" "%GODOT%" --path "%cd%"
