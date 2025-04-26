
function Assert-SecElevated() {
<#
    .SYNOPSIS
        Elevate script to Administrator.
    .DESCRIPTION
        Get the security principal for the Administrator role.
        Check to see if we are currently running "as Administrator",
        Create a new process object that starts PowerShell,
        Indicate that the process should be elevated ("runas"),
        Start the new process.
    .PARAMETER message
        Message to display when elevating.
    .EXAMPLE
        Set-SecElevated "Elevating myself."
    .NOTES
        This works but I think there are problems depending on the shell type.
        ISE for example.
    .OUTPUTS
        None. Returns or Executes current script in an elevated process.
#>


    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose
    )
    process {
        # Assert-SecElevated
        # Self-elevate the script if required
        if (-Not ([Security.Principal.WindowsPrincipal] `
                    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
                    [Security.Principal.WindowsBuiltInRole] 'Administrator' `
            )) {
            return $false
            # if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
            #     $CommandLine = "-File `"" + $MyInvocation.MyCommand_.Path + "`" " + $MyInvocation.UnboundArguments
            #     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            #     Exit
            # }
        }
        else { return $true }
    }
}
function Set-SecElevated ($message) {
<#
    .SYNOPSIS
        Elevate script to Administrator.
    .DESCRIPTION
        Get the security principal for the Administrator role.
        Check to see if we are currently running "as Administrator",
        Create a new process object that starts PowerShell,
        Indicate that the process should be elevated ("runas"),
        Start the new process.
    .PARAMETER message
        Message to display when elevating.
    .EXAMPLE
        Set-SecElevated "Elevating myself."
    .NOTES
        This works but I think there are problems depending on the shell type.
        ISE for example.
    .OUTPUTS
        None. Returns or Executes current script in an elevated process.
#>


    # Set-SecElevated
    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
            
    # Get the security principal for the Administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
            
    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        Write-Verbose "We are running ""as Administrator""."
        # $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand_.Definition + "(Elevated)"
        $Host.UI.RawUI.WindowTitle = $Host.UI.RawUI.WindowTitle + " (Elevated)"
        # $Host.UI.RawUI.BackgroundColor = "DarkGray"
        # clear-host
    }
    else {
        Write-Verbose "We are not running ""as Administrator"" - relaunching as administrator."
        if ($DoVerbose) { 
            Write-Host -NoNewLine "Press any key to continue..." -NoNewline
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
        }
        Invoke-ProcessWithExit -RunAs -DoExit    
    }
            
    # Run your code that needs to be elevated here
    # Write-Verbose -NoNewLine "Press any key to continue..."
    # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
