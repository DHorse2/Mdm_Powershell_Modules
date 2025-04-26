
# Install-Mdm_Dev_Env
if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
# Components installed: 
. "$global:scriptPath\Mdm_DevEnv_Install\Install-DevEnvOsWin.ps1"
. "$global:scriptPath\Mdm_DevEnv_Install\Install-DevEnvIdeWin.ps1"
. "$global:scriptPath\Mdm_DevEnv_Install\Install-DevEnvLlmWin.ps1"
. "$global:scriptPath\Mdm_DevEnv_Install\Install-DevEnvWhisperWin.ps1"
# MAIN function:
. "$global:scriptPath\Mdm_DevEnv_Install\Install-DevEnvWin.ps1"

# Imports
$importName = "Mdm_Std_Library"
Import-Module -Name "$global:scriptPath\$importName\$importName" -Force -ErrorAction Continue

# Variables: 
#############################

# Dev Env Tool Versions
Function Get-DevEnvVersions {
<#
    .SYNOPSIS
        List current versions.
    .DESCRIPTION
        Cycles through components and display the current version.
    .PARAMETER DoPause
        Switch to pause at each step/page.
    .PARAMETER DoVerbose
        Provide detailed information.
    .PARAMETER DoDebug
        Debug this script.
    .EXAMPLE
        Get-DevEnvVersions -DoVerbose
    .NOTES
        needs work.
    .OUTPUTS
        Should output a file and display.
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    Initialize-StdGlobalsReset `
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug
    Initialize-Std `
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug
    # Language mode: FullLanguage needed, Add cert
    # Set-ExecutionPolicy Unrestricted
    # $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
    Write-Verbose "PSScriptRoot: $PSScriptRoot Import"
    Write-Verbose "PSScriptRoot: $PSScriptRoot Initialize $(Get-ScriptName)"
 
    # $PSScriptRoot
    Write-Verbose "PSScriptRoot: $PSScriptRoot Started. Checking libraries."
    Write-Verbose "Powershell version:"
    Write-Verbose $PSVersionTable.PSVersion
    if (Get-Command Wait-AnyKey -ErrorAction SilentlyContinue) {
        if ($global:DoVerbose) { Write-Host "Wait-AnyKey loaded successfully." -foregroundColor Green }
    }
    else {
        Write-Warning "Error: Wait-AnyKey function not loaded."
        if ($global:DoVerbose) { Write-Host "Trying library path method." -ForegroundColor Red }
        $stdLibraryPath = "$PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1"
        if (Test-Path $stdLibraryPath) {
            if ($global:DoVerbose) { Write-Host "Loading Std_Library.ps1..." -ForegroundColor Cyan }
            . $stdLibraryPath
        }
        else {
            Write-Error "Mdm_Std_Library.psm1 NOT FOUND at $stdLibraryPath"
            exit
        }
        # exit
    }
 
    $response = "Y"
    if ($global:DoVerbose -or $global:DoPause) { $response = Wait-YorNorQ }
    If ($response -eq "Y") {

        # Write-Verbose "################################################################################"
        # Write-Host "Console Window"
        # Get-Host
        Write-Verbose "################################################################################"
        # $ThisWindow = Get-Host
        powershell -command "(Get-Host).Name"
        Write-Verbose "################################################################################"

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($global:DoVerbose) { 
            Write-Verbose "Path:"
            # Refresh environment PATH for the current session
            $env:Path -split ";" | Write-Host
            Write-Verbose "################################################################################"
            if ($global:DoPause) { Wait-AnyKey }

            Write-Verbose "Environment:"
            Get-ChildItem Env: | Write-Host
            Write-Verbose "################################################################################"

            # Refresh environment PATH for the current session
            $psPath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
            Write-Host "Path:"
            $psPath -split ";" | Write-Host
            Write-Verbose "################################################################################"
            if ($global:DoPause) { Wait-AnyKey }
        }

        # PowerShell
        Write-Host "PowerShell version: " -NoNewline
        # powershell -Command "$PSVersionTable.PSVersion"
        # powershell -command "(Get-Variable PSVersionTable -ValueOnly).Name"
        $PSVersionTable.PSVersion.ToString() | Write-Host
        # function Get-PSVersion {
        # Write-Verbose $PSVersionTable.PSVersion
        # (depreciated) Write-Verbose pwsh -Version
        # Write-Verbose $Host.Version
        # powershell -command "(Get-Variable PSVersionTable -ValueOnly).Name"
        #     if (test-path variable:psversiontable) {$psversiontable.psversion} else {[version]"1.0.0.0"}
        # }
        Write-Verbose "################################################################################"

        # Python
        Write-Host "Python version: " -NoNewline
        python --version  | Write-Host
        Write-Verbose "################################################################################"

        # VsCodium 
        Write-Host "VsCodium version: " -NoNewline
        codium --version | Write-Host
        Write-Verbose "################################################################################"

        # VsCode 
        Write-Host "VsCode version: " -NoNewline
        code --version | Write-Host
        Write-Verbose "################################################################################"

        # NodeJs
        Write-Host "Node version: " -NoNewline
        node -v | Write-Host
        Write-Verbose "################################################################################"

        if ($global:DoDebug) {
            Write-Host " Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug"
            Write-Host "Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug"
    
            Write-Host "$global:msgAnykey Pause: $global:DoPause"
            if ($global:DoPause) { Wait-AnyKey }
        }
    }
}
# Install-DevEnvWhisperWin
function Install-DevEnvModules {
<#
    .SYNOPSIS
        Install these modules on the local system.
    .DESCRIPTION
        NOT IN USE. Performs an .Add($_) for each object
    .PARAMETER inputObjects
        .
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        .
    .EXAMPLE
        Install-DevEnvModules
    .LINK
        XXX: http://www.XXX
    .LINK
        YYY
    .NOTES
        .
#>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]$inputObjects
    )

    begin {
        [Collections.ArrayList]$inputObjects = @()
    }
    process {
        [void]$inputObjects.Add($_)
    }
    end {
        $inputObjects | ForEach-Object -Parallel {
      
        }
    }
}
#############################
Set-Alias -Name Get-Vs -Value Get-DevEnvVersions
