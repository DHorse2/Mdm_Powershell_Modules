# Set-LocationToPath

function Set-LocationToPath {
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
    if ($saveDirectory && ($null -eq $Global:dirWdSaved || $Global:dirWdSaved -ne $PWD.Path)) {
        Save-DirectoryName($PWD.Path)
    }
    if ($PWD -ne $workingDirectory) {
        Set-Location -ErrorAction Stop -LiteralPath $workingDirectory
        Write-Host "Working directory: $($PWD.Path)"
    }
}

function Set-LocationToScriptRoot {
    [CmdletBinding()]
    param (
        [switch]$saveDirectory
    )
    Set-LocationToPath "$PSScriptRoot" $saveDirectory
}