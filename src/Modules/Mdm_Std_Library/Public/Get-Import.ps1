
function Get-Import {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$moduleRootPath,
        [switch]$DoModuleScan,
        [switch]$CheckActive,
        [switch]$CheckImported,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$errorActionValue
    )
    begin {
        # $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-Parameters.ps1"
        # . "$path"
        # Project settings
        if (-not $global:moduleRootPath -or $CheckImported) {
            $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
            . "$path"
            if (-not $developerMode) {
                $Message = "Get-Import: YOU ARE NOT IN DEVELOPER MODE."
                Add-LogText -IsWarning -SkipScriptLineDisplay -Message $Message
            }
        }
        if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
        if (-not $moduleRootPath) { $moduleRootPath = $global:moduleRootPath }
        # Check if Module is Active (being used)
        if ($CheckActive) {
            $moduleActive = Confirm-ModuleActive -Name $Name `
                -jsonFileName "$global:moduleRootPath\Mdm_DevEnv_Install\data\DevEnvModules.json" `
                @global:combinedParams
            if (-not $moduleActive) { 
                if ($DoVerbose) { 
                    $Message = "Get-Import: Module: $Name is not activated."
                    Add-LogText -Messages $Message
                }
                return $null 
            }
        }
        if ($DoVerbose) { 
            Add-LogText -Messages "Get-Import: Module: $Name"
            if ($DoDebug) {
                $Message = "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
                Add-LogText -Messages $Message
                $Message = " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
                Add-LogText -Messages $Message
                $Message = "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
                Add-LogText -Messages $Message
            }
        }
    }
    process {
        try {
            # Load the Assembly
            $modulePath = "$global:moduleRootPath\$Name"
            # NOTE: Cannot safely do Get-Module without side-effects.
            # $CheckImported (already imported/loaded) should be used carefully
            if ($CheckImported) {
                $moduleValid = $true
                $module = Get-Module -Name $Name -ListAvailable
                if (-not $module) { $moduleValid = $false }
            } else {
                $module = $null
                $moduleValid = Confirm-Module -Name $Name -modulePath $modulePath @global:combinedParams
            }
            if ((Test-Path $modulePath)) { 
                if ($DoModuleScan) {
                    # Scan to file module members
                    $module = Export-ModuleMemberScan -moduleRootPath $modulePath @global:combinedParams
                } else {
                    # Standard Import
                    $folderValid = (Test-Path $modulePath)
                    if ($folderValid -and -not $moduleValid) {
                        # Scan existing folder missing psm1/psd1 files
                        $Message = "Get-Import: Module definition missing. Scan for file module $Name members"
                        Add-LogText -IsWarning -SkipScriptLineDisplay -Message $Message
                        $module = Export-ModuleMemberScan -moduleRootPath $modulePath @global:combinedParams
                    } else {
                        # Standard Import-Module
                        # Check if the module is not loaded and DoForce is not set
                        if (-not $module -or $global:DoForce) {
                            # Attempt to import the module
                            # $module = Import-Module -Name "$modulePath"
                            $module = Get-Module -Name $modulePath -ListAvailable
                            if ($module) {
                                # Import-Module -Name $Name
                                # Remove-Module -Name $Name -Force
                                Import-Module -Name "$modulePath" `
                                    -PassThru `
                                    -Force -NoClobber @global:commonParams 
                            } else {
                                $Message = "Get-Import: Get-Module: Module not found: ($modulePath)."
                                Add-LogText -IsError -Message $Message
                            }
                            # Check if the module was imported successfully
                            if ($CheckImported) {
                                if (-not $module) {
                                    $Message = "Get-Import: Failed to import module '$Name' from path '$modulePath'."
                                    Add-LogText -IsError -IsCritical -Message $Message
                                }
                            }
                        } else {
                            if ($DoDebug -or $DoVerbose) {
                                $Message = "Get-Import: Module already loaded: $Name."
                                Add-LogText -Messages $Message
                            }
                        }
                    }
                }
                if ($module -and ($DoDebug -or $DoVerbose)) {
                    $Message = @"
    Name: $($module.Name)
    Path: $($module.Path)
    Version: $($module.Version)
    Author: $($module.Author)
    Description: $($module.Description)
    ExportedFunctions: $($module.ExportedFunctions)
    ExportedCmdlets: $($module.ExportedCmdlets)
    ExportedVariables: $($module.ExportedVariables)
    RequiredModules: $($module.RequiredModules)
"@
                    Add-LogText -Messages $Message -BackgroundColor DarkBlue
                }
                # $folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -Leaf
                # if ($module.Path -ne "$global:moduleRootPath\$($module.Name)") {
                # $tmp = Split-Path ((get-item $module.Path).FullName) -Parent
                # if ("$global:moduleRootPath\$($module.Name)" -not -like $tmp) {
                #     $Message = "Get-Import: Module path $($module.Path). Expected $global:moduleRootPath\$($module.Name)."
                #     Add-LogText -IsError -Message $Message
                # }
            } else {
                $Message = "Get-Import: Module folder does not exist: ($modulePath)."
                Add-LogText -IsError -Message $Message
                return $null
            }
        } catch {
            # TODO Custom Logging: If you are implementing a logging system,
            # TODO using tags like [BEGIN], [PROCESS], [ERROR], [INFO], etc.
            # TODO can help categorize messages and make it easier to filter or search through logs.
            # TODO This project prefixes messages with the FunctionName: xxxxx pattern.
            $Message = "Get-Import: Something went wrong while loading module $Name.`n$($_.Exception.Message)"
            Add-LogText -IsError -ErrorPSItem $_ -Message $Message
            return $null
        }
    }
    end { return $module }
}
