# Install-Dev_Env_IDE_Win
#
# This script sets up a Windows development environment for neural network projects.
# It installs Chocolatey (if not already installed), Python, Git, VSCode,
# creates a project directory and a Python virtual environment,
# and then installs TensorFlow, Keras, and PyTorch.
function Install-Dev_Env_IDE_Win {
    [CmdletBinding()]
    param ()

    Import-Module Mdm_Std_Library

    Write-Host "######################"
    Write-Host  "Copying Powershell modules to System32 Powershell modules directory..."
    Write-Host "Script Security Check and Elevate"
    Set-ScriptSecElevated

    # Ensure the script is running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as an Administrator. Please restart PowerShell with elevated privileges."
        exit
    }

    # MAIN
    Write-Output  "Install Chocolatey if it is not installed"
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Output "Chocolatey not found. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else {
        Write-Output "Chocolatey is already installed."
    }

    Write-Output  "Install Python 3 (specify a version if needed; here we install the latest stable version)"
    Write-Output "Installing Python 3..."
    choco install python -y

    Write-Output  "Refresh environment PATH for the current session"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

    Write-Output  "Optionally install Git and Visual Studio Code for development"
    Write-Output "Installing Git and Visual Studio Code..."
    choco install git vscode -y

    Write-Output  "Verify Python installation"
    $pythonVersion = python --version
    Write-Output "Python version: $pythonVersion"

    Write-Output  "VsCode"

    Write-Output  "VsCodium"

    Write-Output  "Micrsoft toolchain"

    Write-Output  "Rust toolchain"

    Wait-AnyKey $msgAnykey
}