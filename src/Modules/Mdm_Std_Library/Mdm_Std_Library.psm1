
Write-Host "Mdm_Std_Library.psm1"
# Script Path
if (-not $global:moduleRootPath) {
    $path = "$($(get-item $PSScriptRoot).Parent.FullName)\Mdm_Modules\Project.ps1"
    . "$path"
}

#region Module Members
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
}
# Import Module - Mdm_Std_Library - Components
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
    "Get-VariableScoped",

    "Debug-Script",
    "Debug-AssertFunction",
    "Debug-SubmitFunction"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Module.ps1"
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

    # Globals
    "Initialize-Std",
    "Reset-StdGlobals",
    "Set-DebugVerbose",
    "Show-StdGlobals",
    "Start-Std",

    # Script:
    "Assert-SecElevated",
    "Assert-Verbose",
    "Set-DisplayColors"
)
. "$global:moduleRootPath\Mdm_Std_Library\Public\Mdm_Std_Etl.ps1"
Export-ModuleMember -Function @(
    # Etl
    # Etl Load - Path and directory
    "Get-DirectoryNameFromSaved",
    "Get-FileNamesFromPath",
    "Get-UriFromPath",
    "Set-LocationToPath",
    "Set-LocationToScriptRoot",
    "Set-DirectoryToScriptRoot",
    "Set-SavedToDirectoryName",
    "Copy-ItemWithProgressDisplay",
    # Etl Transform - Convert
    "ConvertFrom-HashValue",
    "ConvertTo-Text",
    "Get-LineFromFile",
    "ConvertTo-ObjectArray",
    "ConvertTo-EscapedText",
    "ConvertTo-TrimmedText",
    "Resolve-Variables",
    # Etl Log
    "Add-LogText",
    "Add-LogError",
    "Open-LogFile",
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
    "Find-File")
# Individual components and functions
. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-Parameters.ps1"
Export-ModuleMember -Function "Get-Parameters"
    
. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-AllCommands.ps1"
Export-ModuleMember -Function "Get-AllCommands"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-Assembly.ps1"
Export-ModuleMember -Function "Get-Assembly"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-Import.ps1"
Export-ModuleMember -Function "Get-Import"

. "$global:moduleRootPath\Mdm_Std_Library\Public\Get-JsonData.ps1"
Export-ModuleMember -Function "Get-JsonData"

