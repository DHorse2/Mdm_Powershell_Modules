# Setup-Dev_Env_Whisper_Win
# 
# PowerShell Script to Install Whisper on Windows

# Check for Administrator Privileges
$adminCheck = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    exit
}

# Check if Python is installed
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "Python is not installed. Downloading and installing Python..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe" -OutFile "$env:TEMP\python-installer.exe"
    Start-Process -FilePath "$env:TEMP\python-installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
    Remove-Item "$env:TEMP\python-installer.exe"
    $env:Path += ";C:\Python310;C:\Python310\Scripts"
    Write-Host "Python installed successfully." -ForegroundColor Green
}

# Ensure pip is up to date
Write-Host "Updating pip..." -ForegroundColor Cyan
python -m ensurepip
python -m pip install --upgrade pip

# Install virtualenv if not installed
Write-Host "Installing virtualenv..." -ForegroundColor Cyan
python -m pip install --user virtualenv

# Create a virtual environment
$venvPath = "$env:USERPROFILE\whisper_env"
Write-Host "Creating a virtual environment at $venvPath" -ForegroundColor Cyan
python -m virtualenv $venvPath

# Activate the virtual environment
Write-Host "Activating the virtual environment..." -ForegroundColor Cyan
$venvActivate = "$venvPath\Scripts\Activate.ps1"
& $venvActivate

# Install Whisper
Write-Host "Installing Whisper and dependencies..." -ForegroundColor Cyan
pip install git+https://github.com/openai/whisper.git

# Verify Installation
Write-Host "Verifying installation..." -ForegroundColor Cyan
whisper --help

Write-Host "Whisper installation is complete. To activate the environment in the future, run:" -ForegroundColor Green
Write-Host "`"$venvPath\Scripts\Activate.ps1`"" -ForegroundColor Yellow
Write-Host "To transcribe audio, use: `whisper your_audio_file.mp3 --model small`"" -ForegroundColor Yellow

Wait-AnyKey $msgAnykey
