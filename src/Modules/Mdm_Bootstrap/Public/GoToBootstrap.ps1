
$path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
. "$path"

Set-Location -Path "$global:moduleRootPath\Mdm_Bootstrap"
Write-Host "Reset the environment using: . .\DevEnv_Module_Reset.ps1"
