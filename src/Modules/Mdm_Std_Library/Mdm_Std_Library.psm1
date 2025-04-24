
# Mdm_Std_Library
# Script Path
if (-not $global:scriptPath) { 
    $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
}
# Import-Module Mdm_Std_Library
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Error.ps1
Export-ModuleMember -Function @(
    # Exceptions Handling
    "Get-LastError",
    "Get-NewError",
    "Set-ErrorBreakOnLine",
    "Set-ErrorBreakOnFunction",
    "Set-ErrorBreakOnVariable",
    "Get-CallStackFormated",
    "Script_Debugger"
)
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Module.ps1
Export-ModuleMember -Function @(
    # Scan and feature (cmdlet) selection
    "Export-ModuleMemberScan",
    "Import-These",
    # Module State
    "Get-ModuleProperty",
    "Set-ModuleProperty",
    "Get-ModuleConfig",
    "Set-ModuleConfig",
    # Module Status
    "Get-ModuleStatus",
    "Set-ModuleStatus"
)
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Script.ps1
Export-ModuleMember -Function @(
    # This script:
    "Get-Invocation_PSCommandPath",
    "Get-PSCommandPath",
    "Get-MyCommand_Definition",
    "Get-MyCommand_InvocationName",
    "Get-MyCommand_Name",
    "Get-MyCommand_Origin",
    "Get-ScriptName",
    "Get-ScriptPositionalParameters",

    # Script:
    "Script_DoStart",
    "Initialize-Std",
    "Initialize-StdGlobalsReset",
    "Show-StdGlobals",
    "Set-DisplayColors",
    "Assert-SecElevated",
    "Assert-Verbose",
    "Push-ShellPwsh"
)
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Etl.ps1
Export-ModuleMember -Function @(
    # Etl
    # Path and directory
    "Get-DirectoryNameFromSaved",
    "Get-FileNamesFromPath",
    "Get-UriFromPath",
    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
    "Set-DirectoryToScriptRoot",
    "Set-SavedToDirectoryName",
    "Search-Directory",

    "Copy-ItemWithProgressDisplay",

    "ConvertFrom-HashValue",
    "ConvertTo-Text",
    "ConvertTo-ObjectArray",
    "ConvertTo-EscapedText",
    "ConvertTo-TrimedText",
    # Etl Log
    "Add-LogText",
    "Add-LogError",
    "Get-LogFileName",
    # Etl Html
    "Write-HtlmData"
)
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Help.ps1
Export-ModuleMember -Function @(
    # Help
    "Write-Mdm_Help",
    "Get-Mdm_Help",
    # "Write-Mdm_Help",  # Duplicate entry, consider removing if not needed
    "ConvertFrom-HtmlTemplate",
    "Get-HelpHtml",
    "Get-HtmlTemplate",
    "ConvertFrom-HtmlTemplate",
    "Export-Help"
)
. $global:scriptPath\Mdm_Std_Library\Get-AllCommands.ps1
Export-ModuleMember -Function "Get-AllCommands"

