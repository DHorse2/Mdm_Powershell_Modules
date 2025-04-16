
Write-Host "Dev_Module_Import"
Write-Host "Remove Mdm Modules"
Remove-Module -name Mdm_Modules `
    -Force `
    -ErrorAction SilentlyContinue `

Write-Host "clearing globals..."
[switch]$global:DoVerbose = $false
[switch]$global:DoPause = $false
[switch]$global:DoDebug = $false
[string]$global:msgAnykey = ""
[string]$global:msgYorN = ""
[switch]$global:InitStdDone = $false

[string]$global:logFileName = ""
[string]$global:logFilePath = ""
[string]$global:logFileNameFull = ""
[bool]$global:LogOneFile = $false

# [string]$global:scriptPath = $null
[string]$source = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
# $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
$global:scriptPath = $source


$global:timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
$global:timeCompleted = $global:timeStarted

$importName = "Mdm_Bootstrap"
Write-Host "Import $importName"
Write-Host "$global:scriptPath\$importName\$importName"
Import-Module -Name "$global:scriptPath\$importName\$importName" -Force

# Import-Module -name "Mdm_Bootstrap" -force -verbose
Set-LocationToPath "$source\$importName"
