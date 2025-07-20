
# Install-DevEnvWin
function Install-DevEnvWin {
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
    $installDevEnvWinParams = @{}
    if ($DoForce) { $installDevEnvWinParams['DoForce'] = $true }
    if ($DoVerbose) { $installDevEnvWinParams['DoVerbose'] = $true }
    if ($DoDebug) { $installDevEnvWinParams['DoDebug'] = $true }
    if ($DoPause) { $installDevEnvWinParams['DoPause'] = $true }
    $installDevEnvWinParams['ErrorAction'] = 'Inquire' 
    if ($KeepOpen) { $installDevEnvWinParams['KeepOpen'] = $true }
    if ($Silent) { $installDevEnvWinParams['Silent'] = $true }
    if ($logFileNameFull) { $installDevEnvWinParams['logFileNameFull'] = $logFileNameFull }
    # $IsMacOS
    # $IsLinux
    if ($IsWindows) {
        if ($Silent -or (Wait-YorNorQ -Message "Set up the Windows OS?" -eq "Y")) { 
            Install-DevEnvOsWin @installDevEnvWinParams
        }

        if ($Silent -or (Wait-YorNorQ -Message "Set up the IDE?"-eq "Y")) { 
            Install-DevEnvIdeWin @installDevEnvWinParams
        }

        if ($Silent -or (Wait-YorNorQ -Message "Set up the LLM?"-eq "Y")) { 
            Install-DevEnvLlmWin @installDevEnvWinParams
        }

        if ($Silent -or (Wait-YorNorQ -Message "Set up the Whisper Voice?"-eq "Y")) { 
            Install-DevEnvWhisperWin @installDevEnvWinParams
        }

        if ($Silent -or (Wait-YorNorQ -Message "Display current versions?"-eq "Y")) { 
            Get-DevEnvVersions @installDevEnvWinParams
        }
    } else {
        $Message = "This script is only run on the Windows OS."
        Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -logFileNameFull $logFileNameFull
    }
    if ($DoPause -or ($KeepOpen -and -not $Silent)) { Wait-AnyKey -Message "Install-DevEnvWin Setup is completed." }
}