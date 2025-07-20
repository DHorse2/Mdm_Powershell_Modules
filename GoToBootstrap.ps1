
# GoToBootstrap
# G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\GoToBootstrap.ps1
$functionParams = $PSBoundParameters
$path = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Std_Library\lib\ProjectLib.ps1"
. $path @functionParams
Set-Location -Path "$global:moduleRootPath\Mdm_Bootstrap"
