
# ImportAllLib
# Using namespace Microsoft.VisualBasic
# Using namespace PresentationFramework
# Using namespace System.Drawing
# Using namespace System.Windows.Forms
# Using namespace System.Web
# Using namespace Microsoft.PowerShell.Security

[CmdletBinding()]
param (
    [string]$importName = "",
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
# Begin
try {
	$functionParams = $PSBoundParameters
    Add-Type -AssemblyName Microsoft.VisualBasic
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Web
    Add-Type -AssemblyName Microsoft.PowerShell.Security

    if (-not $actionStep) { $actionStep = $global:actionStep }
    # Import-All
    # Get-Parameters
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ParametersLib.ps1"
    . $path @importAllParams
    $importParams = $global:importParams
    $importAllParams = $global:mdmParams

    $importName = "Check-Security"; $actionStep++
    if ($DoVerbose) { Write-Host "Load Security" }
    # Check Security
    try {
        $global:CodeActionError = $false; $global:CodeActionErrorInfo = $null
        $global:CodeActionContent = ""
        $global:CodeActionLogFile = "$($(get-item $PSScriptRoot).Parent.FullName)\log\CheckSecurity_ImportAll.txt"
        # Load Security
        Write-Host "ExecutionPolicy." -ForegroundColor Green
        # Check-Security
        $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\Check-Security.ps1"
        . $path -logFileNameFull $global:CodeActionLogFile @importAllParams
    } catch {
        $global:CodeActionErrorInfo = $_
        $CodeActionError = $true
        $UseTraceStack = $false
        # Could-Fail (and did)
        $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\Could-Fail.ps1"
        . $path @importAllParams
    }
    # CommandResultClass
    # MarginClass
    # WindowClass
    # $global:importParams['Force'] = $true
    $global:importParams['ErrorAction'] = 'Continue'
} catch {
    Write-Error -Message "Import-All had a Setup Error on $actionStep) $importName. $_"
}
# Process
try {
    $importName = "Mdm_Std_Library"; $actionStep++
    if ($DoVerbose) { 
        Write-Host "Module: $importName"
        Write-Host "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
        Write-Host " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
        Write-Host "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
    }
    if (-not ((Get-Module -Name $importName) -or $DoForce)) {
        $modulePath = "$global:moduleRootPath\$importName"
        if ($DoVerbose) { Write-Host "Exists: $(Test-Path "$modulePath"): $modulePath" }
        Import-Module -Name $modulePath @importParams
    } else {
        if ($DoVerbose) { Write-Host "Module already loaded: $importName" }
        if ($DoDispose) { 
            if ($DoVerbose) { Write-Host "Module $importName must be removed last. Waiting..." }
        }
    }

    # Get-Import. Not Used, crashes the shell
    # Add $DoXxx params
    # $global:MdmParams.GetEnumerator() | ForEach-Object {
    #     $global:importParams[$_.Key] = $_.Value
    # }
    # $global:importParams['CheckActive'] = $true
    # $global:importParams['CheckImported'] = $false
    # $importName = "Mdm_Bootstrap"
    # Import-Module -Name $importName
    # $null = Get-Import -moduleName $importName @global:importParams
    #
    # $importName = "Mdm_WinFormPS"
    # Get-Import -moduleName $importName @global:importParams
    #
    # $importName = "Mdm_Nightroman_PowerShelf"
    # $null = Get-Import -moduleName $importName -DoModuleScan @global:importParams
    #
    # $importName = "Mdm_DevEnv_Install"
    # $null = Get-Import -moduleName $importName @global:importParams
    #
    # $importName = "Mdm_PoshFunctions"
    # $null = Get-Import -moduleName $importName @global:importParams
    #
    # $importName = "Mdm_Springcomp_MyBox"
    # $null = Get-Import -moduleName $importName -DoModuleScan @global:importParams

    $importName = "Mdm_Bootstrap"; $actionStep++
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidatedLib.ps1"
    . $path -importName $importName -actionStep $actionStep @importAllParams
    
    if ($DoVerbose) { 
        $actionStep++
        Write-Host "Module $actionStep) Available empty slot"
    }

    $importName = "Mdm_WinFormPS"; $actionStep++
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidatedLib.ps1"
    . $path -importName $importName -actionStep $actionStep @importAllParams

    $importName = "Mdm_Nightroman_PowerShelf"; $actionStep++
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidatedLib.ps1"
    . $path -importName $importName -actionStep $actionStep @importAllParams

    $importName = "Mdm_DevEnv_Install"; $actionStep++
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidatedLib.ps1"
    . $path -importName $importName -actionStep $actionStep @importAllParams

    $importName = "Mdm_PoshFunctions"; $actionStep++
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidatedLib.ps1"
    . $path -importName $importName -actionStep $actionStep @importAllParams

    $importName = "Mdm_Springcomp_MyBox"; $actionStep++
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ModuleValidatedLib.ps1"
    . $path -importName $importName -actionStep $actionStep @importAllParams
    # Get-ModuleValidated -importName $importName -actionStep $actionStep @importAllParams
    # . $global:GetModuleValidatedImport @importAllParams
    # $null = Get-Import -moduleName $importName `
    #     -CheckActive -CheckImported -ErrorAction Continue  @global:importParams
    # $moduleActive = Confirm-ModuleActive -moduleName $importName `
    #     -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\data\DevEnvModules.json" `
    #     @importAllParams
    # if ($moduleActive) { 
    #     if ($DoVerbose) { 
    #         Write-Host "Module 8: $importName"
    #     }
    #     if (-not ((Get-Module -Name $importName) -or $DoForce)) {
    #         $modulePath = "$global:moduleRootPath\$importName"
    #         if ($DoVerbose) { Write-Host "Exists: $(Test-Path "$modulePath"): $modulePath" }
    #         $null = Export-ModuleMemberScan -moduleRootPath $modulePath -modulePublicFolder "bootstrap" @global:importParams
    #     }
    # }

    # Standard library has to remain available until the end.
    if ($DoDispose) { 
        $importName = "Mdm_Std_Library"; $actionStep++
        if (-not ((Get-Module -Name $importName) -or $DoForce)) {
            # On a disposal, nothing needs to be done.
            if ($DoVerbose) { Write-Host "Module doesn't need removal: $importName" }
            if ($DoVerbose) { Write-Host "Exists: $(Test-Path "$modulePath"): $modulePath" }
        } else {
            if ($DoVerbose) { Write-Host "Loaded Module will be removed: $importName" }
            try {
                Remove-Module -Name $importName `
                    -Force `
                    -ErrorAction SilentlyContinue
            } catch { $null }
        }
    }
            
} catch {
    Write-Error -Message "Import-All had a Processing Error on $actionStep) $importName. $_"
}
# End
$global:result = "Ok"
if ($DoVerbose) { 
    Write-Host "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
    Write-Host " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
    Write-Host "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
}
