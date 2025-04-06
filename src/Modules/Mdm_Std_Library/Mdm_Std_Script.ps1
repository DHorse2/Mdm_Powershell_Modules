
# Script functions
# ###############################
function Assert-ScriptSecElevated() {
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
        Set-ScriptSecElevated "Elevating myself."
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
    )    # Assert-ScriptSecElevated
    # Self-elevate the script if required
    if (-Not ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
                [Security.Principal.WindowsBuiltInRole] 'Administrator' `
        )) {
        return $false
        # if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        #     $CommandLine = "-File `"" + $MyInvocation.My_Command_.Path + "`" " + $MyInvocation.UnboundArguments
        #     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        #     Exit
        # }
    }
    else { return $true }
}
# Set-ScriptSecElevated
function Set-ScriptSecElevated ($message) {
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
        Set-ScriptSecElevated "Elevating myself."
    .NOTES
        This works but I think there are problems depending on the shell type.
        ISE for example.
    .OUTPUTS
        None. Returns or Executes current script in an elevated process.
#>
    # Set-ScriptSecElevated
    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
            
    # Get the security principal for the Administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
            
    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        Write-Verbose "We are running ""as Administrator""."
        # $Host.UI.RawUI.WindowTitle = $myInvocation.My_Command_.Definition + "(Elevated)"
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
            
        # Create a new process object that starts PowerShell
        $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
            
        # Specify the current script path and name as a parameter
        $newProcess.Arguments = $myInvocation.My_Command_.Definition;
            
        # Indicate that the process should be elevated
        $newProcess.Verb = "runas";
            
        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess);
            
        # Exit from the current, unelevated, process
        exit
    }
            
    # Run your code that needs to be elevated here
    # Write-Verbose -NoNewLine "Press any key to continue..."
    # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
