
# DevEnv_Module_Reset.ps1
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
# DevEnv_Module_Reset
if ($DoVerbose) { Write-Host "==== DevEnv_Module_Reset ====" -ForegroundColor Green }
if (-not $appName) { $appName = "DevEnv_Module_Reset" }
if (-not $actionStep) { $actionStep = $global:actionStep }
# Project Parameters
$devEnvModuleResetParams = $PSBoundParameters
$inArgs = $args
# Get-Parameters
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
. $path
$resetParams = $global:combinedParams
# Project settings and paths
# projectLib.ps1
if ($DoVerbose) { Write-Host "Reset step $($actionStep)) Loading project paths and verification." -ForegroundColor Green }
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
. $path @resetParams

$importName = "Mdm_Std_Library"; $actionStep++
if (-not ((Get-Module -moduleName $importName) -or $DoForce)) {
    if ($DoVerbose) { Write-Host "Reset step $($actionStep)) Import Module: $importName" -ForegroundColor Green }
    $modulePath = "$global:moduleRootPath\$importName"
    try {
        $item = Get-Item "$modulePath\$importName.psm1" -ErrorAction Stop
        # if (Test-Path $modulePath | Out-Null ) { $exists = $true } else { $exists = $false }
        $exists = $true
    } catch { $exists = $false }    
    try {
        if ($DoVerbose) { Write-Host "$($actionStep) Exists: $($exists): $modulePath" }
        # Import-Module -Name "Mdm_Std_Library"
        $module = Import-Module -Name $modulePath @global:importParams
        # Import-Module -Name $modulePath
        if ($module) { $global:moduleArray['Mdm_Std_Library'] = $module }
        $exists = $true
        if ($DoVerbose) { Write-Host "Reset Import Module. $($actionStep)) success: $modulePath" }
    } catch { $exists = $false }    

} else {
    if ($DoVerbose) { Write-Host "Reset, Module already loaded $($actionStep)) $importName" }
}

$source = "$global:projectRootPath\src\Modules"; $actionStep++
if ($DoVerbose) { 
    Write-Host "Reset step $($actionStep)) Path settings:" -ForegroundColor Green
    Write-Host "Project Root: $global:projectRootPath"
    Write-Host " Module Root: $global:moduleRootPath"
    Write-Host "Execution at: $global:projectRootPathActual"
    # Write-Host "      Source: $source"

    Write-Host "Reset step $($actionStep)) Clearing breakpoints..." -ForegroundColor Green
}
# Get-PSBreakpoint | Remove-PSBreakpoint
Set-PSDebug -Off

$importName = "Mdm_Modules"; $actionStep++
if ($DoVerbose) { Write-Host "Reset step $($actionStep): Set location to `"$source\$importName`"" -ForegroundColor Green }
# $scriptDrive = Split-Path -Path "$global:moduleRootPath" -Qualifier
# Set-Location $scriptDrive
# Set-Location -LiteralPath "$source\$importName"
Set-Location -LiteralPath "$source"

if ($DoVerbose) { 
    $actionStep++
    Write-Host "Reset step $($actionStep): Display help for $($importName):" -ForegroundColor Green
    Get-Help $importName
    if ($DoPause) { Wait-AnyKey -Message "DevEnv_Module_Resest Help complete. Enter any key to continue..." }
}

$actionStep++
if ($DoVerbose) { Write-Host "Reset step $($actionStep): Clearing globals before import..." -ForegroundColor Green }
$devEnvModuleResetParams = @{}
if ($DoForce) { $devEnvModuleResetParams['DoForce'] = $true }
if ($DoVerbose) { $devEnvModuleResetParams['DoVerbose'] = $true }
if ($DoDebug) { $devEnvModuleResetParams['DoDebug'] = $true }
if ($DoPause) { $devEnvModuleResetParams['DoPause'] = $true }
if ($logFileNameFull) { $devEnvModuleResetParams['logFileNameFull'] = $logFileNameFull }
# Clear-StdGlobals -DoLogFile -DoDispose @devEnvModuleResetParams
# Stand alone functionality. See projectLib.ps1
if (-not $global:ClearStdGlobalsImport) {
    $global:ClearStdGlobalsImport = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\Public\Clear-StdGlobals.ps1"
    . $path
}
Clear-StdGlobals -actionStep $actionStep -DoLogFile @devEnvModuleResetParams
# Import-All Dispose / Remove Modules
# $DoDispose = $true
# if ($DoDispose) {
#     # $actionStep = 0
#     $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\ImportAllLib.ps1"
#     . $path @devEnvModuleResetParams
# }

# Remove Mdm Modules
# $importName = "Mdm_Modules"; $actionStep++
# if ($DoVerbose) { Write-Host "Reset step $($actionStep): Forced removal of $importName" }
# try {
#     Remove-Module -Name $importName `
#         -Force `
#         -ErrorAction SilentlyContinue
# } catch { $null }

# Project Settings
$actionStep++
if ($DoVerbose) { Write-Host "Reset step $($actionStep): Reloading project paths and verification." -ForegroundColor Green }
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
. $path @devEnvModuleResetParams

# $actionStep++
# if ($DoVerbose) { 
#     Write-Host "The Modules will now be (re)loaded. "
#     Write-Host "Reset step $($actionStep): You might find a list of functions displayed."
#     Write-Host "If not, run this a second time."
#     Write-Host "These are your available commands:"
#     Write-Host " "
#     Write-Host "Import ALL $importName separately"
#     Write-Host "$global:moduleRootPath\$importName"
#     # Import-Module -Name "$global:moduleRootPath\$importName" -Force -Verbose
# } else {
#     # Import-Module -Name "$global:moduleRootPath\$importName" -Force
# }

# # Import-All
# $DoDispose = $false
# $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\ImportAllLib.ps1"
# . $path @devEnvModuleResetParams
