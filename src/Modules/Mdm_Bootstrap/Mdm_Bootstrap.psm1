
# Imports
# This works with uninstalled Modules (both)
$now = Get-Date -UFormat '%Y%m%d%R%z'
$importName = "Mdm_Std_Library"
if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Inquire

. "$global:scriptPath\Mdm_Bootstrap\DevEnv_Install_Modules_Win.ps1"
Export-ModuleMember -Function DevEnv_Install_Modules_Win

# function DevEnv_LanguageMode {
#     [CmdletBinding()]
#     param ()
#     process {
. "$global:scriptPath\Mdm_Bootstrap\DevEnv_LanguageMode.ps1"
#     }
# }
Export-ModuleMember -Function DevEnv_LanguageMode
# !!! TODO !!! this executes DevEnv_Module_Reset
function DevEnv_Module_Reset {
    [CmdletBinding()]
    param ()
    process {
        . "$global:scriptPath\Mdm_Bootstrap\DevEnv_Module_Reset.ps1"
    }
}
Export-ModuleMember -Function DevEnv_Module_Reset
# MAIN
function Initialize-Dev_Env_Win {
<#
    .SYNOPSIS
        Setup (bootstrap) Windows for the Development Environment.
    .DESCRIPTION
        This is the first step of bootstrapping the Development Environment.
        This updates the Windows Environment variables.
        It installs these powershell modules to the system's directories.
        Set registry, Path and load PowerShell modules.
        $source = "$global:scriptPath\"
        $destination = "$Env:ProgramFiles\WindowsPowerShell\Modules"
    .PARAMETER UpdatePath
        Switch: A switch to indicate the path should be checked/updated.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoPause
        Switch: Pause between steps.
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
        .\src\Mdm_Modules\Mdm_Bootstrap
        $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
        
        Source:
        $source = "$global:scriptPath\"
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
        TODO.
#>
    [CmdletBinding()]
    param (
        [switch]$UpdatePath,
        # TODO integrage stardard value (ie verbose)
        [switch]$DoPause,
        [switch]$DoVerbose
    )
    begin {
        # INIT
        # Set-ExecutionPolicy Unrestricted
        if ($DoVerbose) {
            Write-Verbose "Initialize-Dev_Env_Win"
            Write-Verbose "Script Security Check and Elevate" 
        }
        Set-SecElevated
    
        # CONTINUE
        if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
        $scriptDrive = Split-Path -Path "$global:scriptPath" -Qualifier
        Set-Location $scriptDrive
        Set-Location -Path "$global:scriptPath"
        # Source:
        $source = "$global:scriptPath\"
        $destination = "$Env:ProgramFiles\WindowsPowerShell\Modules"

        # #####################
        $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue
        if ($DoVerbose) { 
            Write-Verbose "######################"
            Write-Verbose  "Copying PowerShell modules to ProgramFiles PowerShell modules directory..."
            Write-Verbose  "$global:scriptPath Install to the module library."
            Write-Verbose " "
            Write-Verbose -NoNewLine "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")        
        }
        # 
        $envPathToUpdate = "PSModulePath"
        if ($UpdatePath) { 
            if ($DoVerbose) { 
                Write-Verbose "######################"
                Write-Verbose "Updating registry environment path $envPathToUpdate..."
            }
            Add-RegistryPath ($envPathToUpdate) 
        } else { if ($DoVerbose) { Write-Verbose "Registry skipped." } }
    
        if ($DoVerbose) {
            Write-Verbose "######################" 
            Write-Verbose "Installing Development PowerShell Library..."
            Write-Verbose "To: $destination"
        }
        
    }
    process { Copy-Item -Path $source -Destination $destination -Force -Recurse -PassThru | if ($DoVerbose) { ForEach-Object { Write-Verbose $_.FullName } } }
    end { Write-Verbose "Done " }
}
# Components:
#############################
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
        Environment variables
        Write-Verbose  "Check path for Library module:" -NoNewline
        Notes: There are two options
        The PSModulePath is what powershell uses and should work.
        Default:
        %ProgramFiles%\WindowsPowerShell\Modules;
        %SystemRoot%\system32\WindowsPowerShell\v1.0\Modules
        Alternatively you could use the system path (but indicates a problem)
        $envPathToUpdate = "PSModulePath"
    .OUTPUTS
        none.