function Script_ResetStdGlobals {
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
        Script_ResetStdGlobals
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
    $global:DoVerbose = $DoVerbose
    $global:DoPause = $DoPause
    $global:DoDebug = $DoDebug
    $global:msgAnykey = $msgAnykey
    $global:msgYorN = $msgYorN
    $global:initDone = $initDone
}
function Script_DisplayStdGlobals {
    <#
    .SYNOPSIS
        Display global state.
    .DESCRIPTION
        Display global and automatic state variables.
    .EXAMPLE
        Script_DisplayStdGlobals
#>
    [CmdletBinding()]
    param ()
    Write-Host "Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug Init: $global:initDone"
    if ($global:msgAnykey.Lenth -gt 0) {
        Write-Host "Anykey prompt: $global:msgAnykey"
    }
    if ($global:msgYorN.Lenth -gt 0) {
        Write-Host "Y,Q or N prompt: $global:msgYorN"
    }
}
function Verb-Noun {
    <# 
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
# Script Info
function Script_Name { 
    <#
    .SYNOPSIS
        Get Script Name.
    .DESCRIPTION
        Get $MyInvocation.Script_Name.
    .OUTPUTS
        $MyInvocation.Script_Name 
    .EXAMPLE
        Script_Name
#>
    [CmdletBinding()]
    param()
    return $MyInvocation.Script_Name 
}

function Script_Write_Error {
    <#
.SYNOPSIS
    Creates a powershell error object.
.DESCRIPTION
     Uses $PSCmdlet.WriteError to create a powershell error.
.PARAMETER Message
    The error message.
.PARAMETER ErrorCategory
    The error type.
.PARAMETER DoPause
Switch: Pause between steps.
.PARAMETER DoVerbose
Switch: Verbose output and prompts.
.PARAMETER DoDebug
Switch: Debug this script.
.EXAMPLE
    todo PsError Example
.NOTES
    I haven't tested or used this code yet.
.OUTPUTS
    An error object from what I can tell.
#>
    [cmdletbinding()]
    Param
    (
        [Exception]$Message,
        [Management.Automation.ErrorCategory]$ErrorCategory = "NotSpecified",
        [switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug
    )
    $arguments = @(
        $Message
        $null #errorid
        [Management.Automation.ErrorCategory]::$ErrorCategory
        $null

    )
    $ErrorRecord = New-Object `
        -TypeName "Management.Automation.ErrorRecord" `
        -ArgumentList $arguments
    $PSCmdlet.WriteError($ErrorRecord)
}
function Script_Last_Error {
    <#
    .SYNOPSIS
        Script_Last_Error.
    .DESCRIPTION
        Script_Last_Error does Get-Error.
    .OUTPUTS
        The last error to occur.
    .EXAMPLE
        Script_Last_Error
#>
    [CmdletBinding()]
    param ()
    Get-Error | Write-Host
    
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
    # Import-Module Mdm_Std_Library -Force
    Script_ResetStdGlobals  `
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug `
        -Verbose:$DoVerbose ` # todo is this correct?
    -Debug:$DoDebug
    Initialize_Std -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Verbose:$DoVerbose -Debug:$DoDebug
    if ($global:DoVerbose) { Write-Host "Script Started." }
}
# Script_DoStart
function Script_List_Positional_Parameters {
    <#
    .SYNOPSIS
        Script_List_Positional_Parameters.
    .DESCRIPTION
        Script_List_Positional_Parameters.
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
        Script_List_Positional_Parameters
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$functionName
    )
    Get-Help -Name $functionName -Parameter * | 
    Sort-Object -Property position | 
    Select-Object -Property name, position | Write-Host
}
# from stackoverflow
# ###############################
#
function My_PSCommandPath { 
    <#
    .SYNOPSIS
        My_PSCommandPath.
    .DESCRIPTION
        My_PSCommandPath.
    .OUTPUTS
        $My_PSCommandPath
    .EXAMPLE
        My_PSCommandPath
#>
    [CmdletBinding()]
    param()
    return $My_PSCommandPath 
}
function My_Command_InvocationName {
    <#
    .SYNOPSIS
        My_Command_InvocationName.
    .DESCRIPTION
        My_Command_InvocationName.
    .OUTPUTS
        $MyInvocation.InvocationName
    .EXAMPLE
        My_Command_InvocationName
#>
    [CmdletBinding()]
    param()
    return $MyInvocation.InvocationName
}
function My_Command_Orgin {
    <#
    .SYNOPSIS
        My_Command_Orgin
    .DESCRIPTION
        My_Command_Orgin
    .OUTPUTS
        $MyInvocation.My_Command_.CommandOrigin 
    .EXAMPLE
        My_Command_Orgin
#>
    [CmdletBinding()]
    param()
    return $MyInvocation.My_Command_.CommandOrigin 
}
function My_Command_Name {
    <#
    .SYNOPSIS
        My_Command_Name.
    .DESCRIPTION
        My_Command_Name.
    .OUTPUTS
        $MyInvocation.My_Command_.Name 
    .EXAMPLE
        My_Command_Name
#>
    [CmdletBinding()]
    param()
    return $MyInvocation.My_Command_.Name 
}
function My_Command_Definition {
    <#
    .SYNOPSIS
        My_Command_Definition.
    .DESCRIPTION
        My_Command_Definition.
    .OUTPUTS
        $MyInvocation.My_Command_.Definition
    .EXAMPLE
        My_Command_Definition
#>
    [CmdletBinding()]
    param()
    # Begin of My_Command_Definition()
    # Note: ouput of this script shows the contents of this function, not the execution result
    return $MyInvocation.My_Command_.Definition
    # End of My_Command_Definition()
}
function My_InvocationMy_PSCommandPath { 
    <#
    .SYNOPSIS
        My_InvocationMy_PSCommandPath.
    .DESCRIPTION
        My_InvocationMy_PSCommandPath.
    .OUTPUTS
        $MyInvocation.My_PSCommandPath 
    .EXAMPLE
        My_InvocationMy_PSCommandPath
#>
    [CmdletBinding()]
    param()
    return $MyInvocation.My_PSCommandPath 
}
