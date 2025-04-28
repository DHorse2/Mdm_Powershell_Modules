
# DevEnv_Module_Reset
Write-Host "DevEnv_Module_Reset"
# Remove Mdm Modules
$importName = "Mdm_Modules"
Write-Host "Removing $importName"
Remove-Module -name $importName `
    -Force `
    -ErrorAction SilentlyContinue

$global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
$global:projectRootPath = (get-item $global:moduleRootPath ).Parent.Parent.FullName
$source = "$global:projectRootPath\src\Modules"
Write-Host "Clearing breakpoints..."
Get-PSBreakpoint | Remove-PSBreakpoint
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
[string]$global:projectRootPath = (get-item $PSScriptRoot ).Parent.Parent.Parent.FullName
[string]$global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName

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

