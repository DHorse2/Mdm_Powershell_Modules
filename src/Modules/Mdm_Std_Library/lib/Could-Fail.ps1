
# Could-Fail.ps1
# TODO Hold This code exists allow for scripts that may terminate unexpectedly.
# It's functionality breaks massive lines into readable chunks.
# moduleCoreLoaded (projectLib.ps1) must be loaded.
if (-not $global:moduleCoreLoaded) {
    # Project Parameters
    $inArgs = $args
    # Get-Parameters
    $path = "$($(get-item $PSScriptRoot).FullName)\Get-ParametersLib.ps1"
    . $path
    # Project settings and paths
    # projectLib.ps1
    $path = "$($(get-item $PSScriptRoot).FullName)\ProjectLib.ps1"
    . $path @global:combinedParams
}
try {
    $outputDisplayed = $false
    if (-not $global:CodeActionContent) { $global:CodeActionContent = @() }
    if (-not $global:CodeActionLogFile) { $global:CodeActionLogFile = "$($(get-item $PSScriptRoot).Parent.FullName)\log\NoLogFile.txt" }
    $output = Get-Content -Path $global:CodeActionLogFile -Raw -ErrorAction Stop
    $global:CodeActionContent += $output
    # Remove-Item -Path $global:CodeActionLogFile
    # $directoryPath = [System.IO.Path]::GetDirectoryName($global:CodeActionLogFile)
    # $fileNameExtension = [System.IO.Path]::GetExtension($global:CodeActionLogFile)
    # $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($global:CodeActionLogFile)
    # $currentDate = Get-Date -Format 'yyyyMMdd_HHmmss'
    # $destination = Join-Path -Path $directoryPath -ChildPath "$($fileNameWithoutExtension)_$currentDate$fileNameExtension"
    # Copy-Item -Path $global:CodeActionLogFile -Destination $destination -ErrorAction SilentlyContinue
    # Rename-Item -Path $global:CodeActionLogFile -NewName $destination -ErrorAction SilentlyContinue
} catch {
    # Don't overwrite existing error information
    if ($_ -and -not $global:CodeActionError) {
        # File System access or no output was created.
        # Some Expected.
        $global:CodeActionError = $true
        $global:CodeActionErrorMessage += "Could-Fail: Caught error processing output file $global:CodeActionLogFile. "
        $global:CodeActionErrorInfo += $_
        $global:CodeActionErrorInfo += @{
            Message = $global:CodeActionErrorMessage
            Error   = $CodeActionErrorData
        }
        if (-not $global:CodeActionContent) {
            $global:CodeActionContent = $_.ToString()
        }
        # Optionally, you can output the error message
        # Add-LogText -Message "An error occurred: $($_.Exception.Message)"
    }
}
$messageForegroundColor = [System.ConsoleColor]::Yellow
$messageBackgroundColor = [System.ConsoleColor]::Black
if ($Verbose -or $DoVerbose) { 
    if ($global:CodeActionContent) {
        foreach ($line in $global:CodeActionContent) {
            try {
                if ($line) {
                    $outputDisplayed = $true
                    Add-LogText -Message $($line.ToString().Trim()) `
                        -ForegroundColor $messageForegroundColor -BackgroundColor $messageBackgroundColor `
                        -logFileNameFull $global:CodeActionLogFile
                }
            } catch { $null }
        }
        # $global:CodeActionContent = @() # Clear output
    }
}
# Exception & Error Handling.
if ($_ -and -not $global:CodeActionErrorInfo) { $global:CodeActionErrorInfo = $_ }
# System captured error content last.
if ($global:CodeActionErrorInfo) {
    if ($global:CodeActionError) {
        $messageForegroundColor = [System.ConsoleColor]::Red
        $messageBackgroundColor = [System.ConsoleColor]::Black
    } else {
        $messageForegroundColor = [System.ConsoleColor]::Yellow
        $messageBackgroundColor = [System.ConsoleColor]::Black
    }
    foreach ($errorItem in $global:CodeActionErrorInfo) {
        # Reformat long lines.
        $outputDisplayed = $true
        # if ($errorItem.Error -is [System.Management.Automation.RuntimeException]) {
        #     # More details
        #     $global:CodeActionContent += $errorItem.Error.ErrorDetails.ToString()
        # }
        $Message = "______________________________________________"
        $global:CodeActionContent += $Message
        Add-LogText -Message $Message `
            -ForegroundColor Yellow -BackgroundColor $messageBackgroundColor `
            -logFileNameFull $global:CodeActionLogFile
        # $Message (function)
        if ($errorItem.Message) {
            $output = $errorItem.Message
            $tmp = $output -replace '\. ', ". $global:NL" # Periods
            $tmp1 = $tmp -replace '\! ', "! $global:NL" # Exclamation points
            $output = $tmp1 -replace '\, ', ", $global:NL" # Commas
            $global:CodeActionErrorText = $output.TrimEnd("`n", "`r") # covers $global:NL chars across OSs
            $global:CodeActionContent += $global:CodeActionErrorText
            if ($global:CodeActionError -or $Verbose -or $DoVerbose) {
                foreach ($line in $global:CodeActionErrorText) {
                    try {
                        Add-LogText -Message $($line.ToString().Trim()) `
                            -ForegroundColor $messageForegroundColor -BackgroundColor $messageBackgroundColor `
                            -logFileNameFull $global:CodeActionLogFile
                    } catch { $null }
                }
            }
        }
        # Exception $_ String
        if ($errorItem.Error) {
            $output = $errorItem.Error.ToString()
            $tmp = $output -replace '\. ', ". $global:NL" # Periods
            $tmp1 = $tmp -replace '\! ', "! $global:NL" # Exclamation points
            $output = $tmp1 -replace '\, ', ", $global:NL" # Commas
            $global:CodeActionErrorText = $output.TrimEnd("`n", "`r") # covers $global:NL chars across OSs
            $global:CodeActionContent += $global:CodeActionErrorText
            if ($global:CodeActionError -or $Verbose -or $DoVerbose) {
                foreach ($line in $global:CodeActionErrorText) {
                    try {
                        Add-LogText -Message $($line.ToString().Trim()) `
                            -ForegroundColor $messageForegroundColor -BackgroundColor $messageBackgroundColor `
                            -logFileNameFull $global:CodeActionLogFile
                    } catch { $null }
                }
            }
        }
        if ($UseTraceStack) {
            if ($global:CodeActionError -and $errorItem.Error -and $errorItem.Error.ScriptStackTrace) {
                $global:CodeActionErrorText = $errorItem.Error.ScriptStackTrace
                $global:CodeActionContent += $global:CodeActionErrorText
                foreach ($line in $global:CodeActionErrorText) {
                    try {
                        Add-LogText -Message $($line.ToString().Trim()) `
                            -ForegroundColor Yellow -BackgroundColor Black `
                            -logFileNameFull $global:CodeActionLogFile
                    } catch { $null }
                }
            }
        }
    }
    $messageForegroundColor = [System.ConsoleColor]::White
    $messageBackgroundColor = [System.ConsoleColor]::Black
    Add-LogText -Message "" `
        -ForegroundColor $messageForegroundColor -BackgroundColor $messageBackgroundColor `
        -logFileNameFull $global:CodeActionLogFile
}
$global:CodeActionContent = @() # Clear output
