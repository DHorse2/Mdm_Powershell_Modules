
Write-Host "Start"
try {
# Load Security
Write-Host "ExecutionPolicy:"
$path = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Std_Library\Public\Check-Security.ps1"
. "$path"
Get-ExecutionPolicy
}
catch {
    Write-Error "Security error: $_"
}
# Set-ExecutionPolicy RemoteSigned
# Parameters
$inArgs = $args
$path = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"
# Project settings and paths
# Get-ModuleRootPath
$path = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Modules\Project.ps1"
. "$path"
# Set Location
$scriptDrive = Split-Path -Path "$global:moduleRootPath" -Qualifier
Set-Location $scriptDrive
Set-Location $PSScriptRoot
# Params
$inArgs = $args 
$path = "$PSScriptRoot\src\Modules\Mdm_Std_Library\Public\Get-Parameters.ps1"
. $path

Write-Host "Goto Bootstrap"
$scriptDrive = Split-Path -Path "$global:moduleRootPath" -Qualifier
Set-Location $scriptDrive
Set-Location -Path "$global:moduleRootPath"
$path = "$($(get-item $PSScriptRoot).FullName)\GoToBootstrap.ps1"
. $path @global:combinedParams
# Get-Location

Write-Host "Do Reset"
if ($DoDebug -or $DoVerbose) {
    if ($global:combinedParams.Count) {
        Write-Host "Combined Parameters:"
        ForEach ($Key in $global:combinedParams.Keys) {
            Write-Host "Key: $Key = $($global:combinedParams[$Key])"
        }
    }
    Get-Location
}
$path = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"
. $path @global:combinedParams

Write-Host "=== Start completed ===" -ForegroundColor Green
