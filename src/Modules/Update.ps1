
# Update.ps1
Write-Host "Updating System Modules"

$path = "$($PSScriptRoot)\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"

$path = "$($PSScriptRoot)\Mdm_Modules\Project.ps1"
. "$path"

$localPath = $global:moduleRootPath

Write-Host "ExecutionPolicy:"
Get-ExecutionPolicy
# Set-ExecutionPolicy RemoteSigned

Write-Host "Go To Bootstrap"
. "$localPath\GoToBootstrap.ps1"
Get-Location

$path = "$localPath\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"

Write-Host "Dev Env Module Reset"
$global:logFileNameFull = ""
. "$localPath\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"  @commonParameters

$path = "$localPath\Mdm_Modules\Project.ps1"
. "$path"

Write-Host "Dev Env Install Modules Win - Update only"
try {
    # DevEnv_Install_Modules_Win -SkipHelp
    DevEnv_Install_Modules_Win -SkipHelp @commonParameters
} catch {
    Add-LogError -IsError -ErrorPSItem $_ -Message "Dev Env Install Modules Win - Update only had and error."
    exit
}

Write-Host "Update completed."

$importName = "Mdm_Modules"
Write-Host "Loading the complete module library."
Write-Host "Run from: $localPath. Importing $importName."
Write-Host "Global module root: $global:moduleRootPath"
$commonParameters['Force'] = $true
# Import-Module -Name $importName -Force
Import-Module -Name "$localPath\$importName" @commonParameters
