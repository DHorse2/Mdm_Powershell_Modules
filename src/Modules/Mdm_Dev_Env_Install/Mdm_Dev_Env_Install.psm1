<#
    .SYNOPSIS
        Development Environment Install Module does what it says.
    .DESCRIPTION
        This modules separates the installation by component type:
        Get-Dev_Env_Versions (Get-Vs) will show current installed versions.
        Installation steps/tasks:
            Install-Dev_Env_Win,
            Install-Dev_Env_IDE_Win,
            Install-Dev_Env_LLM_Win,
            Install-Dev_Env_OS_Win,
            Install-Dev_Env_Whisper_Win
    .OUTPUTS
        The Development Environment Install Module.
    .EXAMPLE
        Import-module Install-Mdm_Dev_Env
    .NOTES
        todo.
#>

# Install-Mdm_Dev_Env
# Imports

# Normal Import-Module
#     Import-Module Mdm_Std_Library
# This works with uninstalled Modules (both)
    $importName = "Mdm_Std_Library"
    $scriptPath = (get-item $PSScriptRoot ).parent.FullName
    Import-Module -Name "$scriptPath\$importName\$importName" -Force -ErrorAction Stop

# Variables: 
#############################

# Dev Env Tool Versions
Function Get-Dev_Env_Versions {
<#
    .SYNOPSIS
        List current versions.
    .DESCRIPTION
        Cycles through components and display the current version.
    .PARAMETER DoPause
        Switch to pause at each step/page.
    .PARAMETER DoVerbose
        Provide detailed information.
    .PARAMETER DoDebug
        Debug this script.
    .EXAMPLE
        Get-Dev_Env_Versions -DoVerbose
    .NOTES
        needs work.
    .OUTPUTS
        Should output a file and display.
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    # Import-Module Mdm_Std_Library
    Script_ResetStdGlobals
    Script_Initialize_Std -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Verbose:$DoVerbose -Debug:$DoDebug

    # Language mode: FullLanguage needed, Add cert
    # Set-ExecutionPolicy Unrestricted
    # $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
    Write-Verbose "PSScriptRoot: $PSScriptRoot Import"
    Write-Verbose "PSScriptRoot: $PSScriptRoot Initialize $(Script_Name)"
 
    # $PSScriptRoot
    Write-Verbose "PSScriptRoot: $PSScriptRoot Started. Checking libraries."
    if (Get-Command Wait-AnyKey -ErrorAction SilentlyContinue) {
        if ($global:DoVerbose) { Write-Host "Wait-AnyKey loaded successfully." -ForegroundColor Green }
    }
    else {
        Write-Warning "Error: Wait-AnyKey function not loaded."
        if ($global:DoVerbose) { Write-Host "Trying library path method." -ForegroundColor Red }
        $stdLibraryPath = "$PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1"
        if (Test-Path $stdLibraryPath) {
            if ($global:DoVerbose) { Write-Host "Loading Std_Library.ps1..." -ForegroundColor Cyan }
            . $stdLibraryPath
        }
        else {
            Write-Error "Mdm_Std_Library.psm1 NOT FOUND at $stdLibraryPath"
            exit
        }
        # exit
    }
 
    $response = "Y"
    if ($global:DoVerbose -or $global:DoPause) { $response = Wait-YorNorQ }
    If ($response -eq "Y") {

        # Write-Verbose "################################################################################"
        # Write-Host "Console Window"
        # Get-Host
        Write-Verbose "################################################################################"
        # $ThisWindow = Get-Host
        powershell -command "(Get-Host).Name"
        Write-Verbose "################################################################################"

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($global:DoVerbose) { 
            Write-Verbose "Path:"
            # Refresh environment PATH for the current session
            $env:Path -split ";" | Write-Host
            Write-Verbose "################################################################################"
            if ($global:DoPause) { Wait-AnyKey }

            Write-Verbose "Environment:"
            Get-ChildItem Env: | Write-Host
            Write-Verbose "################################################################################"

            # Refresh environment PATH for the current session
            $psPath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
            Write-Host "Path:"
            $psPath -split ";" | Write-Host
            Write-Verbose "################################################################################"
            if ($global:DoPause) { Wait-AnyKey }
        }

        # PowerShell
        Write-Host "PowerShell version: " -NoNewline
        # powershell -Command "$PSVersionTable.PSVersion"
        # powershell -command "(Get-Variable PSVersionTable -ValueOnly).Name"
        $PSVersionTable.PSVersion.ToString() | Write-Host
        # function Get-PSVersion {
        # Write-Verbose $PSVersionTable.PSVersion
        # (depreciated) Write-Verbose pwsh -Version
        # Write-Verbose $Host.Version
        # powershell -command "(Get-Variable PSVersionTable -ValueOnly).Name"
        #     if (test-path variable:psversiontable) {$psversiontable.psversion} else {[version]"1.0.0.0"}
        # }
        Write-Verbose "################################################################################"

        # Python
        Write-Host "Python version: " -NoNewline
        python --version  | Write-Host
        Write-Verbose "################################################################################"

        # VsCodium 
        Write-Host "VsCodium version: " -NoNewline
        codium --version | Write-Host
        Write-Verbose "################################################################################"

        # VsCode 
        Write-Host "VsCode version: " -NoNewline
        code --version | Write-Host
        Write-Verbose "################################################################################"

        # NodeJs
        Write-Host "Node version: " -NoNewline
        node -v | Write-Host
        Write-Verbose "################################################################################"

        if ($Global:DoDebug) {
            Write-Host " Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug"
            Write-Host "Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug"
    
            Write-Host "$global:msgAnykey Pause: $global:DoPause"
            if ($global:DoPause) { Wait-AnyKey }
        }
    }
}
# MAIN function:
function Install-Dev_Env_Win {
<#
    .SYNOPSIS
      Install the Windows Development Environment.
    .DESCRIPTION
        Performs these installations:
            Install-Dev_Env_OS_Win 
            Install-Dev_Env_IDE_Win
            Install-Dev_Env_LLM_Win
            Install-Dev_Env_Whisper_Win
        When complete it displays current version for the environment.
    .PARAMETER UpdatePath
        Switch: A switch to indicate the path should be checked/updated.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .EXAMPLE
        Install-Dev_Env_Win -DoPause -UpdatePath
    .NOTES
        Confirms each step.
    .OUTPUTS
        todo Should create a log.
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    if (Wait-YorNorQ -message "Set up the Windows OS?" -eq "Y") { 
        Install-Dev_Env_OS_Win -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Set up the IDE?"-eq "Y") { 
        Install-Dev_Env_IDE_Win -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Set up the LLM?"-eq "Y") { 
        Install-Dev_Env_LLM_Win -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Set up the Whisper Voice?"-eq "Y") { 
        Install-Dev_Env_Whisper_Win -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Display current versions?"-eq "Y") { 
        Get-Dev_Env_Versions -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug 
    }
}
# Components: 

