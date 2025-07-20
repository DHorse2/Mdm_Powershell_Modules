
# Initialize-Project
function Initialize-Project {
    [CmdletBinding()]
    param (
        [string]$fileNameFull = "",
        [string]$sourceDirectory = "",
        [string]$dataSourceName = "",
        [string]$dataSet = "",
        [string]$dataSetState = "",
        [switch]$IgnoreState,
        [hashtable]$dataArray,
        [switch]$DoReturn,
        [switch]$SkipStatusUpdate,
        [string]$logFileNameFull = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    # begin {
        # $path = "$($PSScriptRoot)\YYY\Mdm_Std_Library\lib\ProjectLib.ps1"
        # $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\lib\ProjectLib.ps1"
        # . $path
        # Source, destination and current folders
        $global:sourceDefault = "G:\Script\Powershell\Mdm_PowershelModules\src\Modules"
        $global:destinationDefault = "C:\Program Files\WindowsPowerShell\Modules"
        # Location of code and modules
        $global:moduleRootPath = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules"
        # Determine the OS type and NewLine `n `r`n etc.
        if ($IsWindows) {
            $global:NL = "`r`n"
        } elseif ($IsLinux) {
            $global:NL = "`n"
        } elseif ($IsMacOS) {
            $global:NL = "`n"
        } else {
            # Fallback to Line feed
            $global:NL = "`n"
        }
        $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName
        $global:projectRootPathActual = (get-item $PSScriptRoot).Parent.Parent.Parent.Parent.FullName
        if ($global:app) {
            $global:app.moduleRootPath = $global:moduleRootPath
            $global:app.projectRootPath = $global:projectRootPath
            $global:app.projectRootPathActual = $global:projectRootPathActual
        }
        Write-Debug "Project: "
        Write-Debug "    Modules: $global:moduleRootPath"
        Write-Debug "    Project: $global:projectRootPath"
        Write-Debug "     Actual: $global:projectRootPathActual"
    # }
    # process {
        if (-not $global:moduleCoreLoaded -and -not $global:moduleCoreSkip) {
            # Standard Library Core
            $global:moduleCoreLoaded = $true
            $global:folderPath = "$((get-item $PSScriptRoot).Parent.FullName)\data" # Now \Mdm_Std_Library\data\
            $global:folderName = Split-Path $global:folderPath -Parent 
            # Exception Handling.
            # Get-ErrorNew
            $global:GetErrorNewImport = "$((get-item $PSScriptRoot).Parent.FullName)\Public\Get-ErrorNew.ps1"
            . $global:GetErrorNewImport
            # Global Session & State.
            # Import-All
            $global:ImportAllImport = "$($(get-item $PSScriptRoot).Parent.FullName)\Public\Import-All.ps1"
            . $global:ImportAllImport
            # Clear-StdGlobals
            $global:ClearStdGlobalsImport = "$($(get-item $PSScriptRoot).Parent.FullName)\Public\Clear-StdGlobals.ps1"
            . $global:ClearStdGlobalsImport
            # Modules.
            # Get-ModuleValidated
            $global:GetModuleValidatedImport = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Public\Get-ModuleValidated.ps1"
            . $global:GetModuleValidatedImport
            # Confirm-ModuleActive
            $global:ConfirmModuleActiveImport = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Public\Confirm-ModuleActive.ps1"
            . $global:ConfirmModuleActiveImport
            # Confirm-ModuleScan
            $global:ConfirmModuleScanImport = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Public\Confirm-ModuleScan.ps1"
            . $global:ConfirmModuleScanImport
            # File System.
            # Get-JsonData
            $global:GetJsonDataImport = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Public\Get-JsonData.ps1"
            . $global:GetJsonDataImport
            # Exceptions. Errors & Debugging.
            # Mdm_Std_Error
            $global:MdmStdErrorImport = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Public\Get-JsonData.ps1"
            . $global:MdmStdErrorImport
            # Logging and formatted output.
            # Mdm_Std_Log
            $global:MdmStdLogImport = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Public\Mdm_Std_Log.ps1"
            . $global:MdmStdLogImport
            # Mdm_Std
            $global:MdmStdImport = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Public\Mdm_Std.ps1"
            . $global:MdmStdImport
        }
                # G: is the Dev drive (everywhere)
        # G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\Mdm_Std_Library\lib\ProjectLib.ps1
        # G:\Script\Powershell\Mdm_Powershell_Modules\ <- the root of the github project
        # In a live environment:
        # "C:\Program Files\WindowsPowerShell\Modules\Mdm_Std_Library\lib\ProjectLib.ps1
        # "C:\Program Files\ <- the project root is "Program Files"
        # Current:
        # $global:sourceDefault = "G:\Script\Powershell\Mdm_PowershelModules\src\Modules"
        # $global:destinationDefault = "C:\Program Files\WindowsPowerShell\Modules"

        if (-not $global:osCoreLoaded) {
            $global:osCoreLoaded = $true
            # Developer Mode IsDevMode.txt
            # The IsDevMode.txt file additionally confirms HERE, DevMode is not LiveMode.
            try {
                $item = Get-Item "$global:projectRootPathActual\IsDevMode.txt" -ErrorAction Stop
                $global:developerMode = $true
            } catch { $global:developerMode = $false }    
            if ($global:projectRootPathActual -ne $global:projectRootPath) {
                Write-Warning -Message "Project: Project folder: $global:projectRootPath"
                Write-Warning -Message "Project:  Actual folder: $global:projectRootPathActual."
            }
            if ($DoDebug) {
                if (-not $global:developerMode) {
                    Write-Host -Message "[LIVE] " -NoNewline
                } else {
                    Write-Host -Message "[DEV] " -NoNewline
                }
            }
            # Update PS Module Search Path
            if (-not $global:developerModePathSet) {
                $global:developerModePathSet = $true
                # $env:PSModulePath
                $global:modulePaths = $env:PSModulePath -split ';'
                # Remove the custom source path if it exists
                $global:modulePaths = $global:modulePaths | Where-Object { $_ -ne $global:sourceDefault }
                if ($global:developerMode) {
                    # Prepend the custom (development) path
                    $global:modulePaths = @($global:sourceDefault) + $global:modulePaths
                }
                Write-Host "Search path was set."
                $global:modulePaths = $global:modulePaths -join ';'
                $env:PSModulePath = $global:modulePaths
            }
            # Registry
            # Per: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.4#module-search-behavior
            # HKLM
            # $key = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment')
            # $path = $key.GetValue('PSModulePath','','DoNotExpandEnvironmentNames')
            # $path += ';%ProgramFiles%\MyCo\MyModules'
            # $key.SetValue('PSModulePath',$path,[Microsoft.Win32.RegistryValueKind]::ExpandString)
            # HKCU
            # $key = (Get-Item 'HKCU:\Environment')
            # $path = $key.GetValue('PSModulePath','','DoNotExpandEnvironmentNames')
            # $path += ';%ProgramFiles%\MyCo\MyModules'
            # $key.SetValue('PSModulePath',$path,[Microsoft.Win32.RegistryValueKind]::ExpandString)
        }
        # Settings can be temporarily or permanently force set in here:
        $path = "$($PSScriptRoot)\ProjectRunSettings.ps1"
        . $path
    # }
    # end {
        $global:result = "Ok"
    # }
}