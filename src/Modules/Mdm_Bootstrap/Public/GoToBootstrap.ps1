
$path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
. $path

Set-Location -Path "$global:moduleRootPath\Mdm_Bootstrap"
Write-Host "Reset the environment using: . .\DevEnv_Module_Reset.ps1"
