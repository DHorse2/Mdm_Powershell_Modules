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
        I was unable to make this work in the psm1 file:
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
        Also: See function Build-ModuleExports. 
        This also failed for the same reasons.
        This is powershell best practices,
        and similar to modules in the wild.
        The main difference is they typically use .net (C#).
        That isn't a barrier beyond wanting to master (THIS) powershell syntax.
#>

# Mdm_Std_Library
#
# Imports
# Import-Module Mdm_Std_Library

# Init
# $ExecutionContext.SessionState.LanguageMode = “FullLanguage”
#
Write-Host "Loading globals..."
[switch]$global:DoVerbose = $false
[switch]$global:DoPause = $false
[switch]$global:DoDebug = $false
[string]$global:msgAnykey = ""
[string]$global:msgYorN = ""
[switch]$global:initDone = $false
#
# Change the color of error and warning text
#
# $Host.PrivateData.ErrorForegroundColor = 'red'
$opt = (Get-Host).PrivateData
$opt.WarningBackgroundColor = [System.ConsoleColor]::DarkCyan
$opt.WarningForegroundColor = [System.ConsoleColor]::White
$opt.ErrorBackgroundColor = [System.ConsoleColor]::Red
$opt.ErrorForegroundColor = [System.ConsoleColor]::White
# ###############################
function Assert-ScriptSecElevated() {
    <#
    .SYNOPSIS
        Elevate script to Administrator.
    .DESCRIPTION
        Get the security principal for the Administrator role.
        Check to see if we are currently running "as Administrator",
        Create a new process object that starts PowerShell,
        Indicate that the process should be elevated ("runas"),
        Start the new process.
    .PARAMETER message
        Message to display when elevating.
    .EXAMPLE
        Set-ScriptSecElevated "Elevating myself."
    .NOTES
        This works but I think there are problems depending on the shell type.
        ISE for example.
    .OUTPUTS
        None. Returns or Executes current script in an elevated process.
#>
    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose
    )    # Assert-ScriptSecElevated
    # Self-elevate the script if required
    if (-Not ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
                [Security.Principal.WindowsBuiltInRole] 'Administrator' `
        )) {
        return $false
        # if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        #     $CommandLine = "-File `"" + $My_Invocation.My_Command_.Path + "`" " + $My_Invocation.UnboundArguments
        #     Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        #     Exit
        # }
    }
    else { return $true }
}
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
# ###############################
function Get-DirectoryNameFromSaved {
    <#
    .SYNOPSIS
        Get saved directory.
    .DESCRIPTION
        This allow you to store the directory where the command was issued
        and later restore that state.
        Don't alter the Saved Working Directory
        when setting to a passed Working Directory.
    .PARAMETER dirWdPassed
        An optional directory to use.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        Does a Set-Location to this directory. Rhelpeturns it as a string.
    .EXAMPLE
        Get-DirectoryNameFromSaved
    .NOTES
        none.
#>
    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose,
        [Parameter(Mandatory = $false)]
        [string]$dirWdPassed
    )
    # Get-DirectoryNameFromSaved
    # don't alter the Saved Working Directory
    # when setting to a passed Working Directory
    if ($null -ne $dirWdPassed) { $dirWdTemp = $dirWdPassed } 
    else {
        $dirWdTemp = $global:dirWdSaved 
    }
    if ($null -eq $dirWdTemp) { $dirWdTemp = $PWD.Path }
    
    if ($null -ne $global:dirWdTemp -and $global:dirWdTemp -ne $PWD.Path) {
        Write-Verbose "Working directory: $($PWD.Path) set to $global:dirWdTemp."
        $global:dirWdTemp | Set-Location
    }
    $dirWdTemp
}
function Get-FileNamesFromPath {
    <#
    .SYNOPSIS
        Creates a list of files in a directory.
    .DESCRIPTION
        Creates a list of files in a directory.
    .PARAMETER SourcePath
        The folder to list the files of.
    .OUTPUTS
        A list of files.
    .EXAMPLE
        Get-FileNamesFromPath "C:\Progams places"
    .NOTES
        none.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$SourcePath
    )    
    $SourceFileNames = Get-ChildItem `
        -Path $SourcePath `
        -File `
    | ForEach-Object { $_.BaseName }
    # ForEach-Object $SourceFileNames {
        
    # }
    $SourceFileNames
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
    "${prefix}${body}${suffix}"
}
function Save-DirectoryName {
    <#
    .SYNOPSIS
        Save working directory.
    .DESCRIPTION
        Save working directory with a view to restoring it later.
        The default is to save the current directoy.
    .PARAMETER dirWdPassed
        The Working Directory Name.
    .OUTPUTS
        none.
    .EXAMPLE
        Save-DirectoryName "C:\PathToSave"
#>

    [CmdletBinding()]
    param (
        # [switch]$DoPause,
        # [switch]$DoVerbose,
        [Parameter(Mandatory = $false)]
        [string]$dirWdPassed
    )    # Save-DirectoryName
    if ($null -ne $dirWdPassed) { 
        $global:dirWdSaved = $dirWdPassed 
    }
    else {
        # The default is to save the current directoy.
        if ($null -eq $global:dirWdSaved -or $global:dirWdSaved -ne $PWD.Path) {
            $global:dirWdSaved = $PWD.Path
        }
    }
    Write-Verbose "$global:dirWdSaved saved. "
}
function Set-LocationToPath {
    <#
    .SYNOPSIS
        Set the currrent directory.
    .DESCRIPTION
        Set the currrent working directory to the passed path.
    .PARAMETER workingDirectory
        The direcotry to set as the current working directory.
    .PARAMETER saveDirectory
        Save the passed directory path.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-LocationToPath "C:\temp"
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$workingDirectory,
        [switch]$saveDirectory
    )
    # todo validate the passed workingDirectory

    # Profile working directory (PWD)
    # Note: This shouldn't fail; if it did, it would indicate a
    # serious system-wide problem.
    if ($saveDirectory -and $global:dirWdSaved -ne $PWD.Path) {
        Save-DirectoryName($PWD.Path)
    }
    if ($PWD -ne $workingDirectory) {
        Set-Location -ErrorAction Stop -LiteralPath $workingDirectory
        Write-Verbose "Working directory: $($PWD.Path)"
    }
}
function Set-LocationToScriptRoot {
    <#
    .SYNOPSIS
        Set location to script root.
    .DESCRIPTION
        Set location to script root.
    .PARAMETER saveDirectory
        Switch: Save the current directory.
    .OUTPUTS
        none.
    .EXAMPLE
        Set-LocationToScriptRoot -saveDirectory
#>
    [CmdletBinding()]
    param (
        [switch]$saveDirectory
    )
    Set-LocationToPath "$PSScriptRoot" -saveDirectory
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
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug
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
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug
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
#
#############################
#
# Export-ModuleMember -Function * -Alias * -Cmdlet *
Write-Verbose "Ready."
# ###############################
# from stackoverflow
#
function My_PSCommandPath { 
    <#
    .SYNOPSIS
        My_PSCommandPath.
    .DESCRIPTION
        My_PSCommandPath.
    .OUTPUTS
        $My_PSCommandPath
    .EXAMPLE
        My_PSCommandPath
#>
    [CmdletBinding()]
    param()
    return $My_PSCommandPath 
}
function My_Command_InvocationName {
    <#
    .SYNOPSIS
        My_Command_InvocationName.
    .DESCRIPTION
        My_Command_InvocationName.
    .OUTPUTS
        $My_Invocation.InvocationName
    .EXAMPLE
        My_Command_InvocationName
#>
    [CmdletBinding()]
    param()
    return $My_Invocation.InvocationName
}
function My_Command_Orgin {
    <#
    .SYNOPSIS
        My_Command_Orgin
    .DESCRIPTION
        My_Command_Orgin
    .OUTPUTS
        $My_Invocation.My_Command_.CommandOrigin 
    .EXAMPLE
        My_Command_Orgin
#>
    [CmdletBinding()]
    param()
    return $My_Invocation.My_Command_.CommandOrigin 
}
function My_Command_Name {
    <#
    .SYNOPSIS
        My_Command_Name.
    .DESCRIPTION
        My_Command_Name.
    .OUTPUTS
        $My_Invocation.My_Command_.Name 
    .EXAMPLE
        My_Command_Name
#>
    [CmdletBinding()]
    param()
    return $My_Invocation.My_Command_.Name 
}
function My_Command_Definition {
    <#
    .SYNOPSIS
        My_Command_Definition.
    .DESCRIPTION
        My_Command_Definition.
    .OUTPUTS
        $My_Invocation.My_Command_.Definition
    .EXAMPLE
        My_Command_Definition
#>
    [CmdletBinding()]
    param()
    # Begin of My_Command_Definition()
    # Note: ouput of this script shows the contents of this function, not the execution result
    return $My_Invocation.My_Command_.Definition
    # End of My_Command_Definition()
}
function My_InvocationMy_PSCommandPath { 
    <#
    .SYNOPSIS
        My_InvocationMy_PSCommandPath.
    .DESCRIPTION
        My_InvocationMy_PSCommandPath.
    .OUTPUTS
        $My_Invocation.My_PSCommandPath 
    .EXAMPLE
        My_InvocationMy_PSCommandPath
#>
    [CmdletBinding()]
    param()
    return $My_Invocation.My_PSCommandPath 
}
#############################
# ShowData.psm1**
function Show-Data {
    <#
    .SYNOPSIS
        Show-Data.
    .DESCRIPTION
        Sends pipeline object to file.
    .OUTPUTS
        Html file.
    .EXAMPLE
        $YourPipeline | Show-Data "Filename.txt"
#>
    [CmdletBinding()]
    param(
        [Parameter(mandatory = $true, ValueFromPipeline = $true)]$InputObject,
        [Parameter(mandatory = $true)]$FileName
    )
    # [Parameter (Mandatory = $False, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    # [Alias("Path", "FullName")]
    # [string]$File = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'converted.txt'

    # this is process block that is probably missing in your code
    begin { $objects = @() }
    process { $objects += $InputObject }
    end {
        $head = "<style></style>"
        $header = "<H1>Test Results</H1>"
        $title = "Test results"
        $objects `
        | ConvertTo-HTML `
            -head $head `
            -body $header `
            -title $title `
        | Out-File $Filename
    }
}
function Get-ShowDataTestData {
    1
    2
    3
    4
}
function Test-ShowData {
    # Sample testing script
    <#
    .SYNOPSIS
        A basic function to show one or more ojbects.
    .DESCRIPTION
        This isn't being used. It might be useful for testing.
    .PARAMETER InputObject
        This is a ValueFromPipeline and can be used with one or more objects.
    .PARAMETER FileName
        The name of the file inclulding its path.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .OUTPUTS
        A list to the current ouput.
    .EXAMPLE
        Test-ShowData $MyData -DoPause
    .LINK
        XXX: http://www.XXX
    .LINK
        YYY
    .NOTES
        none.
#>
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true, ValueFromPipeline = $true)]$InputObject,
        [Parameter(mandatory = $false)]$FileName = ""
    )
    begin { }
    process { 
        # G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules\Mdm_Module_Test
        if ($FileName.Length = = 0) {
            $scriptPath = (get-item $PSScriptRoot ).Parent.Parent.Parent.FullName 
        }
        # # G:\Script\Powershell\Mdm_Powershell_Modules
        $FileName = "$scriptPath\test\testShowData.txt"
        # # G:\Script\Powershell\Mdm_Powershell_Modules\test\testShowData.txt
        Get-ShowDataTestData | Show-Data -file $Filename 
    }
    end { }
}
# Export the functions to be used by other modules or scripts
# Export-ModuleMember -Function Show-Data
# ###############################