#>
    [CmdletBinding()]
    param ([string]$envPathToUpdate)
    begin {
        Write-Verbose  "Check path for Library module:" -NoNewline
        if ($null -eq $envPathToUpdate) { 
            $envPathToUpdate = "PATH" 
        }
        [string] $oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name "$envPathToUpdate").path
        if ($null -eq $oldPath) {
            # Using the system PATH isn't best practices for powershell:
            # Default:
            Write-Host "Path $envPathToUpdate is null in the system Environment... Enter a key:" -NoNewline
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $envPathToUpdate = "PATH"
            Write-Warning "Using $envPathToUpdate instead..."
            $oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name "$envPathToUpdate").path
            Write-Verbose $oldPath
        }
    }
    process {
        # Check if already updated
        $positionOfPath = $oldPath.IndexOf("$global:scriptPath")
        Write-Verbose " $positionOfPath" # -1 if missing
    
        # Back path up
        # $oldPath | Out-File -FilePath ".\$envPathToUpdate_$(Get-Date -Format 'yyyymmdd HH:mm K').bak"
        # $oldPath | Out-File -FilePath ".\$envPathToUpdate_$(Get-Date -UFormat '%Y%m%d%R%z').bak"
        # $oldPath | Out-File -FilePath ".\$envPathToUpdate_$(Get-Date).bak"
        # Set-Content -Path ".\$envPathToUpdate $(Get-Date).bak" -Value $oldPath
        # $oldPath | Out-File -FilePath ".\$envPathToUpdate $(Get-Date).bak"
        # $oldPath > ".\$envPathToUpdate $(Get-Date).bak"
        # $now = Get-Date -UFormat '%Y%m%d%R%z'
        # $oldPath > ".\$envPathToUpdate $now.bak"
        # Set-Content -Path ".\$envPathToUpdate $now.bak" -Value $oldPath
        Out-File -FilePath "$PSScriptRoot\$envPathToUpdate $now.bak" -InputObject $oldPath
            
        # $oldPath
        $oldPathItems = $oldPath.replace(' ;', ';').replace('; ', ';').split(';')
        $oldPathItems = $oldPath -split ";"
        foreach ($oldPathItem in $oldPathItems) {
            Write-Verbose $oldPathItem
        }
        # Update Environment Path
        if ($positionOfPath -lt 0) {
            Write-Verbose "Updating path: $global:scriptPath"
            $newpath = "$global:scriptPath;$oldPath"
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name "$envPathToUpdate" -Value $newpath
            # Write-Host -NoNewLine "Press any key to continue..."
            # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } else {
            Write-Verbose "Found path: $global:scriptPath"
        }
    }
    end {}
    clean {}
}
# Source: https://stackoverflow.com/questions/5648931/test-if-registry-value-exists
Function Assert-RegistryValue {
<#
    .SYNOPSIS
        Return true if Registry Value exists.
    .DESCRIPTION
        Check the registry path & value. Asserts it exists.
    .PARAMETER Path
        The Registry Path to check.
    .PARAMETER Name
        The Registry Key name (Value) to access.
    .PARAMETER PassThru
        If true this outputs an ItemProperty otherwise true/false
    .EXAMPLE
        Assert-RegistryValue "PATH" 
    .NOTES
        none.
    .OUTPUTS
        True/Fale if the key exists.
        null/ItemProperty if PassThur switch is present.
#>    [CmdletBinding()]
    param(
        [Alias("PSPathTest")]
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$Path,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name,
        [Switch]$PassThru
    ) 
    begin {}
    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path
            if ($null -ne $Key.GetValue($Name, $null)) {
                if ($PassThru) {
                    Get-ItemProperty $Path $Name
                } else {
                    $true
                }
            } else {
                $false
            }
        } else {
            $false
        }
    }
    end {}
}
#
#############################
#
# Initialize-Dev_Env_Win
# 
# Sets up registry, PowerShell common modules and Path
# Copies script folders to the PowerShell Modules directory.
#
# "g:\Script\PowerShell\src\Modules\Mdm_Modules\Mdm_Bootstrap\Initialize-Dev_Env_Win.ps1"
#
# function Initialize-Dev_Env_Win ([switch]$UpdatePath, [switch]$DoVerbose) { }
#
Export-ModuleMember -Function `
    Initialize-Dev_Env_Win, `
    Assert-RegistryValue, `
    Add-RegistryPath,
DevEnv_Module_Reset