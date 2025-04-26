# found in Submit-DebugFunction
# $null = Submit-DebugFunction -functionName $functionName -invocationFunctionName $($MyInvocation.MyCommand.Name) # Script_Debugger
if (-not $global:DebugInScriptDebugger `
    -and $global:DebugProgressFindName `
    -and $(Assert-DebugFunction($functionName))) {
    $logMessage = "Debug $($MyInvocation.MyCommand.Name) for $($functionName)"
    Add-LogText -logMessages $logMessage `
        -IsWarning -DoTraceWarningDetails `
        -localLogFileNameFull $global:logFileNameFull
    Script_Debugger -DoPause 5 -functionName $functionName -localLogFileNameFull $localLogFileNameFull
}
