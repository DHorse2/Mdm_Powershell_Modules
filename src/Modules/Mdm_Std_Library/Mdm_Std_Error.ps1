
function Get-NewError {
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
        TODO PsError Example
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
    begin {
        $arguments = @(
            $Message
            $null #errorid
            [Management.Automation.ErrorCategory]::$ErrorCategory
            $null

        )
        $ErrorRecord = New-Object `
            -TypeName "Management.Automation.ErrorRecord" `
            -ArgumentList $arguments
    }
    process {
        $PSCmdlet.WriteError($ErrorRecord)
    }
}
function Get-LastError {
    <#
    .SYNOPSIS
        Get-LastError.
    .DESCRIPTION
        Get-LastError does Get-Error.
    .OUTPUTS
        The last error to occur.
    .EXAMPLE
        Get-LastError
#>


    [CmdletBinding()]
    param ()
    process {
        # Get-Error | Write-Host
        return Get-Error
    }
}
function Set-ErrorBreakOnLine {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $functionName,
        [int]$LineNumber = 1,
        [string]$commandLine = "break; "

    )
    process {
        if (-not $global:debugSetting) { $global:debugSetting = "" }
        # $serviceName = 'winrm'
        # $orig = "if ($Service.Name -eq $serviceName) { break; }"
        # Set a PSBreakpoint of type "line" on $line.
        # But only if the $Service variable's Name property equals 'winrm'
        # Set-PSBreakpoint -Action { $commandLine } -Line $($LineNumber) -Script $MyInvocation.MyCommand.Path
        Set-PSBreakpoint -Action { $commandLine } -Line $($LineNumber) -Script $functionName
    }
}
# Break on FUNCTION
function Set-ErrorBreakOnFunction {
    [CmdletBinding()]
    param (
        $functionName,
        [int]$LineNumber = 1,
        [string]$commandLine = "break;"

    )
    process {
        if (-not $functionName) { $functionName = $global:debugFunctionName }
        if ($functionName) { 
            Set-PSBreakpoint -Command $functionName -Action { $commandLine }
        }
    }
}
# Break on Variable
function Set-ErrorBreakOnVariable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $watchVariable,
        [int]$Write,
        [string]$commandLine

    )
    begin {
        # Set a PSBreakpoint of type "variable" on a variable.
        # But this breaks only when it has changed.
        # Here it is named "global:debugSetting,".
        # Modes: Read, ReadWrite, Write
        if (-not $watchVariable) { $watchVariable = $global:debugWatchVariable }
        if (-not $mode) { $mode = "Write" } else { $mode = $global:mode }
        # "Write-Host -ForegroundColor Green -Object ("The $Data variable has changed! Value is: {0}" -f $watchVariable); break;"
        if (-not $commandLine) { $commandLine = "break;" }
        $logMessage = "The watch Variable has changed! Value is: $watchVariable"
        $logMessage += "Action: $commandLine"
    }
    process {
        Add-LogText $logMessage -ForegroundColor Green
        Set-PSBreakpoint -Action { $commandLine } -Variable $watchVariable -Mode $mode
    }
}
function Get-CallStackFormatted {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $callStack,
        $separator = ""
    )
    begin {
        # Initialize as an ArrayList
        $logMessageLines = @()
    }
    process {
        $i = 0
        foreach ($frame in $callStack) {
            if ($frame.ScriptName.Length -gt 1 -and $frame.Command -ne "<ScriptBlock>") {
                $logMessageLine = "Frame[$i]: $($frame.Command), line $($frame.ScriptLineNumber)."
                $logMessageLink = "$(Split-Path -Path $($frame.ScriptName) -Leaf):$($frame.ScriptLineNumber):"
                
                if ($frame.InvocationInfo.ScriptName) {
                    $logMessageCaller = "$(Split-Path -Path $($frame.InvocationInfo.ScriptName) -Leaf) at line $($frame.InvocationInfo.ScriptLineNumber)"
                } else {
                    $logMessageCaller = "None"
                }
                # Add a hashtable to the array
                $logMessageLines += [PSCustomObject]@{
                    Function_Name    = $logMessageLine
                    Link             = $logMessageLink
                    Calling_Function = "$logMessageCaller$separator"
                }                
            }
            $i++
        }
    }
    end {
        # Output the formatted table
        return ($logMessageLines | Format-Table -AutoSize | Out-String)
    }
}
function Script_Debugger {
    [CmdletBinding()]
    param (
        $functionName = "",
        $commandLine = "",
        $logMessage = @(),
        $DoPause,
        $PsDebug = "",
        [switch]$Break,
        [switch]$DoPrompt,
        [string]$localLogFileNameFull = "",
        $ErrorPSItem
    )
    begin {
        if ($global:DebugInScriptDebugger -eq $true) { return; }
        $global:DebugInScriptDebugger = $true
        if (-not $localLogFileNameFull) { $localLogFileNameFull = $global:logFileNameFull }
        if ($localLogFileNameFull.Length -le 0) { $localLogFileNameFull = $global:logFileNameFull }
        if ($ErrorPSItem) { $global:lastError = $ErrorPSItem }
        # Get the call stack
        $callStack = Get-PSCallStack
        $frame = $callStack[0]
        if ($functionName.Length -ge 1) { $functionNameText = " for function: $functionName" } else { $functionNameText = "" }
        $logMessageLine = "Script Debugger$functionNameText"
        # "Called by $($MyInvocation.ScriptName), Line: $($MyInvocation.ScriptLineNumber)",
        # Display the header
        $logMessage += @(
            $logMessageLine,
            "Called by $(Split-Path -Path $($MyInvocation.ScriptName) -Leaf), Line: $($MyInvocation.ScriptLineNumber)",
            "(You can add a breakpoint location here:)"
            "Script Debugger in $(Split-Path -Path $($frame.ScriptName) -Leaf), Line: $($frame.ScriptLineNumber)"
        )
        Add-LogText -logMessages $logMessage -IsWarning -localLogFileNameFull $localLogFileNameFull
        Start-Sleep -Seconds 3
    }
    process {
        #region Display Error Details
        if ($ErrorPSItem) {
            Add-LogText -logMessages "Passed error:" -IsError -ErrorPSItem $ErrorPSItem -localLogFileNameFull $localLogFileNameFull
        }
        # Output the call stack
        try {
            $logMessage = @("Stack:")
            $logMessageLine = Get-CallStackFormatted $callStack
            $logMessage += $logMessageLine.Trim()
            Add-LogText -logMessages $logMessage -foregroundColor Green -localLogFileNameFull $localLogFileNameFull
        } catch {
            $logMessage = @("Error processing the stack.", "Command: $commandNext")
            Add-LogText -logMessages $logMessage -IsError  -ErrorPSItem $_ -localLogFileNameFull $localLogFileNameFull
        }
        #endregion
        #region DoPause, DoPrompt, PsDebug and $commandLine
        try {
            # This creates a message fall thru preserving the area the error occured.
            # So the error message is prepared before the involcations.
            $DoPromptError = $false
            # DoPause
            try {
                $logMessage = "The parameter -DoPause $DoPause is incorrect.`nYou must specify -DoPause in seconds between 1 and 3600."
                if ($DoPause) {
                    $commandValid = $true
                    switch ($DoPause) {
                        { $_ -match "\d+$" } { 
                            $sleepSeconds = $DoPause
                            # betwenn one second and one hour or non-numeric
                            if ($sleepSeconds -lt 1 -or $sleepSeconds -gt 3600) {
                                $commandValid = $false 
                            }
                        }
                        { $null } { $sleepSeconds = 5 }
                        default { $commandValid = $false }
                    }
                    if ($commandValid) {
                        $logMessage = "Pause exection timer for the next $sleepSeconds seconds. `nYou can: `n   1. Press the debug pause button followed by step out and `"Y`". `n   2. Enter `"Y`" to just continue. `n   3. Let it time out."
                        Add-LogText -logMessages $logMessage -IsWarning -localLogFileNameFull $localLogFileNameFull
                        # Start-Sleep -Seconds $sleepSeconds
                        $logMessage = "Pause exection timer"
                        $null = Wait-ForKeyPress -message $logMessage -duration $sleepSeconds
                    } else {
                        $DoPromptError = $true
                        Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay -localLogFileNameFull $localLogFileNameFull
                    }
                }
            } catch {
                $DoPromptError = $true
                Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -localLogFileNameFull $localLogFileNameFull
            }
            # DoPrompt
            if ($DoPrompt) {
                if ($(Wait-YorNorQ -message "Continue execution? ") -ne "Y") { 
                    exit
                }
            }
            # PsDebug
            try {
                $logMessage = @("Invalid PsDebug parameter ($PsDebug)!`nUse ""Off"", ""Trace 0, 1, or 2"", ""Step"" or ""Strict"" `nCommand: $PsDebug")
                if ($PsDebug) {
                    $commandValid = $true
                    switch ($PsDebug) {
                        "Off" { }
                        "Step" { }
                        { $_ -match "^Trace \d+$" } { 
                            # "Trace" followed by an integer
                            # Extract the integer value
                            $traceValue = [int]$PsDebug.Split(" ")[1]
                            if (-not ($traceValue -ge 0 -and $traceValue -le 2)) {
                                $commandValid = $false 
                            }
                        }
                        "Strict" { }
                        default { $commandValid = $false }
                    }
                    if ($commandValid) {
                        $commandNext = "Set-PSDebug -$PsDebug"
                        $logMessage = "Attempt: $commandNext"
                        # Add-LogText -logMessages $commandLine -IsWarning -localLogFileNameFull $global:logFileNameFull
                        Add-LogText -logMessages $logMessage `
                            -foregroundColor Green `
                            -localLogFileNameFull $global:logFileNameFull 
                        Invoke-Expression $commandNext 
                    } else {
                        Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay -localLogFileNameFull $global:logFileNameFull
                    }
                }
            } catch {
                $DoPromptError = $true
                Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay-ErrorPSItem $_ -localLogFileNameFull $localLogFileNameFull
            }
            # execute the command
            try {
                # if ($commandLine -eq "" ) { $commandLine = $commandLineDefault }
                if ($commandLine.Length -ge 1) {
                    $logMessage = "Command: $commandLine"
                    $commandNext = $commandLine
                    Add-LogText -logMessages $logMessage -IsWarning -localLogFileNameFull $global:logFileNameFull
                    Invoke-Expression $commandLine 
                }
            } catch {
                $DoPromptError = $true
                $logMessage = @("Invalid command passed to Script_Debbugger`nCommand: $commandLine")
                Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -localLogFileNameFull $localLogFileNameFull
            }
            # Break handling - this returns to the caller
            $logMessage = "Break is not working, use breakpoints and debug to break."
            if ($Break) { 
                break
                $DoPromptError = $true
                Add-LogText -logMessages $logMessage -IsWarning -localLogFileNameFull $localLogFileNameFull
            }
            if ($DoPromptError) {
                if ($(Wait-YorNorQ -message "Script_Debugger had internal errors. Continue execution? ") -ne "Y") { 
                    exit
                }
            }
        } catch {
            $logMessage += @("Script_Debugger is not working!!!`nCommand: $commandNext")
            Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -localLogFileNameFull $localLogFileNameFull
            if ($(Wait-YorNorQ -message "Continue execution? ") -ne "Y") { 
                exit
            }
        }
        #endregion
    }
    end {
        $global:DebugInScriptDebugger = $false
    }
}
# See Add-LogError