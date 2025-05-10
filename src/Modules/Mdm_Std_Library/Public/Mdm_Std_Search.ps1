
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
            Write-Output "Found: $($item.FullName)"
            return $CurrentPath
        }
    }
    Write-Output "File '$FileName' not found in the directory $StartPath to depth $MaxDepth."
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
            Write-Output "Found: $filePath"
            return $filePath
        }

        # Move up to the parent directory
        $currentPath = [System.IO.Directory]::GetParent($currentPath).FullName
        $Depth++
    }

    Write-Output "File '$FileName' not found in the directory $StartPath to depth $MaxDepth."
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
        Write-Output "File '$FileName' not found in the directory $StartPath to depth $MaxDepth."
        if (-not $CurrentPath) { Write-Output "$currentPath is null." }
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
            Write-Output "File '$FileName' not found in the directory '$startPath' within depth up ($MaxDepthUp) and inward ($MaxDepthIn)."
            return $null
        }
        return $CurrentPath
    }
}