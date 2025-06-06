
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
    [switch]$KeepOpen,
    [switch]$Silent
    )
    # $IsMacOS
    # $IsLinux
    if ($IsWindows) {

        if ($Silent -or (Wait-YorNorQ -Message "Set up the Windows OS?" -eq "Y")) { 
            Install-DevEnvOsWin -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Silent:$Silent -KeepOpen:$KeepOpen -ErrorAction Inquire 
        }

        if ($Silent -or (Wait-YorNorQ -Message "Set up the IDE?"-eq "Y")) { 
            Install-DevEnvIdeWin -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Silent:$Silent -KeepOpen:$KeepOpen -ErrorAction Inquire 
        }

        if ($Silent -or (Wait-YorNorQ -Message "Set up the LLM?"-eq "Y")) { 
            Install-DevEnvLlmWin -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Silent:$Silent -KeepOpen:$KeepOpen -ErrorAction Inquire 
        }

        if ($Silent -or (Wait-YorNorQ -Message "Set up the Whisper Voice?"-eq "Y")) { 
            Install-DevEnvWhisperWin -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Silent:$Silent -KeepOpen:$KeepOpen -ErrorAction Inquire 
        }

        if ($Silent -or (Wait-YorNorQ -Message "Display current versions?"-eq "Y")) { 
            Get-DevEnvVersions -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Silent:$Silent -KeepOpen:$KeepOpen
        }
    } else {
        $Message = "This script is only run on the Windows OS."
        Add-LogText -Messages $Message -IsError -SkipScriptLineDisplay
    }
    if ($KeepOpen -and -not $Silent) { Wait-AnyKey -Message "Install-DevEnvWin Setup is completed." }
}
