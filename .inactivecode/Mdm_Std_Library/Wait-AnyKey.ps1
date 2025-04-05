function Wait-AnyKey {
    param([string] $message)
    if ($Global:pauseDo) {
        # Check if running Powershell ISE
        if ($psISE) {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("$message")
        }
        else {
            Write-Host "$message" -ForegroundColor Yellow
            $null = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}


# Set-Variable -Name "Wait-AnyKeyKey" -Value {
#     param ($message)
#     Write-Host "$message" -ForegroundColor Yellow -NoNewLine
#     $null = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# } -Scope Global