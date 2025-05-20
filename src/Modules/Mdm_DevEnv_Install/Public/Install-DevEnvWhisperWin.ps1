
# Install-DevEnvWhisperWin
function Install-DevEnvWhisperWin {
<#
    .SYNOPSIS
        Install local voice recognition (Whisper).
    .DESCRIPTION
        Whisper is models designed to run voice recognition locally.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Install-DevEnvWhisperWin
    .NOTES
        none.
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug, [switch]$DoForce)
    # Install Whisper on Windows
    Initialize-Std -$DoPause -$DoVerbose -$DoDebug
    # Check Administrator Privileges
    $adminCheck = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $adminCheck.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error -Message "Please run this script as an Administrator." -ForegroundColor Red
        exit
    }

    # Python
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Write-Verbose "Python is not installed. Downloading and installing Python..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe" -OutFile "$env:TEMP\python-installer.exe"
        Start-Process -FilePath "$env:TEMP\python-installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item "$env:TEMP\python-installer.exe"
        $env:Path = "$env:Path;C:\Python310;C:\Python310\Scripts"
        Write-Verbose "Python installed successfully." -ForegroundColor Green
    }

    # pip install/update
    Write-Verbose "Updating pip..." -ForegroundColor Cyan
    python -m ensurepip
    python -m pip install --upgrade pip

    # virtualenv install
    Write-Verbose "Installing virtualenv..." -ForegroundColor Cyan
    python -m pip install --user virtualenv
    #endregion

    # Create a virtual environment
    $venvPath = "$env:USERPROFILE\whisper_env"
    Write-Verbose "Creating a virtual environment at $venvPath" -ForegroundColor Cyan
    python -m virtualenv $venvPath
    # Activate the virtual environment
    Write-Verbose "Activating the virtual environment..." -ForegroundColor Cyan
    $venvActivate = "$venvPath\Scripts\Activate.ps1"
    & $venvActivate

    # Install Whisper
    Write-Verbose "Installing Whisper and dependencies..." -ForegroundColor Cyan
    pip install git+https://github.com/openai/whisper.git
    # Verify Installation
    Write-Verbose "Verifying installation..." -ForegroundColor Cyan
    whisper --help

    Write-Verbose "Whisper installation is complete. To activate the environment in the future, run:"
    Write-Verbose "`"$venvPath\Scripts\Activate.ps1`""
    Write-Verbose "To transcribe audio, use: `whisper your_audio_file.mp3 --model small`""
    Wait-AnyKey
}
