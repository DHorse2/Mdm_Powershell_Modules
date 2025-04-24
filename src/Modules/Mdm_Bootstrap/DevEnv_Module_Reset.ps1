
# DevEnv_Module_Reset
[string]$source = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
Write-Host "DevEnv_Module_Reset"
Write-Host "Set location to `"$source\$importName`""
Set-Location -LiteralPath "$source\$importName"

# Import-Module -name "Mdm_Bootstrap" -force -verbose
Write-Host "Remove Mdm Modules"
Remove-Module -name Mdm_Modules `
    -Force `
    -ErrorAction SilentlyContinue `

Write-Host "clearing globals..."
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
[string]$global:scriptPath = $source
[string]$global:timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
[string]$global:timeCompleted = $global:timeStarted

Get-Help  Mdm_Bootstrap

$importName = "Mdm_Bootstrap"
Write-Host "The Bootstrap Module will now be (re)loaded. "
Write-Host "You will find a list of functions displayed."
Write-Host "These are your available commands:"
Write-Host " "
Write-Host "Import $importName"
Write-Host "$global:scriptPath\$importName\$importName"
Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -Verbose

Get-PSBreakpoint | Remove-PSBreakpoint
