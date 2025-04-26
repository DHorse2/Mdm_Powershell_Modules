
# DevEnv_Module_Reset
Write-Host "DevEnv_Module_Reset"
Write-Host "Clearing breakpoints..."
Get-PSBreakpoint | Remove-PSBreakpoint
Set-PSDebug -Off

$importName = "Mdm_Bootstrap"
[string]$source = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
Write-Host "Set location to `"$source\$importName`""
Set-Location -LiteralPath "$source\$importName"

# Import-Module -name "Mdm_Bootstrap" -force -verbose
Write-Host "Remove Mdm Modules"
Remove-Module -name Mdm_Modules `
    -Force `
    -ErrorAction SilentlyContinue

Write-Host "Bootstrap help:"
Get-Help  Mdm_Bootstrap

$importName = "Mdm_Bootstrap"
if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
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
$global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
[string]$global:timeStartedFormatted = "{0:yyyymmdd_hhmmss}" -f (get-date)
[string]$global:timeCompleted = $global:timeStarted

Write-Host "You will find a list of functions displayed."
Write-Host "If not, run this a second time."
Write-Host "These are your available commands:"
Write-Host " "
Write-Host "Import $importName"
Write-Host "$global:scriptPath\$importName\$importName"

Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -Verbose

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
[string]$global:scriptPath = ""
# $global:timeStarted = Get-Date
# Formatted = "{0:yyyymmdd_hhmmss}" -f (Get-Date)
# $global:timeCompleted = $global:timeStarted

