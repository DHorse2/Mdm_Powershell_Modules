
[CmdletBinding()]
param (
    [switch]$DoForce,
    [switch]$DoVerbose,
    [switch]$DoDebug,
    [switch]$DoPause
    # $extraStuff
)
# DevEnv_Module_Reset
if ($DoVerbose) { Write-Host "DevEnv_Module_Reset" }
# Remove Mdm Modules
$importName = "Mdm_Modules"
if ($DoVerbose) { Write-Host "Reset step 1: Forced removal of $importName" }
try {
    Remove-Module -Name $importName `
        -Force `
        -ErrorAction SilentlyContinue
} catch { $null }

if ($DoVerbose) { Write-Host "Reset step 2: Loading project paths and verification." }
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Modules\Project.ps1"
. "$path"

# $folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -leaf
# if ( $folderName -eq "Public" -or $folderName -eq "Private" ) {
#     $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
# } elseif ($folderName -ne $importName) {
#     $global:moduleRootPath = "$global:projectRootPath\src\Modules"
#     # $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
# } else {
#     $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
# }
# if (-not (Get-Item $global:moduleRootPath -ErrorAction SilentlyContinue)) {
#     $global:moduleRootPath = (Get-Item $PSScriptRoot).Parent.FullName
# }
# $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
# if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
$source = "$global:projectRootPath\src\Modules"

if ($DoVerbose) { 
    Write-Host "Project Root: $global:projectRootPath"
    Write-Host " Module Root: $global:moduleRootPath"
    Write-Host "Execution at: $global:projectRootPathActual"
    # Write-Host "      Source: $source"

    Write-Host "Reset step 3: Clearing breakpoints..."
}
# Get-PSBreakpoint | Remove-PSBreakpoint
Set-PSDebug -Off

$importName = "Mdm_Modules"
if ($DoVerbose) { Write-Host "Reset step 4: Set location to `"$source\$importName`"" }
# $scriptDrive = Split-Path -Path "$global:moduleRootPath" -Qualifier
# Set-Location $scriptDrive
# Set-Location -LiteralPath "$source\$importName"
Set-Location -LiteralPath "$source"

if ($DoVerbose) { 
    Write-Host "Reset step 5: $importName help:" 
    Get-Help $importName

    Write-Host "Reset step 6.1: Clearing globals before import..."
}
[bool]$global:InitDone = $false
[bool]$global:InitStdDone = $false

[string]$global:msgAnykey = ""
[string]$global:msgYorN = ""
[switch]$global:InitStdDone = $false

# [bool]$global:DoVerbose = $false
# [bool]$global:DoPause = $false
# [bool]$global:DoDebug = $false
# [bool]$global:DoForce = $false

# This causes a new file to be constructed:
[string]$global:logFileNameFull = ""
[string]$global:logFileName = ""
[string]$global:logFilePath = ""
[bool]$global:LogOneFile = $false

# Project Settings
if ($DoVerbose) { Write-Host "Reset step 6.2: Reloading project paths and verification." }
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Modules\Project.ps1"
. "$path"

# $folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -Leaf
# if ( $folderName -eq "Public" -or $folderName -eq "Private" ) {
#     $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
# } else { $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName }
# $global can set
[bool]$global:DoVerbose = $DoVerbose
[bool]$global:DoPause = $DoPause
[bool]$global:DoDebug = $DoDebug
[bool]$global:DoForce = $DoForce
if ($DoVerbose) { 
    Write-Host "The Modules will now be (re)loaded. "
    Write-Host "Reset step 7: You might find a list of functions displayed."
    Write-Host "If not, run this a second time."
    Write-Host "These are your available commands:"
    Write-Host " "
    Write-Host "Import ALL $importName separately"
    Write-Host "$global:moduleRootPath\$importName"
    # Import-Module -Name "$global:moduleRootPath\$importName" -Force -Verbose
} else {
    # Import-Module -Name "$global:moduleRootPath\$importName" -Force
}
# Import-All
$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Modules\Import-All.ps1"
. $path

if ($DoVerbose) { Write-Host "Reset step 8: Clearing breakpoints..." }
Get-PSBreakpoint | Remove-PSBreakpoint

if ($DoVerbose) { Write-Host "Reset step 9: Clearing globals for next run..." }
[bool]$global:InitDone = $false
[bool]$global:InitStdDone = $false

# [bool]$global:DoVerbose = $false
# [bool]$global:DoPause = $false
# [bool]$global:DoDebug = $false
# [bool]$global:DoForce = $false
[string]$global:msgAnykey = ""
[string]$global:msgYorN = ""
[switch]$global:InitStdDone = $false

# [string]$global:moduleRootPath = $null
# [string]$global:projectRootPath = $null

$global:timeStarted = $null
$global:timeStartedFormatted = ""
$global:timeCompleted = $null

if ($DoVerbose) { 
    Write-Host "log File Name: $global:logFileName"
    Write-Host "log File Path: $global:logFilePath"
    Write-Host "log File Name Full: $global:logFileNameFull"
    Write-Host "Log One File: $global:LogOneFile"
}
