
# DevEnv Gui
function DevEnvGui {
    <#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>


    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$fileNameFull = "",
        [switch]$ResetSettings,
        [string]$logFilePath = "",
        [string]$logFileName = "",
        [switch]$LogOneFile,
        [string]$companyName = "MacroDM",
        [string]$title
    )
    
    begin {
        # $assemblySystemWindowsForms = Get-Assembly -assemblyName $assemblyName
        $assemblyName = "System.Windows.Forms"
        $null = Get-Assembly -assemblyName $assemblyName
        $null = Get-Import "Mdm_WinFormPS" -DoForce
        Get-ModuleRootPath
        $global:timeStarted = Get-Date
        $global:timeStartedFormatted = "{0:yyyymmdd_hhmmss}" -f ($global:timeStarted)
        $global:timeCompleted = $null
    
        # Logging:
        # $global:logFileNameFull = 
        if (-not $logFilePath) { $logFilePath = "$global:projectRootPath\log" }
        if (-not $logFileName) { $logFileName = "Mdm_DevEnvGui_Log" }
        # Sets the global log file name
        $logFileNameFull = Open-LogFile -OpenLogFile `
            -logFilePath $logFilePath -logFileName $logFileName
        Write-Host "Log File: $global:logFileNameFull"
        # Start
        $Message = @(
            " ", `
                "==================================================================", `
                "Loading User Interface at $global:timeStartedFormatted", `
                "==================================================================", `
                "   Function: $PSCommandPath", `
                "    Logfile: $global:logFileNameFull", `
                "Script Root: $PSScriptRoot"
        )
        Add-LogText -Message $Message -logFileNameFull $global:logFileNameFull `
            -ForegroundColor Green
    }
    process {
        try {
            $window = New-WFWindow
            # $window = New-WFWindow -window $null -formsArray $null -state $null
            Get-JsonData -parentObject $window.state.data -inputObject ".\DevEnvGuiConfig.json"
            Get-JsonData -parentObject $window.state.data['Components'] -inputObject ".\DevEnvComponents.json"
            Show-WFForm $window.forms[0]
        } catch {
            $Message = "DevEnvGui unable to create and open form."
            Add-LogText -Message $Message -IsError -logFileNameFull $global:logFileNameFull -ErrorPSItem $_

        }
        Show-WFForm([System.Windows.Forms.Form]$window.forms[0])
    }
    end { }
}
