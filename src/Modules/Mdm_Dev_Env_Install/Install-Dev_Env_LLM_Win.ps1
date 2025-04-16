
# Install-Dev_Env_LLM_Win
function Install-Dev_Env_LLM_Win {
    <#
    .SYNOPSIS
        Install the Large Language Model (LLM)
    .DESCRIPTION
        Install the LLM (NN or AI).
        Create Python virtual environment. Activates it.
        Upgrades pip and installs neural network libraries.
        Libraries: TensorFlow, Keras, PyTorch.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Install-Dev_Env_LLM_Win
    .NOTES
        none.
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    Write-Verbose "######################"
    Write-Verbose  "Copying PowerShell modules to System32 PowerShell modules directory..."
    Write-Verbose "Script Security Check and Elevate"
    Set-SecElevated

    # Ensure the script is running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as an Administrator. Please restart PowerShell with elevated privileges."
        exit
    }

    #MAIN
    Write-Verbose " Create a working directory for your neural network project"
    $projectDir = "$env:USERPROFILE\Dev\NN\TestProject"
    if (!(Test-Path $projectDir)) {
        Write-Host "Creating project directory at $projectDir"
        New-Item -ItemType Directory -Path $projectDir
    }
    Set-Location $projectDir

    Write-Host "Creating Python virtual environment..."
    python -m venv env
    ""
    Write-Host "Activating virtual environment..."
    # "Use the following command in PowerShell to activate the environment"
    & "$projectDir\env\Scripts\Activate.ps1"

    Write-Verbose "Upgrade pip and install neural network libraries."
    Write-Host "Upgrading pip..."
    python -m pip install --upgrade pip

    Write-Host "Installing neural network libraries (TensorFlow, Keras, PyTorch)..."
    python -m pip install tensorflow keras torch torchvision

    Write-Host "Development environment setup is complete."

    Wait-AnyKey
}
