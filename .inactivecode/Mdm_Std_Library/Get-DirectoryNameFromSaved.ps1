# Get-DirectoryNameFromSaved

function Get-DirectoryNameFromSaved($dirWdPassed) {
    # don't alter the Saved Working Directory
    # when setting to a passed Working Directory
    if ($null -ne $dirWdPassed) { $dirWdTemp = $dirWdPassed } else { $dirWdTemp = $Global:dirWdSaved }
    if ($null -eq $dirWdTemp) { $dirWdTemp = $PWD.Path }
    
    if ($null -ne $Global:dirWdTemp && $Global:dirWdTemp -ne $PWD.Path) {
        Write-Host "Working directory: $($PWD.Path) set to $Global:dirWdTemp."
        $Global:dirWdTemp | Set-Location
    }
}