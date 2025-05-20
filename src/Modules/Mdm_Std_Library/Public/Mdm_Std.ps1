
# Mdm_Std.ps1
function Set-StdGlobals {
    <#
    .SYNOPSIS
        Checks global variables and state.
    .DESCRIPTION
        This will set globals to the passed values without validation.
    .PARAMETER message
        The system message. Not used.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-StdGlobals -DoPause -DoVerbose -DoDebug
    .NOTES
        none.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Message = "",
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [switch]$SkipClear,
        [switch]$Preserve
    )
    if (-not $Preserve) {
        $global:DoForce = $local:DoForce
        $global:DoPause = $local:DoPause
        $global:DoVerbose = $local:DoVerbose
        $global:DoDebug = $local:DoDebug
        $global:Message = $local:message
    } else {
        # What this means is that 
        # if they are on, they won't be turned off.
        if (-not $SkipClear) {
            $global:DoForce = $false
            $global:DoPause = $false
            $global:DoVerbose = $false
            $global:DoDebug = $false
            $global:Message = ""
        }
        # However they can be turned on.
        if ($local:DoForce) { $global:DoForce = $local:DoForce }
        if ($local:DoPause) { $global:DoPause = $local:DoPause }
        if ($local:DoVerbose) { $global:DoVerbose = $local:DoVerbose }
        if ($local:DoDebug) { $global:DoDebug = $local:DoDebug }
        if ($local:message.Length -gt 0) { $global:Message = $Message }
    }
    # Parameters
    $path = "$($(Get-Item $PSScriptRoot).FullName)\Get-Parameters.ps1"
    . "$path"
    # Output the current settings
    Write-Debug "Set-StdGlobals: Debug Mode: $DoDebug. Preference: $DebugPreference"
    Write-Verbose "Set-StdGlobals: Verbose Mode: $DoVerbose. Preference: $VerbosePreference"
}
function Get-StdGlobals {
    <#
    .SYNOPSIS
        Gets global variables and state.
    .DESCRIPTION
        This will get globals to be returned without validation.
    .PARAMETER message
        The system message. Not used.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-StdGlobals -DoPause -DoVerbose -DoDebug
    .NOTES
        none.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$DoClear
    )
    if ($DoClear) {
        $global:DoPause = $false
        $global:DoVerbose = $false
        $global:DoDebug = $false
        $global:DoForce = $false
        $global:Message = ""
    }
    return @($global:DoPause, $global:DoVerbose, $global:DoDebug, $global:DoForce, $global:Message)
}
function Show-StdGlobals {
    param (
        $something
    )
    process {
        Write-Host " "
        Write-Host "Folders:"
        Write-Host "Project Root: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
        Write-Host " Module Root: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
        Write-Host "Execution at: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
        Write-Host " "
        Write-Host "Modules:"
        $importName = "Mdm_Std_Library"
        $modulePath = "$global:moduleRootPath\$importName"
        # Write-Host "Module 1: $importName"
        Write-Host "1. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_Bootstrap"
        $modulePath = "$global:moduleRootPath\$importName"
        # Write-Host "Module 2: $importName"
        Write-Host "2. Exists: $(Test-Path "$modulePath"): $importName"
        Write-Host "3. Available empty slot"
        $importName = "Mdm_WinFormPS"
        $modulePath = "$global:moduleRootPath\$importName"
        # Write-Host "Module 4: $importName"
        Write-Host "4. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_Nightroman_PowerShelf"
        $modulePath = "$global:moduleRootPath\$importName"
        # Write-Host "Module 5: $importName"
        Write-Host "5. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_DevEnv_Install"
        $modulePath = "$global:moduleRootPath\$importName"
        # Write-Host "Module 6: $importName"
        Write-Host "6. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_PoshFunctions"
        $modulePath = "$global:moduleRootPath\$importName"
        # Write-Host "Module 7: $importName"
        Write-Host "7. Exists: $(Test-Path "$modulePath"): $importName"
        $importName = "Mdm_Springcomp_MyBox"
        $modulePath = "$global:moduleRootPath\$importName"
        # Write-Host "Module 8: $importName"
        Write-Host "8. Exists: $(Test-Path "$modulePath"): $importName"
        Write-Host " "
        Write-Host "Project: Exists: $(Test-Path "$global:projectRootPath"): $global:projectRootPath"
        Write-Host " Module: Exists: $(Test-Path "$global:moduleRootPath"): $global:moduleRootPath"
        Write-Host " Actual: Exists: $(Test-Path "$global:projectRootPathActual"): $global:projectRootPathActual"
        Write-Host " "
        Write-Host " Log File Name: $global:logFileName"
        Write-Host " Log File Path: $global:logFilePath"
        Write-Host " Log File Name Full: $global:logFileNameFull"
        Write-Host " Log One File: $global:LogOneFile"

        Write-Host " "
        Write-Host "Run Control:"
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity
        $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
        $global:developerMode = Test-Path -Path "$global:projectRootPath\IsDevMode.txt"
        $Message = "Developer mode: $global:developerMode, "
        $Message += "$(if ($principal.IsInRole($adminRole)) { '[Admin] ' } else { '' }) "
        $Message += "$(if (Test-Path Variable:/PSDebugContext) { '[DBG] ' } else { '' })"
        Write-Host $Message
        Write-Host "  Initialized: $InitStdDone"
        Write-Host "  Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug, Force: $local:DoForce"
        Write-Host " Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug, Force: $global:DoForce"
        Write-Host "       Prompt: $global:msgAnykey"
        $headingDone = $false
        foreach ($paramItem in $commonParameters.GetEnumerator()) {
            if (-not $headingDone) {
                $headingDone = $true
                Write-Host "Common Parameters:"
            }
            Write-Host "    Param: $($paramItem.Key): $($paramItem.Value)"
        }
        Write-Host " "
    }
}
function Initialize-StdGlobals {
    [CmdletBinding()]
    param (
        [switch]$DoCheckState,
        [string]$logFileNameFull
    )
    
    begin {
        $DoInit = $true
        if ($DoCheckState -and $global:InitDone) { return }
        # Script Path
        if (-not $global:moduleRootPath) {
            $folderName = Split-Path ((get-item $PSScriptRoot ).FullName) -Leaf
            if ( $folderName -eq "Public" -or $folderName -eq "Private" ) {
                $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.Parent.FullName
            } else { $global:moduleRootPath = (get-item $PSScriptRoot ).Parent.FullName }
        }
        if (-not $global:projectRootPath) { $global:projectRootPath = (get-item $global:moduleRootPath).Parent.Parent.FullName }
    }
    process {
        if ($DoInit) {
            # This indicates that the modules have not been previously imported. 
            [bool]$global:InitDone = $true
            [bool]$global:InitStdDone = $false
            #
            [string]$global:companyName = "MacroDM"
            [string]$global:companyNamePrefix = "Mdm"
            [string]$global:author = "David G. Horsman"
            [string]$global:copyright = $global:author
            [string]$global:copyright = "&Copy-Item; $global:copyright. All rights reserved."
            [string]$global:license = "MIT"
            [string]$global:title = ""

            # Modules array. These will be auto documented
            [array]$global:moduleNames = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install", "Mdm_Modules")
            # Modules array. These are imported external product
            [array]$global:moduleAddons = @("Mdm_Nightroman_PowerShelf", "Mdm_Springcomp_MyBox")
        
            # Parameters
            [hashtable]$global:commonParamsPrelude = @{}
            [hashtable]$global:commonParams = @{}
            [hashtable]$global:combinedParams = @{}
            [hashtable]$global:mdmParams = @{}

            # Error display handling options:
            [bool]$global:UseTrace = $true
            [bool]$global:UseTraceDetails = $true
            [bool]$global:UseTraceStack = $true
            [bool]$global:DebugProgressFindName = $true
            [int]$global:debugTraceStep = 0
            [string]$global:debugSetting = ""
            # include debug info with warnings
            [bool]$global:UseTraceWarning = $true
            # include full details with warnings
            [bool]$global:UseTraceWarningDetails = $false
            # Built in Powershell based Method:
            [bool]$global:UsePsBreakpoint = $true
        
            # Set-PSBreakpoint
            # pause on this cmdlet/function name
            [bool]$global:DebugProgressFindName = $true
            [array]$global:debugFunctionNames = @()
            # [array]$global:debugFunctionNames = @("Get-Vs", "Get-DevEnvVersions")
            # [array]$global:debugFunctionNames = @("Get-Vs", "Get-DevEnvVersions", "Add-RegistryPath", "Assert-RegistryValue")
            [string]$global:debugFunctionName = ""
            [bool]$global:DebugInScriptDebugger = $false
            [int]$global:debugFunctioLineNumber = 0
            [string]$global:debugWatchVariable = ""
            [string]$global:debugMode = "Write"
            
            # Built in Powershell based Method:
            if ($global:UsePsBreakpoint) {
                try {
                    #PSDebug
                    if ($global:debugSetting.Length -ge 1) {
                        $commandNext = "Set-PSDebug -$global:debugSetting"
                    } else {
                        $commandNext = "Set-PSDebug -Off"
                    }
                    Invoke-Expression $commandNext
                    #PSBreakpoint
                    #  TODO Get-PSBreakpoint | Remove-PSBreakpoint
                    Set-PSBreakPoint -Command "Debug-Script" -Action { 
                        Write-Host "<*>" -ForegroundColor Red
                        # Debug-Script -Break;
                    }
                    if ($global:debugFunctionName.Length -ge 1) {
                        Set-PSBreakPoint -Command $global:debugFunctionName -Action { Debug-Script -Break; }
                        Write-Host "Break set up for $global:debugFunctionName" -ForegroundColor Green
                    }
                    foreach ($functionName in $global:debugFunctionNames) {
                        Set-PSBreakpoint -Command $functionName -Action { Debug-Script -Break; }
                        Write-Host "Break set up for $functionName" -ForegroundColor Green
                    }
                } catch {
                    Write-Host -Message "Initialize-StdGlobals PSBreakpoint (global:InitDone). `n$_" `
                        -ForegroundColor Red
                    #  -ErrorRecord $_
                    Write-Host "Powershell debug features are currently unavailable in the Mdm Standard Library" `
                        -ForegroundColor Red
                }
                # This doesn't work:
                # Source : https://stackoverflow.com/questions/20912371/is-there-a-way-to-enter-the-debugger-on-an-error/
                # Get the current session using Get-PSSession
                # $currentSession = New-PSSession
                # $currentSession = Get-PSSession
                # $currentSession = Get-PSSession | Where-Object { $_.Id -eq $session.Id }
        
                # Extract relevant properties from the existing session
                # $computerName = $currentSession.ComputerName
                # $credential = $currentSession.Credential
                # $newSession = New-PSSession -ComputerName $computerName -Credential $credential
                # Invoke-Command -Session $currentSession -ScriptBlock {
                # Set-PSBreakPoint -Command Debug-Script -Action { break; }
                # Break on LINE
                # Set-PSBreakpoint -Script "C:\Path\To\YourScript.ps1" -Line 10
                # }
            }
            # Control and defaults
            [bool]$global:DoVerbose = $false
            [bool]$global:DoPause = $false
            # [bool]$global:DoDebug = $false
            [bool]$global:DoDebug = Assert-Debug
            [bool]$global:DoForce = $false

            [string]$global:debugErrorActionPreference = "Continue"
            [string]$global:msgAnykey = ""
            [string]$global:msgYorN = ""
            
            # Color of error and warning text
            $global:opt = (Get-Host).PrivateData
            $colorChanged = $false # TODO Type handling bug bypass
            Add-Type -AssemblyName PresentationCore
            [System.ConsoleColor]$global:messageBackgroundColor = [System.ConsoleColor]::Black
            [System.ConsoleColor]$global:messageForegroundColor = [System.ConsoleColor]::White
            [System.ConsoleColor]$global:messageWarningBackgroundColor = Convert-MediaToConsoleColor($global:opt.WarningBackgroundColor)
            [System.ConsoleColor]$global:messageWarningForegroundColor = Convert-MediaToConsoleColor($global:opt.WarningForegroundColor)
            [System.ConsoleColor]$global:messageErrorBackgroundColor = Convert-MediaToConsoleColor($global:opt.ErrorBackgroundColor)
            [System.ConsoleColor]$global:messageErrorForegroundColor = Convert-MediaToConsoleColor($global:opt.ErrorForegroundColor)
        
            iF ($colorChanged) {
                $global:opt.WarningBackgroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageWarningBackgroundColor)
                $global:opt.WarningForegroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageWarningForegroundColor)
                $global:opt.ErrorBackgroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageErrorBackgroundColor)
                $global:opt.ErrorForegroundColor = Convert-ConsoleToMediaColor([System.ConsoleColor]$global:messageErrorForegroundColor)
            }
        
            $global:timeStarted = Get-Date
            $global:timeStartedFormatted = "{0:yyyyMMdd_HHmmss}" -f $global:timeStarted
            $global:timeCompleted = $null
            $global:lastError = $null
        }
        # Log
        # The log file name is set.
        # But it won't be created until Add-LogText is called.
        if (-not $global:logFileNameFull) { Open-LogFile -SkipCreate }
    }
    end { }
}
function Reset-StdGlobals {
    <#
    .SYNOPSIS
        Resets the global state.
    .DESCRIPTION
        This equates to, and uses, 
            automatic variables, 
            $PS variables, 
            module metadata and
            state.
    .PARAMETER msgAnykey
        The prompt for "Enter any key".
    .PARAMETER msgYorN
        The prompt for "Enter Y, N, or Q to quit".
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .PARAMETER initDone
        Switch: indicates initialization is done.
    .OUTPUTS
        none.
    .EXAMPLE
        Reset-StdGlobals
#>


    [CmdletBinding()]
    param (
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$msgAnykey = "",
        [string]$msgYorN = "",
        [switch]$initDone
    )
    process {
        $global:msgAnykey = $msgAnykey
        $global:msgYorN = $msgYorN
        $global:InitStdDone = $initDone
        # TODO syntax error with params
        Set-StdGlobals -DoDebug:$DoDebug -DoVerbose:$DoVerbose -DoPause:$DoPause -DoForce:$DoForce
    }
}
# ###############################
function Initialize-Std {
    <#
    .SYNOPSIS
        Initializes a script..
    .DESCRIPTION
        This processes switches, automatic variables, state.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Global variables are set.
    .EXAMPLE
        Initialize-Std -DoPause:$DoPause -DoVerbose:$DoVerbose
    .EXAMPLE
        Reset-StdGlobals
        Initialize-Std -DoPause:$DoPause -DoVerbose:$DoVerbose
    .NOTES
        none.
#>


    [CmdletBinding()]
    param (
        [switch]$DoForce,
        [switch]$DoVerbose,
        [switch]$DoDebug,
        [switch]$DoPause,
        [string]$errorActionValue,
        [string]$debugPreference
    )
    process {
        # Show-StdGlobals
        Write-Verbose "Initialize-Std"
        if ($DoForce -or -not $global:InitStdDone) {
            Write-Verbose " initializing..."
            # $global:DoPause = $local:DoPause; $global:DoVerbose = $local:DoVerbose
            $global:InitStdDone = $true
            # Validation
            # Default messages
            if ($global:msgAnykey.Length -le 0) { 
                $global:msgAnykey = "Press any key to continue" 
                Write-Debug "Anykey: $global:msgAnykey"
            }
            if ($global:msgYorN.Length -le 0) { 
                $global:msgYorN = "Enter Y to continue, Q to quit or N to exit" 
                Write-Debug "YorN: $global:msgYorN"
            }

            # Pause
            if ($local:DoPause) { $global:DoPause = $true } else { $global:DoPause = $false }
            Write-Debug "Global pause: $global:DoPause"

            # Debug
            if ($local:DoDebug) { $global:DoDebug = $true } else { $global:DoDebug = $false }
            # TODO PowerShell setting for -Debug (Issue 2: doesn't work)
            if ($DebugPreference -and $DebugPreference -ne 'SilentlyContinue') { 
                Write-Verbose "Preference: $DebugPreference"
                $global:DoDebug = $true 
            } else {
                if ($local:DoDebug) {
                    $global:DoDebug = $true
                    $DebugPreference = 'Continue'
                    if ($global:DoPause) { $DebugPreference = 'Inquire' }
                } else { $global:DoDebug = $false }
            }
            if ($global:DoDebug) { Write-Verbose "Debugging." } else { Write-Verbose "Debug off." }

            # Verbosity TODO syntax errors
            if ($local:DoVerbose) {
                $global:DoVerbose = $true 
                $VerbosePreference = $true
            } else {
                $global:DoVerbose = $false
                $VerbosePreference = $false
            }

            # Error Action
            # could check PS values. debugPreference
            # The possible values for $PSDebugPreference are:
            $debugPreferenceSet = $true
            switch ($PSDebugPreference) {
                "Continue" { 
                    # This is the default value. 
                    # It allows the script to continue running even if there are errors. 
                    # It will display error messages in the console. 
                }
                "Stop" { 
                    # Will stop execution when an error occurs. 
                }
                "SilentlyContinue" { 
                    # Suppresses (ignore) error messages.
                    # Allows the script to continue running without interruption.
                    # It is useful when you want to ignore errors. 
                }
                "Inquire" { 
                    # When set to Inquire, PowerShell will prompt the user for input when an error occurs, allowing the user to decide how to proceed. 
                }
                "Ignore" { 
                    # This value ignores errors and continues execution without displaying any messages. 
                }
                Default {
                    # Continue
                    $debugPreferenceSet = $false
                    $debugPreference = $PSDebugPreference
                }
            }
            if ($debugPreferenceSet) { 
                $PSDebugPreference = $debugPreference
                $global:errorActionValue = $debugPreference
            }
            if ($errorActionValue) { $global:errorActionValue = $errorActionValue }

            # Check automatice parameters 
            # TODO Write-Host "PSBoundParameters: $PSBoundParameters" (Issue 1: doesn't work)
            # TODO Write-Host "PSBoundParameters Verbose: $($PSCmdlet.Get-Invocation.BoundParameters['Verbose'])" (Issue 1: doesn't work)
            # TODO Write-Host "VerbosePreference: $VerbosePreference" # (Issue 1: doesn't work)

            # PowerShell setting
            # return [bool]$VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue    
            if ($PSBoundParameters.ContainsKey('Verbose')) { 
                # $PSCmdlet.Get-Invocation.BoundParameters["Verbose"]
                # VerbosePreference
                # Command line specifies -Verbose
                $b = $PsBoundParameters.Get_Item('Verbose')
                $global:DoVerbose = $b
                Write-Host "Bound Param Verbose $b"
                # $global:DoVerbose = $false
                if ($null -eq $b) { $global:DoVerbose = $false }
                Write-Debug "Verbose from Bound Param: $global:DoVerbose"
            } else { 
                Write-Debug "Verbose key not present."
            }
            # Verbosity via -verbose produces output.
            $output = ""
            Write-Verbose "Verbose" > $output
            if ($output.Length -gt 0) { $global:DoVerbose = $true }
            if ($global:DoVerbose) {
                Write-Verbose "Verbose."
            } else { Write-Debug "Shhhhh......" }

            $global:developerMode = Test-Path -Path "$global:projectRootPath\IsDevMode.txt"

            # ??? Maybe
            # Set-prompt
        }
        if ($global:DoVerbose) {
            Write-Host ""
            Write-Host "Init end  Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug"
            Write-Host "Init end Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug, Force: $global:DoForce Init: $global:InitStdDone"
        }
        $null = Set-CommonParametersGlobal

        # $importName = "Mdm_Std_Library"
        # $modulePath = "$global:moduleRootPath\$importName"
        # if (-not ((Get-Module -Name $importName) -or $global:DoForce)) {
        #     Import-Module -Name $modulePath @global:commonParamsStd
        # }
    }
}
function Start-Std {
    <#
    .SYNOPSIS
        Reset and initialize.
    .DESCRIPTION
        This resets the global values and call the initializations.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Start-Std -DoVerbose
    .NOTES
        This serves little purpose.
#>


    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug, [switch]$DoForce)
    process {
        # Import-Module Mdm_Std_Library -Force
        Reset-StdGlobals  `
            -DoPause:$DoPause `
            -DoVerbose:$DoVerbose `
            -DoDebug:$DoDebug
        Initialize-Std `
            -DoPause:$DoPause `
            -DoVerbose:$DoVerbose `
            -DoDebug:$DoDebug
        if ($global:DoVerbose) { Write-Host "Script Started." }
    }
}
function Set-CommonParametersGlobal {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [hashtable]$commonParameters = @{}
    )
    begin {
        # Initialize outputParams as a hashtable
        [hashtable]$outputParams = @{}
        if (-not $commonParameters) { $commonParameters = $PSBoundParameters }
    }
    process {
        # Copy each key-value pair from the incoming hashtable
        foreach ($key in $commonParameters.Keys) {
            $outputParams[$key] = $commonParameters[$key]
        }
    }
    end {
        # Add global parameters based on conditions
        if ($global:DoForce) { $outputParams['Force'] = $true }
        if ($global:DoVerbose) { $outputParams['Verbose'] = $true }
        if ($global:DoDebug) { $outputParams['Debug'] = $true }
        # if ($global:DoPause) { $outputParams['Pause'] = $true }
        $outputParams['ErrorAction'] = if ($global:errorActionValue) { $global:errorActionValue } else { 'Continue' }

        # Combine with global prelude
        [hashtable]$global:commonParams = @{}
        foreach ($key in $global:commonParamsPrelude.Keys) {
            $commonParameters[$key] = $global:commonParamsPrelude[$key]
        }
        foreach ($key in $outputParams.Keys) {
            $commonParameters[$key] = $outputParams[$key]
        }

        # Return the combined parameters
        return [hashtable]$global:commonParams
    }
}
# ###############################
# Exports from .psm1 (here) module
Export-ModuleMember -Function @(
    # Mdm_Std_Library
    "Initialize-StdGlobals",
    "Set-StdGlobals",
    "Get-StdGlobals",
    "Show-StdGlobals",
    "Start-Std"
)