function Invoke-ProcessWithExit {
    [CmdletBinding()]
    param (
        $newProcess,
        $newArguments,
        [switch]$RunAs,
        [switch]$DoExit
    )
    process {
        if (-not $newProcess) {
            # Create a new process object that starts PowerShell
            $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
        }
        if (-not $newArguments) {
            # Specify the current script path and name as a parameter
            $newProcess.Arguments = $myInvocation.MyCommand.Definition
            # $newProcess.Arguments = "& '" + $MyInvocation.MyCommand.Name + "'"            
        }
        else {
            $newProcess.Arguments = $newArguments
        }
            
        # Indicate that the process should be elevated
        if ($RunAs) { $newProcess.Verb = "runas" }
            
        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess)
            
        # Exit from the current, unelevated, process
        if ($DoExit) { exit }
    }
}
function Invoke-ProcessWithTimeout {
<#
    .SYNOPSIS
        Execute a command.
    .DESCRIPTION
        This executes the supplied command with a timeout.
    .PARAMETER command
        Command to execute.
    .PARAMETER timeout
        The timeout.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Performs the command.
    .EXAMPLE
        Invoke-ProcessWithTimeout "notepad.exe" 30
#>


    [CmdletBinding()]
    param(
        [Parameter(mandatory = $false)]
        [string]$command = "",
        [Parameter(mandatory = $false)]
        [int]$timeout = 10
    )
    process {
        $process = Start-Process `
            -FilePath "$command" `
            -PassThru
        if ($process.WaitForExit($timeout)) {
            Write-Host "Process completed within timeout."
        }
        else {
            Write-Host "Process timed out and will be terminated."
            $process.Kill()
        }
    }
}
function Push-ShellPwsh {
<# 
    .DESCRIPTION
        Note: Place [CmdletBinding()] above param(...) to make
            the script an *advanced* one, which then prevents passing
            extra arguments that don't bind to declared parameters.
        Issue: Example:
        @powershell -ExecutionPolicy Bypass -File "test.ps1" -stringParam "testing" -switchParam `
            > "output.txt" 2>&1
        The script I am calling requires PowerShell 7+, 
            so I need to restart the script by calling pwsh 
            with the current parameters. 
        I planned to accomplish this via the following:
        Invoke-Command { & pwsh -Command $MyInvocation.Line } -NoNewScope
        Unfortunately, $MyInvocation.Line does not return the correct result
            when a PowerShell script is called from a batch file.
            What alternatives exist that would work in this scenario?
#>


    [CmdletBinding()]
    param (
        [string] $stringParam,
        [switch] $switchParam
    )
    process {
        # If invoked via powershell.exe, re-invoke via pwsh.exe
        if ((Get-Process -Id $PID).Name -eq 'powershell') {
            # $PSCommandPath is the current script's full file path,
            # and @PSBoundParameters uses splatting to pass all 
            # arguments that were bound to declared parameters through.
            # Any extra arguments, if present, are passed through with @args
            pwsh -ExecutionPolicy Bypass -File $PSCommandPath @PSBoundParameters @args
            exit $LASTEXITCODE
        }
 
        # Getting here means that the file is being executed by pwsh.exe
 
        # Print the arguments received:
 
        if ($PSBoundParameters.Count) {
            "-- Bound parameters and their values:`n"
            # !! Because $PSBoundParameters causes table-formatted
            # !! output, synchronous output must be forced to work around a bug.
            # !! See notes below.  
            $PSBoundParameters | Out-Host
        }
 
        if ($args) {
            "`n-- Unbound (positional) arguments:`n"
            $args
        }
 
        exit 0
    }
}
# ###############################
function Initialize-Std {
<#
    .SYNOPSIS
        Initializes a script..
    .DESCRIPTION
        This processes switches, automatic variables, state.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Global variables are set.
    .EXAMPLE
        Initialize-Std -DoPause:$DoPause -DoVerbose:$DoVerbose
    .EXAMPLE
        Initialize-StdGlobalsReset
        Initialize-Std -DoPause:$DoPause -DoVerbose:$DoVerbose
    .NOTES
        none.
#>


    [CmdletBinding()]
    param (
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    process {
        # Write-Verbose "Init Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug"
        # Show-StdGlobals
        Write-Verbose "Initialize-Std"
        if (-not $global:InitStdDone) {
            Write-Verbose " initializing..."
            # $global:DoPause = $local:DoPause; $global:DoVerbose = $local:DoVerbose
            $global:InitStdDone = $true
            # Validation
            # Default messages
            if ($global:msgAnykey.Length -le 0) { 
                $global:msgAnykey = "Press any key to continue" 
                Write-Debug "Anykey: $global:msgAnykey"
            }
            if ($global:msgYorN.Length -le 0) { 
                $global:msgYorN = "Enter Y to continue, Q to quit or N to exit" 
                Write-Debug "YorN: $global:msgYorN"
            }

            # Pause
            if ($local:DoPause) { $global:DoPause = $true } else { $global:DoPause = $false }
            Write-Debug "Global pause: $global:DoPause"

            # Debug
            if ($local:DoDebug) { $global:DoDebug = $true } else { $global:DoDebug = $false }
            # PowerShell setting for -Debug (TODO: Issue 2: doesn't work)
            if ($DebugPreference -ne 'SilentlyContinue') { $global:DoDebug = $true } else {
                if ($local:DoDebug) {
                    $global:DoDebug = $true
                    $DebugPreference = 'Continue'
                    if ($global:DoPause) { $DebugPreference = 'Inquire' }
                }
                else { $global:DoDebug = $false }
            }
            if ($global:DoDebug) { Write-Host "Debugging." } else { Write-Verbose "Debug off." }

            # Verbosity
            if ($local:DoVerbose) { $global:DoVerbose = $true } else { $global:DoVerbose = $false }
            # Check automatice parameters 
            # Write-Host "PSBoundParameters: $PSBoundParameters" (TODO: Issue 1: doesn't work)
            # Write-Host "PSBoundParameters Verbose: $($PSCmdlet.Get-Invocation.BoundParameters['Verbose'])" (TODO: Issue 1: doesn't work)
            # Write-Host "VerbosePreference: $VerbosePreference" # (TODO: Issue 1: doesn't work)

            # PowerShell setting
            # return [bool]$VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue    
            if ($PSBoundParameters.ContainsKey('Verbose')) { 
                # $PSCmdlet.Get-Invocation.BoundParameters["Verbose"]
                # VerbosePreference
                # Command line specifies -Verbose
                $b = $PsBoundParameters.Get_Item('Verbose')
                $global:DoVerbose = $b
                Write-Debug "Bound Param Verbose $b"
                # $global:DoVerbose = $false
                if ($null -eq $b) { $global:DoVerbose = $false }
                Write-Debug "Verbose from Bound Param: $global:DoVerbose"
            }
            else { 
                Write-Host "Verbose key not present."
            }
            # Verbosity via -verbose produces output.
            $output = ""
            Write-Verbose "Verbose" > $output
            if ($output.Length -gt 0) { $global:DoVerbose = $true }
            if ($global:DoVerbose) {
                Write-Verbose "Verbose."
            }
            else { Write-Verbose "Shhhhh....." }

            # ??? Maybe
            # Set-prompt
        }
        if ($global:DoVerbose) {
            Write-Host ""
            Write-Host "Init end  Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug"
            Write-Host "Init end Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug Init: $global:InitStdDone"
        }
    }
}
function Initialize-StdGlobalsReset {
<#
    .SYNOPSIS
        Resets the global state.
    .DESCRIPTION
        This equates to, and uses, 
            automatic variables, 
            $PS variables, 
            module metadata and
            state.
    .PARAMETER msgAnykey
        The prompt for "Enter any key".
    .PARAMETER msgYorN
        The prompt for "Enter Y, N, or Q to quit".
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .PARAMETER initDone
        Switch: indicates initialization is done.
    .OUTPUTS
        none.
    .EXAMPLE
        Initialize-StdGlobalsReset
#>


    [CmdletBinding()]
    param (
        [switch]$DoVerbose,
        [switch]$DoPause,
        [switch]$DoDebug,
        [string]$msgAnykey = "",
        [string]$msgYorN = "",
        [switch]$initDone
    )
    process {
        $global:DoVerbose = $DoVerbose
        $global:DoPause = $DoPause
        $global:DoDebug = $DoDebug
        $global:msgAnykey = $msgAnykey
        $global:msgYorN = $msgYorN
        $global:InitStdDone = $initDone
    }
}
function Show-StdGlobals {
<#
    .SYNOPSIS
        Display global state.
    .DESCRIPTION
        Display global and automatic state variables.
    .EXAMPLE
        Show-StdGlobals
#>


    [CmdletBinding()]
    param ()
    process {
        Write-Host "Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug Init: $global:InitStdDone"
        if ($global:msgAnykey.Lenth -gt 0) {
            Write-Host "Anykey prompt: $global:msgAnykey"
        }
        if ($global:msgYorN.Lenth -gt 0) {
            Write-Host "Y,Q or N prompt: $global:msgYorN"
        }
    }
}
function Get-ScriptName { 
<#
    .SYNOPSIS
        Get the Script Name.
    .DESCRIPTION
        Get $MyInvocation.Script_Name.
    .OUTPUTS
        $MyInvocation.Script_Name
    .EXAMPLE
        Get-ScriptName
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.Script_Name }
}
function Script_DoStart {
<#
    .SYNOPSIS
        Reset and initialize.
    .DESCRIPTION
        This resets the global values and call the initializations.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Script_DoStart -DoVerbose
    .NOTES
        This serves little purpose.
#>


    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    process {
        # Import-Module Mdm_Std_Library -Force
        Initialize-StdGlobalsReset  `
            -DoPause:$DoPause `
            -DoVerbose:$DoVerbose `
            -DoDebug:$DoDebug
        Initialize-Std `
            -DoPause:$DoPause `
            -DoVerbose:$DoVerbose `
            -DoDebug:$DoDebug
        if ($global:DoVerbose) { Write-Host "Script Started." }
    }
}
function Get-ScriptPositionalParameters {
<#
    .SYNOPSIS
        Get-ScriptPositionalParameters.
    .DESCRIPTION
        Get-ScriptPositionalParameters.
    .PARAMETER functionName
        The function name to examine.
    .OUTPUTS
        A list pof positional paramaters for that function.
    .NOTES
        Answered Jan 27, 2022 at 4:23 user16136127 StackOverflow
        "https://stackoverflow.com/questions/70853968/how-do-i-fix-this-positional-parameter-error-powershell"
        Alternatively, you might check if your cmdlet has any positional parameters. 
        You can search the documentation. But a quick way is to have PowerShell do the work. 
        Use the one-liner below. And just replace "Get-ChildItem" with the cmdlet you are interested in. 
        Remember, if the output only shows "Named"" then the cmdlet does not accept positional parameters.
        Below, there are two positional parameters: Path and Filter.
    .EXAMPLE
        Get-ScriptPositionalParameters
#>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$functionName
    )
    process {
        Get-Help -Name $functionName -Parameter * | 
            Sort-Object -Property position | 
                Select-Object -Property name, position | Write-Host
    }
}
# ###############################
function Get-PSCommandPath { 
<#
    .SYNOPSIS
        Get-PSCommandPath.
    .DESCRIPTION
        Get-PSCommandPath.
        from stackoverflow
    .OUTPUTS
        $Script_PSCommandPath
    .EXAMPLE
        Get-PSCommandPath
#>


    [CmdletBinding()]
    param()
    process { return $Script_PSCommandPath }
}
function Get-MyCommand_InvocationName {
<#
    .SYNOPSIS
        Get-MyCommand_InvocationName.
    .DESCRIPTION
        Get-MyCommand_InvocationName.
    .OUTPUTS
        $MyInvocation.InvocationName
    .EXAMPLE
        Get-MyCommand_InvocationName
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.InvocationName }
}
function Get-MyCommand_Origin {
<#
    .SYNOPSIS
        Get-MyCommand_Origin
    .DESCRIPTION
        Get-MyCommand_Origin
    .OUTPUTS
        $MyInvocation.Get-MyCommand_.CommandOrigin 
    .EXAMPLE
        Get-MyCommand_Origin
#>


    [CmdletBinding()]
    param()
    process {
        return $MyInvocation.MyCommand_.CommandOrigin 
    }
}
function Get-MyCommand_Name {
<#
    .SYNOPSIS
        Get-MyCommand_Name.
    .DESCRIPTION
        Get-MyCommand_Name.
    .OUTPUTS
        $MyInvocation.Get-MyCommand_.Name 
    .EXAMPLE
        Get-MyCommand_Name
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.MyCommand_.Name }
}
function Get-MyCommand_Definition {
<#
    .SYNOPSIS
        Get-MyCommand_Definition.
    .DESCRIPTION
        Get-MyCommand_Definition.
    .OUTPUTS
        $MyInvocation.Get-MyCommand_.Definition
    .EXAMPLE
        Get-MyCommand_Definition
#>


    [CmdletBinding()]
    param()
        # Begin of Get-MyCommand_Definition()
        # Note: ouput of this script shows the contents of this function, not the execution result
        process { return $MyInvocation.MyCommand_.Definition }
}
function Get-Invocation_PSCommandPath { 
<#
    .SYNOPSIS
        Get-Invocation_PSCommandPath.
    .DESCRIPTION
        Get-Invocation_PSCommandPath.
    .OUTPUTS
        $MyInvocation.Get-PSCommandPath 
    .EXAMPLE
        Get-Invocation_PSCommandPath
#>


    [CmdletBinding()]
    param()
    process { return $MyInvocation.PSCommandPath }
}
