Using module "..\Mdm_Std_Library\Mdm_Std_Library.psm1"
Using module "..\Mdm_Bootstrap\Mdm_Bootstrap.psm1"
Using module "..\Mdm_WinFormPS\Mdm_WinFormPS.psm1"

$moduleName = "Mdm_DevEnv_Install.psm1"
if ($DoVerbose) { Write-Host "== $moduleName ==" -ForegroundColor Green }
# Script Path
# Get-ModuleRootPath
if (-not $global:moduleRootPath) {
    $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
    . $path @global:combinedParams
}
# Params
$path = "$global:moduleRootPath\Mdm_Std_Library\lib\Get-ParametersLib.ps1"
. $path @global:combinedParams

# Imports Import-Module
# $importName = "Mdm_Bootstrap"
# if (-not ((Get-Module -Name $importName) -or $global:app.DoForce)) {
#     $modulePath = "$global:moduleRootPath\$importName"
#     Import-Module -Name $modulePath @global:commonParams
# }
# # $null = Get-Import -moduleName "$global:moduleRootPath\$importName" `
# #     -CheckImported -ErrorAction Continue
# $importName = "Mdm_Std_Library"
# if (-not ((Get-Module -Name $importName) -or $global:app.DoForce)) {
#     $modulePath = "$global:moduleRootPath\$importName"
#     Import-Module -Name $modulePath @global:commonParams
# }
# $null = Get-Import -moduleName "$global:moduleRootPath\$importName" `
#     -CheckImported -ErrorAction Continue
# $importName = "Mdm_WinFormPS"
# if (-not ((Get-Module -Name $importName) -or $global:app.DoForce)) {
#     $modulePath = "$global:moduleRootPath\$importName"
#     Import-Module -Name $modulePath @global:commonParams
# }
# $null = Get-Import -moduleName "$global:moduleRootPath\$importName" `
#     -CheckImported -ErrorAction Continue

. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\DevEnvGui.ps1"
# MAIN function:
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnvWin.ps1"
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnv.ps1"

# Components installed: 
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnvIdeWin.ps1"
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnvLlmWin.ps1"
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnvOsWin.ps1"
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnvRepository.ps1"
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnvWhisperWin.ps1"
. "$global:moduleRootPath\Mdm_DevEnv_Install\Public\Install-DevEnvWin.ps1"

Set-Alias -Name IWinWhisper -Value Install-DevEnvWhisperWin
Set-Alias -Name IWinLlm -Value Install-DevEnvLlmWin
Set-Alias -Name IWinIde -Value Install-DevEnvIdeWin
Set-Alias -Name IWinOs -Value Install-DevEnvOsWin
Set-Alias -Name IDevEnv -Value Install-DevEnv
Set-Alias -Name IDevEnvWin -Value Install-DevEnvWin
Set-Alias -Name Get-Vs -Value Get-DevEnvVersions

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
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug, [switch]$DoForce,
        [string]$logFileNameFull = "",
        [switch]$KeepOpen,
        [switch]$Silent
    )
    $getDevEnvVersionsParams = @{}
    if ($DoForce) { $getDevEnvVersionsParams['DoForce'] = $true }
    if ($DoVerbose) { $getDevEnvVersionsParams['DoVerbose'] = $true }
    if ($DoDebug) { $getDevEnvVersionsParams['DoDebug'] = $true }
    if ($DoPause) { $getDevEnvVersionsParams['DoPause'] = $true }

    Reset-StdGlobals @getDevEnvVersionsParams

    Initialize-Std @getDevEnvVersionsParams

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
        if ($global:app.DoVerbose) { Write-Host "Wait-AnyKey loaded successfully." -ForegroundColor Green }
    } else {
        Write-Warning -Message "Get-DevEnvVersions Error: Wait-AnyKey function not loaded."
        if ($global:app.DoVerbose) { Write-Host "Trying library path method." -ForegroundColor Red }

        $stdLibraryPath = "$PSScriptRoot\..\Mdm_Std_Library\Mdm_Std_Library.psm1"
        if (Test-Path $stdLibraryPath) {
            if ($global:app.DoVerbose) { Write-Host "Loading Std_Library.ps1..." -ForegroundColor Cyan }
            # . $stdLibraryPath
            Import-Module -Name $stdLibraryPath -Force
            # $null = Get-Import -moduleName $stdLibraryPath -DoVerbose
        } else {
            Write-Error -Message "Mdm_Std_Library.psm1 NOT FOUND at $stdLibraryPath"
            exit
        }
        # exit
    }
 
    $response = "Y"
    if ($DoPause -or ($KeepOpen -and -not $Silent)) { 
        Wait-AnyKey -Message
        if ($global:app.DoVerbose -or $global:app.DoPause) { $response = Wait-YorNorQ  "Get-DevEnvVersions Continue?" }
    }
    If ($response -eq "Y") {

        # Write-Verbose "################################################################################"
        # Write-Host "Console Window"
        # Get-Host
        Write-Verbose "################################################################################"
        # $ThisWindow = Get-Host
        powershell -command "(Get-Host).Name"
        Write-Verbose "################################################################################"

        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($global:app.DoVerbose) { 
            Write-Verbose "Path:"
            # Refresh environment PATH for the current session
            $env:Path -split ";" | Write-Host
            Write-Verbose "################################################################################"
            if ($global:app.DoPause -and $KeepOpen -and -not $Silent) { Wait-AnyKey }

            Write-Verbose "Environment:"
            Get-ChildItem Env: | Write-Host
            Write-Verbose "################################################################################"

            # Refresh environment PATH for the current session
            $psPath = [System.Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
            Write-Host "Path:"
            $psPath -split ";" | Write-Host
            Write-Verbose "################################################################################"
            if ($global:app.DoPause -and $KeepOpen -and -not $Silent) { Wait-AnyKey }
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

        if ($KeepOpen -or ($global:app -and ($global:app.DoPause -or $global:app.DoVerbose -or $global:app.DoDebug -or $global:app.DoForce))) {
            Write-Host " "
            Write-Host "   Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug, Force: $local:DoForce"
            Write-Host "  Global Pause: $global:app.DoPause, Verbose: $global:app.DoVerbose, Debug: $global:app.DoDebug, Force: $global:app.DoForce"
            Write-Host "Default prompt: $global:msgAnykey"
            Write-Host "   Silent Mode: $Silent"
            Write-Host "     Keep Open: $KeepOpen"
            if ($global:app.DoPause -or ($DoPause -or ($KeepOpen -and -not $Silent))) { Wait-AnyKey }
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
#>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]$inputObject,
        [string]$logFileNameFull = ""
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
# Session Arrays
if (-not $global:moduleArray) {
    $global:moduleArray = @{}
    $global:moduleSequence = 0
}
if (-not $global:moduleArray['Mdm_DevEnv_Install']) { $global:moduleArray['Mdm_DevEnv_Install'] = "Imported" }
