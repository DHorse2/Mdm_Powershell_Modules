
# Install-DevEnv
function Install-DevEnv {
    <#
    .SYNOPSIS
      Install the Windows Development Environment.
    .DESCRIPTION
        Performs these installations:
            Install-DevEnvOsWin 
            Install-DevEnvIdeWin
            Install-DevEnvLlmWin
            Install-DevEnvWhisperWin
        When complete it displays current version for the environment.
    .PARAMETER UpdatePath
        Switch: A switch to indicate the path should be checked/updated.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .EXAMPLE
        Install-DevEnvWin -DoPause -UpdatePath
    .NOTES
        Confirms each step.
    .OUTPUTS
        Install the development components.
#>


    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug, [switch]$DoForce,
        [string]$logFileNameFull = "",
        [switch]$KeepOpen,
        [switch]$Silent
    )
    # $IsMacOS
    # $IsLinux
    if ($IsWindows) {
        if (Wait-YorNorQ -Message "Set up the Windows Environment?" -eq "Y") { 
            $installDevEnvParams = @{}
            if ($DoForce) { $installDevEnvParams['DoForce'] = $true }
            if ($DoVerbose) { $installDevEnvParams['DoVerbose'] = $true }
            if ($DoDebug) { $installDevEnvParams['DoDebug'] = $true }
            if ($DoPause) { $installDevEnvParams['DoPause'] = $true }
            if ($KeepOpen) { $installDevEnvParams['KeepOpen'] = $true }
            if ($Silent) { $installDevEnvParams['Silent'] = $true }
            if ($logFileNameFull) { $installDevEnvParams['logFileNameFull'] = $logFileNameFull }
            $installDevEnvParams['ErrorAction'] = 'Inquire' 
                    Install-DevEnvWin @installDevEnvParams
        }
    } else {
        $Message = "This script is only run on the Windows OS."
        Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -logFileNameFull $logFileNameFull
    }

    if ($DoPause -or ($KeepOpen -and -not $Silent)) { Wait-AnyKey -Message "Install-DevEnvLlmWin Setup is completed." }

}
