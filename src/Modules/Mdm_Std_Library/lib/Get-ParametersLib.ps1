

# Get-Parameters
# [CmdletBinding()]
# param (
#     [string]$appName = "",
#     [switch]$GetLocal,
#     [switch]$SetLocal,
#     [string]$importName = "",
#     [int]$actionStep = 0,
#     [switch]$DoDispose,
#     [switch]$DoLogFile,
#     [string]$logFileNameFull = "",
#     [switch]$DoForce,
#     [switch]$DoVerbose,
#     [switch]$DoDebug,
#     [switch]$DoPause
# )
$global:mdmParams = @{}
$local:commonParams = @{}
$functionParams = $PSBoundParameters
# importParams
# Check global but don't replace with possible temporary $Do locals
if (-not $GetLocal) { $GetGlobal = $true } else { $GetGlobal = $false }
if (-not $SetLocal) { $SetGlobal = $true } else { $SetGlobal = $false }
if (-not $global:app) { $GetGlobal = $false; $SetGlobal = $false }
# $inArgs = $args passes arguments in.
# local $DoXxx gets applied inline
#
if ($appName -or ($GetGlobal -and $global:app.appName)) { 
    # if (-not $appName -and ($GetGlobal -and $global:app.appName)) { $appName = $global:app.appName}
    # $local:commonParams['appName'] = $appName
    $global:mdmParams['appName'] = $appName
    if ($SetGlobal) { $global:app.appName = $appName }
    Write-Debug "User Pause $appName" 
}
if ($DoVerbose -or ($GetGlobal -and $global:app.DoVerbose) -or $VerbosePreference -eq "Continue") { 
    $DoVerbose = $true
    $local:commonParams['Verbose'] = $true
    $global:mdmParams['DoVerbose'] = $true
    if ($SetGlobal) { $global:app.DoVerbose = $true }
    Write-Debug "User Verbose $DoVerbose"
}
if ($DoPause -or ($GetGlobal -and $global:app.DoPause)) { 
    $DoPause = $true
    # $local:commonParams['Pause'] = $true
    $global:mdmParams['DoPause'] = $true
    if ($SetGlobal) { $global:app.DoPause = $true }
    Write-Debug "User Pause $DoPause" 
}
if ($DoForce -or ($GetGlobal -and $global:app.DoForce)) { 
    $DoForce = $true
    $local:commonParams['Force'] = $true
    $global:mdmParams['DoVerbose'] = $true
    if ($SetGlobal) { $global:app.DoForce = $true }
    Write-Debug "User Force $DoForce" 
}
if ($DoDebug -or ($GetGlobal -and $global:app.DoDebug) -or $DebugPreference -eq "Continue") { 
    $DoDebug = $true
    $local:commonParams['Debug'] = $true
    $global:mdmParams['DoDebug'] = $true
    if ($SetGlobal) { $global:app.DoDebug = $true }
    Write-Debug "User Debug $DoDebug"
}
if ($logFileNameFull -or ($GetGlobal -and $global:app)) {
    # $local:commonParams['logFileNameFull'] = $logFileNameFull
    $global:mdmParams['logFileNameFull'] = $logFileNameFull
    if ($SetGlobal) {
        $global:app.logFileName = $logFileNameFull
        $global:logFileName = $logFileNameFull
    }
    Write-Debug "User Log File $logFileNameFull"
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
    Write-Debug "Error Action $tmp"
}
# Process command arguments
$Message = "CommonParameters"
if ($inArgs -and $inArgs.Count -gt 0) {
    $argLast = ""
    foreach ($arg in $inArgs) {
        # Check if the argument starts with a dash (indicating a parameter)
        $Message = "Argument: $arg"
        if ($arg.StartsWith('-')) {
            # $commonParameters = @{}
            $arg = $arg.Substring(1)
            $argLast = $arg
            switch ($arg) {
                { $_ -eq "logFileNameFull" } {
                    $local:commonParams['logFileNameFull'] = $logFileNameFull
                    $global:mdmParams['logFileNameFull'] = $logFileNameFull
                    if ($SetGlobal) { $global:app.DoVerbose = $true }
                    Write-Debug "Argument: $arg"
                }
                { $_ -eq "DoVerbose" -or $_ -eq "Verbose" } {
                    $local:commonParams['Verbose'] = $true
                    $global:mdmParams['DoVerbose'] = $true
                    if ($SetGlobal) { $global:app.DoVerbose = $true }
                    $argLast = ""
                    Write-Debug "Argument: $arg"
                }
                { $_ -eq "DoForce" -or $_ -eq "Force" } { 
                    $local:commonParams['Force'] = $true
                    $global:mdmParams['DoForce'] = $true
                    if ($SetGlobal) { $global:app.DoForce = $true }
                    $argLast = ""
                    Write-Debug "Argument: $arg"
                }
                { $_ -eq "DoDebug" -or $_ -eq "Debug" } {
                    $local:commonParams['Debug'] = $true
                    $global:mdmParams['DoDebug'] = $true
                    if ($SetGlobal) { $global:app.DoDebug = $true }
                    $argLast = ""
                    Write-Debug "Argument: $arg"
                }
                { $_ -eq "DoPause" -or $_ -eq "Pause" } { 
                    # $commonParameters['Pause'] = $true
                    $global:mdmParams['DoPause'] = $true
                    if ($SetGlobal) { $global:app.DoPause = $true }
                    $argLast = ""
                    Write-Debug "Argument: $arg"
                }
                Default {
                    # Args don't come in groups like -x $y or -x = $y
                    # TODO Hold Skip positional parameters???
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
                    $argLast = ""
                }
            }
        } else {
            # Only accept the immediately following value
            if ($argLast -and $arg -is [System.String]) {
                $local:commonParams[$argLast] = $arg
                $global:mdmParams['logFileNameFull'] = $arg
                Write-Debug "Argument: $arg"
            }
            $argLast = ""
        }
    }
}
Write-Debug $Message
# Common Params
# $global:commonParams = @{}
# $local:commonParams.GetEnumerator() | ForEach-Object {
#     $global:commonParams[$_.Key] = $_.Value
# }
# Combined Params
$global:combinedParams = @{}
if ($local:commonParams) {
    $local:commonParams.GetEnumerator() | ForEach-Object {
        $global:combinedParams[$_.Key] = $_.Value
    }
}
if ($global:mdmParams) {
    $global:mdmParams.GetEnumerator() | ForEach-Object {
        $global:combinedParams[$_.Key] = $_.Value
    }
}
# Import Module Params
# Uses common. Mdm DoXxx would cause errors
$global:importParams = @{}
if ($global:commonParams) {
    $global:commonParams.GetEnumerator() | ForEach-Object {
        $global:importParams[$_.Key] = $_.Value
    }
}
# Process resulting settings. Won't turn off anything.
if ($global:mdmParams['DoVerbose']) { $DoVerbose = $true }
if ($global:mdmParams['DoDebug']) { $DoDebug = $true }
if ($global:mdmParams['DoForce']) { $DoForce = $true }
if ($global:mdmParams['DoPause']) { $DoPause = $true }

if ($DoDebug) { $DebugPreference = "Continue" } 
else { $DebugPreference = "SilentlyContinue" }
if ($DoVerbose) { $VerbosePreference = "Continue" } 
else { $VerbosePreference = "SilentlyContinue" }

if ($DoDebug) {
    if ($global:mdmParams.Count) {
        Write-Host "Std Library Parameters:" -ForegroundColor Blue
        ForEach ($Key in $global:mdmParams.Keys) {
            Write-Host "Key: $Key = $($global:mdmParams[$Key])" -ForegroundColor Blue
        }
    }
    if ($global:commonParams.Count) {
        Write-Host "PS Std/Common Parameters:" -ForegroundColor Blue
        ForEach ($Key in $global:commonParams.Keys) {
            Write-Host "Key: $Key = $($global:commonParams[$Key])" -ForegroundColor Blue
        }
    }
    if ($global:combinedParams.Count) {
        Write-Host "Combined Parameters:" -ForegroundColor Blue
        ForEach ($Key in $global:combinedParams.Keys) {
            Write-Host "Key: $Key = $($global:combinedParams[$Key])" -ForegroundColor Blue
        }
    }
    Get-Location
    $result = "Ok"
    Write-Host "Get Parameters Done" -ForegroundColor Blue
}
