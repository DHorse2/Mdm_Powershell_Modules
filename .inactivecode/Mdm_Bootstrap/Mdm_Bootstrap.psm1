# Mdm_Bootstrap
#
# Set registry, Path and load Powershell modules
#
# . $PSScriptRoot\Add-RegistryPath.ps1
# . $PSScriptRoot\Set-ScriptSecElevated.ps1
# . $PSScriptRoot\Initialize-Dev_Env_Win.ps1
#
# Export-ModuleMember -Function Add-RegistryPath, Build-ModuleExports, Set-ScriptSecElevated, Initialize-Dev_Env_Win
#
#############################
# Build-ModuleExports
function Build-ModuleExports () {
<#
.SYNOPSIS
    Imports modules automatically.
.DESCRIPTION
    This imports modules and export the functions recursively.
.EXAMPLE
    Build-ModuleExports
.NOTES
    This would be present in an empty PSM1 file where each Cmdlet is in a separate PS1 file.
    Todo Build-ModuleExports had errors. 
    These function types only appear to work with C# (.net) code and not scripts.
.OUTPUTS
    Todo Build-ModuleExports Should output a success or failure.
#>
    #Get public and private function definition files.
    $Flat = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )
    $Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
    # -ErrorAction Break
    Write-Host "Loading..."
    #Dot source the files
    Foreach ($import in @($Public + $Private + $Flat)) {
        # Foreach ($import in @($Flat)) {
        Try {
            Write-Host -Message "Component: $($import.name)" -NoNewline
            # Bring function/cmdlet into scope
            . $import.FullName

            # Export Public and Root functions
            # Export-ModuleMember -Function $import.FullName
            if ($import.FullName.IndexOf("Private") -lt 0) {
                Export-ModuleMember $import.BaseName
                Write-Host -Message " Exported."
            }
        }
        Catch {
            Write-Host " "
            Write-Host -Message "Failed to import function!" -f Red
            Write-Host "$($import.FullName)"
            Write-Host -Message "$_"
        }
        Write-Host " "
    }

    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only
    # Export-ModuleMember -Function $Public.Basename
    # Export-ModuleMember -Function * -Alias * -Cmdlet *
    Write-Host "Ready."
}
# # Export-ModuleMember -Function localBuildModuleExports
# localBuildModuleExports
#
#############################
# Add-RegistryPath
#
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
    Add to HKLM Environtment Path
.DESCRIPTION
    This loads the specifiect Path key (PATH by default) and adds the new path to it.
.PARAMETER envPathToUpdate
    The Path key to use.
.PARAMETER scriptPath
    The Path to add to the envPath
