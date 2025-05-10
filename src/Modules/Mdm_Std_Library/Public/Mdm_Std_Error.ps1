
function Assert-Debug {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$IgnorePSBoundParameters,
        [Parameter(Mandatory = $false)]
        [switch]$IgnoreDebugPreference,
        [Parameter(Mandatory = $false)]
        [switch]$IgnorePSDebugContext
    )
    process {
        ((-not $IgnoreDebugPreference.IsPresent) -and ($DebugPreference -ne "SilentlyContinue")) -or
        ((-not $IgnorePSBoundParameters.IsPresent) -and $PSBoundParameters.Debug.IsPresent) -or
        ((-not $IgnorePSDebugContext.IsPresent) -and ($PSDebugContext))
    }
}
function Get-ErrorNew {
    <#
    .SYNOPSIS
        Creates a powershell error object.
    .DESCRIPTION
        Uses $PSCmdlet.WriteError to create a powershell error.
    .PARAMETER Message
        The error message.
    .PARAMETER ErrorCategory
        TODO The error type.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .EXAMPLE
        Get-NewError "I had an error" -ErrorCategory 
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
function Get-ErrorLast {
    <#
    .SYNOPSIS
        Get-ErrorLast.
    .DESCRIPTION
        Get-ErrorLast does Get-Error.
    .OUTPUTS
        The last error to occur.
    .EXAMPLE
        Get-ErrorLast
#>


    [CmdletBinding()]
    param ()
    process {
        # Get-Error | Write-Host
        return Get-Error
    }
}
function Set-ErrorBreakOnLine {
    # $serviceName = 'winrm'
    # $orig = "if ($Service.Name -eq $serviceName) { break; }"
    # Set a PSBreakpoint of type "line" on $line.
    # But only if the $Service variable's Name property equals 'winrm'
    # Set-PSBreakpoint -Action { $commandLine } -Line $($LineNumber) -Script $MyInvocation.MyCommand.Path


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $functionName,
        [int]$LineNumber = 1,
        [string]$commandLine = "break; "

    )
    process {
        if (-not $global:debugSetting) { $global:debugSetting = "" }
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
    # Set a PSBreakpoint of type "variable" on a variable.
    # But this breaks only when it has changed.
    # Here it is named "global:debugSetting,".
    # Modes: Read, ReadWrite, Write


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $watchVariable,
        [int]$Write,
        [string]$commandLine

    )
    begin {
        if (-not $watchVariable) { $watchVariable = $global:debugWatchVariable }
        if (-not $mode) { $mode = "Write" } else { $mode = $global:mode }
        Write-Verbose `
            -ForegroundColor Green `
            -Object ("The data variable has changed! Value is: {0}" -f $watchVariable)
        # break
        if (-not $commandLine) { $commandLine = "break; " }
        $Message = "The watch Variable has changed! Value is: $watchVariable"
        $Message += "Action: $commandLine"
    }
    process {
        Add-LogText $Message -ForegroundColor Green
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
        $MessageLines = @()
    }
    process {
        $i = 0
        foreach ($frame in $callStack) {
            if ($frame.ScriptName.Length -gt 1 -and $frame.Command -ne "<ScriptBlock>") {
                $MessageLine = "Frame[$i]: $($frame.Command), line $($frame.ScriptLineNumber)."
                $MessageLink = "$(Split-Path -Path $($frame.ScriptName) -Leaf):$($frame.ScriptLineNumber):"
                
                if ($frame.InvocationInfo.ScriptName) {
                    $MessageCaller = "$(Split-Path -Path $($frame.InvocationInfo.ScriptName) -Leaf) at line $($frame.InvocationInfo.ScriptLineNumber)"
                } else {
                    $MessageCaller = "None"
                }
                # Add a hashtable to the array
                $MessageLines += [PSCustomObject]@{
                    Function_Name    = $MessageLine
                    Link             = $MessageLink
                    Calling_Function = "$MessageCaller$separator"
                }                
            }
            $i++
        }
    }
    end {
        # Output the formatted table
        return ($MessageLines | Format-Table -AutoSize | Out-String)
    }
}
function Get-VariableScoped {
    [CmdletBinding()]
    param (
        [string]$variableName,
        [string]$scope = "Global"
    )
    process {
        if ($variableName) {
            # Get the variable from the scope
            $variable = Get-Variable -Name $variableName -Scope $scope -ErrorAction SilentlyContinue
        } else {
            $variableName = "result for $scope"
            $variable = Get-Variable -Scope $scope -ErrorAction SilentlyContinue
        }
        
        if ($null -ne $variable) {
            return $variable.Value
        } else {
            Write-Warning -Message "Get-VariableScoped: Variable $variableName does not exist in the global scope."
            return $null
        }
    }
}
function Debug-Script {
    [CmdletBinding()]
    param (
        $functionName = "",
        $commandLine = "",
        $Message = @(),
        $DoPause,
        $PsDebug = "",
        [switch]$Break,
        [switch]$DoPrompt,
        [string]$logFileNameFull = "",
        $ErrorPSItem
    )
    begin {
        if ($global:DebugInScriptDebugger -eq $true) { return $false; }
        $global:DebugInScriptDebugger = $true
        if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFull }
        if ($logFileNameFull.Length -le 0) { $logFileNameFull = $global:logFileNameFull }
        if ($ErrorPSItem) { $global:lastError = $ErrorPSItem }
        # Get the call stack
        $callStack = Get-PSCallStack
        $frame = $callStack[0]
        if ($functionName.Length -ge 1) { $functionNameText = " for function: $functionName" } else { $functionNameText = "" }
        $MessageLine = "Script Debugger$functionNameText"
        # "Called by $($MyInvocation.ScriptName), Line: $($MyInvocation.ScriptLineNumber)",
        # Display the header
        $Message += @(
            $MessageLine,
            "Called by $(Split-Path -Path $($MyInvocation.ScriptName) -Leaf), Line: $($MyInvocation.ScriptLineNumber)",
            "(You can add a breakpoint location here:)"
            "Script Debugger in $(Split-Path -Path $($frame.ScriptName) -Leaf), Line: $($frame.ScriptLineNumber)"
        )
        Add-LogText -Message $Message -IsWarning -logFileNameFull $logFileNameFull
        Start-Sleep -Seconds 2
    }
    process {
        $DoPromptError = $false
        #region Display Error Details
        if ($ErrorPSItem) {
            Add-LogText -Message "Passed error:" -IsError -ErrorPSItem $ErrorPSItem -logFileNameFull $logFileNameFull
        }
        # Output the call stack
        try {
            $Message = @("Stack:")
            $callStack = Get-PSCallStack
            $MessageLine = Get-CallStackFormatted $callStack
            $Message += $MessageLine.Trim()
            Add-LogText -Message $Message -foregroundColor Green -logFileNameFull $logFileNameFull
        } catch {
            $Message = @("Error processing the stack.", "Command: $commandNext")
            Add-LogText -Message $Message -IsError  -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            $DoPromptError = $true
        }
        #endregion
        #region DoPause, DoPrompt, PsDebug and $commandLine
        try {
            # This creates a message fall thru preserving the area the error occured.
            # So the error message is prepared before the involcations.
            # $DoPromptError = $false
            # DoPause
            try {
                $Message = "The parameter -DoPause $DoPause is incorrect.`nYou must specify -DoPause in seconds between 1 and 3600."
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
                        $Message = "Pause exection timer for the next $sleepSeconds seconds. `nYou can: `n   1. Press the debug pause button followed by step out and `"Y`". `n   2. Enter `"Y`" to just continue. `n   3. Let it time out."
                        Add-LogText -Message $Message -IsWarning -logFileNameFull $logFileNameFull
                        # Start-Sleep -Seconds $sleepSeconds
                        $Message = "Pause exection timer"
                        $null = Wait-ForKeyPress -Message $Message -duration $sleepSeconds
                    } else {
                        $DoPromptError = $true
                        Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -logFileNameFull $logFileNameFull
                    }
                }
            } catch {
                $DoPromptError = $true
                Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            }
            # DoPrompt
            if ($DoPrompt) {
                if ($(Wait-YorNorQ -Message "Continue execution? ") -ne "Y") { 
                    exit
                }
            }
            # PsDebug
            try {
                $Message = @("Invalid PsDebug parameter ($PsDebug)!`nUse ""Off"", ""Trace 0, 1, or 2"", ""Step"" or ""Strict"" `nCommand: $PsDebug")
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
                        $Message = "Attempt: $commandNext"
                        # Add-LogText -Message $commandLine -IsWarning -logFileNameFull $global:logFileNameFull
                        Add-LogText -Message $Message `
                            -foregroundColor Green `
                            -logFileNameFull $global:logFileNameFull 
                        Invoke-Expression $commandNext 
                    } else {
                        $DoPromptError = $true
                        Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -logFileNameFull $global:logFileNameFull
                    }
                }
            } catch {
                $DoPromptError = $true
                Add-LogText -Message $Message -IsError -SkipScriptLineDisplay-ErrorPSItem $_ -logFileNameFull $logFileNameFull
            }
            # execute the command
            try {
                # if ($commandLine -eq "" ) { $commandLine = $commandLineDefault }
                if ($commandLine.Length -ge 1) {
                    $Message = "Command: $commandLine"
                    $commandNext = $commandLine
                    Add-LogText -Message $Message -IsWarning -logFileNameFull $global:logFileNameFull
                    Invoke-Expression $commandLine 
                }
            } catch {
                $DoPromptError = $true
                $Message = @("Invalid command passed to Script_Debbugger`nCommand: $commandLine")
                Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            }
            # Break handling - this returns to the caller
            $Message = "Break is not working, use breakpoints and debug to break."
            if ($Break) { 
                break
                $DoPromptError = $true
                Add-LogText -Message $Message -IsWarning -logFileNameFull $logFileNameFull
            }
            if ($DoPromptError) {
                if ($(Wait-YorNorQ -Message "Debug-Script had internal errors. Continue execution? ") -ne "Y") { 
                    exit
                }
                return $false
            }
        } catch {
            $Message += @("Debug-Script is not working!!!`nCommand: $commandNext")
            Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -logFileNameFull $logFileNameFull
            if ($(Wait-YorNorQ -Message "Continue execution? ") -ne "Y") { 
                exit
            }
            return $false
        }
        #endregion
        return $true
    }
    end {
        $global:DebugInScriptDebugger = $false
    }
}
function Debug-AssertFunction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $functionName
    )
    return ($global:debugFunctionNames -contains $functionName)
}
function Debug-SubmitFunction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $functionName,
        $invocationFunctionName = "",
        $pauseSeconds = 5
    )
    if (-not $global:DebugInScriptDebugger -and $global:DebugProgressFindName -and $(Debug-AssertFunction($functionName))) {
        $Message = "Debug $invocationFunctionName for $($functionName)"
        Add-LogText -Message $Message `
            -IsWarning -DoTraceWarningDetails `
            -logFileNameFull $global:logFileNameFull
        $null = Debug-Script -DoPause $pauseSeconds -functionName $functionName -logFileNameFull $logFileNameFull
        return $true
    }
    return $false
}
# See Add-LogError