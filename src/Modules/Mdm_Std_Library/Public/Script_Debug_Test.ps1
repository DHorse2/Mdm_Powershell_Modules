# found in Debug-SubmitFunction
$null = Debug-SubmitFunction -functionName $functionName -invocationFunctionName $($MyInvocation.MyCommand.Name) # Debug-Script
if (-not $global:DebugInScriptDebugger `
    -and $global:DebugProgressFindName `
    -and $(Debug-AssertFunction($functionName))) {
    $logMessage = "Debug $($MyInvocation.MyCommand.Name) for $($functionName)"
    Add-LogText -logMessages $logMessage `
        -IsWarning -DoTraceWarningDetails `
        -localLogFileNameFull $global:logFileNameFull
    $null = Debug-Script -DoPause 5 -functionName $functionName -localLogFileNameFull $localLogFileNameFull
}
