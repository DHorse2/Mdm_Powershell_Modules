# Save-DirectoryName

function Save-DirectoryName($dirWdPassed) {

    if ($null -ne $dirWdPassed) { $Global:dirWdSaved = $dirWdPassed } else {
        if ($null -eq $Global:dirWdSaved || $Global:dirWdSaved -ne $PWD.Path) {
            $Global:dirWdSaved = $PWD.Path
        }
    }
    Write-Host "$Global:dirWdSaved saved. " -NoNewline
}