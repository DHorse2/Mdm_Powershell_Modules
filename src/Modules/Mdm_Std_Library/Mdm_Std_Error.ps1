
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
}function Script_Debugger {
    [CmdletBinding()]
    param (
        $functionName = "",
        $commandLine = "",
        $logMessage = @(),
        $PsDebug = "",
        [switch]$Break,
        $ErrorPSItem
    )
    begin {
        if ($ErrorPSItem) { $global:lastError = $ErrorPSItem }
        # Get the call stack
        $callStack = Get-PSCallStack
        $frame = $callStack[0]
        if ($functionName.Length -ge 1) { $functionNameText = " for function: $functionName" } else { $functionNameText = "" }
        $logMessageLine = "Script Debugger$functionNameText"
        # "Called by $($MyInvocation.ScriptName), Line: $($MyInvocation.ScriptLineNumber)",
        $logMessage += @(
            $logMessageLine,
            "Called by $(Split-Path -Path $($MyInvocation.ScriptName) -Leaf), Line: $($MyInvocation.ScriptLineNumber)",
            "(You can add a breakpoint location here:)"
            "Script Debugger in $(Split-Path -Path $($frame.ScriptName) -Leaf), Line: $($frame.ScriptLineNumber)"
        )
        Add-LogText -logMessages $logMessage -isWarning -localLogFileNameFull $global:logFileNameFull
    }
    process {
        if ($ErrorPSItem) {
            Add-LogText -logMessages "Passed error:"  `
                -isError -ErrorPSItem $ErrorPSItem
            -localLogFileNameFull $global:logFileNameFull
        }

        try {
            # Output the call stack
            $logMessage = @("Stack:")
            $logMessageLine = Get-CallStackFormatted $callStack
            $logMessage += $logMessageLine.Trim()
            Add-LogText -logMessages $logMessage -foregroundColor Green `
                -localLogFileNameFull $global:logFileNameFull
        } catch {
            $logMessage = @("Error processing the stack.", "Command: $commandNext")
            Add-LogText -logMessages $logMessage -isError -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
        }
        # PsDebug and $commandLine
        try {
            if ($PsDebug) {
                # This creates a message fall thru preserving the area the error occured.
                $logMessage = @("Invalid PsDebug parameter ($PsDebug)!`nUse ""Off"", ""Trace 0, 1, or 2"", ""Step"" or ""Strict"" `nCommand: $PsDebug")
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
                    # Add-LogText -logMessages $commandLine -isWarning -localLogFileNameFull $global:logFileNameFull
                    Add-LogText -logMessages $logMessage `
                        -foregroundColor Green `
                        -localLogFileNameFull $global:logFileNameFull 
                    Invoke-Expression $commandNext 
                } else {
                    Add-LogText -logMessages $logMessage -isError -SkipScriptLineDisplay -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
                }
            }
            # Break handling
            $logMessage = "Break is not working, use breakpoints and debug to break."
            if ($Break) { break; }
            if ($Break) { 
                Add-LogText -logMessages $logMessage -localLogFileNameFull $global:logFileNameFull -isWarning
            }
            # if ($commandLine -eq "" ) { $commandLine = $commandLineDefault }
            $logMessage = ""
            if ($commandLine.Length -ge 1) {
                $commandNext = $commandLine
                Add-LogText -logMessages $commandLine -isWarning -localLogFileNameFull $global:logFileNameFull
                Invoke-Expression $commandLine 
            }
        } catch {
            $logMessage += @("Script_Debugger is not working!!!`nCommand: $commandNext")
            Add-LogText -logMessages $logMessage -isError -SkipScriptLineDisplay -localLogFileNameFull $global:logFileNameFull -ErrorPSItem $_
            if ($(Wait-YorNorQ -message "Continue execution? ") -ne "Y") { 
                exit
            }
        }
    }
}
# See Add-LogError