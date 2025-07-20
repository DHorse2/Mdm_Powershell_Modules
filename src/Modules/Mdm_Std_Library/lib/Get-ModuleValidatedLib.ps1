
# Get-ModuleValidatedLib
[CmdletBinding()]
param (
    [string]$importName = "",

    [string]$Name = "Modules",
    [hashtable]$jsonData,
    [string]$jsonFileName,

    [string]$appName = "",
    [int]$actionStep = 0,
    [switch]$DoForce,
    [switch]$DoVerbose,
    [switch]$DoDebug,
    [switch]$DoPause,
    [string]$logFileNameFull = ""
)
# process {
$functionParams = $PSBoundParameters
# this expects $actionStep to be available.
if (-not $actionStep) { $actionStep = $global:actionStep }
if ($actionStep -ge 0) { $actionStepString = ". $actionStep) " } else { $actionStepString = ": " }
if ($DoVerbose) { 
    Add-LogText -Message "Get-ModuleValidated Module$($actionStepString)$importName" -logFileNameFull $logFileNameFull
}
if (-not $jsonFileName) { $jsonFileName = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_DevEnv_Install\data\DevEnvModules.json" }
if (-not $global:appDataArray) { 
    [hashtable]$global:appDataArray = New-Object System.Collections.Hashtable
}
if (-not $jsonData) {
    if (-not $global:appDataArray[$Name]) {
        # [hashtable]$jsonData = New-Object System.Collections.Hashtable
        # $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Public\Get-JsonData"
        # . $path -jsonItem $jsonFileName -parentObject $jsonData @global:combinedParams
        # $jsonData = & $path -jsonItem $jsonFileName @global:combinedParams
        # . $path @global:combinedParams -jsonItem $jsonFileName -parentObject $jsonData
        # $jsonData = $(. $path @global:combinedParams -jsonItem $jsonFileName)
        # "src\Modules\Mdm_Std_Library\Public\Get-JsonData.ps1"
        $jsonData = Get-JsonData -Name $Name -jsonItem $jsonFileName -logFileNameFull $logFileNameFull
        # $jsonData = $global:jsonDataResult
        $global:appDataArray[$Name] = $jsonData
    } else {
        $jsonData = $global:appDataArray[$Name]
    }
}
# Confirm module
$moduleActive = Confirm-ModuleActive -moduleName $importName `
    -jsonData $jsonData `
    @global:combinedParams

# Process Result    
if ($moduleActive) { 
    if ($DoVerbose) { 
        Add-LogText -Message "Get-ModuleValidated Module$($actionStepString)$importName" -logFileNameFull $logFileNameFull
    }
    if (-not ((Get-Module -Name $importName) -or $DoForce)) {
        $modulePath = "$global:moduleRootPath\$importName"
        if ($DoVerbose) { Add-LogText -Message "Module $importName$($actionStepString)Exists: $(Test-Path "$modulePath"): $modulePath" -logFileNameFull $logFileNameFull }
        if (-not $DoDispose) {
            # Import Modules with ".psm1" ".psd1" files
            if (-not (Confirm-ModuleScan -moduleName $importName `
                        -jsonData $jsonData `
                        @global:combinedParams
                )) {
                try {
                    $module = Import-Module -Name $modulePath @global:importParams
                    if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Import-Module done." -logFileNameFull $logFileNameFull }
                    if (-not $global:moduleArray) {
                        $global:moduleArray = @{}
                        $global:moduleSequence = 0
                    }
                    if (-not $global:appArray) {
                        $global:appArray = @{}
                        $global:appSequence = 0
                    }
                    if (-not $global:moduleArray[$importName]) { $global:moduleSequence++ }
                    if (-not $global:logFileNames) { $global:logFileNames = @{} }
                    if ($module) {
                        $global:moduleArray[$importName] = $module
                    } else {
                        $global:moduleArray[$importName] = $modulePath
                    }
                } catch {
                    if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Import-Module Error loading Module$($actionStepString)$importName." -ForegroundColor Red -logFileNameFull $logFileNameFull }
                }
            } else {
                try {
                    # Powershell standard folder scanning of Public / Private
                    if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Scanning module$($actionStepString)$importName." -logFileNameFull $logFileNameFull }
                    $null = Export-ModuleMemberScan -moduleRootPath $modulePath `
                        @global:combinedParams
                } catch {
                    if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Export-ModuleMemberScan Error loading Module$($actionStepString)$importName." -ForegroundColor Red -logFileNameFull $logFileNameFull }
                }
            }
        } else {
            if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Module not already loaded and not removed$($actionStepString)$importName" -logFileNameFull $logFileNameFull }
        }
    } else {
        if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Module already loaded$($actionStepString)$importName." -logFileNameFull $logFileNameFull }
        if ($DoDispose) { 
            if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Removing Module$($actionStepString)$importName." -logFileNameFull $logFileNameFull }
            try {
                Remove-Module -Name $importName `
                    -Force `
                    -ErrorAction SilentlyContinue
                if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Module removed$($actionStepString)$importName." -logFileNameFull $logFileNameFull }
            } catch { 
                if ($DoVerbose) { Add-LogText -Message "Get-ModuleValidated Module removal errored$($actionStepString)$importName." -logFileNameFull $logFileNameFull }
            }
        }
    }
}
# end {
$global:result = "Ok"
