Using namespace Microsoft.VisualBasic
Using namespace PresentationFramework
Using namespace PresentationCore
Using namespace WindowsBase
Using namespace System.Drawing
Using namespace System.Windows.Forms
Using namespace Microsoft.PowerShell.Security
Using namespace System.Management.Automation

Add-Type -AssemblyName Microsoft.PowerShell.Security
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Management.Automation
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# Mdm_Std_Log
# region Logging
function Add-LogText {
    # per https://stackoverflow.com/questions/24432190/generic-parameter-in-powershell
    # TODO: (In progress. Implement pipelines)
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true, Position = 1)]
        $Message,
        [Parameter(Position = 2)]
        [string]$logFileNameFull = "",
        [switch]$TrimWhitespace,
        [switch]$DoEscapes,
        [switch]$IsCritical,
        [switch]$IsError,
        [switch]$IsWarning,
        [switch]$UseTraceWarningDetails,
        [switch]$SkipScriptLineDisplay,
        [switch]$NoNewLine,
        $ForegroundColor,
        $BackgroundColor,
        [System.Management.Automation.ErrorRecord]$ErrorPSItem,
        [string]$appName = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [System.Windows.Forms.Control]$inputEventSender,
        [System.EventArgs]$inputEventArgs
    )
    begin {
        $global:logFileUsed = $true
        try {
            # Preserve Parameters
            # Log File
            if ($global:app) {
                if (-not $appName) { $appName = $global:app.appName }
                if (-not $logFileNameFull) { $logFileNameFull = $global:app.logFileNameFull }
            }
            if (-not $ErrorPSItem -and ($IsCritical -or $IsError -or $IsWarning)) {
                # Get the most recent error
                $ErrorPSItem = [System.Management.Automation.ErrorRecord]$Error[0] 
            }
        } catch {
            Write-Error -Message "Add-LogText: Log File ($logFileNameFull) Begin error. $global:NL$_"
        }
    }
    process {
        $MessageIndex = -1
        foreach ($MessageItem in $Message) {
            try {
                $MessageIndex++
                # pre-process message (for html)
                # TODO. Should the log be html also?
                [hashtable]$convertParams = @{}
                $convertParams['DoEscapes'] = $DoEscapes
                $convertParams['TrimWhitespace'] = $TrimWhitespace
                if ($DoEscapes) {
                    $MessageItem = ConvertTo-EscapedText $MessageItem @convertParams
                } elseif ($TrimWhitespace) {
                    $MessageItem = $MessageItem.Trim()
                }
                # $MessageItem | Out-File -FilePath $logFileNameFull –Append
            
                # Display message to user
                if ($IsCritical -or $IsError) {
                    if (-not $ForegroundColor) { $ForegroundColor = $global:messageErrorForegroundColor }
                    if (-not $BackgroundColor) { $BackgroundColor = $global:messageErrorBackgroundColor }
                } elseif ($IsWarning) { 
                    if (-not $ForegroundColor) { $ForegroundColor = $global:messageWarningForegroundColor }
                    if (-not $BackgroundColor) { $BackgroundColor = $global:messageWarningBackgroundColor }
                }
                if (-not $ForegroundColor) { $ForegroundColor = $global:messageForegroundColor }
                if (-not $ForegroundColor) { $ForegroundColor = [System.ConsoleColor]::White }
                if (-not $BackgroundColor) { $BackgroundColor = $global:messageBackgroundColor }
                if (-not $BackgroundColor) { $BackgroundColor = [System.ConsoleColor]::Black }

                if ($IsCritical -or $IsError -or $IsWarning) {
                    if ($IsCritical -or $IsError) {
                        if ($global:UseTrace -and $ErrorPSItem) { 
                            $newMessage = Add-LogError -MessageItem $MessageItem `
                                -ErrorPSItem $ErrorPSItem `
                                -logFileNameFull $logFileNameFull `
                                @global:commonParams
                            $MessageItem = $newMessage
                        } else {
                            # Write-Error -Message $MessageItem
                            if ($NoNewLine) {
                                Write-Host -Message $MessageItem `
                                    -NoNewline `
                                    -ForegroundColor $ForegroundColor `
                                    -BackgroundColor $BackgroundColor
                            } else {
                                Write-Host -Message $MessageItem `
                                    -ForegroundColor $ForegroundColor `
                                    -BackgroundColor $BackgroundColor
                            }
                        }
                        if ($global:app.DoDebugPause) {
                            $null = Debug-Script -DoPause 60 -functionName "Error handling pause for debugger interupt (and step out)." -logFileNameFull $logFileNameFull
                        }
                    } elseif ($IsWarning) { 
                        if ($global:UseTrace -and $global:UseTraceWarning -and $ErrorPSItem) { 
                            $newMessage = Add-LogError -MessageItem $MessageItem `
                                -ErrorPSItem $ErrorPSItem `
                                -logFileNameFull $logFileNameFull `
                                @global:commonParams
                            $MessageItem = $newMessage
                        } else {
                            # Write-Warning -Message $MessageItem
                            if ($NoNewLine) {
                                Write-Host -Message $MessageItem `
                                    -NoNewline `
                                    -ForegroundColor $ForegroundColor `
                                    -BackgroundColor $BackgroundColor
                            } else {
                                Write-Host -Message $MessageItem `
                                    -ForegroundColor $ForegroundColor `
                                    -BackgroundColor $BackgroundColor
                            }
                        }
                    }
                    if ($IsCritical) {
                        # Assume $ErrorPSItem is an ErrorRecord object
                        if (-not $ErrorPSItem) { $ErrorPSItem = [System.Management.Automation.ErrorRecord]$Error[0] }
                        # Extract information from the ErrorRecord
                        $errorMessage = $ErrorPSItem.Exception.Message
                        $errorCategory = $ErrorPSItem.CategoryInfo.Category
                        $errorId = $ErrorPSItem.FullyQualifiedErrorId
                        # Throw an exception with structured information
                        throw [System.Exception]::new("Error: $($message). Details: $errorMessage. Category: $errorCategory. Error ID: $errorId.")                    
                    }
                } else { 
                    if ($NoNewLine) {
                        Write-Host -Message $MessageItem `
                            -NoNewline `
                            -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    } else {
                        Write-Host -Message $MessageItem `
                            -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    }
                }
                # Write to storage
                try {
                    if ($NoNewLine) {
                        $MessageItem | Add-Content -Path $logFileNameFull
                    } else {
                        $MessageItem | Out-File -FilePath $logFileNameFull –Append
                    }
                } catch {
                    try {
                        # Create missing log file
                        if (-not $logFileNameFull -or -not(Test-Path $logFileNameFull -PathType Leaf)) {
                            $localParams = @{}
                            if ($InitForce) { $localParams['InitForce'] = $true }
                            # Force Open
                            $localParams['DoOpen'] = $true
                            # [switch]$DoOpen,
                            # Do not propagate $DoSkipCreate
                            # [switch]$SkipCreate,
                            if ($logFileNameFull) { $localParams['logFileNameFull'] = $logFileNameFull }
                            if ($DoForce) { $localParams['DoForce'] = $true }
                            if ($DoVerbose) { $localParams['DoVerbose'] = $true }
                            if ($DoDebug) { $localParams['DoDebug'] = $true }
                            if ($DoPause) { $localParams['DoPause'] = $true }
                            $localParams['ErrorAction'] = 'Inquire' 
                            # if ($IsCritical) { $localParams['IsCritical'] = $true }
                            # if ($IsWarning) { $localParams['IsWarning'] = $true }
                            # if ($IsError) { $localParams['IsError'] = $true }
                            if ($UseTraceWarningDetails) { $localParams['UseTraceWarningDetails'] = $UseTraceWarningDetails }
                            if ($SkipScriptLineDisplay) { $localParams['SkipScriptLineDisplay'] = $SkipScriptLineDisplay }
                            if ($NoNewLine) { $localParams['NoNewLine'] = $true }
                            $null = Open-LogFile -DoSetGlobal @localParams
                            $logFileNameFull = $global:logFileNameFullResult
                            $global:logFileNameFullReady = $true
                        }
                    } catch {
                        Write-Error -Message "Add-LogText: Open Log File ($logFileName) error. $global:NL$_"
                    }
                    if ($NoNewLine) {
                        $MessageItem | Add-Content -Path $logFileNameFull
                    } else {
                        $MessageItem | Out-File -FilePath $logFileNameFull –Append
                    }
                }
            } catch {
                Write-Error -Message "Add-LogText: LogMessage ($MessageIndex) processing error. $global:NL$_"
            }
        }
    }
}
function Add-LogError {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        [string]$MessageItem,
        [string]$logFileNameFull = "",
        [string]$logFileFormat = "text",
        [System.Management.Automation.ErrorRecord]$ErrorPSItem,
        [switch]$IsCritical,
        [switch]$IsError,
        [switch]$IsWarning,
        [switch]$SkipScriptLineDisplay,
        [switch]$UseTraceWarningDetails,
        [switch]$NoNewLine,
        $ForegroundColor,
        $BackgroundColor,
        [string]$appName = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [System.Windows.Forms.Control]$inputEventSender,
        [System.EventArgs]$inputEventArgs
    )
    # You can capture both stdout and stderr to separate variables
    # and then suppress all output:
    # Invoke-Expression "somecommand.exe" `
    #   -ErrorVariable errOut `
    #   -OutVariable succOut 2>&1 >$null
    # 1 is stdout, 2 is stderr, and 
    # 2>&1 combines stderr into stdout. 
    # Then >$null discards stdout
    # also: $errOutput = $( $output = & $command $params ) 2>&1
    begin { 
        [string]$newMessage = "" 
        # Assume $ErrorPSItem is an ErrorRecord object
        if (-not $ErrorPSItem) { $ErrorPSItem = [System.Management.Automation.ErrorRecord]$Error[0] }
        # Extract information from the ErrorRecord
        $errorMessage = $ErrorPSItem.Exception.Message
        $errorCategory = $ErrorPSItem.CategoryInfo.Category
        $errorId = $ErrorPSItem.FullyQualifiedErrorId
        $errorMessageDetailed = "Error: $($message). Details: $errorMessage. Category: $errorCategory. Error ID: $errorId."
        if ($DoDebug -or $DoVerbose) {
            Write-Host $errorMessageDetailed -ForegroundColor Magenta
        }
    }
    process {
        #region Error Objects, debugger, Script and Location of error
        try {
            if (-not $UseTraceWarningDetails) { $UseTraceWarningDetails = $global:UseTraceWarningDetails }
            $callStack = Get-PSCallStack
            if ($ErrorPSItem -and $ErrorPSItem -is [System.Management.Automation.ErrorRecord]) { 
                # Error Type Handling
                # For general errors:
                # $_ -is [System.Management.Automation.RuntimeException]
                # For specific exceptions: You can also check for more specific exception types, such as:
                #     System.IO.FileNotFoundException for file-related errors.
                #     System.UnauthorizedAccessException for permission-related errors.
                #     System.Exception for a general catch-all.
                # TODO Errors. Logging might be added. No current requirements. 
                switch ($ErrorPSItem.Exception) {
                    { $_ -is [System.IO.FileNotFoundException] } { 
                        # Handle FileNotFoundException
                    }
                    { $_ -is [System.UnauthorizedAccessException] } { 
                        # Handle UnauthorizedAccessException
                    }
                    { $_ -is [System.Exception] } { 
                        # Handle general exceptions
                    }
                    { $_ -is [System.Management.Automation.RuntimeException] } { 
                        # Handle RuntimeException
                    }
                    default {
                        # Handle any other exceptions in agnostic manner
                    }
                }
            } else { 
                # $ErrorPSItem = $callStack
                $ErrorPSItem = [System.Management.Automation.ErrorRecord]$Error[0]
            }
            # $null = Debug-Script -DoPause 5 -functionName "Add-LogError" -logFileNameFull $logFileNameFull
            $global:lastError = $ErrorPSItem
            $localLastError = $Error
            $scriptNameFull = $ErrorPSItem.InvocationInfo.ScriptName
            if ($scriptNameFull) {
                $scriptName = Split-Path $scriptNameFull -Leaf -ErrorAction SilentlyContinue
            } else { $scriptName = "" }
            $line = $ErrorPSItem.InvocationInfo.ScriptLineNumber
            $column = $ErrorPSItem.InvocationInfo.OffsetInLine
            $functionName = $($helpInfoObject.Name)
            if (-not $functionName) { $functionName = $scriptName }
            $null = Debug-SubmitFunction -pauseSeconds 5 -functionName "LogError for $functionName" -invocationFunctionName $($MyInvocation.MyCommand.Name) # Debug-Script
        } catch {
            Write-Error -Message "Add-LogError Error Object initialization error. $global:NL$_"
        }
        #endregion
        try {
            #region Colors
            if (-not $ForegroundColor) {
                if ($IsCritical -or $IsError) { $ForegroundColor = $messageErrorForegroundColor }
                elseif ($IsWarning) { $ForegroundColor = $messageWarningForegroundColor }
                else { $ForegroundColor = $global:messageForegroundColor }
            }
            if (-not $BackgroundColor) {
                if ($IsError) { $BackgroundColor = $messageErrorBackgroundColor }
                elseif ($IsWarning) { $BackgroundColor = $messageWarningBackgroundColor }
                else { $BackgroundColor = $global:messageBackgroundColor }
            }
            if (-not $ForegroundColor) { $ForegroundColor = [System.ConsoleColor]::Yellow }
            if (-not $BackgroundColor) { $BackgroundColor = [System.ConsoleColor]::DarkBlue }
            #endregion
            #region Output
            # Category prefix
            if ($IsCritical -or $IsError) { $errorTypeText = "Error in " }
            elseif ($IsWarning) { $errorTypeText = "Warning in " }
            else { $errorTypeText = "" }
            # Determine how much detail to output.
            $traceDetails = $global:UseTraceDetails
            if ($IsWarning -and -not $UseTraceWarningDetails) {
                $traceDetails = $false
            }
            if ($traceDetails) {        
                $errorLine = "============================================="
                Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                $newMessage += $errorLine + "$global:NL"
            }
            # Location info
            $errorLine = "$($errorTypeText)Script: $($scriptName):$($line):$($column)"
            if (-not $SkipScriptLineDisplay) {
                Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                $newMessage += $errorLine + "$global:NL"
            }
            # Newlines are required after this line
            $newMessage += $errorLine
            #endregion
            #region Error Detail
            try {
                $errorLine = $MessageItem
                Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                $newMessage += "$global:NL" + $errorLine
                if ($traceDetails -and $ErrorPSItem) {        
                    $errorLine = "Details: "
                    Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "$global:NL" + $errorLine

                    $errorLine = "$($ErrorPSItem.Exception.Message)"
                    Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "$global:NL" + $errorLine

                    $errorLine = "$($ErrorPSItem.CategoryInfo)"
                    Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "$global:NL" + $errorLine

                    # Stack trace
                    if ($global:UseTraceStack) {
                        $newMessage += "$global:NL"
                        Write-Host " "
                        $errorLine = "Stack trace: "
                        Write-Host $errorLine -ForegroundColor Green -BackgroundColor $BackgroundColor
                        $newMessage += "$global:NL" + $errorLine

                        $MessageLine = Get-CallStackFormatted $callStack "$global:NL"
                        $errorLine = $MessageLine.Trim()
                        Write-Host $errorLine -ForegroundColor Green
                        $newMessage += "$global:NL" + $errorLine
                    }
                    # Additional details
                    if ($traceDetails -and $($ErrorPSItem.ErrorDetails)) { 
                        $newMessage += "$global:NL"
                        Write-Host " "
                        $errorLine = "Additional details: "
                        Write-Host -Message $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                        $newMessage += "$global:NL" + $errorLine
                        $errorLine = "$($ErrorPSItem.ErrorDetails)"
                        Write-Host -Message $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                        $newMessage += "$global:NL" + $errorLine
                    }
                    $errorLine = "============================================="
                    Write-Host -Message $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "$global:NL" + $errorLine
                }
            } catch {
                $MessageItem = "Add-LogError ouput processing Trace Details error. $global:NL$_"
                Write-Error -Message $MessageItem
                $newMessage += "$global:NL" + $MessageItem
            }
            #endregion
        } catch {
            $MessageItem = "Add-LogError output processing error. $global:NL$_"
            Write-Error -Message $MessageItem
            $newMessage += "$global:NL" + $MessageItem
        }
    }
    end { return $newMessage }
}
function Open-LogFile {
    # [string]$global:app.logFileName = "$($global:companyNamePrefix)_Installation_Log"
    # [string]$global:app.logFilePath = "$global:projectRootPath"
    # [string]$global:app.logFileNameFull = ""
    # Use a single log file repeatedly appending to it.
    # The date and time will be appended to the name when LogOneFile is false.
    # [bool]$global:app.logOneFile = $LogOneFile


    [CmdletBinding()]
    param (
        # [CommandApp]$app,
        [string]$appName = "",
        [string]$appDirectory = "",
        [string]$companyName = "",
        [string]$title,
        # Does not include the file extension
        [string]$logFileNameFull = "",
        [string]$logFilePath = "",
        [string]$logFileName = "",
        [string]$logFileExtension = "",
        [string]$logFileFormat = "text",
        [switch]$LogOneFile,
        [switch]$DoCheckState,
        # TODO This is incoherent use of switches. DoForce?
        # Includes Std, Gui and LogFile?
        [switch]$InitForce,
        [switch]$DoOpen,
        [switch]$SkipCreate,
        # DoClear clears the currently running arrays
        [switch]$DoClearGlobal,
        [switch]$DoSetGlobal,
        # Force applies to non-std functions like Import-Module
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    begin {
        try {
            # if ($LogOneFile) { $global:app.logOneFile = $LogOneFile }
            if ($logFileNameFull -and ($logFilePath -or $logFileName)) {
                Write-Warning -Message "Open-LogFile error, don't specify the Full file name AND a FilePath or FileName."
                Write-Warning -Message "FileNameFull will be used and parsed."
            }
            # app
            if (-not $appName) { $appName = "Global" }
            if (-not $app -and $global:appArray -and $global:appArray[$appName]) { $app = $global:appArray[$appName] }
            # Build Structured Log File Names
            if (-not $logFileNameFull) {
                # Path and File Name
                if ($logFilePath -or $logFileName) {
                    # Save changes
                    if (-not $logFilePath) {
                        $logFilePath = "$($(get-item $PSScriptRoot).Parent.FullName)\log"
                    }
                    if (-not $logFileName) {
                        $logFileName = "$($appName)_Log"
                        if ($global:companyNamePrefix) { $logFileName = "$($global:companyNamePrefix)_$($logFileName)" }
                    }
                    $logFileExtension = [System.IO.Path]::GetExtension($logFileName)
                    if (-not $logFileExtension) {
                        $logFileExtension = $global:app.logFileExtension
                        if (-not $logFileExtension) { $logFileExtension = ".txt" }
                    }
                    $logFileNameFull = "$logFilePath\$logFileName$logFileExtension"
                } else {
                    # Build Structured Name
                    # $logFilePath = "$global:projectRootPath\Log"
                    $logFilePath = "$($(get-item $PSScriptRoot).Parent.FullName)\log"
                    # Use defaults from the run CommandApp $app
                    if ($app -and $app -is [CommandApp]) {
                        # Defaults
                        $logFilePath = $app.logFilePath
                        if (-not $logFilePath) { 
                            $logFilePath = "$($(get-item $PSScriptRoot).Parent.FullName)\log"
                        }
                        $logFileName = $app.logFileName
                        if (-not $logFileName) { $logFileName = "$($app.appName)_Log" }
                        if ($app.companyNamePrefix) { $logFileName = "$($app.companyNamePrefix)_$($logFileName)" }
                        if (-not $logFileExtension) {
                            $logFileExtension = $app.logFileExtension
                            if (-not $logFileExtension) { $logFileExtension = ".txt" }
                        }
                        $logFileName = "$logFileName$logFileExtension"
                        $logFileNameFull = "$logFilePath\$logFileName"
                    }
                    # Or Use defaults if Global not already set
                    elseif (-not $global:app.logFileNameFull) {
                        # Build from Defaults
                        $logFileName = "$($appName)_Log"
                        if ($global:companyNamePrefix) { $logFileName = "$($global:companyNamePrefix)_$($logFileName)" }
                        if (-not $logFileExtension) { $logFileExtension = $global:app.logFileExtension }
                        if (-not $logFileExtension) { $logFileExtension = ".txt" }
                        $logFileName = "$logFileName$logFileExtension"
                        $logFileNameFull = "$logFilePath\$logFileName"
                    } else {
                        # Use available Globals
                        $logFileNameFull = $global:app.logFileNameFull
                        $logFilePath = Split-Path -Path $logFileNameFull
                        $logFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFileNameFull)
                        $logFileExtension = [System.IO.Path]::GetExtension($logFileNameFull)
                        if (-not $LogOneFile) { $LogOneFile = $global:app.logOneFile }
                    }
                }
            }
            # $logFileNameFull by this point.
            # It is fault tolerant. It does not fail.
            $logFilePath = Split-Path -Path $logFileNameFull
            $logFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFileNameFull)
            $logFileExtension = [System.IO.Path]::GetExtension($logFileNameFull)
            # Extract the date and time - $logFileTime
            $pattern = '\d{8}_\d{6}'
            if ($logFileName -match $pattern) {
                $logFileTime = $matches[0]  # This will contain the matched date/time value
                Write-Verbose "Extracted Date/Time: $dateTimeValue"
                $logFileName = $logFileName -replace $logFileTime, ''
                Write-Verbose "New File Name: $logFileName"
            } else {
                $logFileTime = ""
                Write-Verbose "No date/time value found in the string."
            }
            #
            # Construct the complete log file name which can include a date.
            # $logFileNameFull = Join-Path -Path $logFilePath -ChildPath $logFileName
            # 
            $logFileNameNew = $logFileName
            if (-not $logFileTime) {
                $timeStarted = Get-Date # ? Use app time ?
                $timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $timeStarted
            } else {
                $timeStartedFormatted = $logFileTime
                $timeStarted = Get-Date $timeStartedFormatted -Format "yyyyMMdd_HHmmss"            
            }
            if (-not $LogOneFile) {
                $logFileNameNew = "$($logFileNameNew)_$timeStartedFormatted"
            }
            if (-not $logFileExtension) { $logFileExtension = ".txt" }
            $logFileNameNew = "$logFileNameNew$logFileExtension"
            $logFileNameFullNew = "$logFilePath\$logFileNameNew"
            # App
            if ($app) {
                $app.timeStarted = $timeStarted
                $app.timeStartedFormatted = $timeStartedFormatted
                $app.timeCompleted = [System.DateTime]::MinValue

                $app.logFileNameFull = $logFileNameFullNew
                $app.logFilePath = $logFilePath
                $app.logFileName = $logFileNameNew
                $app.logOneFile = $LogOneFile
                $app.logFileExtension = $logFileExtension
            }
            if ($global:app) {
                # This code is opinionated and syncs log opening with start time
                if ($DoSetGlobal -and (-not $global:app.logFileNameFull -or $InitForce)) {
                    if (-not $global:app.timeStarted) { 
                        # A new logfile should not hammer a long running job time
                        $global:app.timeStarted = $timeStarted
                        $global:app.timeStartedFormatted = $timeStartedFormatted
                        $global:app.timeCompleted = [System.DateTime]::MinValue
                    }
                    $global:app.logFileNameFull = $logFileNameFullNew
                    $global:app.logFilePath = $logFilePath
                    $global:app.logFileName = $logFileNameNew
                    $global:app.logOneFile = $LogOneFile
                    $global:app.logFileExtension = $logFileExtension
                }
                $displayHeader = Update-StdHeader -DoUseGlobal -logFileNameFull $logFileNameFull
                $global:app.displayHeader = $displayHeader
            } else {
                $displayHeader = Update-StdHeader -logFileNameFull $logFileNameFull
            }
        } catch {
            Write-Error -Message "Open-LogFile error processing file name information. $global:NL$_"
        }
    }
    process {
        try {
            # Log File Creation
            $logFileNameFull = $logFileNameFullNew
            $logFileName = $logFileNameNew
            if ($appName -and $global:appArray) {
                $app = $global:appArray[$appName]
                if ($app) { 
                    $app.logFileNameFull = $logFileNameFull 
                }
            }
            $timeStarted = Get-Date
            $timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $timeStarted
            $timeCompleted = [System.DateTime]::MinValue
            $null = Update-StdHeader -appName $appName -Title $title `
                -timeStarted $timeStarted -timeCompleted $timeCompleted `
                -logFileNameFull $logFileNameFull
            $displayHeader = $global:displayHeaderReturn
            # $displayHeader = Update-StdHeader
            if (-not $SkipCreate) { 
                # Log directory
                try {
                    # Check if folder not exists, and create directory
                    if (-not(Test-Path $logFilePath -PathType Container)) {
                        New-Item -path $logFilePath -ItemType Directory
                    }
                } catch {
                    Write-Error -Message "Open-LogFile error processing file path $logFilePath. $global:NL$_"
                }
                # Log File Name
                try {
                    # Check if file exists, and create it
                    if (-not(Test-Path $logFileNameFull -PathType Leaf)) {
                        New-Item -path $logFileNameFull -ItemType File -Force
                        Write-FileFromText -Message $displayHeader -Append -logFileNameFull "$($(get-item $PSScriptRoot).Parent.FullName)\log\LogFiles_Log.ps1"
                    }
                    try {
                        # Overwrite existing file.
                        # TODO Hold Trim existing files?
                        "$displayHeader$global:NL" | Out-File -FilePath $logFileNameFull -Force
                        if ($app) { $app.logFileCreated = $true }
                        if ($DoSetGlobal -and $global:app) { $global:app.logFileCreated = $true }
                    } catch {
                        Write-Warning -Message "Open-LogFile created file wasn't found: $logFileNameFull."
                    }
                } catch {
                    Write-Error -Message "Open-LogFile error creating file $logFileName. $global:NL$_"
                }
            }
        } catch {
            Write-Error -Message "Open-LogFile had an unexpected error. File: $logFileName. Error: $global:NL$_"
        }
    }
    end {
        if ($DoSetGlobal) { 
            $global:logFileNameFull = $logFileNameFull
            $global:displayHeader = $displayHeader
            $global:timeStarted = $timeStarted
            $global:timeStartedFormatted = $timeStartedFormatted
            $global:timeCompleted = $timeCompleted
            if (-not $global:logFileNames) { $global:logFileNames = @{} }
            $global:logFileNames[$appName] = $logFileNameFull
            if (-not $SkipCreate) { $global:logFileCreated = $true }
            if ($global:app) { 
                $global:app.logFileNameFull = $logFileNameFull
                $global:app.timeStarted = $timeStarted
                $global:app.timeStartedFormatted = $timeStartedFormatted
                $global:app.timeCompleted = $timeCompleted
                $global:app.displayHeader = $displayHeader
                # logFileNames
                if (-not $global:app.logFileNames) { $global:app.logFileNames = @{} }
                $global:app.logFileNames[$appName] = $logFileNameFull
                if (-not $SkipCreate) { $global:app.logFileCreated = $true }
            }
        }
        # return $logFileNameFull
        # $logFileNameFull
        $global:logFileNameFullResult = $logFileNameFull
        return $logFileNameNew
    }
}
function Write-FileFromText {
    [CmdletBinding()]
    param (
        $Message,
        $logFileNameFull,
        [switch]$SkipCreate,
        [switch]$Append
    )
    
    begin {
        try {
            # Log File Creation
            $logFilePath = Split-Path -Path $logFileNameFull
            $logFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFileNameFull)
            $logFileExtension = [System.IO.Path]::GetExtension($logFileNameFull)
            if (-not $SkipCreate) { 
                # Log directory
                try {
                    # Check if folder not exists, and create directory
                    if (-not(Test-Path $logFilePath -PathType Container)) {
                        New-Item -path $logFilePath -ItemType Directory
                    }
                } catch {
                    Write-Error -Message "Write-FileFromText error processing file path $logFilePath. $global:NL$_"
                }
                # Log File Name
                try {
                    # Check if file exists, and create it
                    if (-not(Test-Path $logFileNameFull -PathType Leaf)) {
                        New-Item -path $logFileNameFull -ItemType File -Force
                    }
                    try {
                        # Overwrite existing file.
                        # TODO Hold Trim existing files?
                        "$displayHeader$global:NL" | Out-File -FilePath $logFileNameFull -Force
                    } catch {
                        Write-Warning -Message "Write-FileFromText created file wasn't found: $logFileNameFull."
                    }
                } catch {
                    Write-Error -Message "Write-FileFromText error creating file $logFileNameFull. $global:NL$_"
                }
            }
        } catch {
            Write-Error -Message "Write-FileFromText had an unexpected error. File: $logFileNameFull. Error: $global:NL$_"
        }
    }
    process {
        try {
            if ($Append) {
                $Message | Out-File -Append -FilePath $logFileNameFull -Force
            } else {
                $Message | Out-File -FilePath $logFileNameFull -Force
            }
        } catch {
            Write-Error -Message "Write-FileFromText had an error Writing the message to storage. File: $logFileNameFull. Error: $global:NL$_"
        }
    }
    end { }
}
# endregion
