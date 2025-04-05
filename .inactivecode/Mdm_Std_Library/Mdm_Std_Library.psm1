# Mdm_Std_Library
#
# [bool] $Global:pauseDo = $true
# $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
#############################
#
Write-Host "Loading..."
#
. $PSScriptRoot\Assert-ScriptSecElevated.ps1
. $PSScriptRoot\Build-ModuleExports.ps1
. $PSScriptRoot\Get-DirectoryNameFromSaved.ps1
. $PSScriptRoot\Get-FilesNamesFromSaved.ps1
. $PSScriptRoot\Save-DirectoryName.ps1
. $PSScriptRoot\Set-DirectoryToScriptRoot
. $PSScriptRoot\Set-ScriptSecElevated.ps1
. $PSScriptRoot\Wait-AnyKey.ps1
. $PSScriptRoot\Wait-CheckPauseDo.ps1
. $PSScriptRoot\Wait-YorNorQ.ps1
#
#############################
#
# Export-ModuleMember -Function * -Alias * -Cmdlet *
Write-Host "Ready."
