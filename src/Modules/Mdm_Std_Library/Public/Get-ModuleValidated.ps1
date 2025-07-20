
# Get-ModuleValidated
function Get-ModuleValidated {
    [CmdletBinding()]
    param (
        [string]$importName = "", # mandatory
        [int]$actionStep = 0,
    
        [string]$Name = "Modules",
        [string]$jsonData,
        [string]$jsonFileName,
    
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    $functionParams = $PSBoundParameters
    # Get-ModuleValidatedLib
    $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\lib\Get-ModuleValidatedLib.ps1"
    . $path @functionParams
}
