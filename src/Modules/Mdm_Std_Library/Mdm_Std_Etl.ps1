
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
        [Parameter(Mandatory = $false)]
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
function Save-DirectoryName {
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
        Save-DirectoryName "C:\PathToSave"
#>

    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose,
        [Parameter(Mandatory = $false)]
        [string]$dirWdPassed
    )    # Save-DirectoryName
    if ($null -ne $dirWdPassed) { 
        $global:dirWdSaved = $dirWdPassed 
    }
    else {
        # The default is to save the current directoy.
        if ($null -eq $global:dirWdSaved -or $global:dirWdSaved -ne $PWD.Path) {
            $global:dirWdSaved = $PWD.Path
        }
    }
    Write-Verbose "$global:dirWdSaved saved. "
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
    # todo validate the passed workingDirectory

    # Profile working directory (PWD)
    # Note: This shouldn't fail; if it did, it would indicate a
    # serious system-wide problem.
    if ($saveDirectory -and $global:dirWdSaved -ne $PWD.Path) {
        Save-DirectoryName($PWD.Path)
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
    .PARAMETER scriptPath
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
        $global:scriptPath = (get-item $PSScriptRoot).parent.FullName,
        $scriptDrive = (Split-Path -Path "$global:scriptPath" -Qualifier)
    )
    
    # Drive and Path:
    # NOTE on script location: 
    # This script is found and run in the "Mdm_Bootstrap" module of "Modules"
    # So the parent directory is the Root Root of this Project's Modules
    # $global:scriptPath = Split-Path -Path "$PSScriptRoot" -Parent
    # .\src\Modules\Mdm_Modules\Mdm_Bootstrap
    # $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
    # $scriptDrive = Split-Path -Path "$global:scriptPath" -Qualifier
    Set-Location $scriptDrive
    # NOTE: Must be directories to invoke directory creation
    # NOTE: New-Item doesn't work in priveledged directories
    # New-Item -ItemType File -Path $destination -Force
    Set-Location -Path "$global:scriptPath"
    Get-Location    
}

