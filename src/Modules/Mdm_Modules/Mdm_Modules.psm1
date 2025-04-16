<#
.SYNOPSIS
    Bootstrap, Standard Library, Development Environment Install modules.
#>


Write-Verbose "Loading..."
# Mdm_Modules
# Bootstrap, Standard Library, Development Environment Install
#
# DESCRIPTION
#     Imports:
#         Mdm_Bootstrap
#         Mdm_Std_Library
#         Mdm_Dev_Env_Install
#     This imports the Mdm_Modules so that all functions are available.
# EXAMPLE
#     Import-module Mdm_Modules
# NOTES
#     none.
# OUTPUTS
# Exported functions from Bootstrap, Standard Library, Development Environment Install modules.

. "$global:scriptPath\Mdm_Modules\Mdm_ModuleState.ps1"
Export-ModuleMember -Function `
    Get-ModuleProperty, Set-ModuleProperty, `
    Get-ModuleConfig, Set-ModuleConfig, `
    Get-ModuleConfig, Set-ModuleConfig

. "$global:scriptPath\Mdm_Modules\Build-ModuleExports.ps1"
Export-ModuleMember -Function Build-ModuleExports

# . $PSScriptRoot\..\Mdm_Bootstrap\Mdm_Bootstrap.psm1
# . $PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1
# . $PSScriptRoot\..\Mdm_Dev_Env_Install\Mdm_Dev_Env_Install.psm1
#
# Import-Module -name Mdm_Bootstrap
# Import-Module -name Mdm_Std_Library
# Import-Module -name Mdm_Dev_Env_Install
# . $PSScriptRoot\Mdm_ModuleState.ps1

# This works with uninstalled Modules (both)
if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
$importName = "Mdm_Std_Library"
Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Continue
$importName = "Mdm_Bootstrap"
Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Continue
$importName = "Mdm_Dev_Env_Install"
Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Continue