# ``` Script functions
function Search-Dir {
    <#
    .SYNOPSIS
        Search a folder for files or (todo) something else.
    .DESCRIPTION
        Currently just outputs the folder list to a CSV file.
    .PARAMETER inputObjects
        This is a ValueFromPipeline and can be used with one or more objects.
    .PARAMETER dir
        This defaults to "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules".
    .PARAMETER folder
        Defaults to (Get-Item $dir).Parent.
    .PARAMETER folderName
        Defaults to folder.Name.
    .PARAMETER folderPath
        Defaults to folder.FullName.
    .OUTPUTS
        Export-Csv '.\output.csv'.
    .EXAMPLE
        Search-Dir "G:\Script\Powershell\".
#>

    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]$inputObjects,
        $dir = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules",
        $folder = (Get-Item $dir).Parent,
        $folderName = $folder.Name,
        $folderPath = $folder.FullName    
    )

    begin {
        [Collections.ArrayList]$inputObjects = @()
    }
    process {
        [void]$inputObjects.Add($_)
    }
    end {
        $inputObjects | ForEach-Object -Parallel {
            Get-ChildItem $dir |
            >>     Select-Object Name, FullName, +
            >>         @{n = 'FolderName'; e = { $folderName } }, +
            >>         @{n = 'Folder'; e = { $folderPath } } |
            Export-Csv '.\output.csv' -Encoding UTF8 -NoType
        }
    }
}

