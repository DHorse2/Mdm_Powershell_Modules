
function Close-WFForm {
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
            $_.Close() | Out-Null      
        }
    }
}
