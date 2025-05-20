
# Build.ps1
Write-Host "Building Modules"
# Parameters
$inArgs = $args
$path = "$($(Get-Item $PSScriptRoot).FullName)\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"
# Project Settings
$path = "$($PSScriptRoot)\Mdm_Modules\Project.ps1"
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

# Write-Host "Dev Env Module Reset"
$path = "$localPath\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"
. "$path"  @global:commonParams
# Import Mdm_Std_Library
# $importName = "Mdm_Std_Library"
# # Get-ModuleValidated.ps1
# if ($DoVerbose) { 
#     Write-Host "Module : $importName"
# }
# if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
#     $modulePath = "$global:moduleRootPath\$importName"
#     if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
#     Import-Module -Name $modulePath @global:importParameters
# }
# $importName = "Mdm_Bootstrap"
# $path = "$($(Get-Item $PSScriptRoot).FullName)\Mdm_Modules\Get-ModuleValidated.ps1"
# . $path

# Project settings and paths
# Get-ModuleRootPath
$path = "$localPath\Mdm_Modules\Project.ps1"
. "$path"

# $GetGlobal = $true; $SetGlobal = $false
$inArgs = $args
"$localPath\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"

Write-Host "Dev Env Install Modules Win"
try {
    DevEnv_Install_Modules_Win @global:commonParams
} catch {
    Add-LogText -IsError -ErrorPSItem $_ "Dev Env Install Modules Win had and error. $_"
    exit
}

Write-Host "Build completed."

# $importName = "Mdm_Modules"
# Write-Host "Loading the complete module library."
# Write-Host "Run from: $localPath. Importing $importName."
# Write-Host "Global module root: $global:moduleRootPath"
# $commonParameters['Force'] = $true
# # Import-Module -Name $importName -Force
# Import-Module -Name "$localPath\$importName" @global:commonParams