# ###############################
function Script_Initialize_Std {
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
        Script_Initialize_Std -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Verbose:$DoVerbose -Debug:$DoDebug
    .EXAMPLE
        Script_ResetStdGlobals
        Script_Initialize_Std -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Verbose:$DoVerbose -Debug:$DoDebug
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
    Write-Verbose "Script_Initialize_Std"
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
            # Command line specifies -Verbose[:$false]
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
function Script_ResetStdGlobals {
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
        Script_ResetStdGlobals
#>
    [CmdletBinding()]
    param (
        [switch]$DoVerbose,
        [switch]$DoPause,
        [switch]$DoDebug,
        [string]$msgAnykey = "",
        [string]$msgYorN = "",
        [switch]$initDone
    )
    $global:DoVerbose = $DoVerbose
    $global:DoPause = $DoPause
    $global:DoDebug = $DoDebug
    $global:msgAnykey = $msgAnykey
    $global:msgYorN = $msgYorN
    $global:initDone = $initDone
}
function Script_DisplayStdGlobals {
    <#
    .SYNOPSIS
        Display global state.
    .DESCRIPTION
        Display global and automatic state variables.
    .EXAMPLE
        Script_DisplayStdGlobals
#>
    [CmdletBinding()]
    param ()
    Write-Host "Global Pause: $global:DoPause, Verbose: $global:DoVerbose, Debug: $global:DoDebug Init: $global:initDone"
    if ($global:msgAnykey.Lenth -gt 0) {
        Write-Host "Anykey prompt: $global:msgAnykey"
    }
    if ($global:msgYorN.Lenth -gt 0) {
        Write-Host "Y,Q or N prompt: $global:msgYorN"
    }
}
function Script_Name { 
    <#
    .SYNOPSIS
        Get Script Name.
    .DESCRIPTION
        Get $My_Invocation.Script_Name.
    .OUTPUTS
        $My_Invocation.Script_Name 
    .EXAMPLE
        Script_Name
#>
    [CmdletBinding()]
    param()
    return $My_Invocation.Script_Name 
}

function Script_Write_Error {
    <#
.SYNOPSIS
    Creates a powershell error object.
.DESCRIPTION
     Uses $PSCmdlet.WriteError to create a powershell error.
.PARAMETER Message
    The error message.
.PARAMETER ErrorCategory
    The error type.
.PARAMETER DoPause
Switch: Pause between steps.
.PARAMETER DoVerbose
Switch: Verbose output and prompts.
.PARAMETER DoDebug
Switch: Debug this script.
.EXAMPLE
    todo PsError Example
.NOTES
    I haven't tested or used this code yet.
.OUTPUTS
    An error object from what I can tell.
#>
    [cmdletbinding()]
    Param
    (
        [Exception]$Message,
        [Management.Automation.ErrorCategory]$ErrorCategory = "NotSpecified",
        [switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug
    )
    $arguments = @(
        $Message
        $null #errorid
        [Management.Automation.ErrorCategory]::$ErrorCategory
        $null

    )
    $ErrorRecord = New-Object `
        -TypeName "Management.Automation.ErrorRecord" `
        -ArgumentList $arguments
    $PSCmdlet.WriteError($ErrorRecord)
}
function Script_Last_Error {
    <#
    .SYNOPSIS
        Script_Last_Error.
    .DESCRIPTION
        Script_Last_Error does Get-Error.
    .OUTPUTS
        The last error to occur.
    .EXAMPLE
        Script_Last_Error
#>
    [CmdletBinding()]
    param ()
    Get-Error | Write-Host
    
}
function Script_DoStart {
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
        Script_DoStart -DoVerbose
    .NOTES
        This serves little purpose.
#>
    [CmdletBinding()]
    param ([switch]$DoPause, [switch]$DoVerbose, [switch]$DoDebug)
    # Import-Module Mdm_Std_Library -Force
    Script_ResetStdGlobals  `
        -DoPause:$DoPause `
        -DoVerbose:$DoVerbose `
        -DoDebug:$DoDebug `
        -Verbose:$DoVerbose ` # todo is this correct?
    -Debug:$DoDebug
    Script_Initialize_Std -DoPause:$DoPause -DoVerbose:$DoVerbose -DoDebug:$DoDebug -Verbose:$DoVerbose -Debug:$DoDebug
    if ($global:DoVerbose) { Write-Host "Script Started." }
}
# Script_DoStart
function Script_List_Positional_Parameters {
    <#
    .SYNOPSIS
        Script_List_Positional_Parameters.
    .DESCRIPTION
        Script_List_Positional_Parameters.
    .PARAMETER functionName
        The function name to examine.
    .OUTPUTS
        A list pof positional paramaters for that function.
    .NOTES
        Answered Jan 27, 2022 at 4:23 user16136127 StackOverflow
        "https://stackoverflow.com/questions/70853968/how-do-i-fix-this-positional-parameter-error-powershell"
        Alternatively, you might check if your cmdlet has any positional parameters. 
        You can search the documentation. But a quick way is to have PowerShell do the work. 
        Use the one-liner below. And just replace "Get-ChildItem" with the cmdlet you are interested in. 
        Remember, if the output only shows "Named"" then the cmdlet does not accept positional parameters.
        Below, there are two positional parameters: Path and Filter.
    .EXAMPLE
        Script_List_Positional_Parameters
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$functionName
    )
    Get-Help -Name $functionName -Parameter * | 
    Sort-Object -Property position | 
    Select-Object -Property name, position | Write-Host
}
function Write-Mdm_Help {
    <#
    .SYNOPSIS
        Generates the extended help files for the Mdm Modules.
    .DESCRIPTION
        This runs Get-Modules and Get-Command functions to create help files.
        The general intent is to have function lists.
        To correctly run this command (showing which module it belongs to) enter:
        ```powershell
        Import-Module -name Mdm_Std_Library -force
        ```
        This function re-imports the other module in the correct order.
        Note: It should not need to be run unless changes were made to the Mdm Modules.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .NOTES
        none.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Import-Module -name Mdm_Std_Library -force
        Write-Mdm_Help -DoVerbose -DoPause
#>
    [CmdletBinding()]
    param (
        [String]$moduleRoot = "",
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
    begin {
        
    }
    process {
        # Check path (todo)
        if (-not $moduleRoot) {
            $moduleRoot = (get-item $PSScriptRoot).parent.FullName
        }
        # Standard Functions
        Import-Module -name Mdm_Std_Library `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue
        Get-Module Mdm_Std_Library -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Std_Library.txt"
        Get-Module Mdm_Std_Library -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values.Name } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Std_Library_List.txt"
        
        # Bootstrap
        Import-Module -name Mdm_Bootstrap `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue
        Get-Module Mdm_Bootstrap -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap.txt"
        Get-Module Mdm_Bootstrap -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values.Name } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap_List.txt"
        
        # Development Environment Install
        Import-Module -name Mdm_Dev_Env_Install `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue
        Get-Module Mdm_Dev_Env_Install -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Dev_Env_Install.txt"
        Get-Module Mdm_Dev_Env_Install -ListAvailable `
        | ForEach-Object { $_.ExportedCommands.Values.Name } `
            > "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Dev_Env_Install_List.txt"

        # Mdm Modules (aggragation)
        #

        # This might have an error on Std.
        Import-Module -name Mdm_Modules `
            -verbose:$DoVerbose `
            -force `
            -ErrorAction Continue

        # Aggragation
        Get-Content "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_Mdm_*.txt" `
        | Out-File "$moduleRoot\Mdm_Bootstrap\help\ModuleCommandList_All.txt"
    }
    end {
        
    }
}
function Get-Mdm_Help {
    <#
    .SYNOPSIS
        Displays the help files for the Mdm Modules.
    .DESCRIPTION
        You can display the help Using DoPause and DoVerbose for detailed help.
    .PARAMETER DoPause
        Switch: Pause between steps.
    .PARAMETER DoVerbose
        Switch: Verbose output and prompts.
    .PARAMETER DoDebug
        Switch: Debug this script.
    .NOTES
        none.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Get-Mdm_Help -DoVerbose -DoPause
#>
    [CmdletBinding()]
    param (
        [switch]$DoPause, 
        [switch]$DoVerbose, 
        [switch]$DoDebug
    )
        
    begin {
            
    }
        
    process {
        # Check path (todo)
        $scriptPath = (get-item $PSScriptRoot ).parent.FullName
        $moduleNames = @("Mdm_Dev_Env_Install", "Mdm_Bootstrap", "Mdm_Std_Library")
        # Process modules
        foreach ($moduleName in $moduleNames) {
            try {
                Import-Module `
                    -Name "$scriptPath\$moduleName\$moduleName" `
                    -Force `
                    -verbose:$DoVerbose `
                    -ErrorAction Stop
            }
            catch { 
                $logMessage = @( `
                        "Failed to import module: $moduleName.", `
                        "Error: $_"
                )
                logText $logMessage $global:logFileNameFull -isError
                continue            
            }
            try {
                Get-Module moduleName -ListAvailable `
                | ForEach-Object { $_.ExportedCommands.Values } `
                    > ..\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap.txt 

                Get-Module moduleName -ListAvailable `
                | ForEach-Object { $_.ExportedCommands.Values.Name } `
                    > ..\Mdm_Bootstrap\help\ModuleCommandList_Mdm_Bootstrap_List.txt 
            }
            catch {
                $logMessage = @( `
                        "Get-Module failed for module: $moduleName.", `
                        "Error: $_"
                )
                logText $logMessage $global:logFileNameFull -isError
                continue            
            }
        }            
        # Mdm Modules (aggragation)
        #
        # This might have an error on Std.
        # Import-Module -name Mdm_Modules -force
    }
        
    end {
            
    }
}