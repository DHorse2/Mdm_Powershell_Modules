# Function Set-ScriptSecElevated ([string]$message) {
Function Set-ScriptSecElevated {
    [CmdletBinding()]
    param ([string]$message)
    # begin {}
    # process {
    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
            
    # Get the security principal for the Administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
            
    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        Write-Host 'We are running "as Administrator".'
        # $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
        $Host.UI.RawUI.WindowTitle = $Host.UI.RawUI.WindowTitle + " (Elevated)"
        $Host.UI.RawUI.BackgroundColor = "DarkGray"
        # clear-host
    }
    else {
        Write-Host 'We are not running "as Administrator" - relaunching as administrator.'
        Write-Host -NoNewLine "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
        # Create a new process object that starts PowerShell
        $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
            
        # Specify the current script path and name as a parameter
        $newProcess.Arguments = $myInvocation.MyCommand.Definition;
            
        # Indicate that the process should be elevated
        $newProcess.Verb = "runas";
            
        # Write-Host -NoNewLine "Press any key to continue..."
        # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess);
            
        # Exit from the current, unelevated, process
        exit

    }
    # end {}
    # clean {}
}