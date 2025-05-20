# Using module ".\Mdm_Bootstrap\Mdm_Bootstrap.psm1"
# Using module ".\Mdm_Std_Library\Mdm_Std_Library.psm1"
# Using module ".\Mdm_DevEnv_Install\Mdm_DevEnv_Install.psm1"
# Using namespace System.Windows.Forms

# Update.ps1
Write-Host "Updating System Modules"
# Parameters
$inArgs = $args
$path = "$($(Get-Item $PSScriptRoot).FullName)\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"
# Project Settings
$path = "$($(Get-Item $PSScriptRoot).FullName)\Mdm_Modules\Project.ps1"
. "$path"
# Path
$localPath = $global:moduleRootPath
# Load Security
Write-Host "ExecutionPolicy:"
$path = "$($(Get-Item $PSScriptRoot).FullName)\Mdm_Std_Library\Public\Check-Security.ps1"
. "$path"
Get-ExecutionPolicy
# Set-ExecutionPolicy RemoteSigned

Write-Host "Go To Bootstrap"
. "$localPath\GoToBootstrap.ps1"
Get-Location

Write-Host "Dev Env Module Reset"
$path = "$localPath\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"
. "$path"  @global:commonParams

# Project settings and paths
# Get-ModuleRootPath
$path = "$localPath\Mdm_Modules\Project.ps1"
. "$path"

# $GetGlobal = $true; $SetGlobal = $false
$inArgs = $args
 "$localPath\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"

Write-Host "Dev Env Install Modules Win - Update only"
try {
    # DevEnv_Install_Modules_Win -SkipHelp
    DevEnv_Install_Modules_Win -SkipHelp @global:combinedParams
} catch {
    Add-LogText -IsError -ErrorPSItem $_ -Message "Dev Env Install Modules Win - Update only had and error."
    exit
}

Write-Host "Update completed."

# $importName = "Mdm_Modules"
# Write-Host "Loading the complete module library."
# Write-Host "Run from: $localPath. Importing $importName."
# Write-Host "Global module root: $global:moduleRootPath"
# $commonParameters['Force'] = $true
# # Import-Module -Name $importName -Force
# Import-Module -Name "$localPath\$importName" @global:commonParams
