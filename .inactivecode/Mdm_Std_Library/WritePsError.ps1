function Write-PsError
{
<#
.SYNOPSIS
    Creates a powershell error object.
.DESCRIPTION
     Uses $PSCmdlet.WriteError to create a powershell error.
.PARAMETER Message
    The error message.
.PARAMETER ErrorCategory
    The error type.
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
        [Management.Automation.ErrorCategory]$ErrorCategory = "NotSpecified"
    )

    $arguments = @(
            $Message
            $null #errorid
            [Management.Automation.ErrorCategory]::$ErrorCategory
            $null

            )

    $ErrorRecord = New-Object -TypeName "Management.Automation.ErrorRecord" -ArgumentList $arguments
    $PSCmdlet.WriteError($ErrorRecord)

}
