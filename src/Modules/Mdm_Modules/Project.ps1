
# Project.ps1
# $path = "$($PSScriptRoot)\YYY\Mdm_Modules\Project.ps1"
# $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Modules\Project.ps1"
# . $path

$global:moduleRootPath = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
$global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
Write-Debug " "
Write-Debug "Modules: $global:moduleRootPath"
Write-Debug "Project: $global:projectRootPath"
Write-Debug " Actual: $global:projectRootPathActual"

# Source, destination and current folders
$sourceDefault = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
$destinationDefault = "C:\Program Files\WindowsPowerShell\Modules"
$global:folderPath = (get-item $PSScriptRoot).FullName
$global:folderName = Split-Path $global:folderPath -Leaf 
$global:projectRootPathActual = (get-item $PSScriptRoot).Parent.Parent.Parent.FullName
# Developer Mode IsDevMode.txt
$global:developerMode = Test-Path -Path "$global:projectRootPathActual\IsDevMode.txt"
if ($global:projectRootPathActual -ne $global:projectRootPath) {
    Write-Warning -Message "Project: Project folder doesn't match current folder $global:projectRootPathActual."
}

# if (-not $developerMode) {
#     Write-Host -Message "[LIVE] " -NoNewline
# } else {
#     Write-Host -Message "[DEV] " -NoNewline
# }
if (-not $global:developerModePathSet) {
    $global:developerModePathSet = $true
    # $env:PSModulePath
    $global:modulePaths = $env:PSModulePath -split ';'
    # Remove the custom source path if it exists
    $global:modulePaths = $global:modulePaths | Where-Object { $_ -ne $sourceDefault }
    if ($developerMode) {
        # Prepend the custom (development) path
        $global:modulePaths = @($sourceDefault) + $global:modulePaths
    }
    Write-Host "Search path was set."
    $global:modulePaths = $global:modulePaths -join ';'
    $env:PSModulePath = $global:modulePaths
}

$path = "$($PSScriptRoot)\ProjectRunSettings.ps1"
. "$path"
