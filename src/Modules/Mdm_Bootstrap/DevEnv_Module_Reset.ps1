
# DevEnv_Module_Reset
Write-Host "DevEnv_Module_Reset"
# Remove Mdm Modules
$importName = "Mdm_Modules"
Write-Host "Removing $importName"
Remove-Module -name $importName `
    -Force `
    -ErrorAction SilentlyContinue

$folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -Leaf
if ( $folderName -eq "Public" -or $folderName -eq "Private" ) {
    $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
} elseif ($folderName -ne $importName) {
    $global:moduleRootPath = "$global:projectRootPath\src\Modules"
    # $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
} else {
    $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
}
if (-not (Get-Item $global:moduleRootPath -ErrorAction SilentlyContinue)) {
    $global:moduleRootPath = (Get-Item $PSScriptRoot).Parent.FullName
}
$global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
# if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
$source = "$global:projectRootPath\src\Modules"
Write-Host "Project Root: $global:projectRootPath"
Write-Host " Module Root: $global:moduleRootPath"
# Write-Host "      Source: $source"

Write-Host "Clearing breakpoints..."
# Get-PSBreakpoint | Remove-PSBreakpoint
Set-PSDebug -Off

$importName = "Mdm_Bootstrap"
Write-Host "Set location to `"$source\$importName`""
Set-Location -LiteralPath "$source\$importName"

$importName = "Mdm_Bootstrap"
Write-Host "$importName help:"
Get-Help $importName

Write-Host "The Bootstrap Module will now be (re)loaded. "
Write-Host "Clearing globals before import..."
[bool]$global:InitDone = $false
[bool]$global:InitStdDone = $false

[bool]$global:DoVerbose = $false
[bool]$global:DoPause = $false
[bool]$global:DoDebug = $false
[string]$global:msgAnykey = ""
[string]$global:msgYorN = ""
[switch]$global:InitStdDone = $false

[string]$global:logFileName = ""
[string]$global:logFilePath = ""
[string]$global:logFileNameFull = ""
[bool]$global:LogOneFile = $false

$folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -Leaf
if ( $folderName -eq "Public" `
        -or $folderName -eq "Private" `
        -or $folderName -ne $importName) {
    $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
} else { $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName }
$global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName

Write-Host "You will find a list of functions displayed."
Write-Host "If not, run this a second time."
Write-Host "These are your available commands:"
Write-Host " "
Write-Host "Import $importName"
Write-Host "$global:moduleRootPath\$importName\$importName"

Import-Module -Name "$global:moduleRootPath\$importName\$importName" -Force -Verbose

Write-Host "Clearing breakpoints..."
Get-PSBreakpoint | Remove-PSBreakpoint

Write-Host "Clearing globals for next run..."
[bool]$global:InitDone = $false
[bool]$global:InitStdDone = $false

[bool]$global:DoVerbose = $false
[bool]$global:DoPause = $false
[bool]$global:DoDebug = $false
[string]$global:msgAnykey = ""
[string]$global:msgYorN = ""
[switch]$global:InitStdDone = $false

[string]$global:logFileName = ""
[string]$global:logFilePath = ""
[string]$global:logFileNameFull = ""
[bool]$global:LogOneFile = $false
[string]$global:moduleRootPath = $null
[string]$global:projectRootPath = $null

$global:timeStarted = $null
$global:timeStartedFormatted = "" # "{0:yyyymmdd_hhmmss}" -f ($global:timeStarted)
$global:timeCompleted = $null

