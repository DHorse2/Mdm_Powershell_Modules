<#
    .SYNOPSIS
        Mdm Standard Functions Library addresses cross-cutting functionality.
    .DESCRIPTION
        The Mdm (dba MacroDM) Standard Library is used by the other modules.
        It addresses cross-cutting functionality.
        This includes managing state, permissions, exceptions, path and files.
        Also other functions like pausing, prompting, displaying and searching.
        Also, help functions to auto-generate help more concisely & verbose.
        The universally available switches appear here.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        The Standard Functions Module.
    .EXAMPLE
        import-module Mdm_Std_Library
    .NOTES
        I was (PREVIOUSLY) unable to make this work in the psm1 file:
        It is the "dot sourcing" issue found online.
        ```powershell
            . "$PSScriptRoot\Assert-ScriptSecElevated.ps1"
            . "$PSScriptRoot\Build-ModuleExports.ps1"
            . "$PSScriptRoot\Get-DirectoryNameFromSaved.ps1"
            . "$PSScriptRoot\Get-FilesNamesFromSaved.ps1"
            . "$PSScriptRoot\Save-DirectoryName.ps1"
            . "$PSScriptRoot\Set-LocationToPath"
            . "$PSScriptRoot\Wait-AnyKey.ps1"
            . "$PSScriptRoot\Wait-CheckDoPause.ps1"
            . "$PSScriptRoot\Wait-YorNorQ.ps1"
        ```
        You have to dot source ". xxxx" these in your .PSM1 file.
        Also: See function Build-ModuleExports. 
        This also failed for the same reasons.
        
        Regarless: This is powershell best practices,
        and similar to modules in the wild.
        Additionally, the PSM1 file get unwieldly large
        while using the above technique isolates the functions
        making them easier to find.

        (It seems) the main difference is they typically use .net (C#).
        That isn't a barrier beyond wanting to master (THIS) powershell syntax.

        SOLUTION: This was caused by the registry's envronment setting:
            __PSLockDownPolicy
        This is 4 (Constrainted) and needs to be (8) Full Language Mode
        Note: This reduces the secutiy of the system. todo
        The bootstrap modules contains solution to alter this setting.
#>


if (-not $global:scriptPath) { $global:scriptPath = (get-item $PSScriptRoot ).parent.FullName }
# Imports
# Mdm_Std_Library
# Import-Module Mdm_Std_Library
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Etl.ps1
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Help.ps1
. $global:scriptPath\Mdm_Std_Library\Mdm_Std_Script.ps1
. $global:scriptPath\Mdm_Std_Library\Get-AllCommands.ps1


# Init
# $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
#
#  Options:
[bool]$global:UsePsTrace = $true;
[bool]$global:UsePsTraceWarning = $true;

# Globals:
Write-Verbose "Loading globals..."
[switch]$global:DoVerbose = $false
[switch]$global:DoPause = $false
[switch]$global:DoDebug = $false
[string]$global:msgAnykey = ""
[string]$global:msgYorN = ""
[switch]$global:initDone = $false

[string]$global:logFileName = "Mdm_Installation_Log"
[string]$global:logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log"
[string]$global:logFileNameFull = ""
[bool]$global:LogOneFile = $false
# [string]$global:scriptPath = (get-item $PSScriptRoot ).parent.FullName
[string]$global:scriptPath = ""
$global:moduleNames = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_Dev_Env_Install", "Mdm_Modules")

$global:timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
$global:timeCompleted = $global:timeStarted

# Change the color of error and warning text
#
# $Host.PrivateData.ErrorForegroundColor = 'red'
$opt = (Get-Host).PrivateData
$global:messageBackgroundColor = [System.ConsoleColor]::Black
$global:messageForegroundColor = [System.ConsoleColor]::White
$opt.WarningBackgroundColor = [System.ConsoleColor]::Black
$opt.WarningForegroundColor = [System.ConsoleColor]::DarkCyan
# $opt.WarningForegroundColor = [System.ConsoleColor]::White
$opt.ErrorBackgroundColor = [System.ConsoleColor]::Black
$opt.ErrorForegroundColor = [System.ConsoleColor]::Red
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
        Do to platform inconsistencies many admin maintain their own state.
#>
    [CmdletBinding()]
    param ()
    return $DoVerbose
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
# ###############################
function Wait-CheckGlobals {
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
        Wait-CheckGlobals -DoPause -DoVerbose -DoDebug
    .NOTES
        none.
#>
    [CmdletBinding()]
    param(
        [Parameter(mandatory = $false)]
        [string]$message = "",
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    if ($message.Length -gt 0) { $global:message = $message }
    if ($local:DoPause) { $global:DoPause = $local:DoPause }
    if ($local:DoVerbose) { $global:DoVerbose = $local:DoVerbose }
    if ($local:DoDebug) { $global:DoDebug = $local:DoDebug }
}
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
    Wait-CheckGlobals `
        -DoPause $DoPause `
        -DoVerbose $DoVerbose `
        -DoDebug $DoDebug
    # Write-Host "$message Pause: $global:DoPause"
    # if ($global:DoPause) {
    # Check if running PowerShell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else {
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
function ExecuteProcessWithTimeout {
    <#
    .SYNOPSIS
        Execute a command.
    .DESCRIPTION
        This executes the supplied command with a timeout.
    .PARAMETER command
        Command to execute.
    .PARAMETER timeout
        The timeout.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Performs the command.
    .EXAMPLE
        ExecuteProcessWithTimeout "notepad.exe" 30
#>
    [CmdletBinding()]
    param(
        [Parameter(mandatory = $false)]
        [string]$command = "",
        [Parameter(mandatory = $false)]
        [int]$timeout = 10
    )
    $process = Start-Process `
        -FilePath "$command" `
        -PassThru
    if ($process.WaitForExit($timeout)) {
        Write-Host "Process completed within timeout."
    }
    else {
        Write-Host "Process timed out and will be terminated."
        $process.Kill()
    }
}
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
    Wait-CheckGlobals `
        -DoPause $DoPause `
        -DoVerbose $DoVerbose `
        -DoDebug $DoDebug
    # if ($global:DoPause) {
    if ([string]::IsNullOrEmpty($message)) {
        $message = $global:msgYorN
    }
    if ([string]::IsNullOrEmpty($message)) {
        $message = 'Press Y for Yes, Q to Quit, or N to exit.'
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
# ###############################
function Initialize_Std {
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
        Initialize_Std -DoPause $DoPause -DoVerbose $DoVerbose
    .EXAMPLE
        Script_ResetStdGlobals
        Initialize_Std -DoPause $DoPause -DoVerbose $DoVerbose
    .NOTES
        none.
#>
    [CmdletBinding()]
    param (
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    # Write-Verbose "Init Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug"
    # Script_DisplayStdGlobals
    Write-Verbose "Initialize_Std"
    if (-not $global:initDone) {
        Write-Verbose " initializing..."
        # $global:DoPause = $local:DoPause; $global:DoVerbose = $local:DoVerbose
        $global:initDone = $true
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
        # PowerShell setting for -Debug (ToDo: Issue 2: doesn't work)
        if ($DebugPreference -ne 'SilentlyContinue') { $global:DoDebug = $true } else {
            if ($local:DoDebug) {
                $global:DoDebug = $true
                $DebugPreference = 'Continue'
                if ($global:DoPause) { $DebugPreference = 'Inquire' }
            }
            else { $global:DoDebug = $false }
        }
        if ($global:DoDebug) { Write-Host "Debugging." } else { Write-Verbose "Debug off." }

        # Verbosity
        if ($local:DoVerbose) { $global:DoVerbose = $true } else { $global:DoVerbose = $false }
        # Check automatice parameters 
        # Write-Host "PSBoundParameters: $PSBoundParameters" (ToDo: Issue 1: doesn't work)
        # Write-Host "PSBoundParameters Verbose: $($PSCmdlet.My_Invocation.BoundParameters['Verbose'])" (ToDo: Issue 1: doesn't work)
        # Write-Host "VerbosePreference: $VerbosePreference" # (ToDo: Issue 1: doesn't work)

        # PowerShell setting
        # return [bool]$VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue    
        if ($PSBoundParameters.ContainsKey('Verbose')) { 
            # $PSCmdlet.My_Invocation.BoundParameters["Verbose"]
            # VerbosePreference
            # Command line specifies -Verbose
            $b = $PsBoundParameters.Get_Item('Verbose')
            $global:DoVerbose = $b
            Write-Debug "Bound Param Verbose $b"
            # $global:DoVerbose = $false
            if ($null -eq $b) { $global:DoVerbose = $false }
            Write-Debug "Verbose from Bound Param: $global:DoVerbose"
        }
        else { 
            Write-Host "Verbose key not present."
        }
        # Verbosity via -verbose produces output.
        $output = ""
        Write-Verbose "Verbose" > $output
        if ($output.Length -gt 0) { $global:DoVerbose = $true }
        if ($global:DoVerbose) {
            Write-Verbose "Verbose."
        }
        else { Write-Verbose "Shhhhh....." }

        # ??? Maybe
        # Set-prompt
    }
    if ($global:DoVerbose) {
        Write-Host ""
        Write-Host "Init end  Local Pause: $local:DoPause, Verbose: $local:DoVerbose, Debug: $local:DoDebug"
        Write-Host "Init end Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug Init: $global:initDone"
    }
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
        $opt = (Get-Host).PrivateData
        $opt.WarningBackgroundColor = $WarningBackgroundColor
        $opt.WarningForegroundColor = $WarningForegroundColor
        $opt.ErrorBackgroundColor = $ErrorBackgroundColor
        $opt.ErrorForegroundColor = $ErrorForegroundColor
    }
}
