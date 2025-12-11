@echo off
setlocal

echo Running PowerShell setup script...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

echo.
echo Setup finished.
pause
