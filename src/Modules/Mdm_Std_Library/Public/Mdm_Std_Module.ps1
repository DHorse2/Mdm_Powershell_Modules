
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
        [string]$moduleRootPath,
        [string]$modulePublicFolder,
        [string]$modulePrivateFolder,
        [switch]$TraceDetails,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    begin {
        if (-not $modulePublicFolder) { $modulePublic = "$moduleRootPath\Public" }
        else { $modulePublic = "$moduleRootPath\$modulePublicFolder" }
        if (-not $modulePrivateFolder) { $modulePrivate = "$moduleRootPath\Private" }
        else { $modulePrivate = "$moduleRootPath\$modulePrivateFolder" }

        # $moduleName = Split-Path ((get-item $moduleRootPath ).FullName) -leaf
        $moduleName = [System.IO.Path]::GetFileName($moduleRootPath)
        # Create a new module object
        $module = New-Object PSObject -Property @{
            Name             = [System.IO.Path]::GetFileName($moduleRootPath)
            Path             = $moduleRootPath
            PublicFunctions  = @()
            PrivateFunctions = @()
            Scripts          = @()
        }
        $moduleNameDisplayed = $false
}
    process {
        # Export-ModuleMemberScan
        #Get public and private function definition files.
        $Flat = @( Get-ChildItem -Path "$moduleRootPath\*.ps1" -ErrorAction SilentlyContinue )
        $Public = @( Get-ChildItem -Path "$modulePublic\*.ps1" -ErrorAction SilentlyContinue )
        $Private = @( Get-ChildItem -Path "$modulePrivate\*.ps1" -ErrorAction SilentlyContinue )
        if ($DoVerbose) {
            $Message = "ModuleMemberScan Module: $($module.Name)"
            Add-LogText -Messages $Message
            $moduleNameDisplayed = $true
        }
        # $TraceDetails = $false
        # Dot source the files
        Foreach ($import in @($Public + $Private + $Flat)) {
            Try {
                # $fileName = Split-Path $import -leaf
                $functionName = [System.IO.Path]::GetFileNameWithoutExtension($import.FullName)
                # Get functions defined in the script
                $functions = Get-Command -Name * -CommandType Function | Where-Object { $_.Source -eq $import.FullName } -ErrorAction Continue
                if ($functions) {
                    $functionsString = $($functions | ForEach-Object { $_.Name } -join ', ')
                } else { $functionsString = "$($functionName)_Func" }
                if ($TraceDetails -or ($Verbose -or $DoVerbose)) {
                    if (-not $moduleNameDisplayed) { 
                        $moduleNameDisplayed = $true
                        $Message = "Scan Module $($module.Name): "
                        Add-LogText -Messages $Message -NoNewLine
                    }
                    if ($Verbose -or $DoVerbose) {
                        $Message = "   Component: $($functionName) with functions: $functionsString"
                        Add-LogText -Messages $Message
                    } else {
                        $Message = "$functionName "
                        Add-LogText -Messages $Message -NoNewline
                    }
                }
                if ($functions) {
                    # If functions are found, dot-source the file
                    . $import.FullName
                    if ($TraceDetails -and ($Verbose -or $DoVerbose)) {
                        $Message = "        Function imported: $($import.FullName)" 
                        Add-LogText -Messages $Message -ForegroundColor Green 
                    }
                } else {
                    # If no functions are found, create a wrapper function
                    if ($TraceDetails -and ($Verbose -or $DoVerbose)) {
                        $Message = "        Executable Script: $($import.FullName)" 
                        Add-LogText -Messages $Message -ForegroundColor Green 
                    }
                    $scriptNameFull = $import.FullName
                    $scriptName = "$($functionName)_Func"
                    $functionsString = $scriptName
                    $wrapperFunction = @"
function $scriptName {
    & `"$($import.FullName)`"
}
"@
                    # Use Invoke-Expression to define the wrapper function
                    Invoke-Expression $wrapperFunction
                    if ($TraceDetails -and ($Verbose -or $DoVerbose)) {
                        $Message = " Created wrapper function: $scriptName." # Script: $scriptNameFull"
                        Add-LogText -Messages $Message -ForegroundColor Green 
                    }
                }
                if ($import.FullName.IndexOf("Private") -lt 0) {
                    # Public and Common (Root)
                    Export-ModuleMember -Function $functionsString
                    $module.PublicFunctions += $functionsString
                    if ($TraceDetails -and ($Verbose -or $DoVerbose)) {
                        $Message = "         Public Component: $($import.FullName) with functions: $($functions.Name -join ', ')"
                        Add-LogText -Messages $Message -ForegroundColor Green 
                    }
                } else { 
                    # Private
                    $module.PrivateFunctions += $functionsString
                    if ($TraceDetails -and ($Verbose -or $DoVerbose)) {
                        $Message = "         Private Component: $($import.FullName) skipped." 
                        Add-LogText -Messages $Message -ForegroundColor Green 
                    }
                }
            } catch {
                $Message = "Failed to import component $($import.FullName):"
                Add-LogText -IsWarning -ErrorPSItem $_ -Message $Message
                # Add-LogText -Messages $Message
            }
        }
        if ($TraceDetails -and -not($Verbose -or $DoVerbose)) {
            $Message = " " 
            Add-LogText -Messages $Message
        }
    }
    end { return $module }
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
        [string]$moduleRootPath,
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
        $functionFound = $false
        try {
            # $moduleComponent not done. IE "Mdm_Std_Errors.ps1" TODO
            if (-not $functionNames) {
                Write-Verbose "Importing entire module: $moduleFileNameFull"
                Import-Module $moduleFileNameFull -Force -Verbose -ErrorAction Stop
                $importFound = $true
                return $true
            } elseif ($functionNames) {
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
                            $functionFound = $true
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
            } else {
                Throw "No module or functions specified."
            }
        } catch {
            Write-Error -Message "An error occurred: $_"
            return $false
        }
        if (-not $importFound -and -not $functionFound) {
            if (-not $importFound) {
                Write-Verbose "No import of the module $moduleFileNameFull."
            }
            if ($functionNames -and -not $functionFound) { 
                Write-Verbose "No specified functions found in the module $moduleFileNameFull."
            }
            return $false 
        }
    }
    
    end {
        # Optional: Any cleanup or finalization code can go here
    }
}
#endregion
#region Module State
function Confirm-Module {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$modulePath,
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause
    )
    process {
        if (-not $modulePath) {
            $modulePath = "$global:moduleRootPath\$Name"
        }
        if ($DoVerbose) { Write-Output "Exists: $(Test-Path "$modulePath"): $modulePath" }
        if (-not(Test-Path "$modulePath\$Name.psm1") -and -not(Test-Path "$modulePath\$Name.psd1")) {
            $moduleValid = $false
        } else { $moduleValid = $true }
    }
    end { $moduleValid }
}
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
