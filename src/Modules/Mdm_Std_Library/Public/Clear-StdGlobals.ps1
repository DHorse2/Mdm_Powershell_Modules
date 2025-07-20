
# Clear-StdGlobals
function Clear-StdGlobals {
    [CmdletBinding()]
    param (
        [switch]$DoDispose,
        [switch]$DoLogFile,

        [string]$appName = "",
        [int]$actionStep = 0,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$logFileNameFull = ""
    )
    begin {
        $IsGlobal = $false
        # if (-not $app -and $global:app) { $app = $global:app; $IsGlobal = $true }
        if (-not $actionStep) { $actionStep = $global:actionStep }
        # Remove Mdm Modules (see Import-All Dispose at end)
        # $importName = "Mdm_Modules"
        # if ($DoVerbose) { Write-Host "Reset step 1: Forced removal of $importName" }
        # try {
        #     Remove-Module -Name $importName `
        #         -Force `
        #         -ErrorAction SilentlyContinue
        # } catch { $null }
    }
    process {
        if ($DoVerbose) { Write-Host "Clear-StdGlobals: Set to clear Globals is $IsGlobal" }
        # $global:developerMode
        # $global:osCoreLoaded
        # $global:moduleCoreLoaded
        # $global:modulePaths
        $global:appArray = @{}
        $global:appSequence = 0
        $global:logFileNames = @{}

        $global:appName = ""
        $global:appDirectory = ""
        $global:moduleRootPath = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
        $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
        $global:projectRootPathActual = (get-item $PSScriptRoot).Parent.Parent.Parent.Parent.FullName
        
        $global:sourceDefault = "G:\Script\Powershell\Mdm_PowershelModules\src\Modules"
        $global:destinationDefault = "C:\Program Files\WindowsPowerShell\Modules"
        $global:folderPath = "$((get-item $PSScriptRoot).Parent.FullName)\data" # Now \Mdm_Std_Library\data\
        $global:folderName = Split-Path $global:folderPath -Parent 

        $global:msgAnykey = ""
        $global:msgYorN = ""
        # $global:NL
        $global:logFileUsed = $false
        $global:lastError = $null
        $global:logFileNameFullResult = ""

        if ($global:app) {
            if ($DoVerbose) { Write-Host "Clear-StdGlobals: Clear App Control Data." }

            $global:app.appName = "Global"
            $global:app.appDirectory = "$($(get-item $PSScriptRoot).Parent.FullName)"

            $global:app.timeStarted = [System.DateTime]::MinValue
            $global:app.timeStartedFormatted = ""
            $global:app.timeCompleted = [System.DateTime]::MinValue

            $global:app.projectRootPath = $null
            $global:app.moduleRootPath = $null
            $global:app.projectRootPathActual = $null

            # $global:appDataChanged = $false
            # [hashtable]$global:appDataArray = New-Object System.Collections.Hashtable

            $global:app.InitDone = $false
            $global:app.InitStdDone = $false
            $global:app.InitGuiDone = $false
            # $global:app.InitLogFileDone = $false

            if ($DoLogFile) {
                # This causes a new file to be constructed:
                $global:app.InitLogFileDone = $false
                $global:app.logFileNames = @{}
                # Current file
                $global:app.logFileNameFull = ""
                $global:app.logFilePath = ""
                $global:app.logFileName = ""
                $global:app.logOneFile = $false
                $global:app.logFileExtension = ""
                $global:app.logFileCreated = $false
                if ($DoVerbose) { Write-Host "Clear-StdGlobals: Log File cleared." }
            } elseif ($DoVerbose) { 
                # The Log File file state shouldn't be changed.
                Write-Host "Clear-StdGlobals: retaining Log File."
                Write-Host " Log File Name: $($global:app.logFileName)"
                Write-Host "          Path: $($global:app.logFilePath)"
                Write-Host "File Extension: $($global:app.logFilePath)"
                Write-Host "  Log One File: $($global:app.logOneFile)"
                Write-Host "       Created: $($global:app.logFileCreated)"
                Write-Host "File Name Full: $($global:app.logFileNameFull)"
            }
        }

        if ($DoVerbose) { Write-Host "Clear-StdGlobals: Clear breakpoints." }
        Get-PSBreakpoint | Remove-PSBreakpoint
        Set-PSDebug -Off

        if ($DoVerbose) { Write-Host "Clear-StdGlobals: Sync PS Debug and Verbose Preference." }
        if ($DoDebug) { $DebugPreference = "Continue" } 
        else { $DebugPreference = "SilentlyContinue" }
        if ($DoVerbose) { $VerbosePreference = "Continue" } 
        else { $VerbosePreference = "SilentlyContinue" }

        # # Import-All Dispose / Remove Modules
        # # $DoDispose = $true
        # if ($DoDispose) {
        #     # $global:actionStep = 0
        #     $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\ImportAllLib.ps1"
        #     . $path @global:combinedParams
        # }
    }
}