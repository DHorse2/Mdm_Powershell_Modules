
$path = "$PSScriptRoot\src\Modules\Mdm_Modules\Project.ps1"
. "$path"

Set-Location -Path "$global:moduleRootPath"
Write-Host "Reset the environment"
Write-Host ". .\DevEnv_Module_Reset.ps1"
