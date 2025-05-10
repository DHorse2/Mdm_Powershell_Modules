
function Close-WFForm {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $form
    )

    begin {
        [Collections.ArrayList]$forms = @()
    }
    process {
        [void]$forms.Add($_)
    }
    end {
        # $inputObjects | ForEach-Object -Parallel {
            $inputObjects | ForEach-Object {
                # Show the form
            $_.Close() | Out-Null      
        }
    }
}
