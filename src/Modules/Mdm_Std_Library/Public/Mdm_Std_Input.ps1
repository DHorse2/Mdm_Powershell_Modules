
# Mdm_Std_Input
# Function to check for key press
function Wait-ForKeyPress {
    param (
        $Message = "",
        $duration = 10,
        $ForegroundColor,
        $BackgroundColor
    )
    if (-not $ForegroundColor) { $ForegroundColor = $messageWarningForegroundColor }
    if (-not $BackgroundColor) { $BackgroundColor = $messageWarningBackgroundColor }
    Write-Host -NoNewline "" -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    [int]$startTime = $(Get-Date -UFormat "%s")
    [int]$remainingTime = $duration
    while ($remainingTime -gt 0) {
        if ($host.UI.RawUI.KeyAvailable) {
            $key = $host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp") # ,IncludeKeyDown
            if ($key.Character -eq "Y") { return $true }
        }
        $percentComplete = [int][math]::Round(($remainingTime / $duration) * 100)
        if ($Message) {
            # Display the countdown using Write-Progress
            Write-Progress -Activity $Message -Status "$remainingTime seconds remaining..." -PercentComplete $percentComplete
        }
        Start-Sleep -Milliseconds 500  # Sleep for a short time to avoid high CPU usage
        $remainingTime = $startTime + $duration - (Get-Date -UFormat "%s" )
    }
    $ForegroundColor = $global:messageForegroundColor
    $BackgroundColor = $global:messageBackgroundColor
    Write-Host -NoNewline "" -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor

    # $keyPressed = $false
    # $job = Start-Job -ScriptBlock {
    #     [Console]::ReadKey($true) | Out-Null
    #     return $true
    # }
    # # Sleep for a specified duration (in seconds)
    # $duration = 10
    # for ($i = 0; $i -lt $duration; $i++) {
    #     Start-Sleep -Seconds 1
    #     if ($job.HasExited) {
    #         $keyPressed = $job.Receive()
    #         break
    #     }
    # }
    # # Clean up the job
    # Stop-Job $job
    # Remove-Job $job
    return $keyPressed
}
function Wait-AnyKey {
    <#
    .SYNOPSIS
        Enter any key.
    .DESCRIPTION
        Prompts the user to enter any key to continue.
    .PARAMETER message
        The prompt message.
    .PARAMETER timeout
        Number of seconds to wait (if present).
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Wait-AnyKey
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Message = "",
        [Parameter(Mandatory = $false)]
        [int]$timeout = -1,        
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )

    Write-Debug "$Message Pause: $global:DoPause"
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = $global:msgAnykey
    }
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = 'Enter any key to continue: '
    }
    Set-StdGlobals `
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug
    # Write-Host "$Message Pause: $global:DoPause"
    # if ($global:DoPause) {
    # Check if running PowerShell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$Message")
    } else {
        Write-Host -Message "$Message " -ForegroundColor Yellow -NoNewline
        # $null = $host.ui.RawUI.ReadKey("NoEcho, IncludeKeyUp")
        $null = [Console]::ReadKey()
        Write-Host " " -ForegroundColor White
    }
    # }
}
function Wait-CheckDoPause {
    <#
    .SYNOPSIS
        Check DoPause switch.
    .DESCRIPTION
        Returns true when DoPause is set.
    .OUTPUTS
        True is DoPause.
    .EXAMPLE
        Wait-CheckDoPause
    .NOTES
        Depreciated
        Rename to Assert-Pause
#>
    [CmdletBinding()]
    param ()
    return $global:DoPause
}
function Wait-YorNorQ {
    <#
    .SYNOPSIS
        Prompts for Y(es), N(o) or Q(uit).
    .DESCRIPTION
        Prompt the user for a Yes, No or Quit response.
    .PARAMETER message
        The prompt.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        The user response.
    .EXAMPLE
        $theResponse = Wait-YorNorQ "Wait?" 
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Message = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    # ($local:DoPause, $local:DoVerbose, $local:DoDebug, $local:message ) = Get-StdGlobals
    # if ($global:DoPause) {
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = $global:msgYorN
    }
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = 'Press Y for Yes, Q to Quit, or N to exit'
    }
    if ([string]::IsNullOrEmpty($Message)) {
        Write-Debug -Message "The message is either null or empty."
        # } else {
        #     Write-Debug "The message is set: $Message."
    }

    $response = ""
    $continue = 1
    Do {
        # $response = Read-Host -Prompt $Message
        $response = Read-Host $Message
        Switch ($response) {
            Y { 
                $continue = 0
                Write-Debug ' Answer Yes.'
                return $response
                break
            }
            N { 
                $continue = 0
                Write-Debug " Answer No."
                return $response
                break 
            }
            Q { exit }
        }
    } while ($continue -ne 0)
    # Write-Verbose 'The script executes yet another instruction'
    # } else { return $null }
    return $response
}
