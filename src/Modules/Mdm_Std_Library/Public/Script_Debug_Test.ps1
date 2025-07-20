# found in Debug-SubmitFunction
$null = Debug-SubmitFunction -functionName $functionName -invocationFunctionName $($MyInvocation.MyCommand.Name) # Debug-Script
if (-not $global:DebugInScriptDebugger `
    -and $global:DebugProgressFindName `
    -and $(Debug-AssertFunction($functionName))) {
    $Message = "Debug $($MyInvocation.MyCommand.Name) for $($functionName)"
    Add-LogText -Message $Message `
        -IsWarning -UseTraceWarningDetails `
        -logFileNameFull $logFileNameFull
    $null = Debug-Script -DoPause 5 -functionName $functionName -logFileNameFull $logFileNameFull
}
