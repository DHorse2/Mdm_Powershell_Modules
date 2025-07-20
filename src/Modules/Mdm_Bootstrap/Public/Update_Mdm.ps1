
# Update_Mdm.ps1
[CmdletBinding()]
param (
    [string]$appName = "",
    [int]$actionStep = 0,
    [switch]$DoForce,
    [switch]$DoVerbose,
    [switch]$DoDebug,
    [switch]$DoPause,
    [string]$logFileNameFull = ""
)
$functionParams = $PSBoundParameters
Write-Host "====== Start ======" -ForegroundColor Green
Write-Host "Updating System Modules"
Write-Host "===================" -ForegroundColor Green
if (-not $appName) {
    $appName = "Update_Mdm"
    $functionParams['appName'] = $appName
}
if (-not $actionStep) { $actionStep = $global:actionStep }
# Parameters
if (-not $logFileNameFull) { $logFileNameFull = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\log\$($appName)_Log.txt" }
# $global:combinedParams['logFileNameFull'] = $logFileNameFull
$inArgs = $args
# Get-ParametersLib
$path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
. $path
# Project Settings ProjectLib
$path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
. $path
# Path
$localPath = $global:moduleRootPath

Write-Host "Load Security"
try {
    $global:CodeActionError = $true; $global:CodeActionError = $null
    $global:CodeActionLogFile = "$localPath\Mdm_Std_Library\log\CheckSecurity_Update.txt"
    # Check-Security
    $path = "$localPath\Mdm_Std_Library\lib\Check-Security.ps1"
    . $path
} catch {
    $global:CodeActionError = $_
    $UseTraceStack = $false
    # Could-Fail (and did)
    $path = "$localPath\Mdm_Std_Library\lib\Could-Fail.ps1"
    . $path
}

Write-Host "Go To Bootstrap"
$path = "$localPath\Mdm_Bootstrap\GoToBootstrap.ps1"
. $path @global:combinedParams
# Get-Location

# Write-Host "Dev Env Module Reset"
# $path = "$localPath\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"
# . $path  @global:commonParams

# Project settings and paths
# Get-ModuleRootPath
# $path = "$localPath\Mdm_Std_Library\lib\ProjectLib.ps1"
# . $path @global:combinedParams

# $GetGlobal = $true; $SetGlobal = $false
# $inArgs = $args
#  "$localPath\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
# . $path @global:combinedParams

Write-Host "Dev Env Install Modules Win - Update only"
try {
    # DevEnv_Install_Modules_Win -SkipHelp
    DevEnv_Install_Modules_Win -DoRegistry -DoCopy @global:combinedParams
} catch {
    Add-LogText -IsError -IsCritical -ErrorPSItem $_ `
        -Message "Unable to call Dev Env Install Modules Win. Update only had a critical error." `
        -ForegroundColor Red -BackgroundColor Black
    exit
}

Write-Host "Update completed."

# $importName = "Mdm_Modules"
# Write-Host "Loading the complete module library."
# Write-Host "Run from: $localPath. Importing $importName."
# Write-Host "Global module root: $global:moduleRootPath"
# $commonParameters['Force'] = $true
# # Import-Module -Name $importName -Force
# Import-Module -Name "$localPath\$importName" @global:commonParams
