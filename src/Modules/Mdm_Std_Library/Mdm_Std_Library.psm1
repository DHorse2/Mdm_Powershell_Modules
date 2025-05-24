
Write-Host "Mdm_Std_Library.psm1"
# Script Paths - Project
if (-not $global:moduleRootPath) {
    $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Modules\Project.ps1"
    . "$path"
}
# Get-Parameters
$path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\Public\Get-Parameters.ps1"
. "$path"
# Join-Hashtable
#region Module Members
#region Classes
# Import Module - Mdm_Std_Library - Classes
class CommandResult {
    [int]$sequence
    [int]$exitCode
    [string]$CommandName
    [string[]]$standardOutput
    [string[]]$errorOutput
    [string]$CommandLine
    [string[]]$result

    # Constructor to initialize the properties
    CommandResult() {
        $this.sequence = 0
        $this.exitCode = 999
        $this.CommandName = $null
        $this.standardOutput = $null
        $this.errorOutput = $null
        $this.CommandLine = $null
        $this.result = $null

    }
    # Constructor to initialize the properties
    CommandResult([int]$sequence = 0, [int]$exitCode = 999, [string]$CommandName = $null, [string[]]$standardOutput = $null, [string[]]$errorOutput = $null, [string]$CommandLine = $null, [string[]]$result = $null) {
        $this.sequence = $sequence
        $this.exitCode = $exitCode
        $this.CommandName = $CommandName
        $this.standardOutput = $standardOutput
        $this.errorOutput = $errorOutput
        $this.CommandLine = $CommandLine
        $this.result = $result
    }

