
# Install-DevEnvOsWin
function Install-DevEnvOsWin {
<#
    .SYNOPSIS
        Prepares windows and powershell to install tools.
    .DESCRIPTION
        This script sets up a Windows OS for the development environment.
        It installs Chocolatey (if not already installed).
        It will update PowerShell (from vs 5 to 7).
        TODO: sed, win linux, other tools?
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Install-DevEnvOsWin -DoPause
    .NOTES
        Language mode issues (Constrained Mode vs Full)
        Remove-Item Env:__PSLockDownPolicy
        Set-ExecutionPolicy Unrestricted -Scope CurrentUser
        $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
        $ExecutionContext.SessionState.LanguageMode = "ConstrainedLanguage"
        Uses Security.Principal.WindowsPrincipal
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug, [switch]$DoForce)
    Initialize-Std -$DoPause -$DoVerbose -$DoDebug
    # Ensure the script is running as administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error -Message "This script must be run as an Administrator. Please restart PowerShell with elevated privileges."
        exit
    }
    # Refresh environment PATH for the current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

    # Network visibility in cmd for Administrators
    # reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLinkedConnections" /t REG_DWORD /d 0x00000001 /f
    # or with PowerShell:
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLinkedConnections -Value 1 -PropertyType 'DWord'

    # Update PowerShell (from vs 5 to 7)
    winget install --id Microsoft.PowerShell --source winget
    Wait-AnyKey
}
