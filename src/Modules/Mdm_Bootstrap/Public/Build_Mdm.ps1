
# Build_Mdm.ps1
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
Write-Host "Building Modules"
Write-Host "===================" -ForegroundColor Green
if (-not $appName) {
    $appName = "Build_Mdm"
    $functionParams['appName'] = $appName
}
if (-not $actionStep) { $actionStep = $global:actionStep }
# Parameters
$logFileNameFull = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\log\Build_Mdm.txt"
$inArgs = $args
$path = "$($(Get-Item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
. $path @global:combinedParams
# Project Settings
$path = "$($(Get-Item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
. $path @global:combinedParams
# Path
$localPath = $global:moduleRootPath
Write-Host "Load Security"
try {
    $global:CodeActionError = $true; $global:CodeActionError = $null
    $global:CodeActionLogFile = "$localPath\Mdm_Std_Library\log\CheckSecurity_Build.txt"
    # Check-Security
    $path = "$localPath\Mdm_Std_Library\lib\Check-Security.ps1"
    . $path @global:combinedParams
} catch {
    $global:CodeActionError = $_
    $UseTraceStack = $false
    # Could-Fail (and did)
    $path = "$localPath\Mdm_Std_Library\lib\Could-Fail.ps1"
    . $path @global:combinedParams
}
Write-Host "Go To Bootstrap"
. "$localPath\Mdm_Bootstrap\GoToBootstrap.ps1"  @global:combinedParams
Get-Location

# # Write-Host "Dev Env Module Reset"
# $path = "$localPath\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"
# . $path @global:commonParams

# # Get-ModuleRootPath
# $path = "$localPath\Mdm_Std_Library\lib\ProjectLib.ps1"
# . $path @global:combinedParams

# # $GetGlobal = $true; $SetGlobal = $false
# $inArgs = $args
# "$localPath\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
# . $path @global:combinedParams


Write-Host "Dev Env Install Modules Win"
try {
    DevEnv_Install_Modules_Win -DoRegistry -DoCopy -DoHelp @global:commonParams
} catch {
    Add-LogText -IsError -ErrorPSItem $_ "Dev Env Install Modules Win had and error."
    exit
}

Write-Host "Build completed."

# $importName = "Mdm_Modules"
# Write-Host "Loading the complete module library."
# Write-Host "Run from: $localPath. Importing $importName."
# Write-Host "Global module root: $global:moduleRootPath"
# $commonParameters['Force'] = $true
# # Import-Module -Name $importName -Force
# Import-Module -Name "$localPath\$importName" @global:commonParams