    # Method to display the properties
    [void] Display() {
        Write-Host "Sequence: $($this.sequence): Exit Code: $($this.exitCode) Command Name: $($this.CommandName)"
        Write-Host "Command Line: $($this.CommandLine)"
        if ($this.standardOutput) {
            Write-Host "Standard Output:"
            foreach ($line in $this.standardOutput) {
                Write-Host $line
            }
        }
        if ($this.errorOutput) {
            Write-Host "Error Output:"
            foreach ($line in $this.standardOutput) {
                Write-Host $line
            }
        }
        # if ($this.result) {
        #     Write-Host "Original Output: $($this.result)"
        # }
    }
    # CommandResultClass
    # $path = "$($(Get-Item $PSScriptRoot).Parent.FullName)\Mdm_Std_Library\Public\CommandResultClass.psm1"
    # Write-Output "Exists: $(Test-Path "$path"): $path"
    # . "$path"
    # Import-Module -Name $path
    # Import Module - Mdm_Std_Library - Classes
    # CommandResultClass
}
#endregion
#region Import Module Component files
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Error.ps1"
Export-ModuleMember -Function @(
    # Exceptions Handling
    
    "Assert-Debug"
    "Get-ErrorLast",
    "Get-ErrorNew",
    "Set-ErrorBreakOnLine",
    "Set-ErrorBreakOnFunction",
    "Set-ErrorBreakOnVariable",
    "Get-CallStackFormatted",

    "Debug-Script",
    "Debug-AssertFunction",
    "Debug-SubmitFunction",
    "Write-IndexOutOfBounds"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Input.ps1"
Export-ModuleMember -Function @(
    # Waiting & pausing
    "Wait-ForKeyPress",
    "Wait-AnyKey",
    "Wait-CheckDoPause",
    "Wait-YorNorQ"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Log.ps1"
Export-ModuleMember -Function @(
    # Etl Log
    "Add-LogText",
    "Add-LogError",
    "Open-LogFile"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Module.ps1"
Export-ModuleMember -Function @(
    # Scan and feature (cmdlet) selection
    "Export-ModuleMemberScan",
    "Import-These",
    # Module State
    "Confirm-Module",
    "Get-ModuleProperty",
    "Set-ModuleProperty",
    "Get-ModuleConfig",
    "Set-ModuleConfig",
    # Module Status
    "Get-ModuleStatus",
    "Set-ModuleStatus"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std.ps1"
Export-ModuleMember -Function @(
    # Mdm_Std_Library
    # Globals
    "Initialize-Std",
    "Start-Std",
    "Initialize-StdGlobals",
    "Set-StdGlobals",
    "Get-StdGlobals",
    "Reset-StdGlobals",
    "Show-StdGlobals"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Script.ps1"
Export-ModuleMember -Function @(
    # This script:
    "Get-Invocation_PSCommandPath",
    "Get-MyCommand_Definition",
    "Get-MyCommand_InvocationName",
    "Get-MyCommand_Name",
    "Get-MyCommand_Origin",
    "Get-PSCommandPath",
    "Get-ScriptName",

    # Invoke
    "Invoke-ProcessWithExit",
    "Invoke-ProcessWithTimeout",
    "Invoke-Invoke",
    "Push-ShellPwsh"

    # Params
    "Get-ScriptPositionalParameters",
    "Set-CommonParametersGlobal",
    "Set-CommonParameters",

    # Script:
    "Confirm-SecElevated",
    "Confirm-Verbose",
    "Set-DisplayColors"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Convert.ps1"
Export-ModuleMember -Function @(
    # Etl Transform - Convert
    "ConvertFrom-HashValue",
    "ConvertTo-Text",
    "Get-LineFromFile",
    "ConvertTo-ObjectArray",
    "ConvertTo-EscapedText",
    "ConvertTo-TrimmedText",
    # Convert Colors
    "Convert-ConsoleToMediaColor",
    "Convert-MediaToConsoleColor",
    "Convert-NameToConsoleColor"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Etl.ps1"
Export-ModuleMember -Function @(
    # Etl
    # Etl Load - Path and directory
    "Get-SavedDirectoryName",
    "Set-SavedDirectoryName",
    "Get-FileNamesFromPath",
    "Get-UriFromPath",
    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
    "Set-DirectoryToScriptRoot",
    "Copy-ItemWithProgressDisplay",
    # Scope
    "Get-VariableScoped",
    "Resolve-Variables",
    # Etl Html
    "Write-HtlmData",
    "Get-RobocopyExitMessage"
    # Etl Other
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Help.ps1"
Export-ModuleMember -Function @(
    # Help
    "Export-Mdm_Help",
    "Export-Help",
    "Write-Mdm_Help",
    "Write-Module_Help",
    "Build-HelpHtml",
    # Templates
    "Initialize-TemplateData",
    "Get-Template",
    "ConvertFrom-Template"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Search.ps1"
Export-ModuleMember -Function @(
    # Help
    "Search-Directory",
    "Find-FileInDirectory",
    "Search-FileUpDirectory",
    "Search-FileInDirectory",
    "Find-File",
    "Search-StringInFiles"
)
#endregion
#region external functions
. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-AllCommands.ps1"
Export-ModuleMember -Function "Get-AllCommands"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-Assembly.ps1"
Export-ModuleMember -Function "Get-Assembly"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-Import.ps1"
Export-ModuleMember -Function "Get-Import"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Confirm-ModuleActive.ps1"
Export-ModuleMember -Function "Confirm-ModuleActive"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Confirm-ModuleScan.ps1"
Export-ModuleMember -Function "Confirm-ModuleScan"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-JsonData.ps1"
Export-ModuleMember -Function "Get-JsonData"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Join-Hashtable.ps1"
Export-ModuleMember -Function "Join-Hashtable"
function Invoke-GetParameters {
    param ()
    . "$global:moduleRootPath\Mdm_Std_Library\Public\Get-Parameters.ps1"
    return $commonParameters
}
Export-ModuleMember -Function "Get-Parameters"
    
#endregion
#endregion
#region local functions
function Confirm-Verbose {
    <#
    .SYNOPSIS
        Asserts verbose is on.
    .DESCRIPTION
        Should check state.
    .OUTPUTS
        True if verbose is on
    .EXAMPLE
        If (Confirm-Verbose) { $null }
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
        $messageWarningBackgroundColor = $WarningBackgroundColor
        $messageWarningForegroundColor = $WarningForegroundColor
        $messageErrorBackgroundColor = $ErrorBackgroundColor
        $messageErrorForegroundColor = $ErrorForegroundColor
    }
}
# ###############################
# Exports from .psm1 (here) module
Export-ModuleMember -Function @(
    # Mdm_Std_Library
    "Set-DisplayColors",
    "Set-prompt",
    "Confirm-Verbose"
)
Export-ModuleMember -Variable @(
    "CommandResult"
)
#endregion
# MAIN
#region Globals:
Write-Verbose "Loading globals..."
# Global settings
if (-not $global:InitDone) { Initialize-StdGlobals -DoCheckState }
# Log
if (-not $global:logFileNameFull) { Open-LogFile -logFileNameFull $logFileName -SkipCreate -DoClear }
#endregion
