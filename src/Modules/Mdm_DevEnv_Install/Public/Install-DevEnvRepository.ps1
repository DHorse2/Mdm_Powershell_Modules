
# Install-DevEnvRepository
function Install-DevEnvRepository {
    <#
        .SYNOPSIS
            Install the DevEnvRepository
        .DESCRIPTION
            Install the DevEnvRepository
        .PARAMETER DoPause
            Switch: Pause between steps.
        .PARAMETER DoVerbose
            Switch: Verbose output and prompts.
        .PARAMETER DoDebug
            Switch: Debug this script.
        .OUTPUTS
            none.
        .EXAMPLE
            Install-DevEnvRepository
        .NOTES
            none.
    #>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug, [switch]$DoForce,
        [string]$logFileNameFull = "",
        [switch]$KeepOpen,
        [switch]$Silent
    )
    $installDevEnvRepositoryParams = @{}
    if ($DoForce) { $installDevEnvRepositoryParams['DoForce'] = $true }
    if ($DoVerbose) { $installDevEnvRepositoryParams['DoVerbose'] = $true }
    if ($DoDebug) { $installDevEnvRepositoryParams['DoDebug'] = $true }
    if ($DoPause) { $installDevEnvRepositoryParams['DoPause'] = $true }
    # if ($KeepOpen) { $installDevEnvRepositoryParams['KeepOpen'] = $true }
    # if ($Silent) { $installDevEnvRepositoryParams['Silent'] = $true }
    if ($logFileNameFull) { $installDevEnvRepositoryParams['logFileNameFull'] = $logFileNameFull }
    $installDevEnvRepositoryParams['ErrorAction'] = 'Inquire' 

    Initialize-Std -$DoPause -$DoVerbose -$DoDebug

    Write-Verbose "######################"
    Write-Verbose  "Copying PowerShell modules to System32 PowerShell modules directory..."
    Write-Verbose "Script Security Check and Elevate"
    Set-SecElevated
    
    # Ensure the script is running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error -Message "This script must be run as an Administrator. Please restart PowerShell with elevated privileges."
        exit
    }
    
    #MAIN
    Write-Verbose "Installing / Updating Repositoy Software"

        

    # Chocolatey
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    } else {
        Write-Verbose "Chocolatey is already installed."
    }

    # winget -update

    # python 
    # pip is up to date
    Write-Verbose "Updating pip..." -ForegroundColor Cyan
    python -m ensurepip
    python -m pip install --upgrade pip
    # Virtualenv
    Write-Verbose "Installing virtualenv..." -ForegroundColor Cyan
    python -m pip install --user virtualenv

    if ($DoPause -or ($KeepOpen -and -not $Silent)) { Wait-AnyKey -Message "Install-DevEnvLlmWin Setup is completed." }
    
}
