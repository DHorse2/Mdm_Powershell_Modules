# Assert-ScriptSecElevated

function Assert-ScriptSecElevated() {
    # Self-elevate the script if required
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        return $false
        # if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        #     $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        #     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        #     Exit
        # }
    } else { return $true}
}
######################
