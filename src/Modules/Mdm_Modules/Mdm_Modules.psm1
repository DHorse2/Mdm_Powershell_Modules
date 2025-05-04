
Write-Host "Mdm_Modules.psm1"
# Write-Verbose "Loading..."
# $importName = "Mdm_Modules"
# Import-Module -Name "$global:moduleRootPath\$importName\$importName" -Force -ErrorAction Continue

# Mdm_Modules
# Imports Bootstrap, Standard Library, Development Environment Install

# Note: By always doing imports any function will be removed by Remove-Module
# . $PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1
# . $PSScriptRoot\..\Mdm_Bootstrap\Mdm_Bootstrap.psm1
# . $PSScriptRoot\..\Mdm_DevEnv_Install\Mdm_DevEnv_Install.psm1
#
# Get-ModuleRootPath may not be available so: 
if (-not $global:moduleRootPath) {
    if (-not $folderPath) {
        $folderPath = (get-item $PSScriptRoot).FullName
        $folderName = Split-Path $folderPath -Leaf 
    }
    if ( $folderName -eq "Public" `
            -or $folderName -eq "Private" `
            -or $folderName -ne $importName) {
        $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
    } else { $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName }
    # $global:projectRootPath = $null
}
if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }

$importParams = @{}
if ($global:DoForce) { $importParams['Force'] = $true }
if ($global:DoVerbose) { $importParams['Verbose'] = $true }
if ($global:DoDebug) { $importParams['Debug'] = $true }
$importParams['ErrorAction'] = if ($global:errorActionValue) { $global:errorActionValue } else { 'Continue' }

$importName = "Mdm_Bootstrap"
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName\$importName"
    Import-Module -Name $modulePath @importParams
}

$importName = "Mdm_Std_Library"
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName\$importName"
    Import-Module -Name $modulePath @importParams
}

$importName = "Mdm_DevEnv_Install"
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName\$importName"
    Import-Module -Name $modulePath @importParams
}

$importName = "Mdm_WinFormPS"
if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
    $modulePath = "$global:moduleRootPath\$importName\$importName"
    Import-Module -Name $modulePath @importParams
}

# Export all the functions
# Export-ModuleMember -Function $Public.Basename -Alias *

# Note: This works with uninstalled Modules (both) and unstable environments
Get-ModuleRootPath
# $commandString = ""
# if ($VerbosePreference -eq 'Continue') { commandString += " -Verbose" }
# if ($Force) { $commandString += " -Force" }
# if ($Debug) { $commandString += " -Debug" }
# $command = 'Import-Module -Name "$global:moduleRootPath\$importName\$importName" -ErrorAction Continue'
# if ($commandString.Length -ge 1) { $command += $commandString }
# Invoke-Expression $command

# $importName = "Mdm_Std_Library"
# $importName = "Mdm_Bootstrap"
# $importName = "Mdm_DevEnv_Install"
