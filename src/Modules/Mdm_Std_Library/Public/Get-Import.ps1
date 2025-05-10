function Get-Import {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [string]$moduleRootPath,
        [switch]$CheckImported,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [string]$errorActionValue
    )
    begin {
        $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-Parameters.ps1"
        # $path = ".\Get-Parameters.ps1"
        # . "$path"

        if (-not $global:moduleRootPath -or $CheckImported) {
            $path = "$($(get-item $PSScriptRoot).Parent.Parent.FullName)\Mdm_Modules\Project.ps1"
            . "$path"
            if (-not $developerMode) {
                Write-Warning -Message "Get-Import: YOU ARE NOT IN DEVELOPER MODE."
            }
        }
        if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
        if (-not $moduleRootPath) { $moduleRootPath = $global:moduleRootPath }
    }
    process {
        try {
            # Load the Assembly
            $module = Get-Module -Name $Name -ListAvailable
    
            # Check if the module is not loaded and DoForce is not set
            if ((-not $module -and $CheckImported) -or $global:DoForce) {
                $modulePath = "$global:moduleRootPath\$Name\$Name"
                # Attempt to import the module
                $module = Import-Module -Name "$modulePath" -PassThru @commonParameters
                # Check if the module was imported successfully
                if (-not $module) {
                    throw "Failed to import module '$Name' from path '$modulePath'."
                }
            } else {
                Write-Warning -Message "Get-Import: Module already loaded: $Name."
            }
            if ($module) {
                # if ($DoVerbose) {
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
                Add-LogText -Message $Message -BackgroundColor DarkBlue
                # }
                if ($module.Path -ne "$global:moduleRootPath\$($module.Name)") {
                    $Message = "Get-Import: Module path $($module.Path). Expected $global:moduleRootPath\$($module.Name)."
                    Add-LogText -IsWarning -Message $Message
                }
            }
            return $module
        } catch {
            # Custom Logging: If you are implementing a logging system,
            # TODO using tags like [BEGIN], [PROCESS], [ERROR], [INFO], etc.
            # can help categorize messages and make it easier to filter or search through logs.
            $Message = "Get-Import: Something went wrong while loading module $Name.`n$($_.Exception.Message)"
            Add-LogText -IsError -ErrorPSItem $ErrorPSItem -Message $Message
            return $null  # Optionally return null or handle the error as needed
        }
    }
    end { }
}
