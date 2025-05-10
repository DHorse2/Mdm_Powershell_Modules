
Write-Host "Mdm_WinFormPS.psm1"

# This works with uninstalled Modules (both)
$importName = "Mdm_Std_Library"
Get-ModuleRootPath
# if (-not (Get-Module -Name $importName)) {
Import-Module -Name "$global:moduleRootPath\$importName" -Force -ErrorAction Inquire
# }

#Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

#Dot source the files
Foreach ($import in @($Public + $Private))
{
	TRY
	{
		. $import.fullname
	}
	CATCH
	{
		Add-LogError -IsError -ErrorPSItem $ErrorPSItem -Message "Failed to import function $($import.fullname): $_"
	}
}

# Create Aliases
New-Alias -Name Load-ListBox -value Import-WFListBoxItem -Description "SAPIEN Name"
New-Alias -Name Load-DataGridView -value Import-WFDataGridViewItem -Description "SAPIEN Name"
New-Alias -Name Refresh-DataGridView -value Update-WFDataGridView -Description "SAPIEN Name"

# Export all the functions
Export-ModuleMember -Function $Public.Basename -Alias *
# Export-ModuleMember -Class WFWindow, WindowState