
# Get-ErrorNew
function Get-ErrorNew {
    <#
    .SYNOPSIS
        Creates a powershell error object.
    .DESCRIPTION
        Uses $PSCmdlet.WriteError to create a powershell error.
    .PARAMETER Message
        The error message.
    .PARAMETER ErrorCategory
        TODO: FUTR: The error type.
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
        [string]$Message,
        [int]$errorIdSequence = 0,
        [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::NotSpecified,
        $targetObject = $null,
        $arguments = $null,
        [string]$logFileNameFull = "",
        [switch]$DoWrite,
        [switch]$DoReturn,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    process {
        try {
            if ($Message) {
                if ($DoVerbose) { Write-Host "Get-ErrorNew: New error Message." }
                try {
                    $exception = New-Object System.Exception("Exception: $Message")
                    if (-not $errorIdSequence) {
                        if (-not $global:errorIdSequence) { $global:errorIdSequence = 0 }
                        $global:errorIdSequence++
                        $errorIdSequence = $global:errorIdSequence
                    }
                    $errorId = $errorIdSequence
                    if ($errorCategory -and $errorCategory -is [Management.Automation.ErrorCategory]) {
                        $null
                    } else {
                        $errorCategory = [Management.Automation.ErrorCategory]::InvalidData
                    }
   
                    $ErrorRecord = New-Object `
                        -TypeName "Management.Automation.ErrorRecord" `
                        -ArgumentList $exception, $errorId, $errorCategory, $targetObject `
                        -ErrorAction Stop
                
                    # $ErrorRecord = New-ErrorRecord -Exception $exception `
                    #     -ErrorId $errorId -ErrorCategory $errorCategory  `
                    #     -TargetObject $targetObject
                } catch {
                    Write-Host "Get-ErrorNew: Unable to use Message to create an Error Record. $($global:NL)Error: $_" `
                        -ForegroundColor Red
                    # if ($DoReturn) { return $null }
                }
            } elseif ($arguments) {
                try {
                    if ($DoVerbose) { Write-Host "Get-ErrorNew: New error Arguments." }
                    # $arguments = @(
                    #     New-Object System.Exception("Exception: $Message")
                    #     #errorid = $errorIdSequence
                    #     [Management.Automation.ErrorCategory]$ErrorCategory = $ErrorCategory
                    #     $null
                    # )
                    $ErrorRecord = New-Object `
                        -TypeName "Management.Automation.ErrorRecord" `
                        -ArgumentList $arguments -ErrorAction Stop
                } catch {
                    Write-Host "Get-ErrorNew: Unable to use Arguments to create an Error Record. $($global:NL)Error: $_" `
                        -ForegroundColor Red
                    # if ($DoReturn) { return $null }
                }
            }
            if ($DoWrite) { $PSCmdlet.WriteError($ErrorRecord) }
            if ($DoReturn) {
                $global:errorRecord = $ErrorRecord
                return $ErrorRecord
            }
        } catch {
            Write-Host "Get-ErrorNew: Unable to create an Error Record. $($global:NL)Error: $_" `
                -ForegroundColor Red
            # if ($DoReturn) { return $null }
        }
    }
}
# ErrorCategory enumeration:
#     NotSpecified: The error category is not specified.
#     InvalidArgument: An invalid argument was provided.
#     InvalidOperation: The operation is invalid.
#     ObjectNotFound: An object was not found.
#     PermissionDenied: Permission was denied.
#     ResourceUnavailable: A resource is unavailable.
#     OperationStopped: The operation was stopped.
#     Timeout: The operation timed out.
#     SyntaxError: There is a syntax error.
#     MethodNotFound: A method was not found.
#     ParameterBindingFailed: Parameter binding failed.
#     InvalidType: An invalid type was encountered.
#     InvalidCast: An invalid cast was attempted.
#     NotImplemented: The operation is not implemented.
#     FileNotFound: A file was not found.
#     PathNotFound: A specified path was not found.
#     DriveNotFound: A specified drive was not found.
#     ContainerNotFound: A specified container was not found.
#     ProviderNotFound: A specified provider was not found.
#     CommandNotFound: A specified command was not found.
#     PipelineStopped: The pipeline was stopped.
#     ExecutionFailure: The execution failed.
#     InvalidData: The data is invalid.
#     InvalidOperationException: An invalid operation exception occurred.
#     InvalidArgumentException: An invalid argument exception occurred.
#     InvalidOperationException: An invalid operation exception occurred
