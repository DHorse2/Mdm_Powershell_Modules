
# ProjectRunSettings.ps1
# NOTE: You can activate any of these for debugging. IE Always on.
# This code occurs after Project and Parameter loading.
# $DoForce = $true
# $DoDebug = $true
# $DoVerbose = $true
# $DoPause = $true
# $global:app.DoForce = $DoForce
# $global:app.DoDebug = $DoDebug
# $global:app.DoVerbose = $DoVerbose
# $global:app.DoPause = $DoPause

# $global:moduleRootPath = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
# $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
# Source, destination and current folders
# $global:sourceDefault = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
# $global:destinationDefault = "C:\Program Files\WindowsPowerShell\Modules"

if ($DoDebug -or $DoVerbose) {
    Write-Host " " -ForegroundColor Blue
    Write-Host "Modules: $global:moduleRootPath" -ForegroundColor Blue
    Write-Host "Project: $global:projectRootPath" -ForegroundColor Blue
    Write-Host " Actual: $global:projectRootPathActual" -ForegroundColor Blue

    Write-Host " Source: $sourceDefault (Default)" -ForegroundColor Blue
    Write-Host "Destination: $destinationDefault (Default)" -ForegroundColor Blue

    Write-Host "  Debug: $DoDebug" -ForegroundColor Blue
    Write-Host "Verbose: $DoVerbose" -ForegroundColor Blue
    Write-Host "  Pause: $DoPause" -ForegroundColor Blue
    Write-Host "  Force: $DoForce" -ForegroundColor Blue
    Write-Host "  DebugPreference: $DebugPreference" -ForegroundColor Blue
    Write-Host "  VerbosePreference: $VerbosePreference" -ForegroundColor Blue
}
# if ($DoDebug) { $DebugPreference = "Continue" } 
# else { $DebugPreference = "SilentlyContinue" }
# if ($DoVerbose) { $VerbosePreference = "Continue" } 
# else { $VerbosePreference = "SilentlyContinue" }

if ($DoPause) {
    # possible location for prompt.
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