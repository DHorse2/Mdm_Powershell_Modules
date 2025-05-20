
function Confirm-SecElevated() {
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
        # Confirm-SecElevated
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
        } else { return $true }
    }
}
function Set-SecElevated {
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
    param ($Message)

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
    } else {
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
        } else {
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
        [Parameter(Mandatory = $false)]
        [string]$command = "",
        [Parameter(Mandatory = $false)]
        [int]$timeout = 10
    )
    process {
        $process = Start-Process `
            -FilePath "$command" `
            -PassThru
        if ($process.WaitForExit($timeout)) {
            Write-Host "Process completed within timeout."
        } else {
            Write-Host "Process timed out and will be terminated."
            $process.Kill()
        }
    }
}
function Invoke-Invoke {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline = $true)]
        [hashtable]$Command,

        [string]$CommandLineOnly,
        [string]$CommandNameOnly,

        [string]$Options,
        [switch]$DoNewWindow,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [switch]$HandleError
    )

    begin {
        # $null = Debug-Script -DoPause 60 -functionName "Invoke-Invoke pause for interupt" -logFileNameFull $logFileNameFull
        [Collections.ArrayList]$CommandLines = @()
        [Collections.ArrayList]$CommandResults = @()
        if (-not $Options) { $Options = "" }
    }
    process {
        Write-Verbose "Command: $Command"
        Write-Verbose "CommandName: $CommandNameOnly"
        Write-Verbose "CommandLine: $CommandLineOnly"
        if ($Command) {
            # A piped command will ignore passed single values (Only's)
            if ($Command -is [hashtable]) {
                Write-Debug " Hashtable"
                if (-not $Command.ContainsKey('CommandLine') -or -not $Command.ContainsKey('CommandName')) {
                    Write-Verbose " Bad Keys"
                    $Message = "The hashtable does not contain the required keys."
                    Add-LogText -Message $Message -IsError
                    return
                }
            } else {
                $Message = "The variable `Command` is not a hashtable."
                Add-LogText -Message $Message -IsError
                return
            }
            $CommandLine = $Command['CommandLine']
            $CommandName = $Command['CommandName']
        } else {
            $CommandLine = "$CommandLineOnly"
            $CommandName = "$CommandNameOnly"
            [hashtable]$Command = @{
                CommandLine = $commandLine
                CommandName = $commandName
            }
        }
        if (-not $Command['CommandLine'] -or -not $Command['CommandName']) {
            $Message = "The hashtable must contain both 'CommandLine' and 'CommandName' keys. `nCommand: $Command"
            Add-LogText -Message $Message -IsError
            return
        }            
        if ($DoVerbose) {
            Add-LogText -Message "Received Command: $($Command | Out-String)" -ForegroundColor Red
        }
        if (-not $CommandLine -or -not $CommandName) {
            $Message = "Both CommandLine and CommandName must be provided. `nCommandName($CommandName)- CommandLine($CommandLine)"
            Add-LogText -Message $Message -IsError
            return
        }
        [void]$CommandLines.Add( @{
                CommandName = $CommandName
                CommandLine = $CommandLine
            }
        )
    }
    end {
        # Produces array of ($exitCode, $standardOutput, $errorOutput)
        $standardOutput = ""
        $errorOutput = ""
        $exitCode = 0
        $i = 0
        if ($DoVerbose) { Add-LogText "Invoke command..." $global:logFileNameFull }
        foreach ($Command in $CommandLines) {
            $i++
            $CommandLine = $Command['CommandLine']
            $CommandName = $Command['CommandName']
            if ($DoNewWindow) {
                $outOptions = ""
                $optionsArray = $Options.split(" ")
                foreach ($option in $optionsArray) {
                    $outOptions += $option
                }
                # $installProcess = 
                if ($DoVerbose) { 
                    Add-LogText -Message "NOTE: Opening new window..." `
                        `
                        -ForegroundColor Red
                }
                # Create a new process
                $process = New-Object System.Diagnostics.Process
                $process.StartInfo.FileName = $global:companyName
                $process.StartInfo.Arguments = $outOptions
                $process.StartInfo.UseShellExecute = $false
                $process.StartInfo.RedirectStandardOutput = $true
                $process.StartInfo.RedirectStandardError = $true
                $process.StartInfo.CreateNoWindow = $true
                # Start the process
                $process.Start() | Out-Null
                # Capture the output
                $standardOutput = $process.StandardOutput.ReadToEnd()
                $errorOutput = $process.StandardError.ReadToEnd()
                # Wait for the process to exit
                $process.WaitForExit()
                $exitCode = $process.ExitCode
            } else {
                # Execute the command and capture output and error
                # Redirect output to a temporary file
                $tempFile = [System.IO.Path]::GetTempFileName()
                Invoke-Expression "$commandLine *> $tempFile"
                $output = Get-Content $tempFile
                Remove-Item $tempFile
                $errorOutput = $output | Where-Object { $_ -match "error" }
                $standardOutput = $output | Where-Object { $_ -notmatch "error" }
                $exitCode = $LASTEXITCODE
            }
            if ($HandleError) {
                if ($exitCode -ne 1 -or $errorOutput) {
                    $Message = "$CommandName error $exitCode - $(Get-RobocopyExitMessage($exitCode))."
                    if ($errorOutput) { $Message += "`nDetails: $errorOutput" }
                    Add-LogText -Message $Message -IsError
                } elseif ($standardOutput) {
                    if ($DoVerbose) { 
                        Add-LogText -Message "Output from $($CommandName): `n$standardOutput" -IsError
                    } else {
                        Add-LogText -Message "Ok"
                    }
                }
            }
            # $CommandResults.Add("($i) [$exitCode] { $commandLine } ### $output")
            [CommandResult]$result = @{
                sequence       = $i
                ExitCode       = $exitCode
                CommandName    = $CommandName
                CommandLine    = $CommandLine
                standardOutput = $standardOutput
                errorOutput    = $errorOutput
                result         = $output
            }

            $CommandResults.Add($result)
        }
        return [Collections.ArrayList]$CommandResults
    }
    # Execute the  command using cmd.exe
    # with /c which does the command and then terminates. 
    # The 2>&1 redirects standard error to standard output, 
    # allowing you to capture both in the $output variable.
    # Execute the command and capture only the error output
    # $errorOutput = & cmd.exe /c $commandLine 2>&1 1>$null
    # $errorOutput = & cmd.exe /c $commandLine 1>$null 2>&1
    # $output = & cmd.exe /c $commandLine 2>&1
    # $output = & cmd.exe /c $commandLine 1>&1 2>&1
    # $output = Invoke-Expression "$commandLine 2>&1"
    # $output = & cmd.exe /c "$commandLine 1>&1 2>&1"
    # $output = & cmd.exe /c "$commandLine 2>&1"
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
function Set-CommonParameters {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [hashtable]$commonParameters = @{},
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    begin {
        #  if (-not $outputParams) { $outputParams = New-Object System.Collections.ArrayList($null) }
        $outputParams = $PSBoundParameters
    }
    process {
        $outputParams.Add($_) | Out-Null
    }
    end {
        if ($DoForce -or $PSBoundParameters['Force']) { $outputParams['Force'] = $true; Write-Verbose "Force" }
        if ($DoVerbose -or $PSBoundParameters['Verbose'] -or $VerbosePreference -ne 'Continue') { $outputParams['Verbose'] = $true; Write-Verbose "Verbose" }
        # if ($DoDebug -or $PSBoundParameters['Debug']) { $outputParams['Debug'] = $true; Write-Verbose "Debug" }
        if (Assert-Debug) { $outputParams['Debug'] = $true; Write-Verbose "Debug" }
        $outputParams['ErrorAction'] = if ($errorActionValue) { $errorActionValue } else { 'Continue' }
        # $outputParams += $global:commonParamsPrelude
        return $outputParams
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
