
Write-Host "Mdm_Modules.psm1"
# Write-Verbose "Loading..."
# $importName = "Mdm_Modules"
# Import-Module -Name "$global:moduleRootPath\$importName" -Force -ErrorAction Continue

# Mdm_Modules
# Imports Bootstrap, Standard Library, Development Environment Install

# Note: By always doing imports any function will be removed by Remove-Module
# . $PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1
# . $PSScriptRoot\..\Mdm_Bootstrap\Mdm_Bootstrap.psm1
# . $PSScriptRoot\..\Mdm_DevEnv_Install\Mdm_DevEnv_Install.psm1
#
# Get-ModuleRootPath may not be available so: 
# if (-not $global:moduleRootPath) {
#     $folderPath = (get-item $PSScriptRoot).FullName
#     $folderName = Split-Path $folderPath -Leaf 
#     if ( $folderName -eq "Public" -or $folderName -eq "Private" ) {
#         $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
#     } else { $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName }
# }
# if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
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
. .\Import-All.ps1

# Export all the functions
# Export-ModuleMember -Function $Public.Basename -Alias *

# Note: This works with uninstalled Modules (both) and unstable environments
Get-ModuleRootPath
# $commandString = ""
# if ($VerbosePreference -eq 'Continue') { commandString += " -Verbose" }
# if ($Force) { $commandString += " -Force" }
# if ($Debug) { $commandString += " -Debug" }
# $command = 'Import-Module -Name "$global:moduleRootPath\$importName" -ErrorAction Continue'
# if ($commandString.Length -ge 1) { $command += $commandString }
# Invoke-Expression $command

# $importName = "Mdm_Std_Library"
# $importName = "Mdm_Bootstrap"
# $importName = "Mdm_DevEnv_Install"