.EXAMPLE
    Add-RegistryPath "PATH" "c:\SOMEWHERER"
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
        Write-Host "$envPathToUpdate is null in Env..."
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
#
#############################
# Set-ScriptSecElevated
#
# Function Set-ScriptSecElevated ([string]$message) {
Function Set-ScriptSecElevated {
<#
.SYNOPSIS
    Elevate script to Administrator.
.DESCRIPTION
    Get the security principal for the Administrator role.
    Check to see if we are currently running "as Administrator",
    Create a new process object that starts PowerShell,
    Indicate that the process should be elevated ("runas"),
    Start the new process.
.PARAMETER message
    Message to display when elevating.
.EXAMPLE
    Set-ScriptSecElevated "Elevating myself."
.NOTES
    This works but I think there are problems depending on the shell type.
    ISE for example.
.OUTPUTS
    None. Returns or Executes current script in an elevated process.
#>
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
#
#############################
#
# Initialize-Dev_Env_Win
# 
# Sets up registry, Powershell common modules and Path
# Copies script folders to the Powershell Modules directory.
#
# "g:\Script\Powershell\src\Mdm_Modules\Mdm_Bootstrap\Initialize-Dev_Env_Win.ps1"
#
# function Initialize-Dev_Env_Win ([switch]$UpdatePath, [switch]$SilentMode) {
function Initialize-Dev_Env_Win {
<#
.SYNOPSIS
    Setup Windows for the Development Environment.
.DESCRIPTION
    This updates the Windows Environment variables.
    It installs these powershell modules to the system's directories.
    $source = "$scriptPath\"
    $destination = "$Env:ProgramFiles\WindowsPowerShell\Modules"
.PARAMETER UpdatePath
    A switch to indicate the path should be checked/updated.
.PARAMETER SilentMode
    Suppress output and prompts.
.EXAMPLE
    Initialize-Dev_Env_Win -SilentMode -UpdatePath
.NOTES
    There are three locations for Powershell Modules.
    However this can be referenced using a number of different ways.
    This script install to the %ProgramFiles% Module directory.
    
    Drive and Path:
    NOTE on script location: 
    This script is found and run in the "Mdm_Bootstrap" module of "Modules"
    So the parent directory is the Root Root of this Project's Modules
    $scriptPath = Split-Path -Path "$PSScriptRoot" -Parent
    .\src\Mdm_Modules\Mdm_Bootstrap
    $scriptPath = (get-item $PSScriptRoot ).parent.FullName
    
    Source:
    $source = "$scriptPath\"
    $destination = "$Env:ProgramFiles\WindowsPowerShell\Modules"
    Destination:
    This user (CurrentUser);
    $destination = "$Home\Documents\PowerShell\Modules"
    $destination = "C:\Users\%username%\Documents\WindowsPowerShell\Modules"
    
    All computer users (-Scope AllUsers);
    $destination = "C:\%ProgramFiles%\WindowsPowerShell\Modules"
    $destination = "C:\Program Files\WindowsPowerShell\Modules"
    
    Default folder for built-in modules:
    $destination = "C:\Windows\system32\WindowsPowerShell\v1.0\Modules"
    $destination = "$PSHOME\Modules"
    
    Unknown
    Copy-Item -Path ".\Modules\*.*" -Destination "$PSHOME\Modules" -Force

    NOTE: Must be directories to invoke directory creation
    NOTE: New-Item doesn't work in priveledged directories
    New-Item -ItemType File -Path $destination -Force

    There should be not requirement to update the path
    assuming you install to a powershell directory.
.OUTPUTS
    .
#>
    # [CmdletBinding()]
    param (
        [switch]$UpdatePath,
        [switch]$SilentMode
    )
    # begin {}
    # process {
    
    # INIT
    # Set-ExecutionPolicy Unrestricted
    if (-not $SilentMode) {
        Write-Host "Initialize-Dev_Env_Win"
        Write-Host "Script Security Check and Elevate" 
    }
    Set-ScriptSecElevated
    
    # CONTINUE

    $scriptPath = (get-item $PSScriptRoot ).parent.FullName
    $scriptDrive = Split-Path -Path "$scriptPath" -Qualifier
    Set-Location $scriptDrive
    Set-Location -Path "$scriptPath"
    # Source:
    $source = "$scriptPath\"
    $destination = "$Env:ProgramFiles\WindowsPowerShell\Modules"    
    # #####################
    if (-not $SilentMode) { 
        Write-Host "######################"
        Write-Host  "Copying Powershell modules to ProgramFiles Powershell modules directory..."
        Write-Host  "$scriptPath Install to the module library."
        Write-Host " "
        Write-Host -NoNewLine "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")        
    }
    # 
    $envPathToUpdate = "PSModulePath"
    if (UpdatePath) { 
        if (-not $SilentMode) { 
            Write-Host "######################"
            Write-Host "Updating registry environment path $envPathToUpdate..."
        }
        Add-RegistryPath ($envPathToUpdate) 
    }
    else { if (-not $SilentMode) { Write-Host "Registry skipped." } }
    
    if (-not $SilentMode) {
        Write-Host "######################" 
        Write-Host "Installing Development Powershell Library..."
        Write-Host "To: $destination"
    }
    
    Copy-Item -Path $source -Destination $destination -Force -Recurse -PassThru | if (-not $SilentMode) { ForEach-Object { Write-Host $_.FullName } }
    if (-not $SilentMode) { 
        Write-Host " "
        Write-Host -NoNewLine "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
    
        Write-Host "######################"
        Write-Host "Results:"
        Write-Host "User Profile:"
        # Get-ChildItem -Path "$env:USERPROFILE\Documents\PowerShell\Modules" 
        $env:userprofile
        Write-Host " "
        # Write-Host -NoNewLine "Press any key to continue..."
        # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
        Write-Host "######################"
        Write-Host "Powershell Modules:"
        # $moduleList = Get-ChildItem -Path "$PSHOME\Modules"
        $moduleList = Get-ChildItem -Path $destination
        $moduleList | Format-Wide -Column 3
        foreach ($file in $moduleList) {
            #     Write-Host $file.Name -NoNewline
            #     Write-Host "        " -NoNewline
            # }
            # Write-Host " "
            Write-Host "Done "
        }
    }
    # }
}
# Export-ModuleMember -Function Initialize-Dev_Env_Win
# Initialize-Dev_Env_Win
#
#############################
#
Export-ModuleMember -Function Build-ModuleExports, Set-ScriptSecElevated, Initialize-Dev_Env_Win
