
# Build_Mdm.ps1
$path = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Bootstrap\Public\Build_Mdm.ps1"
. $path @global:combinedParams
