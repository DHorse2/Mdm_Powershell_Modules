Using module "..\Mdm_Std_Library\Mdm_Std_Library.psm1"
Using module "..\Mdm_Bootstrap\Mdm_Bootstrap.psm1"
Using module "..\Mdm_DevEnv_Install\Mdm_DevEnv_Install.psm1"
Using module "..\Mdm_WinFormPS\Mdm_WinFormPS.psm1"
# Mdm_Modules
# Imports Bootstrap, Standard Library, Development Environment Install
#
# Note: By always doing imports any function will be removed by Remove-Module
# . $PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1
# . $PSScriptRoot\..\Mdm_Bootstrap\Mdm_Bootstrap.psm1
# . $PSScriptRoot\..\Mdm_DevEnv_Install\Mdm_DevEnv_Install.psm1
#
# Get-ModuleRootPath may not be available so: 
# TODO Crashes in Powershell: Get-ModuleRootPath crash powershell.
# TODO Crashes in Powershell: Get-Module crash powershell.
# $importName = "Mdm_Modules"
# if (-not $global:moduleRootPath) {
#     $folderPath = (get-item $PSScriptRoot).FullName
#     $folderName = Split-Path $folderPath -Leaf 
#     if ( $folderName -eq "Public" -or $folderName -eq "Private" ) {
#         $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
#     } else { $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName }
# }
# if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
# Import-Module -Name "$global:moduleRootPath\$importName" -Force -ErrorAction Continue
#
Write-Host "Mdm_Modules.psm1"
$path = "$($(get-item $PSScriptRoot).FullName)\Project.ps1"
. "$path"

[bool]$DoVerbose = $global:DoVerbose
[bool]$DoPause = $global:DoPause
[bool]$DoDebug = $global:DoDebug
[bool]$DoForce = $global:DoForce

if ($DoVerbose) { 
    Write-Host "Mdm_Modules.psm1"
    Write-Host "Project Root: $global:projectRootPath"
    Write-Host " Module Root: $global:moduleRootPath"
    Write-Host "Execution at: $global:projectRootPathActual"
}

# Import all modules and set commonParameters
$path = "$($(get-item $PSScriptRoot).FullName)\Import-All.ps1"
. "$path"

# Export all the functions
# Export-ModuleMember -Function $Public.Basename -Alias *
# Project settings and paths
# Get-ModuleRootPath
$path = "$($(get-item $PSScriptRoot).FullName)\Project.ps1"
. "$path"
# $importName = "Mdm_Std_Library"
# $importName = "Mdm_Bootstrap"
# $importName = "Mdm_DevEnv_Install"
