<#
.SYNOPSIS
    Bootstrap, Standard Library, Development Environment Install modules.
.DESCRIPTION
    Imports:
        Mdm_Bootstrap
        Mdm_Std_Library
        Mdm_Dev_Env_Install
    This imports the Mdm_Modules so that all functions are available.
.OUTPUTS
    Exported functions from Bootstrap, Standard Library, Development Environment Install modules.
.EXAMPLE
    Import-module Mdm_Modules.
.NOTES
    none.
#>

# Mdm_Modules
# Bootstrap, Standard Library, Development Environment Install
#
Write-Verbose "Loading..."
#
# . $PSScriptRoot\..\Mdm_Bootstrap\Mdm_Bootstrap.psm1
# . $PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1
# . $PSScriptRoot\..\Mdm_Dev_Env_Install\Mdm_Dev_Env_Install.psm1
#
# Import-Module -name Mdm_Bootstrap
# Import-Module -name Mdm_Std_Library
# Import-Module -name Mdm_Dev_Env_Install
# . $PSScriptRoot\Mdm_ModuleState.ps1

# This works with uninstalled Modules (both)
$scriptPath = (get-item $PSScriptRoot ).parent.FullName
$importName = "Mdm_Bootstrap"
Import-Module -Name "$scriptPath\$importName\$importName" -Force -ErrorAction Stop
$importName = "Mdm_Std_Library"
Import-Module -Name "$scriptPath\$importName\$importName" -Force -ErrorAction Stop
$importName = "Mdm_Dev_Env_Install"
Import-Module -Name "$scriptPath\$importName\$importName" -Force -ErrorAction Stop

. $scriptPath\Mdm_Modules\Mdm_ModuleState.ps1

#
# Export-ModuleMember -Function * -Alias * -Cmdlet *
Write-Verbose "Ready."
