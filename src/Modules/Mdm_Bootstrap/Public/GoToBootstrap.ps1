
# G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules
# + \Mdm_Bootstrap\Public\GoToBootstrap.ps1

$path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
. "$path"

Set-Location -Path "$global:moduleRootPath\Mdm_Bootstrap"
Write-Host "Reset the environment"
Write-Host ". ..\DevEnv_Module_Reset.ps1"
