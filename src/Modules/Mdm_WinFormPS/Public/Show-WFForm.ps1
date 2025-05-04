
function Show-WFForm {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $Forms
    )

    begin {
        [Collections.ArrayList]$Forms = @()
    }
    process {
        [void]$Forms.Add($_)
    }
    end {
        # $inputObjects | ForEach-Object -Parallel {
            $inputObjects | ForEach-Object {
                # Show the form
                $_.Show() | Out-Null      
                # $_.ShowDialog() | Out-Null      
        }
    }
}
