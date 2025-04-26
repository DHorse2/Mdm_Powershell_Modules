
# Install-DevEnvIdeWin
function Install-DevEnvIdeWin {
<#
    .SYNOPSIS
        Install the IDE (Intergrated development environment).
    .DESCRIPTION
        This script sets up a Windows development environment for neural network projects.
        It installs Chocolatey (if not already installed), Python, Git, VSCode,
        creates a project directory and a Python virtual environment,
        and then installs TensorFlow, Keras, and PyTorch.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .EXAMPLE
        Install-DevEnvIdeWin -DoVerbose
    .NOTES
        Installs:
            Chocolatey
            Python 3
            Git
            Visual Studio Code
        TODO incomplete. .
            Micrsoft toolchain
            VsCode
            VsCodium
            Rust toolchain
    .OUTPUTS
        A log (TODO).
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    Initialize-Std -$DoPause -$DoVerbose

    Wait-AnyKey

    Write-Verbose "######################"
    Write-Verbose  "Copying PowerShell modules to System32 PowerShell modules directory..."
    Write-Verbose "Script Security Check and Elevate"
    Set-SecElevated

    # Ensure the script is running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as an Administrator. Please restart PowerShell with elevated privileges."
        exit
    }

    # MAIN
    Write-Host  "Install Chocolatey if it is not installed"
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else {
        Write-Host "Chocolatey is already installed."
    }

    Write-Host  "Install Python 3 (specify a version if needed; here we install the latest stable version)"
    Write-Host "Installing Python 3..."
    choco install python -y

    Write-Host  "Refresh environment PATH for the current session"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

    Write-Host  "Optionally install Git and Visual Studio Code for development"
    Write-Host "Installing Git and Visual Studio Code..."
    choco install git vscode -y

    Write-Host  "Verify Python installation"
    $pythonVersion = python --version
    Write-Host "Python version: $pythonVersion"

    Write-Host  "VsCode"

    Write-Host  "VsCodium"

    Write-Host  "Micrsoft toolchain"

    Write-Host  "Rust toolchain"

    Wait-AnyKey
}