#endregion
#region Functions
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
        $messageWarningBackgroundColor = $WarningBackgroundColor
        $messageWarningForegroundColor = $WarningForegroundColor
        $messageErrorBackgroundColor = $ErrorBackgroundColor
        $messageErrorForegroundColor = $ErrorForegroundColor
    }
}
# Define a function to convert ConsoleColor to System.Windows.Media.Color
function Convert-ConsoleToMediaColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.ConsoleColor]$consoleColor
    )
    switch ($consoleColor) {
        'Black' { return [System.Windows.Media.Color]::FromRgb(0, 0, 0) }
        'DarkBlue' { return [System.Windows.Media.Color]::FromRgb(0, 0, 128) }
        'DarkGreen' { return [System.Windows.Media.Color]::FromRgb(0, 128, 0) }
        'DarkCyan' { return [System.Windows.Media.Color]::FromRgb(0, 128, 128) }
        'DarkRed' { return [System.Windows.Media.Color]::FromRgb(128, 0, 0) }
        'DarkMagenta' { return [System.Windows.Media.Color]::FromRgb(128, 0, 128) }
        'DarkYellow' { return [System.Windows.Media.Color]::FromRgb(128, 128, 0) }
        'Gray' { return [System.Windows.Media.Color]::FromRgb(192, 192, 192) }
        'DarkGray' { return [System.Windows.Media.Color]::FromRgb(128, 128, 128) }
        'Blue' { return [System.Windows.Media.Color]::FromRgb(0, 0, 255) }
        'Green' { return [System.Windows.Media.Color]::FromRgb(0, 255, 0) }
        'Cyan' { return [System.Windows.Media.Color]::FromRgb(0, 255, 255) }
        'Red' { return [System.Windows.Media.Color]::FromRgb(255, 0, 0) }
        'Magenta' { return [System.Windows.Media.Color]::FromRgb(255, 0, 255) }
        'Yellow' { return [System.Windows.Media.Color]::FromRgb(255, 255, 0) }
        'White' { return [System.Windows.Media.Color]::FromRgb(255, 255, 255) }
        default { throw "Unsupported ConsoleColor: $consoleColor" }
    }
}
# Define a function to convert System.Windows.Media.Color to ConsoleColor
function Convert-MediaToConsoleColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $mediaColor
    )
    $mediaColorType = $mediaColor.GetType().FullName
    if ($mediaColorType -eq "System.ConsoleColor") {
        return [System.ConsoleColor]$mediaColor
    } elseif ($mediaColorType -eq "System.Windows.Media.Color") {
        # Get the RGB values from the MediaColor
        $r = $mediaColor.R
        $g = $mediaColor.G
        $b = $mediaColor.B
        # Determine the ConsoleColor based on the RGB values
        switch ("$r,$g,$b") {
            '0,0,0' { return [System.ConsoleColor]::Black }
            '0,0,128' { return [System.ConsoleColor]::DarkBlue }
            '0,128,0' { return [System.ConsoleColor]::DarkGreen }
            '0,128,128' { return [System.ConsoleColor]::DarkCyan }
            '128,0,0' { return [System.ConsoleColor]::DarkRed }
            '128,0,128' { return [System.ConsoleColor]::DarkMagenta }
            '128,128,0' { return [System.ConsoleColor]::DarkYellow }
            '192,192,192' { return [System.ConsoleColor]::Gray }
            '128,128,128' { return [System.ConsoleColor]::DarkGray }
            '0,0,255' { return [System.ConsoleColor]::Blue }
            '0,255,0' { return [System.ConsoleColor]::Green }
            '0,255,255' { return [System.ConsoleColor]::Cyan }
            '255,0,0' { return [System.ConsoleColor]::Red }
            '255,0,255' { return [System.ConsoleColor]::Magenta }
            '255,255,0' { return [System.ConsoleColor]::Yellow }
            '255,255,255' { return [System.ConsoleColor]::White }
            default { 
                Write-Error -Message "Unsupported MediaColor: $mediaColor" 
                return [System.ConsoleColor]::Red
            }
        }
    } else {
        Write-Error -Message $("Expected [System.Windows.Media.Color] or [System.ConsoleColor]`n" `
                + "Got type: $mediaColorType from: $mediaColor.`n"  `
                + "Attempting to Convert-NameToConsoleColor by value.")
        return Convert-NameToConsoleColor $mediaColor
    }
}
function Convert-NameToConsoleColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$colorName
    )
    $colorName = $colorName.ToLower()
    switch ($colorName) {
        'black' { return [System.ConsoleColor]::Black }
        'darkblue' { return [System.ConsoleColor]::DarkBlue }
        'darkgreen' { return [System.ConsoleColor]::DarkGreen }
        'darkcyan' { return [System.ConsoleColor]::DarkCyan }
        'darkred' { return [System.ConsoleColor]::DarkRed }
        'darkmagenta' { return [System.ConsoleColor]::DarkMagenta }
        'darkyellow' { return [System.ConsoleColor]::DarkYellow }
        'gray' { return [System.ConsoleColor]::Gray }
        'darkgray' { return [System.ConsoleColor]::DarkGray }
        'blue' { return [System.ConsoleColor]::Blue }
        'green' { return [System.ConsoleColor]::Green }
        'cyan' { return [System.ConsoleColor]::Cyan }
        'red' { return [System.ConsoleColor]::Red }
        'magenta' { return [System.ConsoleColor]::Magenta }
        'yellow' { return [System.ConsoleColor]::Yellow }
        'white' { return [System.ConsoleColor]::White }
        default {
            Write-Error -Message "Unsupported color name: $colorName. Using Red."
            return [System.ConsoleColor]::Red
        }
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
        [string]$Message = "",
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug,
        [switch]$DoForce,
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
        $global:DoForce = $false
        $global:Message = ""
    }
    return @($global:DoPause, $global:DoVerbose, $global:DoDebug, $global:DoForce, $global:Message)
}
function Initialize-StdGlobals {
    [CmdletBinding()]
    param (
        [switch]$DoCheckState
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
            [string]$global:copyright = "&copy; $global:copyright. All rights reserved."
            [string]$global:license = "MIT"
            [string]$global:title = ""
            # Modules array
            [array]$global:moduleNames = @("Mdm_Bootstrap", "Mdm_Std_Library", "Mdm_DevEnv_Install", "Mdm_Modules")
            [array]$global:moduleAddons = @("Mdm_Nightroman_PowerShelf", "Mdm_Springcomp_MyBox")
        
            # Error display handling options:
            [bool]$global:UseTrace = $true
            [bool]$global:UseTraceDetails = $true
            [bool]$global:UseTraceStack = $true
            [hashtable]$global:commonParametersPrelude = @{}
            [hashtable]$global:commonParameters = @{}
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
            [bool]$global:DoDebug = $false
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
            $global:timeStartedFormatted = "{0:yyyymmdd_hhmmss}" -f ($global:timeStarted)
            $global:timeCompleted = $null
            $global:lastError = $null
        }
        # Log
        # [string]$global:logFileName = "$($global:companyNamePrefix)_Installation_Log"
        # [string]$global:logFilePath = "$global:projectRootPath\log"
        # [string]$global:logFileNameFull = ""
        # Use a single log file repeatedly appending to it.
        # The date and time will be appended to the name when LogOneFile is false.
        # [bool]$global:LogOneFile = $LogOneFile
        if (-not $global:logFileNameFull) { $null = Open-LogFile -SkipCreate }

    }
    
    end {
        
    }
}
# ###############################
# Function to check for key press
function Wait-ForKeyPress {
    param (
        $Message = "",
        $duration = 10,
        $ForegroundColor,
        $BackgroundColor
    )
    if (-not $ForegroundColor) { $ForegroundColor = $messageWarningForegroundColor }
    if (-not $BackgroundColor) { $BackgroundColor = $messageWarningBackgroundColor }
    Write-Host -NoNewline "" -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    [int]$startTime = $(Get-Date -UFormat "%s")
    [int]$remainingTime = $duration
    while ($remainingTime -gt 0) {
        if ($host.UI.RawUI.KeyAvailable) {
            $key = $host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp") # ,IncludeKeyDown
            if ($key.Character -eq "Y") { return $true }
        }
        $percentComplete = [int][math]::Round(($remainingTime / $duration) * 100)
        if ($Message) {
            # Display the countdown using Write-Progress
            Write-Progress -Activity $Message -Status "$remainingTime seconds remaining..." -PercentComplete $percentComplete
        }
        Start-Sleep -Milliseconds 500  # Sleep for a short time to avoid high CPU usage
        $remainingTime = $startTime + $duration - (Get-Date -UFormat "%s" )
    }
    $ForegroundColor = $global:messageForegroundColor
    $BackgroundColor = $global:messageBackgroundColor
    Write-Host -NoNewline "" -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor

    # $keyPressed = $false
    # $job = Start-Job -ScriptBlock {
    #     [Console]::ReadKey($true) | Out-Null
    #     return $true
    # }
    # # Sleep for a specified duration (in seconds)
    # $duration = 10
    # for ($i = 0; $i -lt $duration; $i++) {
    #     Start-Sleep -Seconds 1
    #     if ($job.HasExited) {
    #         $keyPressed = $job.Receive()
    #         break
    #     }
    # }
    # # Clean up the job
    # Stop-Job $job
    # Remove-Job $job
    return $keyPressed
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
        [string]$Message = "",
        [Parameter(mandatory = $false)]
        [int]$timeout = -1,        
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )

    Write-Debug "$Message Pause: $global:DoPause"
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = $global:msgAnykey
    }
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = 'Enter any key to continue: '
    }
    Set-StdGlobals `
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug
    # Write-Host "$Message Pause: $global:DoPause"
    # if ($global:DoPause) {
    # Check if running PowerShell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$Message")
    } else {
        Write-Host -Message "$Message " -ForegroundColor Yellow -NoNewline
        # $null = $host.ui.RawUI.ReadKey("NoEcho, IncludeKeyUp")
        $null = [Console]::ReadKey()
        Write-Host " " -ForegroundColor White
    }
    # }
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
        [string]$Message = "",
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug    
    )
    # ($local:DoPause, $local:DoVerbose, $local:DoDebug, $local:message ) = Get-StdGlobals
    # if ($global:DoPause) {
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = $global:msgYorN
    }
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = 'Press Y for Yes, Q to Quit, or N to exit'
    }
    if ([string]::IsNullOrEmpty($Message)) {
        Write-Debug -Message "The message is either null or empty."
        # } else {
        #     Write-Debug "The message is set: $Message."
    }

    $response = ""
    $continue = 1
    Do {
        # $response = Read-Host -Prompt $Message
        $response = Read-Host $Message
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
    "Initialize-StdGlobals",
    "Set-StdGlobals",
    "Get-StdGlobals",
    # Waiting & pausing
    "Wait-ForKeyPress",
    "Wait-AnyKey",
    "Wait-CheckDoPause",
    "Set-StdGlobals",
    "Wait-YorNorQ"
    # Other
    "Set-DisplayColors",
    "Set-prompt",
    "Assert-Verbose"
)
#endregion
#region Globals:
Write-Verbose "Loading globals..."
# Global settings
if (-not $global:InitDone) { Initialize-StdGlobals -DoCheckState }
# Log
if (-not $global:logFileNameFull) { $null = Open-LogFile -SkipCreate }
#endregion
