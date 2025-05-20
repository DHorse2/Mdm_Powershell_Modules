# region Logging
function Add-LogText {
    # per https://stackoverflow.com/questions/24432190/generic-parameter-in-powershell
    # TODO: (Inprogress. Implement pipelines)
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        $Messages,
        [string]$logFileNameFull,
        [switch]$TrimWhitespace,
        [switch]$DoEscapes,
        [switch]$IsCritical,
        [switch]$IsError,
        [switch]$IsWarning,
        [switch]$DoTraceWarningDetails,
        [switch]$SkipScriptLineDisplay,
        [switch]$NoNewLine,
        $ForegroundColor,
        $BackgroundColor,
        [System.Management.Automation.ErrorRecord]$ErrorPSItem,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause    
    )
    begin {
        try {
            # Preserve Parameters
            $commonParameters = @{}
            $commonParameters['IsCritical'] = $IsCritical
            $commonParameters['IsWarning'] = $IsWarning
            $commonParameters['IsError'] = $IsError
            $commonParameters['DoTraceWarningDetails'] = $DoTraceWarningDetails
            $commonParameters['SkipScriptLineDisplay'] = $SkipScriptLineDisplay
            $commonParameters['NoNewLine'] = $NoNewLine
            # Log File
            if (-not $logFileNameFull) { $logFileNameFull = $global:logFileNameFull }
            if (-not $logFileNameFull -or -not(Test-Path $logFileNameFull -PathType Leaf)) {
                Open-LogFile -DoOpen -logFileNameFull $logFileNameFull
                $logFileNameFull = $global:logFileNameFull
            }
            if (-not $ErrorPSItem -and ($IsCritical -or $IsError -or $IsWarning)) {
                # Get the most recent error
                $ErrorPSItem = $Error[0] 
            }
        } catch {
            Write-Error -Message "Add-LogText: Log File ($logFileName) validation error, path ($logFilePath). $_"
        }
    }
    process {
        $MessageIndex = -1
        foreach ($Message in $Messages) {
            try {
                $MessageIndex++
                # pre-process message (for html)
                # TODO. Should the log be html also?
                [hashtable]$convertParams = @{}
                $convertParams['DoEscapes'] = $DoEscapes
                $convertParams['TrimWhitespace'] = $TrimWhitespace
                if ($DoEscapes) {
                    $Message = ConvertTo-EscapedText $Message @convertParams
                } elseif ($TrimWhitespace) {
                    $Message = $Message.Trim()
                }
                # $Message | Out-File -FilePath $logFileNameFull –Append
            
                # Display message to user
                if ($IsCritical -or $IsError -or $IsWarning) {
                    if ($IsCritical -or $IsError) {
                        if ($global:UseTrace -and $ErrorPSItem) { 
                            $newMessage = Add-LogError $Message `
                                -ErrorPSItem $ErrorPSItem `
                                -logFileNameFull $logFileNameFull `
                                @global:commonParams
                            $Message = $newMessage
                        } else {
                            # Write-Error -Message $Message
                            if ($NoNewLine) {
                                Write-Host -Message $Message `
                                    -NoNewline $NoNewLine `
                                    -ForegroundColor $global:messageErrorForegroundColor `
                                    -BackgroundColor $global:messageErrorBackgroundColor
                            } else {
                                Write-Host -Message $Message `
                                    -ForegroundColor $global:messageErrorForegroundColor `
                                    -BackgroundColor $global:messageErrorBackgroundColor
                            }
                        }
                        if ($global:DoDebugPause) {
                            $null = Debug-Script -DoPause 60 -functionName "Error handling pause for debugger interupt (and step out)." -logFileNameFull $logFileNameFull
                        }
                    } elseif ($IsWarning) { 
                        if ($global:UseTrace -and $global:UseTraceWarning -and $ErrorPSItem) { 
                            $newMessage = Add-LogError -Message $Message `
                                -ErrorPSItem $ErrorPSItem `
                                -logFileNameFull $logFileNameFull `
                                @global:commonParams
                            $Message = $newMessage
                        } else {
                            # Write-Warning -Message $Message
                            if ($NoNewLine) {
                                Write-Host -Message $Message `
                                    -NoNewline `
                                    -ForegroundColor $global:messageWarningForegroundColor `
                                    -BackgroundColor $global:messageWarningBackgroundColor
                            } else {
                                Write-Host -Message $Message `
                                    -ForegroundColor $global:messageWarningForegroundColor `
                                    -BackgroundColor $global:messageWarningBackgroundColor
                            }
                        }
                    }
                    if ($IsCritical) {
                        # Assume $ErrorPSItem is an ErrorRecord object
                        if (-not $ErrorPSItem) { $ErrorPSItem = $Error[0] }
                        # Extract information from the ErrorRecord
                        $errorMessage = $ErrorPSItem.Exception.Message
                        $errorCategory = $ErrorPSItem.CategoryInfo.Category
                        $errorId = $ErrorPSItem.FullyQualifiedErrorId
                        # Throw an exception with structured information
                        throw [System.Exception]::new("Error: $($message). Details: $errorMessage. Category: $errorCategory. Error ID: $errorId.")                    
                    }
                } else { 
                    if (-not $ForegroundColor) { $ForegroundColor = $global:messageForegroundColor }
                    if (-not $ForegroundColor) { $ForegroundColor = [System.ConsoleColor]::White }
                    if (-not $BackgroundColor) { $BackgroundColor = $global:messageBackgroundColor }
                    if (-not $BackgroundColor) { $BackgroundColor = [System.ConsoleColor]::Black }
                    if ($NoNewLine) {
                        Write-Host -Message $Message `
                            -NoNewline `
                            -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    } else {
                        Write-Host -Message $Message `
                            -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    }
                }
                # Write to storage
                if ($NoNewLine) {
                    $Message | Add-Content -Path $logFileNameFull
                } else {
                    $Message | Out-File -FilePath $logFileNameFull –Append
                }
            } catch {
                Write-Error -Message "Add-LogText: LogMessage ($MessageIndex) processing error. $_"
            }
        }
    }
}
function Add-LogError {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        $Message,
        $logFileNameFull = "",
        [System.Management.Automation.ErrorRecord]$ErrorPSItem,
        [switch]$IsCritical,
        [switch]$IsError,
        [switch]$IsWarning,
        [switch]$SkipScriptLineDisplay,
        [switch]$DoTraceWarningDetails,
        [switch]$NoNewLine,
        $ForegroundColor,
        $BackgroundColor,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    
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
        if (-not $ErrorPSItem) { $ErrorPSItem = $Error[0] }
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
            if (-not $DoTraceWarningDetails) { $DoTraceWarningDetails = $global:DoTraceWarningDetails }
            $callStack = Get-PSCallStack
            if ($ErrorPSItem) { 
                $global:lastError = $ErrorPSItem 
            } else { 
                $ErrorPSItem = $callStack
            }
            $localLastError = $Error
            $scriptNameFull = $ErrorPSItem.InvocationInfo.ScriptName
            $scriptName = Split-Path $scriptNameFull -leaf
            $line = $ErrorPSItem.InvocationInfo.ScriptLineNumber
            $column = $ErrorPSItem.InvocationInfo.OffsetInLine
            $functionName = $($helpInfoObject.Name)
            if (-not $functionName) { $functionName = $scriptName }
            $null = Debug-SubmitFunction -pauseSeconds 5 -functionName "LogError for $functionName" -invocationFunctionName $($MyInvocation.MyCommand.Name) # Debug-Script
        } catch {
            Write-Error -Message "Add-LogError Error Object initialization error. $_"
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
            if ($IsWarning -and -not $DoTraceWarningDetails) {
                $traceDetails = $false
            }
            if ($traceDetails) {        
                $errorLine = "============================================="
                Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                $newMessage += $errorLine + "`n"
            }
            # Location info
            $errorLine = "$($errorTypeText)Script: $($scriptName):$($line):$($column)"
            if (-not $SkipScriptLineDisplay) {
                Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                $newMessage += $errorLine + "`n"
            }
            # Newlines are required after this line
            $newMessage += $errorLine
            #endregion
            #region Error Detail
            try {
                $errorLine = $Message
                Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                $newMessage += "`n" + $errorLine
                if ($traceDetails) {        
                    $errorLine = "Details: "
                    Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "`n" + $errorLine

                    $errorLine = "$($ErrorPSItem.Exception.Message)"
                    Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "`n" + $errorLine

                    $errorLine = "$($ErrorPSItem.CategoryInfo)"
                    Write-Host $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "`n" + $errorLine

                    # Stack trace
                    if ($global:UseTraceStack) {
                        $newMessage += "`n"
                        Write-Host " "
                        $errorLine = "Stack trace: "
                        Write-Host $errorLine -ForegroundColor Green -BackgroundColor $BackgroundColor
                        $newMessage += "`n" + $errorLine

                        $MessageLine = Get-CallStackFormatted $callStack "`n"
                        $errorLine = $MessageLine.Trim()
                        Write-Host $errorLine -ForegroundColor Green
                        $newMessage += "`n" + $errorLine
                    }
                    # Additional details
                    if ($traceDetails -and $($ErrorPSItem.ErrorDetails)) { 
                        $newMessage += "`n"
                        Write-Host " "
                        $errorLine = "Additional details: "
                        Write-Host -Message $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                        $newMessage += "`n" + $errorLine
                        $errorLine = "$($ErrorPSItem.ErrorDetails)"
                        Write-Host -Message $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                        $newMessage += "`n" + $errorLine
                    }
                    $errorLine = "============================================="
                    Write-Host -Message $errorLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
                    $newMessage += "`n" + $errorLine
                }
            } catch {
                $Message = "Add-LogError ouput processing Trace Details error. $_"
                Write-Error -Message $Message
                $newMessage += "`n" + $Message
            }
            #endregion
        } catch {
            $Message = "Add-LogError output processing error. $_"
            Write-Error -Message $Message
            $newMessage += "`n" + $Message
        }
    }
    end { return $newMessage }
}
function Open-LogFile {
    # [string]$global:logFileName = "$($global:companyNamePrefix)_Installation_Log"
    # [string]$global:logFilePath = "$global:projectRootPath\log"
    # [string]$global:logFileNameFull = ""
    # Use a single log file repeatedly appending to it.
    # The date and time will be appended to the name when LogOneFile is false.
    # [bool]$global:LogOneFile = $LogOneFile


    [CmdletBinding()]
    param (
        # Does not include the file extension
        [string]$logFileNameFull,
        [string]$logFilePath,
        [string]$logFileName,
        [string]$logFileExtension,
        [switch]$DoOpen,
        [switch]$LogOneFile,
        [switch]$SkipCreate,
        [switch]$DoClear
    )
    begin {
        try {
            if ($DoClear) {
                [string]$logFileNameFull = ""
                [string]$logFilePath = ""
                [string]$logFileName = ""
                [string]$logFileExtension = ""
                [switch]$LogOneFile = $false
            }
            if ($LogOneFile) { $global:LogOneFile = $LogOneFile }
            if ($logFileNameFull -and ($logFilePath -or $logFileName)) {
                Write-Warning -Message "Open-LogFile error, don't specify the Full file name AND a FilePath or FileName."
                Write-Warning -Message "FileNameFull will be used and parsed."
            }
            if ($logFileNameFull) {
                $logFilePath = Split-Path -Path $logFileNameFull
                $logFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFileNameFull)
                $logFileExtension = [System.IO.Path]::GetExtension($logFileNameFull)
            } else {
                if ($logFilePath -or $logFileName) {
                    # Save changes
                    if (-not $logFilePath) { $logFilePath = "$global:projectRootPath\Log" }
                    $global:logFilePath = $logFilePath
                    if (-not $logFileName) { $logFileName = "$global:companyNamePrefix _Log" }
                    $global:logFileName = $logFileName
                    if (-not $logFileExtension) { $logFileExtension = [System.IO.Path]::GetExtension($logFileNameFull) }
                    $logFileNameFull = "$logFilePath\$logFileName.$logFileExtension"
                } else {
                    # Use defaults
                    if (-not $global:logFileNameFull) {
                        $global:logFileName = "$($global:companyNamePrefix)_Log"
                        $global:logFilePath = "$global:projectRootPath\log"
                        # Use a single log file repeatedly appending to it.
                        # The date and time will be appended to the name when LogOneFile is false.
                        [bool]$global:LogOneFile = $LogOneFile
                    }
                    $logFilePath = $global:logFilePath
                    $logFileName = $global:logFileName
                    $LogOneFile = $global:LogOneFile
                    if (-not $logFileExtension) {
                        $logFileExtension = [System.IO.Path]::GetExtension($logFileNameFull)
                    }
                }
            }
            # Construct the full log file name
            # $logFileNameFull = Join-Path -Path $logFilePath -ChildPath $logFileName
            $logFileNameFull = "$logFilePath\$logFileName"
            if (-not $global:timeStarted) { $global:timeStarted = Get-Date }
            if (-not $global:timeStartedFormatted) { 
                $global:timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:timeStarted
            }
            if (-not $LogOneFile) { $logFileNameFull = "$($logFileNameFull)_$global:timeStartedFormatted" }
            if (-not $logFileExtension) { $logFileExtension = ".txt" }
            $logFileNameFull = "$logFileNameFull$logFileExtension"
            $global:logFileNameFull = $logFileNameFull
            $global:logFilePath = $logFilePath
            $global:logFileName = $logFileName
            $global:LogOneFile = $LogOneFile

        } catch {
            Write-Error -Message "Open-LogFile error processing file name information. $_"
        }
    }
    process {
        try {
            # Log folder
            try {
                # Check if folder not exists, and create it
                if (-not(Test-Path $logFilePath -PathType Container)) {
                    if (-not $SkipCreate) { New-Item -path $logFilePath -ItemType Directory }
                }
                # $logFilePath = Convert-Path $logFilePath
            } catch {
                Write-Error -Message "Open-LogFile error processing file path $logFilePath. $_"
            }
    
            try {
                if (-not $SkipCreate) { 
                    # Check if file exists, and create it
                    if (-not(Test-Path $logFileNameFull -PathType Leaf)) {
                        New-Item -path $logFileNameFull -ItemType File -Force
                    }
                    try {
                        " " | Out-File -FilePath $logFileNameFull -Force
                        # –Append
                        # $logFilePath = Convert-Path $logFileNameFull -ItemType File -ErrorAction Stop
                    } catch {
                        Write-Warning -Message "Open-LogFile created file wasn't found: $logFileNameFull."
                    }
                }
            } catch {
                Write-Error -Message "Open-LogFile error creating file $logFileName. $_"
            }            
        } catch {
            Write-Error -Message "Oper-LogFile had an unexpected error. File: $logFileName. Error: $_"
        }
    }
    end {
        # $global:logFileNameFull = $logFileNameFull
        # return $logFileNameFull
    }
}
# endregion
