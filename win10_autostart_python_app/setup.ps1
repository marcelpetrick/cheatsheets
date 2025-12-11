# Stop on any error
$ErrorActionPreference = "Stop"

Write-Host "Creating virtual environment..."
python -m venv .venv

Write-Host "Ensuring PowerShell can run activation scripts..."
# Temporarily allow script execution for this session only
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

Write-Host "Activating virtual environment..."
# Windows activation script
. .\.venv\Scripts\Activate.ps1

Write-Host "Installing requirements..."
pip install -r requirements.txt

Write-Host "Done with setup - running app now"
python3 main.py --version
python3 main.py --borderless
