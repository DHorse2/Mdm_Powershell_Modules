
#region Path and directory
function Get-SavedDirectoryName {
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
        Does a Set-Location to this directory. Returns it as a string.
    .EXAMPLE
        Get-SavedDirectoryName
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
    # Get-SavedDirectoryName
    # don't alter the Saved Working Directory
    # when setting to a passed Working Directory
    if ($null -ne $dirWdPassed) { $dirWdTemp = $dirWdPassed } 
    else {
        $dirWdTemp = $global:dirWdSaved 
    }
    if ($null -eq $dirWdTemp) { $dirWdTemp = $PWD.Path }
    
    if ($null -ne $global:dirWdTemp -and $global:dirWdTemp -ne $PWD.Path) {
        Write-Debug "Working directory: $($PWD.Path) set to $global:dirWdTemp."
        $global:dirWdTemp | Set-Location
    }
    $dirWdTemp
}
function Set-SavedDirectoryName {
    <#
    .SYNOPSIS
        Save working directory.
    .DESCRIPTION
        Save working directory with a view to restoring it later.
        The default is to save the current directory.
    .PARAMETER dirWdPassed
        The Working Directory Name.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-SavedDirectoryName "C:\PathToSave"
#>


    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose,
        [Parameter(Mandatory = $false)]
        [string]$dirWdPassed
    )    # Set-SavedDirectoryName
    if ($null -ne $dirWdPassed) { 
        $global:dirWdSaved = $dirWdPassed 
    } else {
        # The default is to save the current directory.
        if ($null -eq $global:dirWdSaved -or $global:dirWdSaved -ne $PWD.Path) {
            $global:dirWdSaved = $PWD.Path
        }
    }
    Write-Debug "$global:dirWdSaved saved. "
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
        Get-FileNamesFromPath "C:\Programs places"
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
        Set the current directory.
    .DESCRIPTION
        Set the current working directory to the passed path.
    .PARAMETER workingDirectory
        The directory to set as the current working directory.
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
        [string]$workingDirectory,
        [switch]$saveDirectory
    )
    # TODO validate the passed workingDirectory

    # Profile working directory (PWD)
    # Note: This shouldn't fail; if it did, it would indicate a
    # serious system-wide problem.
    if ($saveDirectory -and $global:dirWdSaved -ne $PWD.Path) {
        Set-SavedDirectoryName($PWD.Path)
    }
    if ($PWD -ne $workingDirectory) {
        Set-Location -ErrorAction Stop -LiteralPath $workingDirectory
        Write-Debug "Working directory: $($PWD.Path)"
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
        $global:moduleRootPath = (get-item $PSScriptRoot).Parent.FullName,
        $scriptDrive = (Split-Path -Path "$global:moduleRootPath" -Qualifier)
    )
    
    # Drive and Path:
    # NOTE on script location: 
    # This script is found and run in the "Mdm_Bootstrap" module of "Modules"
    # So the parent directory is the Root Root of this Project's Modules
    # $global:moduleRootPath = Split-Path -Path "$PSScriptRoot" -Parent
    # .\src\Modules\Mdm_Modules\Mdm_Bootstrap
    # $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName
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
    /X :: report all extra files, not just those selected.
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
            # Does $source.count work? When?
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
function Get-LineFromFile {
    [CmdletBinding()]
    param (
        [string]$FileName,
        [int]$FileLineNumber,
        [string]$logFileNameFull = ""
    )
    # Check if the file exists
    if (-Not (Test-Path $FileName)) {
        $Message = "The script '$FileName' does not exist."
        Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        return
    }
    # Read the content of the script file
    $scriptContent = Get-Content -Path $FileName

    # Check if the line number is valid
    if ($FileLineNumber -lt 1 -or $FileLineNumber -gt $scriptContent.Count) {
        $Message = "Line number $FileLineNumber is out of range for the script '$FileName'."
        Add-LogText -Message $Message -IsError -SkipScriptLineDisplay -ErrorPSItem $_ -logFileNameFull $logFileNameFull
        return
    }

    # Display the specified line
    $lineText = $scriptContent[$FileLineNumber - 1]  # Adjust for zero-based index
    $results = "Line $FileLineNumber from '$FileName': $lineText"
    Write-Debug $results
    return $lineText
}
#endregion
#region Scope
function Resolve-Type {
    param (
        [string]$TypeName
    )

    # Initialize a variable to hold the result
    $typeFound = $false

    # Check all loaded assemblies for the specified type
    $types = [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        $_.GetTypes() | Where-Object { $_.Name -eq $TypeName }
    }

    # If the type is found, set the flag to true
    if ($types) {
        $typeFound = $true
        Add-LogText -Message "$TypeName type found."
    } else {
        Add-LogText -Message "$TypeName type not found."
    }

    # Return the result
    return $typeFound
}
function Get-VariableScoped {
    [CmdletBinding()]
    param (
        [string]$variableName,
        [string]$scope = "Global"
    )
    process {
        if ($variableName) {
            # Get the variable from the scope
            $variable = Get-Variable -Name $variableName -Scope $scope -ErrorAction SilentlyContinue
        } else {
            $variableName = "result for $scope"
            $variable = Get-Variable -Scope $scope -ErrorAction SilentlyContinue
        }
        
        if ($null -ne $variable) {
            return $variable.Value
        } else {
            Write-Warning -Message "Get-VariableScoped: Variable $variableName does not exist in the global scope."
            return $null
        }
    }
}
function Test-ResolveType {
    Example usage
    $typeToCheck = "WFWindow"
    $exists = Resolve-Type -TypeName $typeToCheck

    if ($exists) {
        Add-LogText -Message "You can proceed with using the $typeToCheck type."
    } else {
        Add-LogText -Message "The $typeToCheck type is not available."
    }
}
function Resolve-Variables {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$inputString,
        [string]$logFileNameFull = ""
    )
    # Use a regex to find all variable references in the string
    try {
        # Find all matches for variables in the input string
        # $resolvedString = $inputString -replace '\$([a-zA-Z_]\w*|$\$[^$]+\))', {
        if ($inputString -match '\$(\w+)' -or `
                $inputString -match '\$([a-zA-Z_]\w*|$\$[^$]+\))') {
            # Hold the resolved string
            $resolvedString = $inputString
            # Find all variable references
            i=0
            $matches = [regex]::Matches($inputString, '\$(\w+)')
            foreach ($match in $matches) {
                # Get the variable
                $varName = $match.Groups[1].Value
                Write-Debug "Variable: $varName"
                # Retrieve the value of the variable
                $varValue = (Get-Variable -Name $varName -ValueOnly -ErrorAction SilentlyContinue)
                Write-Debug "Variable value: $varValue"

                if ($null -ne $varValue) {
                    i++
                    # Replace the variable in the resolved string
                    $resolvedString = $resolvedString -replace [regex]::Escape($match.Value), $varValue
                } else {
                    $Message = "Resolve-Variables: $varName has a null value."
                    Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull
                }
            }
            Write-Debug "$i variables found."
            return $resolvedString
        } else {
            Write-Debug "No variables found."
            return $inputString
        }

    } catch {
        $Message = "Resolve-Variables encountered an error."
        Add-LogText -Message $Message -IsError -ErrorPSItem $_ -logFileNameFull $logFileNameFull   
    }
}
#endregion
# ShowData.psm1**
#region HTML
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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject,
        [Parameter(Mandatory = $true)]
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
        A basic function to show one or more objects.
    .DESCRIPTION
        This isn't being used. It might be useful for testing.
    .PARAMETER InputObject
        This is a ValueFromPipeline and can be used with one or more objects.
    .PARAMETER FileName
        The name of the file including its path.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        A list to the current output.
    .EXAMPLE
        Test-HtmlData $MyData -DoPause
    .LINK
        http://www.XXX
    .NOTES
        none.
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$InputObject,
        [Parameter(Mandatory = $false)]$fileName = ""
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
#endregion
#region Robocopy
function Get-RobocopyExitMessage {
    param ( 
        [int]$exitCode,
        [switch]$IsError
    )
    switch ($exitCode) {
        0 { if ($IsError) { return $false } else { return "No errors occurred, no files copied" } }
        1 { if ($IsError) { return $false } else { return "All files copied successfully" } }
        2 { if ($IsError) { return $false } else { return "Some files copied successfully" } }
        3 { if ($IsError) { return $false } else { return "Some files copied successfully, some skipped" } }
        5 { if ($IsError) { return $true } else { return "Access denied" } }
        6 { if ($IsError) { return $true } else { return "Source and destination are the same" } }
        7 { if ($IsError) { return $true } else { return "Destination path is invalid" } }
        8 { if ($IsError) { return $true } else { return "Some files or directories could not be copied" } }
        16 { if ($IsError) { return $true } else { return "Serious error occurred" } }
        default { if ($IsError) { return $true } else { return "An unknown error occurred. Exit code: $exitCode" } }
    }
}

#endregion