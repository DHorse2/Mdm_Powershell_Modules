
# Show-Error
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
    $Message,
    [Parameter(Mandatory = $false)]
    [System.Management.Automation.ErrorRecord]$ErrorPSItem,
    [switch]$IsError,
    [switch]$IsWarning,
    [switch]$SkipScriptLineDisplay,
    [switch]$UseTraceWarningDetails,
    [switch]$DoForce,
    [switch]$DoVerbose,
    [switch]$DoDebug,
    [switch]$DoPause,
    [string]$logFileNameFull = ""
)
# DevEnv_Module_Reset
Write-Host "Show-Error"
$callStack = Get-PSCallStack
$errorValue = $Error
if (-not $Message) {
    $Message = $errorValue
}
$MessageArray = $Message.split("+")
$i=0
foreach ($MessageLine in $MessageArray) {
    Write-Host "[$i] $MessageLine"
    $i++
}    
Write-Host " "

Add-LogError -Message $Message -ErrorPSItem $ErrorPSItem -logFileNameFull $logFileNameFull

Write-Host "Project Root: $global:projectRootPath"
Write-Host " Module Root: $global:moduleRootPath"

Write-Host "  Call stack: "
$MessageLine = Get-CallStackFormatted $callStack "$global:NL"
Write-Host $MessageLine

Write-Host "log File Name: $global:app.logFileName"
Write-Host "log File Path: $global:app.logFilePath"
Write-Host "log File Name Full: $global:app.logFileNameFull"
Write-Host "Log One File: $global:app.logOneFile"
