
# Start.ps1
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
if (-not $appName) { $appName = "Start" }
$functionParams = $PSBoundParameters
Write-Host "====== Start ======" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
if (-not $actionStep) { $actionStep = $global:actionStep }
if (-not $logFileNameFull) {
    if (-not $logFileNameFull -and $global:app) { $logFileNameFull = $global:app.logFileNames[$appName] }
    if (-not $logFileNameFull) { $logFileNameFull = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Std_Library\log\Start.txt" }
}
$functionParams['logFileNameFull'] = $logFileNameFull
# Project Parameters
$inArgs = $args
# Get-Parameters
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\Get-ParametersLib.ps1"
. $path
$startParams = $global:combinedParams
# Project settings and paths
# projectLib.ps1
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\ProjectLib.ps1"
. $path
# Check Security
try {
    $global:CodeActionError = $false; $global:CodeActionErrorInfo = @(); $global:CodeActionErrorMessage = @()
    $global:CodeActionContent = ""; $global:CodeActionLogFile = "$($(get-item $PSScriptRoot).Parent.FullName)\log\CheckSecurity_Start.txt"
    Remove-Item -Path $global:CodeActionLogFile -ErrorAction SilentlyContinue
    # Load Security
    Write-Host "====== ExecutionPolicy ======" -ForegroundColor Green
    # Check-Security
    $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\Check-Security.ps1"
    # . $path -logFileNameFull $global:CodeActionLogFile @startParams
    . $path
} catch {
    $global:CodeActionErrorInfo = $_
    $CodeActionError = $true
    $UseTraceStack = $false
    # Could-Fail (and did)
    $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\Could-Fail.ps1"
    . $path
}
#
# # Could-Fail Test-CouldFail Test Data Collection
# $DoVerbose = $true
# $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\Could-Fail.ps1"
# . $path @startParams

Write-Host "====== Set Location ======" -ForegroundColor Green
$PSScriptDrive = Split-Path -Path "$global:moduleRootPath" -Qualifier
Set-Location $PSScriptDrive
Set-Location $PSScriptRoot

Write-Host "====== Goto Bootstrap ======" -ForegroundColor Green
$PSScriptDrive = Split-Path -Path "$global:moduleRootPath" -Qualifier
Set-Location $PSScriptDrive
Set-Location -Path "$global:moduleRootPath"
$path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Bootstrap\GoToBootstrap.ps1"
. $path @startParams
# Get-Location

try {
    Write-Host "====== Do Reset ======" -ForegroundColor Green
    if ($DoDebug -or $DoVerbose) {
        if ($startParams.Count) {
            Write-Host "Combined Parameters:" -ForegroundColor Blue
            ForEach ($Key in $startParams.Keys) {
                Write-Host "Key: $Key = $($startParams[$Key])" -ForegroundColor Blue
            }
        }
        Get-Location
    }
    # Mdm_Bootstrap\DevEnv_Module_Reset
    $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"
    . $path -actionStep $actionStep @startParams
    if ($DoDebug -or $DoVerbose) { Write-Host "Reset finished." -ForegroundColor Yellow }
} catch {
    Write-Host "Do Reset failed with error: $_" -ForegroundColor Red
}
# Update Project Parameters
$inArgs = $args
if (-not $logFileNameFull -and $global:app) { $logFileNameFull = $global:app.logFileNames[$appName] }
if ($logFileNameFull) { $functionParams['logFileNameFull'] = $logFileNameFull }
# Get-Parameters
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\Get-ParametersLib.ps1"
. $path
$startParams = $global:combinedParams
# Import-All
if ($DoDebug -or $DoVerbose) { Write-Host "====== Import All Modules ======" -ForegroundColor Green }
try {
    $actionStep++
    if ($DoVerbose) { 
        Write-Host "Reset step $($actionStep): Import all modules." -ForegroundColor Green
        Write-Host "The Modules will now be (re)loaded. "
        Write-Host "You should find a list of functions displayed."
        Write-Host "If not, run this a second time."
        Write-Host "These are your available commands:"
    }
    $DoDispose = $false
    # Import-All.ps1
    $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\ImportAllLib.ps1"
    # . "$path"
    # . $path
    . $path -actionStep $actionStep @startParams
    # Import-All -actionStep $actionStep @startParams
} catch {
    Write-Host "Import All failed with error: $_" -ForegroundColor Red
}

Write-Host "====== Start completed ======" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
