# Initialize-Dev_Env_Win
# 
# Sets up registry, Powershell common modules and Path
# Copies script folders to the Powershell Modules directory.
#
# "g:\Script\Powershell\src\Mdm_Modules\Mdm_Bootstrap\Initialize-Dev_Env_Win.ps1"
#
# function Initialize-Dev_Env_Win ([switch]$UpdatePath, [switch]$SilentMode) {
function Initialize-Dev_Env_Win {
    [CmdletBinding()]
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
    # Notes:
    # There are three locations for Powershell Modules.
    # However this can be referenced using a number of different ways.
    # This script install to the %ProgramFiles% Module directory.

    # Drive and Path:
    # NOTE on script location: 
    # This script is found and run in the "Mdm_Bootstrap" module of "Modules"
    # So the parent directory is the Root Root of this Project's Modules
    # $scriptPath = Split-Path -Path "$PSScriptRoot" -Parent
    # .\src\Mdm_Modules\Mdm_Bootstrap
    $scriptPath = (get-item $PSScriptRoot ).parent.FullName
    $scriptDrive = Split-Path -Path "$scriptPath" -Qualifier
    Set-Location $scriptDrive
    # NOTE: Must be directories to invoke directory creation
    # NOTE: New-Item doesn't work in priveledged directories
    # New-Item -ItemType File -Path $destination -Force
    Set-Location -Path "$scriptPath"

    # #####################
    # Source:
    $source = "$scriptPath\"
    # Destination:
    # This user (CurrentUser);
    # $destination = "$Home\Documents\PowerShell\Modules"
    # $destination = "C:\Users\%username%\Documents\WindowsPowerShell\Modules"

    # All computer users (-Scope AllUsers);
    $destination = "$Env:ProgramFiles\WindowsPowerShell\Modules"
    # $destination = "C:\%ProgramFiles%\WindowsPowerShell\Modules"
    # $destination = "C:\Program Files\WindowsPowerShell\Modules"

    # Default folder for built-in modules:
    # $destination = "C:\Windows\system32\WindowsPowerShell\v1.0\Modules"
    # $destination = "$PSHOME\Modules"

    # Unknown
    # Copy-Item -Path ".\Modules\*.*" -Destination "$PSHOME\Modules" -Force

    # #####################

    if (-not $SilentMode) { 
        Write-Host "######################"
        Write-Host  "Copying Powershell modules to ProgramFiles Powershell modules directory..."
        Write-Host  "$scriptPath Install to the module library."
        Write-Host " "
        Write-Host -NoNewLine "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")        
    }
    # There should be not requirement to update the path
    # assuming you install to a powershell directory.
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
############################################
############################################
