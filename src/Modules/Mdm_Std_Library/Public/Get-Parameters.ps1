
# Get-Parameters
function Get-Parameters {
    [CmdletBinding()]
    param (
        [switch]$GetLocal,
        [switch]$SetLocal,
        [string]$importName = "",
        [int]$actionStep = 0,
        [switch]$DoDispose,
        [switch]$DoLogFile,
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    $functionParams = $PSBoundParameters
    # Check global but don't replace with possible temporary $Do locals
    # $GetGlobal = $true; $SetGlobal = $true
    # if (-not $global:app) { $SetGlobal = $false }
    # Params
    $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\Get-ParametersLib.ps1"
    . $path @functionParams
}
