
# Get-Parameters
$global:mdmParams = @{}
$local:commonParams = @{}
# Check global but don't replace with possible temporary $Do locals
$GetGlobal = $true; $SetGlobal = $true
# $inArgs = $args passes arguments in.
# local $DoXxx gets applied inline
#
if (($GetGlobal -and $global:DoVerbose) -or $DoVerbose) { 
    $local:commonParams['Verbose'] = $true
    $global:mdmParams['DoVerbose'] = $true
    if ($SetGlobal) { $global:DoVerbose = $true }
    Write-Verbose "User Verbose" 
}
if (($GetGlobal -and $global:DoForce) -or $DoForce) { 
    $local:commonParams['Force'] = $true
    $global:mdmParams['DoVerbose'] = $true
    if ($SetGlobal) { $global:DoForce = $true }
    Write-Verbose "User Force" 
}
if (($GetGlobal -and $global:DoDebug) -or $DoDebug) { 
    $local:commonParams['Debug'] = $true
    $global:mdmParams['DoDebug'] = $true
    if ($SetGlobal) { $global:DoDebug = $true }
    Write-Verbose "User Debug"
}
if (($GetGlobal -and $global:DoPause) -or $DoPause) { 
    # $local:commonParams['Pause'] = $true
    $global:mdmParams['DoPause'] = $true
    if ($SetGlobal) { $global:DoPause = $true }
    Write-Verbose "User Pause" 
}
if (($GetGlobal -and $global:DoDebug) -or $DoDebug) { 
    $local:commonParams['Debug'] = $true
    $global:mdmParams['DoDebug'] = $true
    if ($SetGlobal) { $global:DoDebug = $true }
    Write-Verbose "User Debug"
}
if (($GetGlobal -and $global:DoDebug) -or $DoDebug) { 
    $local:commonParams['Debug'] = $true
    $global:mdmParams['DoDebug'] = $true
    if ($SetGlobal) { $global:DoDebug = $true }
    Write-Verbose "User Debug"
}
if (($GetGlobal -and $global:errorActionValue) -or $local:errorActionPreference) {
    if ($SetGlobal -and $local:errorActionPreference) { $global:errorActionValue = $local:errorActionPreference }
    $tmp = if ($global:errorActionValue) { $global:errorActionValue } else { 'Continue' }
    if ($local:errorActionPreference) { $tmp = $local:errorActionPreference }
    # validate
    if ($tmp -ne 'Continue' `
            -and $tmp -ne 'ContinueSilently' `
            -and $tmp -ne 'Stop' `
            -and $tmp -ne 'Inquire') {
        Write-Warning "$tmp is not a valid Error Action."
        $tmp = 'Inquire'
    }
    $local:commonParams['ErrorAction'] = $tmp
    $global:mdmParams['ErrorAction'] = $tmp
    Write-Verbose "Error Action $tmp"
}
# Process command arguments
$Message = "CommonParameters"
if ($inArgs -and $inArgs.Count -gt 0) {
    foreach ($arg in $inArgs) {
        # Check if the argument starts with a dash (indicating a parameter)
        $Message = "Argument: $arg"
        if ($arg.StartsWith('-')) {
            # $commonParameters = @{}
            switch ($arg) {
                { $_ -eq "-DoVerbose" -or $_ -eq "-Verbose" } {
                    $local:commonParams['Verbose'] = $true
                    $global:mdmParams['DoVerbose'] = $true
                    if ($SetGlobal) { $global:DoVerbose = $true }
                    Write-Verbose "Argument: $arg"
                }
                { $_ -eq "-DoForce" -or $_ -eq "-Force" } { 
                    $local:commonParams['Force'] = $true
                    $global:mdmParams['DoForce'] = $true
                    if ($SetGlobal) { $global:DoForce = $true }
                    Write-Verbose "Argument: $arg"
                }
                { $_ -eq "-DoDebug" -or $_ -eq "-Debug" } {
                    $local:commonParams['Debug'] = $true
                    $global:mdmParams['DoDebug'] = $true
                    if ($SetGlobal) { $global:DoDebug = $true }
                    Write-Verbose "Argument: $arg"
                }
                { $_ -eq "-DoPause" -or $_ -eq "-Pause" } { 
                    # $commonParameters['Pause'] = $true
                    $global:mdmParams['DoPause'] = $true
                    if ($SetGlobal) { $global:DoPause = $true }
                    Write-Verbose "Argument: $arg"
                }
                Default {
                    # Split the argument into name and value
                    if ($arg -like '*=*') {
                        # Handle the case where the argument is in the form -ParameterName=Value
                        $nameValue = $arg -split '=', 2
                        # Remove the leading dash
                        $name = $nameValue[0].TrimStart('-')
                        $value = $nameValue[1]
                    } else {
                        # Handle the case where the argument is in the form -ParameterName Value
                        $nameValue = $arg -split ' ', 2
                        $name = $nameValue[0].TrimStart('-')
                        # Default to $true if no value is provided
                        if ($nameValue.Count -gt 1) {
                            if ($nameValue[1] -like '-*') {
                                $value = $true
                                # $inArgs = $nameValue[1] + $inArgs
                            } else {
                                $value = if ($nameValue.Count -gt 1) { $nameValue[1] } else { $true }
                            }
                        }
                    }
                    # Add to common parameters only.
                    $local:commonParams[$name] = $value
                    $Message = "Argument: $name = $value"
                }
            }
        }
        Write-Verbose $Message
    }
}
# Common Params
$global:commonParams = @{}
$local:commonParams.GetEnumerator() | ForEach-Object {
    $global:commonParams[$_.Key] = $_.Value
}
# Combined Params
$global:combinedParams = @{}
$local:commonParams.GetEnumerator() | ForEach-Object {
    $global:combinedParams[$_.Key] = $_.Value
}
$global:mdmParams.GetEnumerator() | ForEach-Object {
    $global:combinedParams[$_.Key] = $_.Value
}
# Import Module Params
# Uses common. Mdm DoXxxxx would cause errors
$global:importParameters = @{}
$global:commonParams.GetEnumerator() | ForEach-Object {
    $global:importParameters[$_.Key] = $_.Value
}
# Process resulting settings. Won't turn off anything.
if ($global:mdmParams['DoVerbose']) { $DoVerbose = $true }
if ($global:mdmParams['DoDebug']) { $DoDebug = $true }
if ($global:mdmParams['DoForce']) { $DoForce = $true }
if ($global:mdmParams['DoPause']) { $DoPause = $true }
