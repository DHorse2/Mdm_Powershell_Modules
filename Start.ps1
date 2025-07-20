
# Start.ps1
$functionParams = $PSBoundParameters
$path = "$($(get-item $PSScriptRoot).FullName)\src\Modules\Mdm_Std_Library\Public\Start.ps1"
. $path @functionParams
