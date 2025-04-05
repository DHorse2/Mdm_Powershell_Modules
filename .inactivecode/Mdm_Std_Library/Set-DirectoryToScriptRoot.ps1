# Set-DirectoryToScriptRoot

function Set-DirectoryToScriptRoot ($passedWorkingDirectory) {
    # Save the current location and switch to this script's directory.
    # Profile working directory (PWD)
    # Note: This shouldn't fail; if it did, it would indicate a
    #       serious system-wide problem.
    if ($PWD -ne $PSScriptRoot) {
        if ($null -eq $Global:dirWdSaved || $Global:dirWdSaved -ne $PWD.Path) {
            # Write-Host "$($PWD.Path) saved. " -NoNewline
            # $Global:dirWdSaved = $PWD.Path
            Save-DirectoryName($PWD.Path)
        }
        Set-Location -ErrorAction Stop -LiteralPath $PSScriptRoot
        Write-Host "Working directory: $($PWD.Path)"
    }
}