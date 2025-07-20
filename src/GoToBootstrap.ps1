
# GoToBootstrap
# G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\GoToBootstrap.ps1
$path = "$($(get-item $PSScriptRoot).FullName)\Modules\Mdm_Std_Library\lib\ProjectLib.ps1"
. $path
Set-Location -Path "$global:moduleRootPath\Mdm_Bootstrap"
