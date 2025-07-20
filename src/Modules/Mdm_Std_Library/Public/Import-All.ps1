Using namespace Microsoft.VisualBasic
Using namespace PresentationFramework
Using namespace System.Drawing
Using namespace System.Windows.Forms
Using namespace System.Web
Using namespace Microsoft.PowerShell.Security

# Import-All
function Import-All {
    [CmdletBinding()]
    param (
        [string]$importName = "",
        [switch]$DoDispose,
        [switch]$DoLogFile,

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
    )
    $functionParams = $PSBoundParameters
    if ($DoVerbose) { Write-Host "Mdm_Std_Libaray Import-All." -ForegroundColor Yellow }
    . "$($(get-item $PSScriptRoot).Parent.FullName)\lib\ImportAllLib.ps1" @functionParams
    # Export-ModuleMember -Function "Import-All"
   
}

