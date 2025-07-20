Using namespace Microsoft.VisualBasic
Using namespace PresentationFramework
Using namespace System.Drawing
Using namespace System.Windows.Forms
Using namespace System.Web
Using module "..\Mdm_Std_Library\Mdm_Std_Library.psm1"
# Using module Mdm_Std_Library

$moduleName = "Mdm_WinFormPS_FrancoisXavierCat.psm1"
if ($DoVerbose) { Write-Host "== $moduleName ==" -ForegroundColor Green }
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Web

if (-not $global:moduleRootPath) {
	$path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
	. $path @global:combinedParams
}

# Global Module Members
# $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\WFFormGlobal.ps1"
# . $path @global:combinedParams

# Classes
# $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\WFFormClasses.ps1"
# . $path @global:combinedParams

# Module Folder Processing
# Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$Classes = @(Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue)
#Dot source the files
Foreach ($import in @($Public + $Private + $Classes)) {
	TRY {
		. $import.fullname
	} CATCH {
		Add-LogText -IsError -ErrorPSItem $_ -Message "Failed to import function $($import.fullname)."
	}
}
# Create Aliases
New-Alias -Name Load-WFListBox -value Import-WFListBox -Description "SAPIEN Name"
New-Alias -Name Load-WFDataGridView -value Import-WFDataGridView -Description "SAPIEN Name"
New-Alias -Name Refresh-WFDataGridView -value Update-WFDataGridView -Description "SAPIEN Name"
# Export all the functions
Export-ModuleMember -Function $Public.Basename -Alias *
Export-ModuleMember -Variable @(
	"DisplayElement"
    "WFWindow", 
	"WindowState", 
	"MarginClass"
)
# Session Arrays
if (-not $global:moduleArray) {
    $global:moduleArray = @{}
    $global:moduleSequence = 0
}
if (-not $global:moduleArray['Mdm_WinFormPS']) { $global:moduleArray['Mdm_WinFormPS'] = "Imported" }