# Install-Dev_Env_IDE_Win
function Install-Dev_Env_IDE_Win {
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
        Install-Dev_Env_IDE_Win -DoVerbose
    .NOTES
        Installs:
            Chocolatey
            Python 3
            Git
            Visual Studio Code
        todo incomplete. .
            Micrsoft toolchain
            VsCode
            VsCodium
            Rust toolchain
    .OUTPUTS
        A log (todo).
#>
[CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    # Import-Module Mdm_Std_Library
    Script_Initialize_Std -$DoPause -$DoVerbose

    Wait-AnyKey

    Write-Verbose "######################"
    Write-Verbose  "Copying PowerShell modules to System32 PowerShell modules directory..."
    Write-Verbose "Script Security Check and Elevate"
    Set-ScriptSecElevated

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

    # Import-Module Mdm_Std_Library

    Write-Verbose "######################"
    Write-Verbose  "Copying PowerShell modules to System32 PowerShell modules directory..."
    Write-Verbose "Script Security Check and Elevate"
    Set-ScriptSecElevated

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
# Install-Dev_Env_OS_Win
function Install-Dev_Env_OS_Win {
<#
    .SYNOPSIS
        Prepares windows and powershell to install tools.
    .DESCRIPTION
        This script sets up a Windows OS for the development environment.
        It installs Chocolatey (if not already installed).
        It will update PowerShell (from vs 5 to 7).
        todo: sed, win linux, other tools?
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Install-Dev_Env_OS_Win -DoPause
    .NOTES
        Language mode issues (Constrained Mode vs Full)
        Remove-Item Env:__PSLockDownPolicy
        Set-ExecutionPolicy Unrestricted -Scope CurrentUser
        $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
        $ExecutionContext.SessionState.LanguageMode = "ConstrainedLanguage"
        Uses Security.Principal.WindowsPrincipal
#>
[CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    # Ensure the script is running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "This script must be run as an Administrator. Please restart PowerShell with elevated privileges."
        exit
    }
    # Install Chocolatey if it is not installed
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else {
        Write-Host "Chocolatey is already installed."
    }

    # Refresh environment PATH for the current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

    # Network visibility in cmd for Administrators
    # reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLinkedConnections" /t REG_DWORD /d 0x00000001 /f
    # or with PowerShell:
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLinkedConnections -Value 1 -PropertyType 'DWord'

    # Update PowerShell (from vs 5 to 7)
    winget install --id Microsoft.PowerShell --source winget

    # ?
    Wait-AnyKey
}
# Install-Dev_Env_Whisper_Win
function Install-Dev_Env_Whisper_Win {
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
        Install-Dev_Env_Whisper_Win
    .NOTES
        none.
#>
[CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    # PowerShell Script to Install Whisper on Windows

    # Check for Administrator Privileges
    $adminCheck = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $adminCheck.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Verbose "Please run this script as an Administrator." -ForegroundColor Red
        exit
    }

    # Check if Python is installed
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Write-Verbose "Python is not installed. Downloading and installing Python..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe" -OutFile "$env:TEMP\python-installer.exe"
        Start-Process -FilePath "$env:TEMP\python-installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item "$env:TEMP\python-installer.exe"
        $env:Path += ";C:\Python310;C:\Python310\Scripts"
        Write-Verbose "Python installed successfully." -ForegroundColor Green
    }

    # Ensure pip is up to date
    Write-Verbose "Updating pip..." -ForegroundColor Cyan
    python -m ensurepip
    python -m pip install --upgrade pip

    # Install virtualenv if not installed
    Write-Verbose "Installing virtualenv..." -ForegroundColor Cyan
    python -m pip install --user virtualenv

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

function Install-Dev_Env_Modules {
<#
    .SYNOPSIS
        Install these modules on the local system.
    .DESCRIPTION
        NOT IN USE.
    .PARAMETER inputObjects
        .
    .PARAMETER xxxx
        .
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        .
    .EXAMPLE
        Install-Dev_Env_Modules
    .LINK
        XXX: http://www.XXX
    .LINK
        YYY
    .NOTES
        .
#>
[CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]$inputObjects
    )

    begin {
        [Collections.ArrayList]$inputObjects = @()
    }
    process {
        [void]$inputObjects.Add($_)
    }
    end {
        $inputObjects | ForEach-Object -Parallel {
      
        }
    }
}
#############################
Set-Alias -Name Get-Vs -Value Get-Dev_Env_Versions

<# Programmer's dead/alternative code.
#############################
# Export-ModuleMember -Function Get-Dev_Env_Versions, Install-Dev_Env_Win, Install-Dev_Env_IDE_Win, Install-Dev_Env_LLM_Win, Install-Dev_Env_OS_Win, Install-Dev_Env_Whisper_Win -Alias "" -Cmdlet ""

# Export-ModuleMember -Function Get-Dev_Env_Versions,
#     Install-Dev_Env_Win,
#     Install-Dev_Env_IDE_Win,
#     Install-Dev_Env_LLM_Win,
#     Install-Dev_Env_OS_Win,
#     Install-Dev_Env_Whisper_Win
#  -Alias "" -Cmdlet ""
# Set-Alias -Name Get-Vs -Value Get-Dev_Env_Versions
# Get-Vs | Write-Debug

#############################
# . $PSScriptRoot\Get-Dev_Env_Versions.ps1
# . $PSScriptRoot\Install-Dev_Env_Win.ps1
# . $PSScriptRoot\Install-Dev_Env_IDE_Win.ps1
# . $PSScriptRoot\Install-Dev_Env_LLM_Win.ps1
# . $PSScriptRoot\Install-Dev_Env_OS_Win.ps1
# . $PSScriptRoot\Install-Dev_Env_Whisper_Win.ps1

#############################
# Export-ModuleMember -Function " +
#     "Install-Dev_Env_Win", +
#     "Install-Dev_Env_IDE_Win", + 
#     "Install-Dev_Env_LLM_Win", +
#     "Install-Dev_Env_OS_Win", +
#     "Install-Dev_Env_Whisper_Win" +
# " -Alias "" -Cmdlet "Get-Dev_Env_Versions"

#############################
# . "$(Split-Path -Parent $PSScriptRoot)\Mdm_Std_Library\Std_Start.psm1"
# Import-Module '$(Split-Path -Parent $PSScriptRoot)\Mdm_Std_Library\Std_Start.psm1'
# Import-Module Std_Start
#>
