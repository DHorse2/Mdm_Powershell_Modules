# Get-FileNamesFromPath

function Get-FileNamesFromPath ($SourcePath) {
    $SourceFileNames = Get-ChildItem -Path $SourcePath -File | ForEach-Object { $_.BaseName }
    # ForEach-Object $SourceFileNames {
        
    # }
    $SourceFileNames
}
