# Add-RegistryPath

# Environment variables
# Write-Host  "Check path for Library module:" -NoNewline
# Notes: There are two options
# The PSModulePath is what powershell uses and should work.
# Default:
#   %ProgramFiles%\WindowsPowerShell\Modules;
#   %SystemRoot%\system32\WindowsPowerShell\v1.0\Modules
# Alternatively you could use the system path (but indicates a problem)
# $envPathToUpdate = "PSModulePath"
# function Add-RegistryPath ([string]$envPathToUpdate) {
function Add-RegistryPath {
<#
.SYNOPSIS
    .
.DESCRIPTION
    .
.PARAMETER xxx
    .
.PARAMETER xxxx
    .
.EXAMPLE
    .
.NOTES
    .
.OUTPUTS
    .
#>
[CmdletBinding()]
    param ([string]$envPathToUpdate)
    # begin {}
    # process {
    Write-Host  "Check path for Library module:" -NoNewline
    if ($null -eq $envPathToUpdate) { $envPathToUpdate = "PATH" }
    [string] $oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name "$envPathToUpdate").path
    if ($null -eq $oldPath) {
        # Using the system PATH isn't best practices for powershell:
        # Default:
        Write-Host "PSModulePath is null in Env..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $envPathToUpdate = "PATH"
        $oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name "$envPathToUpdate").path
        Write-Host $oldPath
    }
    # Check if already updated
    $positionOfPath = $oldPath.IndexOf("$scriptPath")
    Write-Host " $positionOfPath" # -1 if missing

    # Back path up
    # $oldPath | Out-File -FilePath ".\$envPathToUpdate_$(Get-Date -Format 'yyyymmdd HH:mm K').bak"
    # $oldPath | Out-File -FilePath ".\$envPathToUpdate_$(Get-Date -UFormat '%Y%m%d%R%z').bak"
    # $oldPath | Out-File -FilePath ".\$envPathToUpdate_$(Get-Date).bak"
    # Set-Content -Path ".\$envPathToUpdate $(Get-Date).bak" -Value $oldPath
    # $oldPath | Out-File -FilePath ".\$envPathToUpdate $(Get-Date).bak"
    # $oldPath > ".\$envPathToUpdate $(Get-Date).bak"
    $now = Get-Date -UFormat '%Y%m%d%R%z'
    # $oldPath > ".\$envPathToUpdate $now.bak"
    # Set-Content -Path ".\$envPathToUpdate $now.bak" -Value $oldPath
    Out-File -FilePath "$PSScriptRoot\$envPathToUpdate $now.bak" -InputObject $oldPath
        
    # $oldPath
    $oldPathItems = $oldPath.replace(' ;', ';').replace('; ', ';').split(';')
    $oldPathItems = $oldPath -split ";"
    foreach ($oldPathItem in $oldPathItems) {
        Write-Host $oldPathItem
    }
        
    # Update Environment Path
    if ($positionOfPath -lt 0) {
        Write-Host "Updating path: $scriptPath"
        $newpath = "$scriptPath;$oldPath"
        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name "$envPathToUpdate" -Value $newpath
        # Write-Host -NoNewLine "Press any key to continue..."
        # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    else {
        Write-Host "Found path: $scriptPath"
    }
    # end {}
    # clean {}
}
