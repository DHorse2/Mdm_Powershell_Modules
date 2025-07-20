
function Get-Import {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$moduleName,
        [string]$moduleRootPath,
        [switch]$DoModuleScan,
        [switch]$CheckActive,
        [switch]$CheckImported,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$errorActionValue,
        [string]$logFileNameFull = ""
    )
    begin {
        # $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-ParametersLib.ps1"
        # . $path @global:combinedParams
        # Project settings
        if (-not $global:moduleRootPath -or $CheckImported) {
            $path = "$($(get-item $PSScriptRoot).Parent.FullName)\lib\ProjectLib.ps1"
            . $path @global:combinedParams
            if (-not $developerMode) {
                $Message = "Get-Import: YOU ARE NOT IN DEVELOPER MODE."
                Add-LogText -IsWarning -SkipScriptLineDisplay -Message $Message -logFileNameFull $logFileNameFull
            }
        }
        if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
        if (-not $moduleRootPath) { $moduleRootPath = $global:moduleRootPath }
        # Check if Module is Active (being used)
        if ($CheckActive) {
            $moduleActive = Confirm-ModuleActive -moduleName $moduleName `
                -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\data\DevEnvModules.json" `
                -logFileNameFull $logFileNameFull `
                @global:combinedParams
            if (-not $moduleActive) { 
                if ($DoVerbose) { 
                    $Message = "Get-Import: Module: $moduleName is not activated."
                    Add-LogText -Message $Message -logFileNameFull $logFileNameFull
                }
                return $null 
            }
        }
        if ($DoVerbose) { 
            Add-LogText -Message "Get-Import: Module: $moduleName"
            if ($DoDebug) {
                $Message = "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
                Add-LogText -Message $Message -logFileNameFull $logFileNameFull
                $Message = " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
                Add-LogText -Message $Message -logFileNameFull $logFileNameFull
                $Message = "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
                Add-LogText -Message $Message -logFileNameFull $logFileNameFull
            }
        }
    }
    process {
        try {
            # Load the Assembly
            $modulePath = "$global:moduleRootPath\$moduleName"
            # NOTE: Cannot safely do Get-Module without side-effects.
            # $CheckImported (already imported/loaded) should be used carefully
            if ($CheckImported) {
                $moduleValid = $true
                $module = Get-Module -Name $moduleName -ListAvailable
                if (-not $module) { $moduleValid = $false }
            } else {
                $module = $null
                $moduleValid = Confirm-Module -moduleName $moduleName -modulePath $modulePath -logFileNameFull $logFileNameFull @global:combinedParams
            }
            if ((Test-Path $modulePath)) { 
                if ($DoModuleScan) {
                    # Scan to file module members
                    $module = Export-ModuleMemberScan -moduleRootPath $modulePath -logFileNameFull $logFileNameFull @global:combinedParams
                } else {
                    # Standard Import
                    $folderValid = (Test-Path $modulePath)
                    if ($folderValid -and -not $moduleValid) {
                        # Scan existing folder missing psm1/psd1 files
                        $Message = "Get-Import: Module definition missing. Scan for file module $moduleName members"
                        Add-LogText -IsWarning -SkipScriptLineDisplay -Message $Message
                        $module = Export-ModuleMemberScan -moduleRootPath $modulePath -logFileNameFull $logFileNameFull @global:combinedParams
                    } else {
                        # Standard Import-Module
                        # Check if the module is not loaded and DoForce is not set
                        if (-not $module -or $global:app.DoForce) {
                            # Attempt to import the module
                            # $module = Import-Module -Name "$modulePath"
                            $module = Get-Module -Name $modulePath -ListAvailable
                            if ($module) {
                                # Import-Module -Name $moduleName
                                # Remove-Module -Name $moduleName -Force
                                Import-Module -Name "$modulePath" `
                                    -PassThru `
                                    -Force -NoClobber @global:commonParams 
                            } else {
                                $Message = "Get-Import: Get-Module: Module not found: ($modulePath)."
                                Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
                            }
                            # Check if the module was imported successfully
                            if ($CheckImported) {
                                if (-not $module) {
                                    $Message = "Get-Import: Failed to import module '$moduleName' from path '$modulePath'."
                                    Add-LogText -IsError -IsCritical -Message $Message -logFileNameFull $logFileNameFull
                                }
                            }
                        } else {
                            if ($DoDebug -or $DoVerbose) {
                                $Message = "Get-Import: Module already loaded: $moduleName."
                                Add-LogText -Message $Message -logFileNameFull $logFileNameFull
                            }
                        }
                    }
                }
                if ($module -and ($DoDebug -or $DoVerbose)) {
                    $moduleItem = [ModuleClass]::new(
    $($module.Name),
    $($module.Path),
    $($module.Version),
    $($module.Author),
    $($module.Description),
    $($module.ExportedFunctions),
    $($module.ExportedCmdlets),
    $($module.ExportedVariables),
    $($module.RequiredModules)
                    )
                    # $Message = $moduleItem.Display
                    Add-LogText -Message $($moduleItem.Display) -BackgroundColor DarkBlue -logFileNameFull $logFileNameFull
                }
                # $folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -Parent
                # if ($module.Path -ne "$global:moduleRootPath\$($module.Name)") {
                # $tmp = Split-Path ((get-item $module.Path).FullName) -Parent
                # if ("$global:moduleRootPath\$($module.Name)" -not -like $tmp) {
                #     $Message = "Get-Import: Module path $($module.Path). Expected $global:moduleRootPath\$($module.Name)."
                #     Add-LogText -IsError -Message $Message
                # }
            } else {
                $Message = "Get-Import: Module folder does not exist: ($modulePath)."
                Add-LogText -IsError -Message $Message -logFileNameFull $logFileNameFull
                return $null
            }
        } catch {
            # TODO Custom Logging: If you are implementing a logging system,
            # TODO using tags like [BEGIN], [PROCESS], [ERROR], [INFO], etc.
            # TODO can help categorize messages and make it easier to filter or search through logs.
            # TODO This project prefixes messages with the FunctionName: xxx pattern.
            $Message = "Get-Import: Something went wrong while loading module $moduleName.$global:NL$($_.Exception.Message)"
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message -logFileNameFull $logFileNameFull
            return $null
        }
    }
    end { return $module }
}
