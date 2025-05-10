
#region Module Import / Export
Function Export-ModuleMemberScan {
    <#
    .SYNOPSIS
        The scans a module folder with a view to automatically load/import it.
    .DESCRIPTION
        It didn't work. The problem isn't clear.
    .PARAMETER scriptRoot
        Mandatory path to script files.
    .PARAMETER modulePublic
        Path for Public cmdlets to export.
    .PARAMETER modulePrivate
        Path for Private functions.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Imports modules.
    .EXAMPLE
        Export-ModuleMemberScan
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$moduleRootPath,
        [Parameter(Mandatory = $false)]
        [string]$modulePublic = "",
        [Parameter(Mandatory = $false)]
        [string]$modulePrivate = ""
    )
    begin {
        if (-not $modulePublic) { $modulePublic = "$moduleRootPath\Public" }
        if (-not $modulePrivate) { $modulePrivate = "$moduleRootPath\Private" }
    }
    process {
        # Export-ModuleMemberScan
        #Get public and private function definition files.
        $Flat = @( Get-ChildItem -Path "$moduleRootPath\*.ps1" -ErrorAction SilentlyContinue )
        $Public = @( Get-ChildItem -Path "$modulePublic\*.ps1" -ErrorAction SilentlyContinue )
        $Private = @( Get-ChildItem -Path "$modulePrivate\*.ps1" -ErrorAction SilentlyContinue )
        Write-Host "Loading... $moduleRootPath"
        # Dot source the files
        Foreach ($import in @($Public + $Private + $Flat)) {
            Try {
                Write-Host -Message "Module Component: $($import.FullName) with functions: $($functions.Name -join ', ')"
                # Check if the script contains any functions
                $functions = Get-Command -Name * -CommandType Function | Where-Object { $_.Source -eq $import.FullName }
                if ($functions) {
                    # If functions are found, dot-source the file
                    . $import.FullName
                    
                    # Export Public functions
                    if ($import.FullName.IndexOf("Private") -lt 0) {
                        Export-ModuleMember -Function $functions.Name
                        Write-Host -Message "    Public Component: $($import.FullName) with functions: $($functions.Name -join ', ')"
                    } else { 
                        Write-Host -Message "    Private Component: $($import.FullName) skipped."
                    }
                } else {
                    # If no functions are found, execute the script directly
                    & $import.FullName
                    Write-Host -Message "    Executable Script: $($import.FullName)"
                    # If no functions are found, create a wrapper function
                    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($import.FullName) + "_Func"
                    $wrapperFunction = @"
function $scriptName {
    & `"$($import.FullName)`"
}
"@
                    # Use Invoke-Expression to define the wrapper function
                    $null = Invoke-Expression $wrapperFunction
                    Export-ModuleMember -Function $scriptName
                    # Export-ModuleMember -Function $functions.Name
                    # (You could prompt to execute here. Don't.)
                    Write-Host -Message "Created wrapper function: $scriptName for script: $($import.FullName)"                    
                }
            } Catch {
                Add-LogError -IsError -ErrorPSItem $ErrorPSItem -Message "Failed to import component $($import.FullName): $_"
            }
        }
    }
}
function Import-These {
    <#
    .SYNOPSIS
        Imports specified functions from a module.
    .DESCRIPTION
        This function imports specified functions from a PowerShell module or script file.
        If no function names are provided, the entire module is imported.
    .NOTES
        This function is not supported in Linux.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Import-These -moduleRootPath "C:\Path\To\Module" -functionNames "Function1", "Function2"
Import-These -moduleRootPath "C:\Path\To\Module" -functionNames "Function1", "Function2", "Function3"
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$moduleRootPath,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $moduleComponent,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$functionNames
    )
    
    begin {
        if (-not $moduleRootPath) { $moduleRootPath = $global:moduleRootPath }
        $moduleName = Split-Path -Path $moduleRootPath -Qualifier
        if (-not $moduleComponent) { 
            $moduleFileName = $moduleName + ".psm1"
        } else {
            $moduleFileName = $moduleComponent + ".ps1"
        }
        $moduleFileNameFull = "$($moduleRootPath)\$moduleFileName"
    }
    
    process {
        $importFound = $false
        try {
            if (-not $functionNames) {
                Write-Verbose "Importing entire module: $moduleFileNameFull"
                Import-Module $moduleFileNameFull -Force -Verbose -ErrorAction Stop
                return $true
            } else {
                # Read the content of the script file
                $content = Get-Content -Path $moduleFileNameFull -ErrorAction Stop

                # Loop through each line in the content
                foreach ($line in $content) {
                    # Use a regex to match function definitions
                    # if ($line -match 'function\s+(\w+)') {
                    # Explanation of the Updated Regex:
                    # function\s+: Matches the keyword function followed by one or more spaces.
                    # (\w+): Captures the function name, which consists of word characters (letters, digits, or underscores).
                    # (\s*$.*$)?: Optionally matches any whitespace followed by parentheses containing any characters (this captures the parameter list). The ? makes this group optional, allowing for functions without parameters.
                    # \s*{: Matches any whitespace followed by the opening curly brace {, indicating the start of the function body.
                    if ($line -match 'function\s+(\w+)(\s*$.*$)?\s*{') {
                        # Extract the function name
                        $functionNameNext = $matches[1]
                        if ($functionNames -contains $functionNameNext) {
                            # Found a/the function
                            Write-Verbose "Found function: $functionNameNext"
                            if (-not $importFound) {
                                $importFound = $true
                                Write-Verbose "Dot including the component file: $moduleFileNameFull"
                                . $moduleFileNameFull
                            }
                            # Export the found function.
                            Export-ModuleMember $functionNameNext
                        }
                    }
                }
            }
            if (-not $importFound) { 
                Write-Verbose "No specified functions found in the module."
                return $false 
            }
        } catch {
            Write-Error -Message "An error occurred: $_"
            return $false
        }
    }
    
    end {
        # Optional: Any cleanup or finalization code can go here
    }
}
#endregion
#region Module State

