
# Path and directory
#############################
function Get-DirectoryNameFromSaved {
    <#
    .SYNOPSIS
        Get saved directory.
    .DESCRIPTION
        This allow you to store the directory where the command was issued
        and later restore that state.
        Don't alter the Saved Working Directory
        when setting to a passed Working Directory.
    .PARAMETER dirWdPassed
        An optional directory to use.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Does a Set-Location to this directory. Rhelpeturns it as a string.
    .EXAMPLE
        Get-DirectoryNameFromSaved
    .NOTES
        none.
#>


    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose,
        [Parameter(Mandatory = $false)]
        [string]$dirWdPassed
    )
    # Get-DirectoryNameFromSaved
    # don't alter the Saved Working Directory
    # when setting to a passed Working Directory
    if ($null -ne $dirWdPassed) { $dirWdTemp = $dirWdPassed } 
    else {
        $dirWdTemp = $global:dirWdSaved 
    }
    if ($null -eq $dirWdTemp) { $dirWdTemp = $PWD.Path }
    
    if ($null -ne $global:dirWdTemp -and $global:dirWdTemp -ne $PWD.Path) {
        Write-Verbose "Working directory: $($PWD.Path) set to $global:dirWdTemp."
        $global:dirWdTemp | Set-Location
    }
    $dirWdTemp
}
function Set-SavedToDirectoryName {
    <#
    .SYNOPSIS
        Save working directory.
    .DESCRIPTION
        Save working directory with a view to restoring it later.
        The default is to save the current directoy.
    .PARAMETER dirWdPassed
        The Working Directory Name.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-SavedToDirectoryName "C:\PathToSave"
#>


    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose,
        [Parameter(Mandatory = $false)]
        [string]$dirWdPassed
    )    # Set-SavedToDirectoryName
    if ($null -ne $dirWdPassed) { 
        $global:dirWdSaved = $dirWdPassed 
    } else {
        # The default is to save the current directoy.
        if ($null -eq $global:dirWdSaved -or $global:dirWdSaved -ne $PWD.Path) {
            $global:dirWdSaved = $PWD.Path
        }
    }
    Write-Verbose "$global:dirWdSaved saved. "
}
function Get-FileNamesFromPath {
    <#
    .SYNOPSIS
        Creates a list of files in a directory.
    .DESCRIPTION
        Creates a list of files in a directory.
    .PARAMETER SourcePath
        The folder to list the files of.
    .OUTPUTS
        A list of files.
    .EXAMPLE
        Get-FileNamesFromPath "C:\Progams places"
    .NOTES
        none.
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath
    )    
    $SourceFileNames = Get-ChildItem `
        -Path $SourcePath `
        -File `
    | ForEach-Object { $_.BaseName }
    # ForEach-Object $SourceFileNames {
        
    # }
    $SourceFileNames
}
function Get-UriFromPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    # Replace backslashes with forward slashes
    $convertedPath = $Path -replace '\\', '/'
    return $convertedPath
}
function Set-LocationToPath {
    <#
    .SYNOPSIS
        Set the currrent directory.
    .DESCRIPTION
        Set the currrent working directory to the passed path.
    .PARAMETER workingDirectory
        The direcotry to set as the current working directory.
    .PARAMETER saveDirectory
        Save the passed directory path.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-LocationToPath "C:\temp"
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$workingDirectory,
        [switch]$saveDirectory
    )
    # TODO validate the passed workingDirectory

    # Profile working directory (PWD)
    # Note: This shouldn't fail; if it did, it would indicate a
    # serious system-wide problem.
    if ($saveDirectory -and $global:dirWdSaved -ne $PWD.Path) {
        Set-SavedToDirectoryName($PWD.Path)
    }
    if ($PWD -ne $workingDirectory) {
        Set-Location -ErrorAction Stop -LiteralPath $workingDirectory
        Write-Verbose "Working directory: $($PWD.Path)"
    }
}
function Set-LocationToScriptRoot {
    <#
    .SYNOPSIS
        Set location to script root.
    .DESCRIPTION
        Set location to script root.
    .PARAMETER saveDirectory
        Switch: Save the current directory.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-LocationToScriptRoot -saveDirectory
#>


    [CmdletBinding()]
    param (
        [switch]$saveDirectory
    )
    Set-LocationToPath "$PSScriptRoot" -saveDirectory
}
function Set-DirectoryToScriptRoot {
    <#
    .SYNOPSIS
        Set directory to the script's root directory.
    .DESCRIPTION
        Set the working directory to the script's root directory..
    .PARAMETER moduleRootPath
        Optional path to use.
    .PARAMETER scriptDrive
        Optional drive letter.
    .EXAMPLE
        Set-DirectoryToScriptRoot
    .OUTPUTS
        none.
#>


    [CmdletBinding()]
    param (
        $global:moduleRootPath = (get-item $PSScriptRoot).parent.FullName,
        $scriptDrive = (Split-Path -Path "$global:moduleRootPath" -Qualifier)
    )
    
    # Drive and Path:
    # NOTE on script location: 
    # This script is found and run in the "Mdm_Bootstrap" module of "Modules"
    # So the parent directory is the Root Root of this Project's Modules
    # $global:moduleRootPath = Split-Path -Path "$PSScriptRoot" -Parent
    # .\src\Modules\Mdm_Modules\Mdm_Bootstrap
    # $global:moduleRootPath = (get-item $PSScriptRoot ).parent.FullName
    # $scriptDrive = Split-Path -Path "$global:moduleRootPath" -Qualifier
    Set-Location $scriptDrive
    # NOTE: Must be directories to invoke directory creation
    # NOTE: New-Item doesn't work in priveledged directories
    # New-Item -ItemType File -Path $destination -Force
    Set-Location -Path "$global:moduleRootPath"
    Get-Location    
}
function Copy-ItemWithProgressDisplay {
    <# 
    
    2025/03/26 09:11:03 ERROR 5 (0x00000005) Accessing Destination Directory C:\Program Files\WindowsPowerShell\Modules\
    Access is denied.
    Waiting 30 seconds... Retrying...

    ================================= Robocopy documentation:
    /V - verbose
    /MIRror = /E /PURGE (cleans out depreciated files (scripts))
    /MIRror folder contents
    /FP : Include Full Pathname of files in the output.
    /NS : No Size - don’t log file sizes.
    
    Other Robocopy options:
    /L :: List only - don't copy, timestamp or delete any files.
    /X :: report all eXtra files, not just those selected.
    /V :: produce Verbose output, showing skipped files.
    /TS :: include source file Time Stamps in the output.
    /FP :: include Full Pathname of files in the output.
    /BYTES :: Print sizes as bytes.
    
    /NS :: No Size - don't log file sizes.
    /NC :: No Class - don't log file classes.
    /NFL :: No File List - don't log file names.
    /NDL :: No Directory List - don't log directory names.
    
    /NP :: No Progress - don't display percentage copied.
    /ETA :: show Estimated Time of Arrival of copied files.
    
    /LOG:file :: output status to LOG file (overwrite existing log).
    /LOG+:file :: output status to LOG file (append to existing log).
#>


    [CmdletBinding()]
    param (
        $source,
        $destination
    )
    # ================================= Copy with progress %
    if (-not $source) { $source = Get-ChildItem c:\temp *.* }
    if (-not $destination) { $destination = "c:\temp" }
    $itemCount = 1
    $displayInterval = 99
    $copyTime = [System.Diagnostics.Stopwatch]::StartNew()
    $copyTimeLast = $copyTimeElapsed.Seconds
    $source | ForEach-Object {
        $displayInterval++
        if ($displayInterval -ge 10 -or ($copyTime.Seconds - $copyTimeLast) -ge 5) {
            $displayInterval = 0
            $copyTimeLast = $copyTime.Seconds
            [int]$percent = $itemCount / $source.count * 100
            Write-Progress `
                -Activity "Copying ... ($percent %) ($($copyTime.Elapsed) secs.)" `
                -status $_  -PercentComplete $percent -verbose
        }
        Copy-Item $_.fullName -Destination $destination 
        $itemCount++
    }
}
# Text extraction
#############################
function ConvertFrom-HashValue {
    [CmdletBinding()]
    param (
        $textIn,
        $textOut = @(),
        $textLineBreak = "`n"
    )
    process {
        $textOutExtra = @()
        # $textInType = $textIn.GetType()
        # Write-Verbose " "
        # Write-Verbose "TextIn Name: $($textIn.Name)"
        # Write-Verbose "TextIn Type: $($textInType)"
        # Write-Verbose "TextIn TypeNameOfValue: $($textIn.TypeNameOfValue)"
        # Write-Verbose "TextIn Value: $($textIn.Value)"
        foreach ($textItem in $textIn.PSObject.Properties) {
            # $textItem = $textItem.Key
            # Write-Verbose " "
            # Write-Verbose "Object Key: $($textItem.Name)"
            # Write-Verbose "Object Type: $($textItem.TypeNameOfValue)"
            # Write-Verbose "Object Value: $($textItem.Value)"
            if ($textItem.Name -eq "Name" -or $textItem.Name -eq "name") {
                $textOut += "$($textItem.Value)$textLineBreak"
            } elseif ($textItem.Name -eq "Text" -or $textItem.Name -eq "text") {
                $textOut += "$($textItem.Value)$textLineBreak"
            } elseif ($textItem.Name -eq "Description" -or $textItem.Name -eq "description") {
                $textInType = $textItem.Value.GetType().FullName
                if ($textInType -eq "System.String") { 
                    Write-Verbose "String"
                    # If it's a string, just use it directly
                    $textOut += "$($textItem.Name): $($textItem.Value)$textLineBreak"
                } else {
                    $textOut += "$($textItem.Name): $(ConvertTo-Text $textItem.Value)$textLineBreak"
                }
            } elseif ($textItem.Name -eq "Type" -or $textItem.Name -eq "type") {
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "syntaxItem") {
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "returnValue") {
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "parameter") {
                $textOut += ConvertTo-Text $textItem.Value
            } elseif ($textItem.Name -eq "textItem") {
                $textOut += ConvertTo-Text $textItem.Value
            } else {
                $textOutExtra += "$($textItem.Name): $($textItem.Value)$textLineBreak"
            }
        }
        # foreach ($textItem in $textOutExtra) {
        #     Write-Host "Item: $textItem, Type: $($textItem.GetType().Name)"
        # }
        # Write-Host "Contents of textOutExtra:"
        # $textOutExtra | ForEach-Object { Write-Host $_ }        
        # $textOutString = $textOutExtra -join ", "
        $textInType = $textOutExtra.GetType().Name
        [string]$textOutString = ""
        foreach ($textItem in $textOutExtra) {
            $textInType = $textItem.GetType().Name
            if ($textOutString.Length -ge 1) { $textOutString += ", " }
            [string]$textOutString += $textItem.Trim()
        }
        if ($textOutString.Length -ge 1) { $textOut += $textOutString }
        return $textOut
    }
}
function ConvertTo-Text {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $textIn
    )
    # Initialize description text
    $textOut = @()
    if ($textIn) {
        $textInType = $textIn.GetType().FullName
        $properties = $textIn.PSObject.Properties
        # Output the structure of the detailed description for inspection
        # $textIn | Get-Member
        switch ( $textInType ) {
            "hashtable" {
                Write-Verbose "hashtable"
                # Access the description property
                if ($textIn.ContainsKey('Text')) {
                    if ($textIn.text -is [System.Collections.IEnumerable] `
                            -and -not ($textIn.text -is [string])) {
                        # If the description is an array, join it into a single string
                        # $textOut = $textIn.text -join "`n"
                        $textOut += $textIn.text
                    } else {
                        $textOut += $textIn.text
                    }
                }
            }
            "System.Object[]" {
                Write-Verbose "Object[]"
                # Create the output string, including all properties and avoiding empty strings
                $formattedProperties = @()
                $textIn | ForEach-Object {
                    # Create a formatted string for each property
                    $tmp = $_.PSObject
                    Write-Verbose $tmp
                    # $formattedProperties += $_

                    # Loop through each property in the object
                    $properties = $_.PSObject.Properties
                    if ($properties) {
                        foreach ($property in $properties) {
                            if ($property -eq "parameter") {}
                            if (-not [string]::IsNullOrWhiteSpace($property.Name)) {
                                $formattedProperties += "$($property.Name): $($property.Value)"
                            } elseif (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                                $formattedProperties += "$($property.Value)"
                            } else {
                                $formattedProperties += "$property"
                            }
                        }
                    }

                    # # Create a formatted string for each property
                    # $formattedProperties = $_.GetEnumerator() | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Value) } | 
                    # ForEach-Object { "$($_.Key): $($_.Value)" }

                    # Join the formatted properties with a comma and space
                    # $formattedString = $formattedProperties -join ", "

                    # Return the formatted string
                    # $formattedString
                }
                $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }            
            "System.Management.Automation.PSObject[]" {
                Write-Verbose "PSObject[]"
                # If it's an array of PSObjects, join their 'text' properties
                # Create the output string, including all properties and avoiding empty strings
                $textIn | ForEach-Object {
                    ConvertTo-Text $_
                    # Create a formatted string for each property
                    # $formattedProperties = @()
                    # # Loop through each property in the object
                    # foreach ($property in $_.PSObject.Properties) {
                    #     if (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                    #         $formattedProperties += "$($property.Name): $($property.Value)"
                    #     }
                    # }
                    # Join the formatted properties with a comma and space
                }
                # $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }
            "System.Management.Automation.PSObject" {
                Write-Verbose "PSObject"
                # Handle the case where $textIn is a single PSObject
                $properties = $textIn.PSObject.Properties
                $formattedProperties = @()
                foreach ($property in $properties) {
                    $formattedProperties += "$($property.Name): $($property.Value)"
                }
                $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }
            "System.Collections.IEnumerable" {
                Write-Verbose "IEnumerable"
                # Access the Text property if it exists
                $textOut += ($textIn | ForEach-Object {
                        if ($textIn.PSObject.Properties['Text']) { $textInType.Text } 
                    }) -join "`n"
            }
            "System.Management.Automation.PSCustomObject" {
                Write-Verbose "PSCustomObject"
                # Create a formatted string of properties
                $properties = $textIn.PSObject.Properties
                $textOut += ConvertFrom-HashValue -textIn $textIn -textOut $textOut
            }
            "System.String" { 
                Write-Verbose "String"
                # If it's a string, just use it directly
                $textOut += $textIn            
            }
            default { 
                Write-Verbose "default: $textInType"
                # Unknow object
                # TODO throw warning
                $textOut += $textIn            
            }
        }
    } else { 
        $textOut += "No detailed description available."
        Write-Verbose $textOut
    }
    $textOutType = $textOut.GetType()
    Write-Verbose "Result: $textOut (type: $textOutType)"
    return $textOut
}
function Get-LineFromFile {
    [CmdletBinding()]
    param (
        [string]$FileName,
        [int]$FileLineNumber
    )
    # Check if the file exists
    if (-Not (Test-Path $FileName)) {
        $logMessage = "The script '$FileName' does not exist."
        Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -localLogFileNameFull $global:logFileNameFull
        return
    }
    # Read the content of the script file
    $scriptContent = Get-Content -Path $FileName

    # Check if the line number is valid
    if ($FileLineNumber -lt 1 -or $FileLineNumber -gt $scriptContent.Count) {
        $logMessage = "Line number $FileLineNumber is out of range for the script '$FileName'."
        Add-LogText -logMessages $logMessage -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -localLogFileNameFull $global:logFileNameFull
        return
    }

    # Display the specified line
    $lineText = $scriptContent[$FileLineNumber - 1]  # Adjust for zero-based index
    $results = "Line $FileLineNumber from '$FileName': $lineText"
    Write-Verbose $results
    return $lineText
}
function ConvertTo-ObjectArray {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [object[]]$InputObjects
    )
    # asked Jun 26, 2014 at 13:43 nlowe's
    begin {
        $OutputObjects = New-Object System.Collections.ArrayList($null)
    }
    process {
        $OutputObjects.Add($_) | Out-Null
    }
    end {
        Write-Verbose "Passing off $($OutputObjects.Count) objects downstream" 
        # return ,$OutputObjects.ToArray()
        @(, $OutputObjects)
    }
}
# escape text
function ConvertTo-EscapedText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $localLogFileNameFull = "",
        [switch]$KeepWhitespace,
        [switch]$KeepEscapes
    )
    process {
        # Initialize description text
        $textOut = $textIn
        if ($textOut) {
            $textInType = $textIn.GetType().FullName
            switch ( $textInType ) {
                # Create the output string, including all properties and avoiding empty strings
                "System.String" { 
                    if (-not $KeepWhitespace) { $textOut = $textOut.TrimEnd() }
                    if (-not $KeepEscapes) {
                        $textOut = $textOut `
                            -replace '&', '&amp;' `
                            -replace '<', '&lt;' `
                            -replace '>', '&gt;' `
                            -replace '"', '&quot;' `
                            -replace "'", '&apos;'    
                    }
                }
                "System.Object[]" {
                    # Recursive loop
                    foreach ($textRow in $textOut) {
                        <# $textRow is the current item #>
                        $textRow = ConvertTo-EscapedText $textRow $localLogFileNameFull `
                            -KeepEscapes:$KeepEscapes `
                            -KeepWhitespace:$KeepWhitespace
                    }
                }              
                default { 
                    # Unknow object
                    # TODO throw warning
                    $textOut += "Error. Cant handle type $textInType for $textIn"
                    Add-LogText $textOut
                }
            }       
        }
    }
    end {
        return $textOut
    }
}
function ConvertTo-TrimmedText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $localLogFileNameFull = ""
    )
    process { return ConvertTo-EscapedText $textIn $localLogFileNameFull -KeepEscapes }
}
# Logging
#############################
function Add-LogText {
    # per https://stackoverflow.com/questions/24432190/generic-parameter-in-powershell
    # (TODO: Inprogress. Implement pipelines)
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        $logMessages,
        [Parameter(Mandatory = $false)]
        [string]$localLogFileNameFull = "",
        [switch]$KeepWhitespace,
        [switch]$KeepEscapes,
        [switch]$IsError,
        [switch]$IsWarning,
        [switch]$DoTraceWarningDetails,
        [switch]$SkipScriptLineDisplay,
        [Parameter(Mandatory = $false)]
        $foregroundColor,
        [Parameter(Mandatory = $false)]
        $backgroundColor,
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorRecord]$ErrorPSItem
    )
    process {
        try {
            # if (-not $ErrorPSItem) { $ErrorPSItem = Get-PSCallStack }
            # Log File
            if (-not $localLogFileNameFull) { $localLogFileNameFull = $global:logFileNameFull }
            if ($localLogFileNameFull.Length -le 0) { $localLogFileNameFull = $global:logFileNameFull }
            # Check if folder not exists, and create it
            $logFilePath = Split-Path -Path $localLogFileNameFull
            if (-not(Test-Path $logFilePath -PathType Container)) {
                New-Item -path $logFilePath -ItemType Directory
            }
            # Check if file exists, and create it
            if (-not(Test-Path $localLogFileNameFull -PathType Leaf)) {
                New-Item -path $localLogFileNameFull -ItemType File
            }
        } catch {
            Write-Error "Add-LogText Log File preparation error. $_"
        }
        $logMessageIndex = -1
        foreach ($logMessage in $logMessages) {
            try {
                $logMessageIndex++
                # pre-process message (for html)
                # TODO. Should the log be html also?
                $logMessage = ConvertTo-EscapedText $logMessage -KeepEscapes
                # $logMessage | Out-File -FilePath $localLogFileNameFull –Append
            
                # Display message to user
                if ($IsError -or $IsWarning) {
                    if ($IsError) {
                        if ($global:UseTrace -and $ErrorPSItem) { 
                            Add-LogError $logMessage `
                                -IsError -ErrorPSItem $ErrorPSItem `
                                -DoTraceWarningDetails:$DoTraceWarningDetails `
                                -SkipScriptLineDisplay:$SkipScriptLineDisplay `
                                -localLogFileNameFull $localLogFileNameFull
                        } else {
                            Write-Error -Message $logMessage
                        }
                        $null = Debug-Script -DoPause 60 -functionName "Add-LogError pause for interupt" -localLogFileNameFull $localLogFileNameFull
                    } elseif ($IsWarning) { 
                        if ($global:UseTrace -and $global:UseTraceWarning -and $ErrorPSItem) { 
                            Add-LogError $logMessage `
                                -IsWarning -ErrorPSItem $ErrorPSItem `
                                -DoTraceWarningDetails:$DoTraceWarningDetails `
                                -SkipScriptLineDisplay:$SkipScriptLineDisplay `
                                -localLogFileNameFull $localLogFileNameFull
                        } else {
                            Write-Warning -Message $logMessage
                        }
                    }
                } else { 
                    if (-not $foregroundColor) { $foregroundColor = $global:messageForegroundColor }
                    if (-not $foregroundColor) { $foregroundColor = [System.ConsoleColor]::White }
                    if (-not $backgroundColor) { $backgroundColor = $global:messageBackgroundColor }
                    if (-not $backgroundColor) { $backgroundColor = [System.ConsoleColor]::Black }
                    Write-Host $logMessage `
                        -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                }
                # Write to storage
                $logMessage | Out-File -FilePath $localLogFileNameFull –Append
            } catch {
                Write-Error "Add-LogText LogMessage processing error at index $logMessageIndex. $_"
            }
        }
    }
}
function Add-LogError {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        $logMessage,
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorRecord]$ErrorPSItem,
        [switch]$IsError,
        [switch]$IsWarning,
        [switch]$SkipScriptLineDisplay,
        [switch]$DoTraceWarningDetails,
        [Parameter(Mandatory = $false)]
        $localLogFileNameFull = "",
        [Parameter(Mandatory = $false)]
        $foregroundColor,
        [Parameter(Mandatory = $false)]
        $backgroundColor
    )
    begin { [string]$newMessage = "" }
    process {
        #region Error Objects, debugger, Script and Location of error
        try {
            if (-not $DoTraceWarningDetails) { $DoTraceWarningDetails = $global:DoTraceWarningDetails }
            if ($ErrorPSItem) { 
                $global:lastError = $ErrorPSItem 
            } else { 
                $ErrorPSItem = Get-PSCallStack
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
            if (-not $foregroundColor) {
                if ($IsError) { $foregroundColor = $messageErrorForegroundColor }
                elseif ($IsWarning) { $foregroundColor = $messageWarningForegroundColor }
                else { $foregroundColor = $global:messageForegroundColor }
            }
            if (-not $backgroundColor) {
                if ($IsError) { $backgroundColor = $messageErrorBackgroundColor }
                elseif ($IsWarning) { $backgroundColor = $messageWarningBackgroundColor }
                else { $backgroundColor = $global:messageBackgroundColor }
            }
            if (-not $foregroundColor) { $foregroundColor = [System.ConsoleColor]::Yellow }
            if (-not $backgroundColor) { $backgroundColor = [System.ConsoleColor]::DarkBlue }
            #endregion
            #region Output
            # Category prefix
            if ($IsError) { $errorTypeText = "Error in " }
            elseif ($IsWarning) { $errorTypeText = "Warning in " }
            else { $errorTypeText = "" }
            # Determine how much detail to output.
            $traceDetails = $global:UseTraceDetails
            if ($IsWarning -and -not $DoTraceWarningDetails) {
                $traceDetails = $false
            }
            if ($traceDetails) {        
                $errorLine = "============================================="
                Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                $newMessage += $errorLine + "`n"
            }
            $errorLine = "$($errorTypeText)Script: $scriptName, line $line, column $column"
            if (-not $SkipScriptLineDisplay) {
                Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                $newMessage += $errorLine + "`n"
            }
            # Newlines are required after this line
            $newMessage += $errorLine
            #endregion
            #region Error Detail
            try {
                $errorLine = $logMessage
                Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                $newMessage += "`n" + $errorLine
                if ($traceDetails) {        
                    $errorLine = "Details: "
                    Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                    $newMessage += "`n" + $errorLine

                    $errorLine = "$($ErrorPSItem.Exception.Message)"
                    Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                    $newMessage += "`n" + $errorLine

                    $errorLine = "$($ErrorPSItem.CategoryInfo)"
                    Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                    $newMessage += "`n" + $errorLine

                    # Stack trace
                    if ($global:UseTraceStack) {
                        $newMessage += "`n"
                        Write-Host " "
                        $errorLine = "Stack trace: "
                        Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                        $newMessage += "`n" + $errorLine

                        $logMessageLine = Get-CallStackFormatted $ErrorPSItem.InvocationInfo "`n"
                        $errorLine = $logMessageLine.Trim()
                        Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                        $newMessage += "`n" + $errorLine

                        if ($ErrorPSItem.ScriptStackTrace) {
                            $newMessage += "`n"
                            Write-Host " "
                            $errorLine = "Script stack trace: "
                            Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                            $newMessage += "`n" + $errorLine

                            $errorLine = "$($ErrorPSItem.ScriptStackTrace)"
                            Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                            $newMessage += "`n" + $errorLine
                        }
                        # $errorLine = "$($ErrorPSItem.ScriptStackTrace)"
                        # Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                        # $newMessage += "`n" + $errorLine
                    }
                    # Additional details
                    if ($traceDetails -and $($ErrorPSItem.ErrorDetails)) { 
                        $newMessage += "`n"
                        Write-Host " "
                        $errorLine = "Additional details: "
                        Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                        $newMessage += "`n" + $errorLine

                        $errorLine = "$($ErrorPSItem.ErrorDetails)"
                        Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                        $newMessage += "`n" + $errorLine
                    }
                    $errorLine = "============================================="
                    Write-Host $errorLine -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
                    $newMessage += "`n" + $errorLine
                }
            } catch {
                Write-Error "Add-LogError ouput processing Trace Details error. $_"
            }
            #endregion
        } catch {
            Write-Error "Add-LogError output processing error. $_"
        }
    }
    end { return $newMessage }
}
function Open-LogFile {
    [CmdletBinding()]
    param (
        $localLogFileNameFull = "",
        [switch]$LogOneFile
    )
    process {
        if ($localLogFileNameFull) { 
            $logFilePath = Split-Path -Path $localLogFileNameFull
            $logFileName = Split-Path $localLogFileNameFull -leaf
        } else {
            $logFilePath = $global:logFilePath
            $logFileName = $global:logFileName
            $LogOneFile = $global:LogOneFile
        }
        # Log folder
        if (-not $logFilePath) { $logFilePath = "$global:projectRootPath\Log" }
        $logFilePath = Convert-Path $logFilePath
        # Check if folder not exists, and create it
        if (-not(Test-Path $logFilePath -PathType Container)) {
            New-Item -path $logFilePath -ItemType Directory
        }
    
        # Construct the full log file name
        if (-not $logFileName) { $logFileName = "Mdm_Installation_Log" }
        # $logFileNameFull = Join-Path -Path $logFilePath -ChildPath $logFileName
        $logFileNameFull = "$logFilePath\$logFileName"
        if (-not $LogOneFile) { $logFileNameFull = "$($logFileNameFull)_$global:timeStartedFormatted" }
        $logFileNameFull = "$logFileNameFull.txt"
        
        # Check if file exists, and create it
        if (-not(Test-Path $logFileNameFull -PathType Leaf)) {
            New-Item -path $logFileNameFull -ItemType File
        }
    }
    end {
        # Write-Host "Returning: $logFileNameFull"
        # POWERSHELL ERROR. This cannot be return as a string.
        # Weird bug. It becomes duplicated in an array [0] [1]
        # Fix:
        $global:logFileNameFull = $logFileNameFull
        # return $logFileNameFull
    }
}
# ShowData.psm1**
#############################
function Write-HtlmData {
    <#
    .SYNOPSIS
        Write-HtlmData.
    .DESCRIPTION
        Sends pipeline object to file.
    .OUTPUTS
        Html file.
    .EXAMPLE
        $YourPipeline | Write-HtlmData "Filename.txt"
#>


    [CmdletBinding()]
    param(
        [Parameter(mandatory = $true, ValueFromPipeline = $true)]
        $InputObject,
        [Parameter(mandatory = $true)]
        $FileName,
        $head = "<style></style>",
        $header = "<H1>Test Results</H1>",
        $title = "Test results"
    )
    # [Parameter (Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    # [Alias("Path", "FullName")]
    # [string]$File = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'converted.txt'

    # this is process block that is probably missing in your code
    begin { $objects = @() }
    process { $objects += $InputObject }
    end {
        $objects `
        | ConvertTo-HTML `
            -head $head `
            -body $header `
            -title $title `
        | Out-File $Filename
    }
}
function Get-TestHtmlData {
    1
    2
    3
    4
}
# Sample testing script
function Test-HtmlData {
    <#
    .SYNOPSIS
        A basic function to show one or more ojbects.
    .DESCRIPTION
        This isn't being used. It might be useful for testing.
    .PARAMETER InputObject
        This is a ValueFromPipeline and can be used with one or more objects.
    .PARAMETER FileName
        The name of the file inclulding its path.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        A list to the current ouput.
    .EXAMPLE
        Test-HtmlData $MyData -DoPause
    .LINK
        XXX: http://www.XXX
        TODO: Maybe
    .LINK
        YYY
    .NOTES
        none.
#>


    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true, ValueFromPipeline = $true)]$InputObject,
        [Parameter(mandatory = $false)]$fileName = ""
    )
    begin { }
    process { 
        # $global:projectRootPath\src\Modules\Mdm_Module_Test
        if (-not $global:projectRootPath) {
            $global:projectRootPath = (get-item $PSScriptRoot ).Parent.Parent.Parent.FullName 
        }
        if (-not $fileName) {
            $fileName = "$global:projectRootPath\test\testShowData.txt"
        }
        # # $global:projectRootPath\test\testShowData.txt
        Get-TestHtmlData | Write-HtlmData -file $filename 
    }
    end { }
}
# Search
# ###############################
function Search-Directory {
    <#
    .SYNOPSIS
        Search a folder for files or (TODO) something else.
    .DESCRIPTION
        Currently just outputs the folder list to a CSV file.
    .PARAMETER inputObjects
        This is a ValueFromPipeline and can be used with one or more objects.
    .PARAMETER dir
        This defaults to "$global:projectRootPath\src\Modules".
    .PARAMETER folder
        Defaults to (Get-Item $dir).Parent.
    .PARAMETER folderName
        Defaults to folder.Name.
    .PARAMETER folderPath
        Defaults to folder.FullName.
    .OUTPUTS
        Export-Csv '.\output.csv'.
    .EXAMPLE
        Search-Directory "G:\Script\Powershell\".
#>


    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]$inputObjects,
        $dir = "$global:projectRootPath\src\Modules",
        $folder = (Get-Item $dir).Parent,
        $folderName = $folder.Name,
        $folderPath = $folder.FullName    
    )
    begin { [Collections.ArrayList]$inputObjects = @() }
    process { [void]$inputObjects.Add($_) }
    end {
        $inputObjects | `
                ForEach-Object -Parallel {
                Get-ChildItem $dir | 
                    >> Select-Object Name, FullName, +
                    >>  @{n = 'FolderName'; e = { $folderName } }, +
                    >>  @{n = 'Folder'; e = { $folderPath } } | 
                        Export-Csv '.\output.csv' -Encoding UTF8 -NoType
                    }
    }
}
