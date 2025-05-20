
function Show-WFForm {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Windows.Forms.Form]$window,
        [switch]$NotDialog
    )
    begin { [Collections.ArrayList]$windows = @() }
    process { [void]$windows.Add($window) }
    end {
        # $inputObjects | ForEach-Object -Parallel {
        $windows | ForEach-Object {
            # Show the form
            if ($NotDialog) {
                $_.Show() | Out-Null
                $dialogResult = [System.Windows.Forms.DialogResult]::OK
            } else {
                $dialogResult = $_.ShowDialog()
                #  | Out-Null
            }
        }
        return $dialogResult
    }
}