function Get-ModuleProperty {
    <#
    .SYNOPSIS
        Gets the Module property.
    .DESCRIPTION
        Retrieves the value of the Module property.
    .PARAMETER InputObject
        The input object to retrieve the property from.
    .EXAMPLE
        Get-ModuleProperty -InputObject $obj
    .Outputs
        System.String
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$InputObject
    )
    process {
        return ($InputObject | Select-Object -ExpandProperty Module)
    }
}
function Set-ModuleProperty {
    <#
    .SYNOPSIS
        Sets the Module property.
    .DESCRIPTION
        Updates the value of the Module property.
    .PARAMETER InputObject
        The input object to update the property on.
    .PARAMETER Value
        The new value for the Module property.
    .EXAMPLE
        Set-ModuleProperty -InputObject $obj -Value "new value"
    .OUTPUTS
        System.Void
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$InputObject,
    
        [Parameter(Mandatory = $true)]
        [string]$Value
    )
    process { $InputObject | ForEach-Object { $_.Module = $Value } }
}
function Get-ModuleConfig {
    <#
    .SYNOPSIS
        Retrieves the Module configuration.
    .DESCRIPTION
        Gets the Module configuration settings.
    .EXAMPLE
        Get-ModuleConfig
    .OUTPUTS
        System.Collections.Hashtable
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Filter = "*"
    )
    begin {
        $config = @{
            "Setting1" = "Value1"
            "Setting2" = "Value2"
            "Setting3" = "Value3"
        }
    }
    process {
        if ($Filter) {
            return @($config | Where-Object { $_.Name -like $Filter })
        } else {
            return $config
        }
    }
}
function Set-ModuleConfig {
    <#
    .SYNOPSIS
        Updates the Module configuration.
    .DESCRIPTION
        Sets the Module configuration settings.
    .PARAMETER Config
        The new configuration values.
    .EXAMPLE
        Set-ModuleConfig -Config @{
            "Setting1" = "New Value"
            "Setting2" = "New Value"
        }
    .OUTPUTS
        System.Void
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Config
    )
    process {
        foreach ($key in $config.Keys) {
            Set-Item -Path ("Module.Config.$key") -Value $config[$key]
        }
    }
}
    
#endregion
#region Module Status
function Get-ModuleStatus {
    <#
    .SYNOPSIS
        Retrieves the Module status.
    .DESCRIPTION
        Gets the current status of Module.
    .EXAMPLE
        Get-ModuleStatus
    .OUTPUTS
        System.String
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Format = "Detailed"
    )
    process {
        if ($Format -eq "Brief") {
            return "Module is online."
        } else {
            return "Module status: Online, last updated 2023-02-20 14:30:00 UTC"
        }
    }
}
function Set-ModuleStatus {
    <#
    .SYNOPSIS
        Updates the Module status.
    .DESCRIPTION
        Sets the current status of Module.
    .PARAMETER Status
        The new status value.
    .EXAMPLE
        Set-ModuleStatus -Status "Offline"
    .OUTPUTS
        System.Void
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Status
    )
    process { Set-Item -Path "Module.Status" -Value $Status }
}
#endregion
