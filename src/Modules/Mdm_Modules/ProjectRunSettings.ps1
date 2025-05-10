
# ProjectRunSettings.ps1
# $DoForce = $true
# $DoDebug = $true
# $DoVerbose = $true
# $DoPause = $true

# $global:DoForce = $DoForce
# $global:DoDebug = $DoDebug
# $global:DoVerbose = $DoVerbose
# $global:DoPause = $DoPause
$global:DoDebugPause = $false

# $global:moduleRootPath = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
# $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
Write-Debug " "
Write-Debug "Modules: $global:moduleRootPath"
Write-Debug "Project: $global:projectRootPath"
Write-Debug " Actual: $global:projectRootPathActual"

# Source, destination and current folders
# $sourceDefault = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
# $destinationDefault = "C:\Program Files\WindowsPowerShell\Modules"
Write-Debug " Source: $sourceDefault (Default)"
Write-Debug "Destination: $destinationDefault (Default)"

Write-Debug "  Debug: $DoDebug"
Write-Debug "Verbose: $DoVerbose"
Write-Debug "  Pause: $DoPause"
Write-Debug "  Pause: $DoForce"

if ($DoDebug -or $global:DoDebug) { $DebugPreference = "Continue" } 
else { $DebugPreference = "SilentlyContinue" }
if ($DoVerbose -or $global:DoVerbose) { $VerbosePreference = "Continue" } 
else { $VerbosePreference = "SilentlyContinue" }
if ($DoPause -or $global:DoPause) {
    #     # possible location for prompt.
    # Check if running PowerShell ISE
    if ($psISE) {
        $Message = 'Enter any key to continue: '
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$Message")
    } else {
        $Message = 'Enter any key to continue: '
        Write-Host -Message "$Message " -ForegroundColor Yellow -NoNewline
        # $null = $host.ui.RawUI.ReadKey("NoEcho, IncludeKeyUp")
        $null = [Console]::ReadKey()
        Write-Host " " -ForegroundColor White
    }
}