# Globals:
Write-Verbose "Loading globals..."
# Log
if (-not $global:logFileNameFull) {
    # The date and time will be appended to the name
    # when LogOneFile is false.
    [string]$global:logFileName = "Mdm_Installation_Log"
    [string]$global:logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log"
    [string]$global:logFileNameFull = ""
    # Use a single log file repeatedly appending to it.
    [bool]$global:LogOneFile = $false
}
# Global settings
if (-not $global:InitDone) { 
    # This indicates that the modules have not been previously imported. 
    [bool]$global:InitDone = $true
    [bool]$global:InitStdDone = $false
    # Modules array
    [array]$global:moduleNames = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install", "Mdm_Modules")
    [array]$global:moduleAddons = @("Mdm_Nightroman_PowerShelf", "Mdm_Springcomp_MyBox", "DevEnv_LanguageMode")

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
    [bool]$global:DebugProgressFindName = $false
    # [array]$global:debugFunctionNames = @()
    [array]$global:debugFunctionNames = @("Export-ModuleMemberScan")
    [string]$global:debugFunctionName = ""
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
            Get-PSBreakpoint | Remove-PSBreakpoint
            Set-PSBreakPoint -Command "Script_Debugger" -Action { 
                Write-Host "<*>" -ForegroundColor Red
                # Script_Debugger -Break;
            }
            if ($global:debugFunctionName.Length -ge 1) {
                Set-PSBreakPoint -Command $global:debugFunctionName -Action { Script_Debugger -Break; }
                Write-Host "Break set up for $global:debugFunctionName" -ForegroundColor Green
            }
            foreach ($functionName in $global:debugFunctionNames) {
                Set-PSBreakpoint -Command $functionName -Action { Script_Debugger -Break; }
                Write-Host "Break set up for $functionName" -ForegroundColor Green
            }
        } catch {
            Write-Error "$_"
            Write-Host "Powershell debug features are unavailable in the Mdm Standard Library" `
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
        # Set-PSBreakPoint -Command Script_Debugger -Action { break; }
        # Break on LINE
        # Set-PSBreakpoint -Script "C:\Path\To\YourScript.ps1" -Line 10
        # }
    }
    # Control and defaults
    [bool]$global:DoVerbose = $false
    [bool]$global:DoPause = $false
    [bool]$global:DoDebug = $false
    [string]$global:msgAnykey = ""
    [string]$global:msgYorN = ""
    
    # Color of error and warning text
    $global:opt = (Get-Host).PrivateData
    $global:messageBackgroundColor = [System.ConsoleColor]::Black
    $global:messageForegroundColor = [System.ConsoleColor]::White
    $global:opt.WarningBackgroundColor = [System.ConsoleColor]::Black
    $global:opt.WarningForegroundColor = [System.ConsoleColor]::DarkYellow
    # $global:opt.WarningForegroundColor = [System.ConsoleColor]::White
    $global:opt.ErrorBackgroundColor = [System.ConsoleColor]::Black
    $global:opt.ErrorForegroundColor = [System.ConsoleColor]::Red

    $global:timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
    $global:timeCompleted = $global:timeStarted
    $global:lastError = $null
}

# ###############################
function Assert-Verbose {
    <#
    .SYNOPSIS
        Asserts verbose is on.
    .DESCRIPTION
        Should check state.
    .OUTPUTS
        True if verbose is on
    .EXAMPLE
        If (Assert-Verbose) { $null }
    .NOTES
        I had to experiment to get automatic settings to work.
        Due to platform inconsistencies many admin maintain their own state.
#>
    [CmdletBinding()]
    param ()
    return $global:DoVerbose
}
## Customize the prompt
function Set-prompt {
    <#
    .SYNOPSIS
        Set command prompt.
    .DESCRIPTION
        Set command prompt to Module default.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-prompt
#>
    [CmdletBinding()]
    param (
        $prefix = "",
        $body = "",
        $suffix = ""
    )    
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    $prefix += if (Test-Path variable:/PSDebugContext) { '[DBG]: ' } else { '' }
    if ($principal.IsInRole($adminRole)) {
        $prefix = "'[ADMIN]':$prefix"
    }
    if (-not $body) { $body = '[MDM]PS ' + $PWD.path }
    $suffix += $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
    $prefix = $prefix -join ""
    $suffix = $suffix -join ""
    "${prefix}${body}${suffix}"
}
function Set-DisplayColors {
    [CmdletBinding()]
    param (
        $WarningBackgroundColor = "Orange",
        $WarningForegroundColor = "white",
        $ErrorBackgroundColor = "red",
        $ErrorForegroundColor = "white"    
    )
    process {
        # Change the color of error and warning text
        # https://sqljana.wordpress.com/2017/03/01/powershell-hate-the-error-text-and-warning-text-colors-change-it/
        $global:opt = (Get-Host).PrivateData
        $global:opt.WarningBackgroundColor = $WarningBackgroundColor
        $global:opt.WarningForegroundColor = $WarningForegroundColor
        $global:opt.ErrorBackgroundColor = $ErrorBackgroundColor
        $global:opt.ErrorForegroundColor = $ErrorForegroundColor
    }
}
# ###############################
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
        [Parameter(mandatory = $false)]
        [string]$message = "",
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug,
        [switch]$SkipClear,
        [switch]$Preserve
    )
    if (-not $Preserve) {
        $global:DoPause = $local:DoPause
        $global:DoVerbose = $local:DoVerbose
        $global:DoDebug = $local:DoDebug
        $global:message = $local:message
    } else {
        # What this means is that 
        # if they are on, they won't be turned off.
        if (-not $SkipClear) {
            $global:DoPause = $false
            $global:DoVerbose = $false
            $global:DoDebug = $false
            $global:message = ""
        }
        # However they can be turned on.
        if ($local:DoPause) { $global:DoPause = $local:DoPause }
        if ($local:DoVerbose) { $global:DoVerbose = $local:DoVerbose }
        if ($local:DoDebug) { $global:DoDebug = $local:DoDebug }
        if ($local:message.Length -gt 0) { $global:message = $message }
    }
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
        [Parameter(mandatory = $false)]
        [switch]$DoClear
    )
    if ($DoClear) {
        $global:DoPause = $false
        $global:DoVerbose = $false
        $global:DoDebug = $false
        $global:message = ""
    }
    return @($global:DoPause, $global:DoVerbose, $global:DoDebug, $global:message)
}
function IsDebugFunction {
    param (
        [Parameter(Mandatory = $true)]
        $functionName
    )
    return ($global:debugFunctionNames -contains $functionName)
}

# ###############################
function Wait-AnyKey {
    <#
    .SYNOPSIS
        Enter any key.
    .DESCRIPTION
        Prompts the user to enter any key to continue.
    .PARAMETER message
        The prompt message.
    .PARAMETER timeout
        Number of seconds to wait (if present).
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        none.
    .EXAMPLE
        Wait-AnyKey
#>
    [CmdletBinding()]
    param(
        [Parameter(mandatory = $false)]
        [string]$message = "",
        [Parameter(mandatory = $false)]
        [int]$timeout = -1,        
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )

    Write-Debug "$message Pause: $global:DoPause"
    if ([string]::IsNullOrEmpty($message)) {
        $message = $global:msgAnykey
    }
    if ([string]::IsNullOrEmpty($message)) {
        $message = 'Enter any key to continue: '
    }
    Set-StdGlobals `
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug
    # Write-Host "$message Pause: $global:DoPause"
    # if ($global:DoPause) {
    # Check if running PowerShell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    } else {
        Write-Host "$message " -ForegroundColor Yellow -NoNewline
        # $null = $host.ui.RawUI.ReadKey("NoEcho, IncludeKeyUp")
        $null = [Console]::ReadKey()
        Write-Host " " -ForegroundColor White
    }
    # }
}
# Set-Variable -Name "Wait-AnyKeyKey" -Value {
# param ($message)
# if (Assert-Verbose) { 
#     Write-Host "$message" -ForegroundColor Yellow -NoNewline
#     $null = $host.ui.RawUI.ReadKey("NoEcho, IncludeKeyDown")
# }
# } -Scope Global
# Todo wait timeout /t 5
# Timeout preparation
function Wait-CheckDoPause {
    <#
    .SYNOPSIS
        Check DoPause switch.
    .DESCRIPTION
        Returns true when DoPause is set.
    .OUTPUTS
        True is DoPause.
    .EXAMPLE
        Wait-CheckDoPause
    .NOTES
        Depreciated
        Rename to Assert-Pause
#>
    [CmdletBinding()]
    param ()
    return $global:DoPause
}
function Wait-YorNorQ {
    <#
    .SYNOPSIS
        Prompts for Y(es), N(o) or Q(uit).
    .DESCRIPTION
        Prompt the user for a Yes, No or Quit response.
    .PARAMETER message
        The prompt.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        The user response.
    .EXAMPLE
        $theResponse = Wait-YorNorQ "Wait?" 
#>
    [CmdletBinding()]
    param(
        [Parameter(mandatory = $false)]
        [string]$message = "",
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug    
    )
    ($local:DoPause, $local:DoVerbose, $local:DoDebug, $local:message ) = Get-StdGlobals
    # if ($global:DoPause) {
    if ([string]::IsNullOrEmpty($message)) {
        $message = $global:msgYorN
    }
    if ([string]::IsNullOrEmpty($message)) {
        $message = 'Press Y for Yes, Q to Quit, or N to exit'
    }
    if ([string]::IsNullOrEmpty($message)) {
        Write-Debug "The message is either null or empty."
        # } else {
        #     Write-Debug "The message is set: $message."
    }

    $response = ""
    $continue = 1
    Do {
        # $response = Read-Host -Prompt $message
        $response = Read-Host $message
        Switch ($response) {
            Y { 
                $continue = 0
                Write-Debug ' Answer Yes.'
                return $response
                break
            }
            N { 
                $continue = 0
                Write-Debug " Answer No."
                return $response
                break 
            }
            Q { exit }
        }
    } while ($continue -ne 0)
    # Write-Verbose 'The script executes yet another instruction'
    # } else { return $null }
    return $response
}
# Exports from .psm1 (here) module
Export-ModuleMember -Function @(
    # Mdm_Std_Library
    "Set-StdGlobals",
    "Get-StdGlobals",
    "IsDebugFunction",

    # Waiting & pausing
    "Wait-AnyKey",
    "Wait-CheckDoPause",
    "Set-StdGlobals",
    "Wait-YorNorQ"
)