# Text extraction
#############################
function ExtractText {
    param (
        [Parameter(Mandatory = $true)]
        $textIn
    )
    # Initialize description text
    $textOut = @()
    if ($textIn) {
        $textInType = $textIn.GetType().FullName
        # Output the structure of the detailed description for inspection
        # $textIn | Get-Member
        switch ( $textInType ) {
            "hashtable" {
                # Access the description property
                if ($textIn.ContainsKey('Text')) {
                    if ($textIn.text -is [System.Collections.IEnumerable] `
                            -and -not ($textIn.text -is [string])) {
                        # If the description is an array, join it into a single string
                        # $textOut = $textIn.text -join "`n"
                        $textOut += $textIn.text
                    }
                    else {
                        $textOut += $textIn.text
                    }
                }
            }
            "System.Object[]" {
                # Create the output string, including all properties and avoiding empty strings
                $textOut += ($textIn | ForEach-Object {
                        # Create a formatted string for each property
                        $formattedProperties = @()

                        # Loop through each property in the object
                        foreach ($property in $_.PSObject.Properties) {
                            if (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                                $formattedProperties += "$($property.Name): $($property.Value)"
                            }
                        }

                        # # Create a formatted string for each property
                        # $formattedProperties = $_.GetEnumerator() | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Value) } | 
                        # ForEach-Object { "$($_.Key): $($_.Value)" }

                        # Join the formatted properties with a comma and space
                        $formattedString = $formattedProperties -join ", "

                        # Return the formatted string
                        $formattedString
                    }
                ) # -join "`n"  # Join each object's output with a new line
            }            
            "System.Management.Automation.PSObject[]" {
                # If it's an array of PSObjects, join their 'text' properties
                # Create the output string, including all properties and avoiding empty strings
                $textOut += ($textIn | ForEach-Object {
                        # Create a formatted string for each property
                        $formattedProperties = @()

                        # Loop through each property in the object
                        foreach ($property in $_.PSObject.Properties) {
                            if (-not [string]::IsNullOrWhiteSpace($property.Value)) {
                                $formattedProperties += "$($property.Name): $($property.Value)"
                            }
                        }

                        # # Create a formatted string for each property
                        # $formattedProperties = $_.GetEnumerator() | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Value) } | 
                        # ForEach-Object { "$($_.Key): $($_.Value)" }
    
                        # Join the formatted properties with a comma and space
                        $formattedString = $formattedProperties -join ", "
    
                        # Return the formatted string
                        $formattedString
                    }
                ) # -join "`n"  # Join each object's output with a new line

                # $textIn | ForEach-Object { 
                #     if (-not [string]::IsNullOrWhiteSpace($_)) {
                #     $textOut += $_.Text + "`n"
                #     }
                # }

                # $textOut = ($textIn | ForEach-Object { 
                #     $_.name
                # } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join "`n"
                # $textOut = ($textIn | ForEach-Object { $textIn.text }) -join "`n"
                # $textOut = ($textIn | ForEach-Object { $textIn.text }) -join ", "

            }
            "System.Management.Automation.PSObject" {
                # Handle the case where $textIn is a single PSObject
                $properties = $textIn.PSObject.Properties
                $formattedProperties = @()

                foreach ($property in $properties) {
                    $formattedProperties += "$($property.Name): $($property.Value)"
                }

                $textOut += $formattedProperties -join "`n"  # Join with new line for better readability            
            }
            "System.Collections.IEnumerable" {
                # Access the Text property if it exists
                $textOut += ($textIn | ForEach-Object {
                        if ($textIn.PSObject.Properties['Text']) { $textInType.Text } 
                    }) -join "`n"

            }
            "System.Management.Automation.PSCustomObject" {
                # Create a formatted string of properties
                $properties = $textIn.PSObject.Properties
                # $formattedProperties = @()

                # foreach ($property in $properties) {
                #     $formattedProperties += "$($property.Name): $($property.Value)"
                # }
                # $textOut = $formattedProperties -join "`n"  # Join with new line for better readability
                $textOutExtra = @()
                foreach ($property in $properties) {
                    if ($property.Name -eq "Name") {
                        $textOut += "$($property.Name): $($property.Value)`n"
                    }
                    elseif ($propery.Name -eq "Text") {
                        $textOut += "$($property.Value)`n"
                    }
                    elseif ($propery.Name -eq "description") {
                        $textOut += "$($property.Name): $($property.Value)`n"
                    }
                    else {
                        $textOutExtra += "$($property.Name): $($property.Value)`n"
                    }
                }
                $textOut += $textOutExtra
            }
            "System.String" { 
                # If it's a string, just use it directly
                $textOut += $textIn            
            }
            default { 
                # Unknow object
                # todo throw warning
                $textOut += $textIn            
            }
        }
    }
    else { 
        $textOut += "No detailed description available."
    }
    $textOutType = $textOut.GetType()
    Write-Debug "Result: $textOut (type: $textOutType)"
    return $textOut
}
function PackTextArray {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [object[]]$InputObjects
    )
    # asked Jun 26, 2014 at 13:43 nlowe's
    BEGIN {
        $OutputObjects = New-Object System.Collections.ArrayList($null)
    }
    PROCESS {
        $OutputObjects.Add($_) | Out-Null
    }
    END {
        Write-Verbose "Passing off $($OutputObjects.Count) objects downstream" 
        # return ,$OutputObjects.ToArray()
        @(, $OutputObjects)
    }
}
# escape text
function EscapeText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $localLogFileNameFull = "",
        [switch]$keepWhitespace,
        [switch]$keepEscapes
    )
    # Initialize description text
    $textOut = $textIn
    if ($textOut) {
        $textInType = $textIn.GetType().FullName
        switch ( $textInType ) {
            # Create the output string, including all properties and avoiding empty strings
            "System.String" { 
                if (-not $keepWhitespace) { $textOut = $textOut.TrimEnd() }
                if (-not $keepEscapes) {
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
                    $textRow = EscapeText $textRow $localLogFileNameFull `
                        -keepEscapes:$keepEscapes `
                        -keepWhitespace:$keepWhitespace
                }
            }              
            default { 
                # Unknow object
                # todo throw warning
                $textOut += "Error. Cant handle type $textInType for $textIn"
                LogText $textOut
            }
        }       
    }
    return $textOut
}
function TrimText {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $textIn,
        $localLogFileNameFull = ""
    )
    return EscapeText $textIn $localLogFileNameFull -keepEscapes
}
# Logging
#############################
function LogText {
    # per https://stackoverflow.com/questions/24432190/generic-parameter-in-powershell
    # (todo: Inprogress. Implement pipelines)
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        $logMessages,
        $localLogFileNameFull = "",
        [switch]$keepWhitespace,
        [switch]$keepEscapes,
        [switch]$isError,
        [switch]$isWarning,
        $foregroundColor,
        $backgroundColor,
        $ErrorPSItem
    )
    process {
        # Log File
        if (-not $localLogFileNameFull) {
            # $localLogFileNameFull = Get-LogFileName
            $localLogFileNameFull = $global:logFileNameFull
        }
        # Check if folder not exists, and create it
        $logFilePath = Split-Path -Path $localLogFileNameFull
        if (-not(Test-Path $logFilePath -PathType Container)) {
            New-Item -path $logFilePath -ItemType Directory
        }
        # Check if file exists, and create it
        if (-not(Test-Path $localLogFileNameFull -PathType Leaf)) {
            New-Item -path $localLogFileNameFull -ItemType File
        }

        foreach ($logMessage in $logMessages) {
            # pre-process message (for html)
            # todo. Should the log be html also?
            $logMessage = EscapeText $logMessage -keepEscapes
            $logMessage | Out-File -FilePath $localLogFileNameFull –Append
            
            # Display message to user
            if ($isError -or $isWarning) {
                if ($isError) {
                    if ($global:UsePsTrace -and $ErrorPSItem) { 
                        LogError $logMessage `
                            -isError `
                            -ErrorPSItem $ErrorPSItem `
                            -localLogFileNameFull $localLogFileNameFull
                    }
                    else {
                        Write-Error -Message $logMessage
                    }
                }
                elseif ($isWarning) { 
                    if ($global:UsePsTrace -and $global:UsePsTraceWarning -and $ErrorPSItem) { 
                        LogError $logMessage `
                            -isWarning `
                            -ErrorPSItem $ErrorPSItem `
                            -localLogFileNameFull $localLogFileNameFull
                    }
                    else {
                        Write-Warning -Message $logMessage
                    }
                }
            }
            else { 
                if (-not $foregroundColor) { $foregroundColor = $global:messageForegroundColor }
                if (-not $backgroundColor) { $backgroundColor = $global:messageBackgroundColor }
                Write-Host $logMessage `
                    -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
            }

        }
    }
}
function LogError {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $true)]
        $logMessages,
        [Parameter(Mandatory = $true)]
        $ErrorPSItem,
        [switch]$isError,
        [switch]$isWarning,
        $localLogFileNameFull = "",
        $foregroundColor,
        $backgroundColor
    )
    process {
        if ($isError) { $errorType = "Error in " }
        elseif ($isWarning) { $errorType = "Warning in " }
        else { $errorType = "" }

        if (-not $foregroundColor) {
            if ($isError) { $foregroundColor = $opt.ErrorForegroundColor }
            elseif ($isWarning) { $foregroundColor = $opt.WarningForegroundColor }
            else { $foregroundColor = $global:messageForegroundColor }
        }
        if (-not $backgroundColor) {
            if ($isError) { $backgroundColor = $opt.ErrorBackgroundColor }
            elseif ($isWarning) { $backgroundColor = $opt.WarningBackgroundColor }
            else { $backgroundColor = $global:messageBackgroundColor }
        }
        $scriptNameFull = $ErrorPSItem.InvocationInfo.ScriptName
        $scriptName = Split-Path $scriptNameFull -leaf
        $line = $ErrorPSItem.InvocationInfo.ScriptLineNumber
        $column = $ErrorPSItem.InvocationInfo.OffsetInLine
        Write-Host "=============================================" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
        Write-Host "$($errorType)Script: $scriptName, line $line, column $column" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
        Write-Host "$($ErrorPSItem.CategoryInfo)" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
        Write-Host "$($ErrorPSItem.Exception.Message)" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
        Write-Host "Stack trace:" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
        Write-Host "$($ErrorPSItem.ScriptStackTrace)" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
        if ($ErrorPSItem.ErrorDetails) { 
            Write-Host "$($ErrorPSItem.ErrorDetails)" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
        }
        Write-Host "=============================================" -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor
    }
    # Set-PSDebug
    # [-Trace <Int32>]
    # [-Step]
    # [-Strict]
    # [<CommonParameters>]
    # [-Off]
    # 0: Turn script tracing off.
    # 1: Trace script lines as they run.
    # 2: Trace script lines, variable assignments, function calls, and scripts.
    # Set-PSDebug -Trace 1
}
function Get-LogFileName {
    [CmdletBinding()]
    param (
        $localLogFileNameFull = "",
        [switch]$LogOneFile
    )
    if ($localLogFileNameFull) { 
        $logFilePath = Split-Path -Path $localLogFileNameFull
        $logFileName = Split-Path $localLogFileNameFull -leaf
    }
    else {
        $logFilePath = $global:logFilePath
        $logFileName = $global:logFileName
        $LogOneFile = $global:LogOneFile
    }
    # Log folder
    if (-not $logFilePath) { $logFilePath = "$((get-item $PSScriptRoot ).FullName)\Log" }
    $logFilePath = Convert-Path $logFilePath
    # Check if folder not exists, and create it
    if (-not(Test-Path $logFilePath -PathType Container)) {
        New-Item -path $logFilePath -ItemType Directory
    }
    
    # Construct the full log file name
    if (-not $logFileName) { $logFileName = "Mdm_Installation_Log" }
    # $logFileNameFull = Join-Path -Path $logFilePath -ChildPath $logFileName
    $logFileNameFull = "$logFilePath\$logFileName"
    if (-not $LogOneFile) { $logFileNameFull = "$($logFileNameFull)_$global:timeStarted" }
    $logFileNameFull = "$logFileNameFull.txt"
        
    # Check if file exists, and create it
    if (-not(Test-Path $logFileNameFull -PathType Leaf)) {
        New-Item -path $logFileNameFull -ItemType File
    }
    # Write-Host "Returning: $logFileNameFull"
    # POWERSHELL ERROR. This cannot be return as a string.
    # Weird bug. It becomes duplicated in an array [0] [1]
    # Fix:
    $global:logFileNameFull = $logFileNameFull
    # return $logFileNameFull
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
function Test-HtmlData {
    # Sample testing script
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
    .LINK
        YYY
    .NOTES
        none.
#>
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true, ValueFromPipeline = $true)]$InputObject,
        [Parameter(mandatory = $false)]$FileName = ""
    )
    begin { }
    process { 
        # G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\Mdm_Module_Test
        if ($FileName.Length = = 0) {
            $global:scriptPath = (get-item $PSScriptRoot ).Parent.Parent.Parent.FullName 
        }
        # # G:\Script\Powershell\Mdm_Powershell_Modules
        $FileName = "$global:scriptPath\test\testShowData.txt"
        # # G:\Script\Powershell\Mdm_Powershell_Modules\test\testShowData.txt
        Get-TestHtmlData | Write-HtlmData -file $Filename 
    }
    end { }
}
# Search
# ###############################
function Search-Directory {
    <#
    .SYNOPSIS
        Search a folder for files or (todo) something else.
    .DESCRIPTION
        Currently just outputs the folder list to a CSV file.
    .PARAMETER inputObjects
        This is a ValueFromPipeline and can be used with one or more objects.
    .PARAMETER dir
        This defaults to "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules".
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
        $dir = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules",
        $folder = (Get-Item $dir).Parent,
        $folderName = $folder.Name,
        $folderPath = $folder.FullName    
    )

    begin {
        [Collections.ArrayList]$inputObjects = @()
    }
    process {
        [void]$inputObjects.Add($_)
    }
    end {
        $inputObjects | ForEach-Object -Parallel {
            Get-ChildItem $dir |
            >>     Select-Object Name, FullName, +
            >>         @{n = 'FolderName'; e = { $folderName } }, +
            >>         @{n = 'Folder'; e = { $folderPath } } |
            Export-Csv '.\output.csv' -Encoding UTF8 -NoType
        }
    }
}

