# Install-Dev_Env_LLM_Win
#

function Install-Dev_Env_LLM_Win {
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

    #MAIN
    Write-Host " Create a working directory for your neural network project"
    $projectDir = "$env:USERPROFILE\Dev\NN\TestProject"
    if (!(Test-Path $projectDir)) {
        Write-Output "Creating project directory at $projectDir"
        New-Item -ItemType Directory -Path $projectDir
    }
    Set-Location $projectDir

    Write-Output "Creating Python virtual environment..."
    python -m venv env
    ""
    Write-Output "Activating virtual environment..."
    # "Use the following command in PowerShell to activate the environment"
    & "$projectDir\env\Scripts\Activate.ps1"

    Write-Host "Upgrade pip and install neural network libraries."
    Write-Output "Upgrading pip..."
    python -m pip install --upgrade pip

    Write-Output "Installing neural network libraries (TensorFlow, Keras, PyTorch)..."
    python -m pip install tensorflow keras torch torchvision

    Write-Output "Development environment setup is complete."

    Wait-AnyKey $MsgAnykey
}