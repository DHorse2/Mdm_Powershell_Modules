
# Mdm_Std_Search
# Search
# ###############################
function Search-Directory {
    <#
    .SYNOPSIS
        TODO Search a folder for files or something else.
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
function Find-FileInDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [string]$CurrentPath = (Get-Location),
        [int]$CurrentDepth = 0,
        [int]$MaxDepth = [int]::MaxValue
    )

    # Check if the current depth exceeds the maximum depth
    if ($CurrentDepth -gt $MaxDepth) {
        return $null
    }

    # Get files and directories in the current path
    $items = Get-ChildItem -Path $CurrentPath -ErrorAction SilentlyContinue

    # Search for the file in the current directory
    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            # If it's a directory, recurse into it
            $CurrentPath = Find-FileInDirectory -CurrentPath $item.FullName -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
        } elseif ($item.Name -eq $FileName) {
            # If it's the file we're looking for, output the full path
            Write-Host "Found: $($item.FullName)"
            return $CurrentPath
        }
    }
    Write-Host "File '$FileName' not found in the directory $StartPath to depth $MaxDepth."
    return $null
}
function Search-FileUpDirectory {
    [CmdletBinding()]
    param (
        [string]$FileName,
        [string]$StartPath = (Get-Location),
        [int]$MaxDepth = 5
    )

    # Normalize the start path
    $currentPath = [System.IO.Path]::GetFullPath($StartPath)
    $Depth = 1
    while ($currentPath -ne [System.IO.Path]::GetPathRoot($currentPath) -and $Depth -le $MaxDepth) {
        # Check if the file exists in the current directory
        $filePath = Join-Path -Path $currentPath -ChildPath $FileName
        if (Test-Path -Path $filePath) {
            Write-Host "Found: $filePath"
            return $filePath
        }

        # Move up to the parent directory
        $currentPath = [System.IO.Directory]::GetParent($currentPath).FullName
        $Depth++
    }

    Write-Host "File '$FileName' not found in the directory $StartPath to depth $MaxDepth."
    return $null
}
function Search-FileInDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [string]$StartPath = (Get-Location),
        [int]$MaxDepth = 5
    )

    # Normalize the start path
    $startPath = [System.IO.Path]::GetFullPath($StartPath)
    # Internal function to perform the recursive search
    # Start the search from the initial path at depth 0
    $CurrentPath = Find-FileInDirectory -FileName $FileName -CurrentPath $startPath -CurrentDepth 0 -MaxDepth $MaxDepth

    # If no files were found, output a message
    if (-not $CurrentPath -or -not (Get-ChildItem -Path $startPath -Filter $FileName -Recurse -ErrorAction SilentlyContinue)) {
        Write-Host "File '$FileName' not found in the directory $StartPath to depth $MaxDepth."
        if (-not $CurrentPath) { Write-Host "$currentPath is null." }
        return $null
    }
    return $CurrentPath
}
function Find-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [string]$StartPath = (Get-Location),
        [int]$MaxDepthUp = 5,
        [int]$MaxDepthIn = 5
    )
    process {
        $CurrentPath = Search-FileUpDirectory -FileName $FileName -StartPath $StartPath -MaxDepth $MaxDepthUp
        if (-not $CurrentPath) { Search-FileInDirectory -FileName $FileName -StartPath $StartPath -MaxDepth -$MaxDepthIn }
        if (-not $CurrentPath) {
            Write-Host "File '$FileName' not found in the directory '$startPath' within depth up ($MaxDepthUp) and inward ($MaxDepthIn)."
            return $null
        }
        return $CurrentPath
    }
}
function Search-StringInFiles {
    <#
 This accepts a ";" delimited path like $env:PSModulePath, 
 a ";" separated list of file extensions (incl wildcards), 
 and a search string. 
 It recursively searches each directory for the search string.
 It displays the line and line number of each occurence within each file,
 and totoal occurence counts.
 #>
    param (
        [string]$Path,
        [string]$Extensions = "txt;ps1*;psm1;psd1;md;json;csv;xml*;html;css",
        [string]$FileNames = "*",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchString,
        [switch]$SkipLineDetail,
        [switch]$DoLog,
        [string]$resultFileNameFull,
        [string]$logFileNameFull = ""
    )
    begin {
        $outputBuffer = @()
        $Message = "Seaching for $SearchString"
        Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
        $outputBuffer += $Message
        if (-not $Path) { 
            $Path = $env:PSModulePath 
            $Message += " (Using default powershell path)"
            Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
        }
        $outputBuffer += $Message

        $Message = "  Extensions: $Extensions"
        Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
        $outputBuffer += $Message
        $pathContainsString = $false
        $count = 0
        $directories = $Path -split ';'
        $extensionArray = $Extensions -split ';'
        $fileNamesArray = $FileNames -split ";"
    }
    process {
        for ($directoryIndex = 0; $directoryIndex -lt $directories.Count; $directoryIndex++) {
            $directory = $directories[$directoryIndex]
            $directoryContainsString = $false
            $countDirectory = 0
            if (Test-Path $directory) {
                # $directoryName = Split-Path -Path $directory -Leaf
                $Message = "Folder [$directoryIndex] $directory"
                Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
                $outputBuffer += $Message
                # Get all files with the specified extensions recursively
                # Get all files recursively
                $files = Get-ChildItem -Path $directory -Recurse -File
                foreach ($file in $files) {
                    $fileName = Split-Path -Path $file -Leaf
                    # Check if the file extension matches any of the specified patterns
                    $fileExamined = $false
                    $fileContainsString = $false
                    $countFile = 0
                    foreach ($fileNameMatch in $fileNamesArray) {
                        if ($fileName -like $fileNameMatch) {
                            # Check if the file extension matches any of the specified patterns
                            foreach ($extension in $extensionArray) {
                                if ($file.Extension -like ".$extension") {
                                    $fileExamined = $true
                                    Write-Debug "Check: $($fileName)"
                                    # Read the file line by line
                                    $lines = Get-Content -Path $file.FullName
                                    for ($lineNumber = 0; $lineNumber -lt $lines.Count; $lineNumber++) {
                                        if ($lines[$lineNumber] -like "*$SearchString*") {
                                            $countFile++
                                            if (-not $fileContainsString) {
                                                # if (-not $SkipLineDetail) {
                                                #     Write-Host "  File: $($file.FullName)"
                                                # }
                                                $outputBuffer += $Message
                                                $fileContainsString = $true
                                                $directoryContainsString = $true
                                                $pathContainsString = $true
                                            }
                                            if (-not $SkipLineDetail) {
                                                $line = $lines[$lineNumber]
                                                # $Message = $line
                                                # Format Clickable link
                                                # Local link
                                                # $MessageLink = "$(Split-Path -Path $($frame.ScriptName) -Leaf):$($frame.ScriptLineNumber):"
                                                # Link using full name 
                                                $sliceLen = [Math]::Min(30, $line.Length)
                                                $Message = "$($line.Substring(0,$sliceLen)) :: Link: $($file):$($lineNumber):"
                                                # $Message = " $($file):$($lineNumber):"
                                                Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
                                                $outputBuffer += $Message

                                                # line number and the line content
                                                # Format 1
                                                # $Message = "    [Line $($lineNumber + 1)]: $($lines[$lineNumber])"
                                                # Format 2 Wide
                                                # $MessageLine = "Directory[$directoryIndex]: $($directoryName), File: $($fileName), line $($lineNumber)."
                                            }
                                        }
                                    }
                                    break # Exit the Extensions loop if a match is found
                                }
                                if (-not $SkipLineDetail -and $fileContainsString -and $countFile -ge 7) {
                                    # line number and the line content
                                    $Message = "        Found $countFile."
                                    Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
                                    $outputBuffer += $Message
                                }
                                $countDirectory += $countFile
                            }
                            # finished matching extension
                        }
                        # Exit the fileNameMatch loop if the file was examined
                        if ($fileExamined) { break }
                    }
                    # finshed matching file names
                    if ($fileContainsString) {
                        # The string was found in the file
                    } else {
                        # String missing from file
                    }
                }
                # finished looking in directory $directoryContainsString
                if ($directoryContainsString) {
                    # The string was found in the directory
                    if (-not $SkipLineDetail -and $countDirectory -gt 7) {
                        $Message = "  Found $countDirectory."
                        Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
                        $outputBuffer += $Message
                    }
                } else {
                    # String missing from directory
                }
            } else {
                $Message = "Directory not found [$directoryIndex] $directory"
                Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
                $outputBuffer += $Message
            }
            $count += $countDirectory
        }
        if (-not $SkipLineDetail -and $count -gt 7) {
            $Message = "Total count: $count."
            Add-LogText -ForegroundColor DarkYellow -Message $Message -logFileNameFull $logFileNameFull
            $outputBuffer += $Message
        }
    }
    end {
        # finshed matching file names
        if ($pathContainsString) {
            # The string was found
        } else {
            # String missing
        }
        if ($DoLog) {
            if (-not $resultFileNameFull) { $resultFileNameFull = ".\SearchResults.txt" }
            $outputBuffer | Out-File -FilePath $resultFileNameFull -Encoding utf8
        }
    }
    # Example usage:
    # Search-StringInFiles -Path $env:PSModulePath -Extensions "ps1;txt" -SearchString "your_search_string"
}
