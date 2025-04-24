
Write-Verbose "Loading..."
# Mdm_Modules
# Imports Bootstrap, Standard Library, Development Environment Install

# Note: By always doing imports any function will be removed by Remove-Module
# . $PSScriptRoot\..\Mdm_Bootstrap\Mdm_Bootstrap.psm1
# . $PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1
# . $PSScriptRoot\..\Mdm_DevEnv_Install\Mdm_DevEnv_Install.psm1
#
# Import-Module -name Mdm_Bootstrap
# Import-Module -name Mdm_Std_Library
# Import-Module -name Mdm_DevEnv_Install
# . $PSScriptRoot\Mdm_ModuleState.ps1

# Note: This works with uninstalled Modules (both) and unstable environments
if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }

# $commandString = ""
# if ($VerbosePreference -eq 'Continue') { commandString += " -Verbose" }
# if ($Force) { $commandString += " -Force" }
# if ($Debug) { $commandString += " -Debug" }
# $command = 'Import-Module -Name "$global:scriptPath\$importName\$importName" -ErrorAction Continue'
# if ($commandString.Length -ge 1) { $command += $commandString }
# Invoke-Expression $command

    $importName = "Mdm_Std_Library"
    Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Continue

    $importName = "Mdm_Bootstrap"
    Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Continue

    $importName = "Mdm_DevEnv_Install"
    Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Continue
    