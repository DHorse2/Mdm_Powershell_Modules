
# Install-Dev_Env_Win
function Install-Dev_Env_Win {
    <#
    .SYNOPSIS
      Install the Windows Development Environment.
    .DESCRIPTION
        Performs these installations:
            Install-Dev_Env_OS_Win 
            Install-Dev_Env_IDE_Win
            Install-Dev_Env_LLM_Win
            Install-Dev_Env_Whisper_Win
        When complete it displays current version for the environment.
    .PARAMETER UpdatePath
        Switch: A switch to indicate the path should be checked/updated.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .EXAMPLE
        Install-Dev_Env_Win -DoPause -UpdatePath
    .NOTES
        Confirms each step.
    .OUTPUTS
        todo Should create a log.
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    if (Wait-YorNorQ -message "Set up the Windows OS?" -eq "Y") { 
        Install-Dev_Env_OS_Win -DoPause $DoPause -DoVerbose $DoVerbose -DoDebug $DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Set up the IDE?"-eq "Y") { 
        Install-Dev_Env_IDE_Win -DoPause $DoPause -DoVerbose $DoVerbose -DoDebug $DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Set up the LLM?"-eq "Y") { 
        Install-Dev_Env_LLM_Win -DoPause $DoPause -DoVerbose $DoVerbose -DoDebug $DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Set up the Whisper Voice?"-eq "Y") { 
        Install-Dev_Env_Whisper_Win -DoPause $DoPause -DoVerbose $DoVerbose -DoDebug $DoDebug -ErrorAction Inquire 
    }

    if (Wait-YorNorQ -message "Display current versions?"-eq "Y") { 
        Get-Dev_Env_Versions -DoPause $DoPause -DoVerbose $DoVerbose -DoDebug $DoDebug 
    }
}

