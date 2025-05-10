
function Show-WFForm {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.Windows.Forms.Form]$window
    )

    begin {
        [Collections.ArrayList]$windows = @()
    }
    process {
        [void]$windows.Add($_)
    }
    end {
        # $inputObjects | ForEach-Object -Parallel {
            $windows | ForEach-Object {
                # Show the form
                $_.Show() | Out-Null      
                # $_.ShowDialog() | Out-Null      
        }
    }
}
