function DoStart {
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    Import-Module Mdm_Std_Library -Force
    ResetStdGlobals  -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Verbose:$DoVerbose -Debug:$DoDebug
    Initialize-Std -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Verbose:$DoVerbose -Debug:$DoDebug
    if ($global:DoVerbose) { Write-Host "Script Started." }
}
# DoStart