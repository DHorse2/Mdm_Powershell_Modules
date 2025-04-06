<#
    .SYNOPSIS
        Install or update Mdm Modules.
    .DESCRIPTION
        This installs the libraries to the live system using Robocopy.
    .PARAMETER source
        default: "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules" 
    .PARAMETER destination
        default: "$env:PROGRAMFILES\\WindowsPowerShell\Modules"

        .PARAMETER logFilePath
        default: "G:\Script\Powershell\Mdm_Powershell_Modules\log\"
    .PARAMETER logFileName
        default: "Mdm_Installation_Log.txt"
    .PARAMETER LogOneFile
        Switch to not create separate file with the date in the file name.

        .PARAMETER SkpHelp
        Switch to skip generating the help documentation.
    .PARAMETER SkpRegistry
        Skip updating the registry.
    .PARAMETER DoNewWindow
        Switch to execute copy commands in a separate shell window.
    .PARAMETER copyOptions
        These are RoboCopy options.
        Currently: "/E /FP /nc /ns /np /TEE"

    .PARAMETER nameFilter
        Default is "Mmd_*". IE. These modules.
        You could override it if you had other local modules to install
    .PARAMETER companyName
        MacroDM currently. It's optional.
    .PARAMETER DoPause
        Switch to pause at each step/page.
    .PARAMETER DoVerbose
        Provide detailed information.
    .PARAMETER DoDebug
        Debug this script.
   .NOTES
        The above defaults appear again in the code below. 
        One or the other clearly.
        There are huge amounts of notes in this script.
        This is not best practices but whatever.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Dev_Env_Install_Modules_Win    
#>
[CmdletBinding()]
param (
    [switch]$DoVerbose,
    [switch]$DoPause,
    [switch]$DoDebug,
    [string]$source = "G:\Script\Powershell\Mdm_Powershell_Modules\src\Modules",
    [string]$destination = "$env:PROGRAMFILES\WindowsPowerShell\Modules",
    [string]$logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log",
    [string]$logFileName = "Mdm_Installation_Log",
    [switch]$LogOneFile,
    [string]$nameFilter = "Mdm_*",
    [switch]$SkipHelp,
    [switch]$SkipRegistry,
    [switch]$DoNewWindow,
    [string]$companyName = "MacroDM",
    [string]$copyOptions = "/E /FP /nc /ns /np /TEE"

)
# Dev_Env_Install_Modules_Win
# ================================= Initialization

# Normal Import-Module
#     Import-Module Mdm_Std_Library
# This works with uninstalled Modules (both)
$importName = "Mdm_Std_Library"
$scriptPath = (get-item $PSScriptRoot ).parent.FullName
Import-Module -Name "$scriptPath\$importName\$importName" -Force -ErrorAction Stop

# Import-Module Microsoft.PowerShell.Security
# Set-ExecutionPolicy Unrestricted -Scope CurrentUser
# [string]$global:logData = ""
[string]$global:logFileNameFull = ""
[string]$global:scriptPath = (get-item $PSScriptRoot ).parent.FullName

# MAIN
$timeStarted = "{0:yyyymmdd_hhmmss}" -f (get-date)
$timeCompleted = $timeStarted
$source = Convert-Path $source
if (-not $source) { $source = (get-item $PSScriptRoot).parent.FullName }

$destination = Convert-Path $destination
if (-not $destination) { $destination = Convert-Path "$env:PROGRAMFILES\WindowsPowerShell\Modules" }

# Logging:
if (-not $global:logFilePath) { $global:logFilePath = "G:\Script\Powershell\Mdm_Powershell_Modules\log" }
$global:logFilePath = Convert-Path $global:logFilePath
if (-not $global:logFilePath) { $global:logFilePath = Convert-Path ".\" }
# Check if folder not exists, and create it
if (-not(Test-Path $global:logFilePath -PathType Container)) {
    New-Item -path $global:logFilePath -ItemType Directory
}

if (-not $global:logFileName) { $global:logFileName = "Mdm_Installation_Log" }
$global:logFileNameFull = "$logFilePath\$logFileName"
if (-not $LogOneFile) { $global:logFileNameFull += "_$timeStarted" }
$global:logFileNameFull += ".txt"
# Check if file exists, and create it
if (-not(Test-Path $global:logFileNameFull -PathType Leaf)) {
    New-Item -path $global:logFileNameFull -ItemType File
}

$logMessage = @(
    " ", `
        "==================================================================", `
        "Installing Mdm Modules at $timeStarted", `
        "==================================================================", `
        "Source: $source", `
        "Destination: $destination", `
        "Logfile: $global:logFileNameFull"
)
LogText $logMessage $global:LogFileNameFull `
    -ForegroundColor Green

# ================================= Codium setup
# https://dev.to/opdev1004/how-to-add-open-with-vscodium-for-windows-3g0l

if (-not $SkipRegistry) {
    LogText "==================================================================" $global:LogFileNameFull `
        -ForegroundColor Green
    LogText "Updating Registry" $global:LogFileNameFull
    LogText "Updating: $regPath" $global:LogFileNameFull
    
    # ================================= Registry (Language mode)
    # Notes: Meaning of %V
    #   %V: This placeholder is used to represent the full path of the file.
    #   It is specifically intended for use with file paths that include spaces. 
    #   When %V is used, it is automatically enclosed in quotes, 
    #       which helps ensure that the path is correctly interpreted
    #       by the application, even if it contains spaces.

    # Key: Computer\HKEY_CLASSES_ROOT\Directory\shell\Powershell\command
    # powershell.exe -noexit -command Set-Location -literalPath '%V'

    # ================================= Registry (codium)
    # Setup "Open with "
    # Method 1: 
    # Check if Codium is installed for single user.
    $appExePath = "$env:USERPROFILE\AppData\Local\Programs\VSCodium\VSCodium.exe"
    # Check if the path exists
    if (Test-Path $appExePath) {
        # Resolve the path
        $appExePath = Resolve-Path $appExePath | Select-Object -ExpandProperty Path
    }
    else {
        # Codium must be installed for all users.
        $appExePath = Resolve-Path "$env:Programfiles\VSCodium\VSCodium.exe"
        if (Test-Path $appExePath) {
            # Resolve the path
            $appExePath = Resolve-Path $appExePath | Select-Object -ExpandProperty Path
        }
        else {
            # Throw an error todo.
            LogText "VSCodium not found." $global:LogFileNameFull -isError
        }
    }
    $commandString = "`"$appExePath`" `"%V`""
    # # Note on UserProfile: This method uses the user's account name:

    # Directory shell
    $regPath = "HKEY_CLASSES_ROOT\Directory\shell" 
    LogText "Updating: $regPath" $global:LogFileNameFull
    $regKey = "Open with VSCodium"
    $regProperty = "command"
    # Create registry key
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }
    # Set Default
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

    # command subkey
    $regPath += "\$regKey"
    LogText "Updating: $regPath" $global:LogFileNameFull
    $regKey = "command"
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }
    # Set the command
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

    # Directory Background Shell
    $regPath = "HKEY_CLASSES_ROOT\Directory\Background\shell"
    LogText "Updating: $regPath" $global:LogFileNameFull
    $regKey = "Open with VSCodium"
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }
    # Set Default
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $regKey -Force

    $regPath += "\$regKey"
    LogText "Updating: $regPath" $global:LogFileNameFull
    # command subkey
    $regKey = "command"
    if (-not (Test-Path "Registry::$regPath\$regKey")) {
        New-Item -Path "Registry::$regPath" -Name $regKey -Force
    }

    # Set the Command Path - Open with VSCodium
    $regProperty = "(Default)"
    Set-ItemProperty -Path "Registry::$regPath\$regKey" -Name $regProperty -Value $commandString -Force

    # Method 2:
    # https://www.thewindowsclub.com/change-registry-using-windows-powershell
    # Step 1: Type following and press Enter key to go to the Registry location:
    #   Set-Location -Path 'HKLM:\Software\Policies\Microsoft\Windows'
    # Step 2: Then execute the following cmdlet to create the new registry sub-key
    #   Get-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows' | New-Item -Name 'Windows Search' -Force
    # Step 3: Now as the registry sub-key is created, I’ll now create a registry DWORD and execute the following code for this: 
    #   New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name 'AllowIndexingEncryptedStoresOrItems' -Value "1" -PropertyType DWORD -Force
}

# ================================= Install modules:

# ================================= Execute COPY command:
$roboCopyOptions = @($helpSource, $helpDestination)
$optionsArray = $copyOptions.split(" ")
foreach ($option in $optionsArray) {
    $roboCopyOptions += $Option
}
$roboCopyOptions += "/LOG+:$global:logFileNameFull"
$commandLine = "Robocopy `"$source`" `"$destination`" $copyOptions"
$commandLine += " /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
# ================================= Reporting:
# if ($DoVerbose) {
LogText "==================================================================" $global:LogFileNameFull `
    -ForegroundColor Green
$logMessage = @( `
        "Copying SOURCE: ""$source""", `
        "DESTINATION: ""$destination""", `
        " ", `
        "Command: $commandLine", `
        " ", `
        "Starting processing..."
)
LogText $logMessage $global:LogFileNameFull
# }

LogText "Remove modules if they exist" $global:LogFileNameFull
Remove-Item "$destination\Mdm_*" `
    -Recurse -Force `
    -ErrorAction SilentlyContinue

LogText "Copy modules to destination" $global:LogFileNameFull
if ($DoNewWindow) {
    # $installProcess = 
    LogText "NOTE: Opening new window..." `
        $global:LogFileNameFull `
        -ForegroundColor Red
    Start-Process -FilePath "robocopy" `
        -ArgumentList $roboCopyOptions `
        -Verb RunAs `
        -NoNewWindow
    # Start-Process cmd "/c `"$commandLine & pause `""
    # $installProcess = Start-Process powershell -ArgumentList "-NoProfile -Command $commandLine" -Verb RunAs -NoNewWindow
    # Start-Process powershell -ArgumentList "-NoProfile -Command `"$commandLine`"" -Verb RunAs
    # Start-Process powershell -ArgumentList "-NoExit -Command $commandLine" -Verb RunAs
    # Note: NoNewWindow might be preferred if output isn't captured.
    # ================================= Wait for completion
    # if you have a process:
    # $installProcess.WaitForExit()

}
else {
    Invoke-Expression $commandLine
}
# Notes on various ways to copy items:
# powershell -command $commandLine -Verb runas
# Copy-Item -Path $source -Destination $destination -Verbose -Force –PassThru | Where-Object{$_ -is [system.io.fileinfo]}
# Copy-Item -Path $source -Destination $destination -Verbose -Force –PassThru | ForEach-Object {
#     LogText "$_.FullName copied."
# }
# (Copy-Item -Path $source -Destination $destination -Force -Verbose).Message

# ================================= Help files
if (-not $SkipHelp) {
    LogText "==================================================================" $global:LogFileNameFull `
        -ForegroundColor Green
    LogText " " $global:LogFileNameFull
    LogText "Updating Help for Mdm Modules." $global:LogFileNameFull
    $helpSource = "$source\Mdm_Bootstrap\help"
    $helpDestination = "$destination\Mdm_Bootstrap\help"
    # $helpFileName = "$Mdm_Help.html"  # Update the path

    try {
        Export-Help $source $global:logFileNameFull
    }
    catch {
        $logMessage = @( `
                "Export-Help Failed.", `
                "Error: $_"
        )
        LogText $logMessage $global:LogFileNameFull -isError
    }
    $importName = "Mdm_Modules"
    try {
        Import-Module -Name "$importName" `
        -Force -ErrorAction Stop
        Get-Mdm_Help
    }
    catch {
        $logMessage = @( `
                "Get-Mdm_Help Failed.", `
                "Error: $_"
        )
        LogText $logMessage $global:LogFileNameFull -isError
    }
}
if ($DoVerbose) { LogText " " $global:LogFileNameFull }

# ================================= Reporting part 2
LogText "==================================================================" $global:LogFileNameFull `
    -ForegroundColor Green
LogText " " $global:LogFileNameFull
LogText "Reloading Mdm Modules." $global:LogFileNameFull
if ($DoVerbose) {
    # Get-ChildItem "%userprofile%\Documents\PowerShell\Modules\*.*"
    Get-ChildItem -Path $destination
    # to display something?
}

# ================================= Reload Modules
$moduleName = "Mdm_Modules"
LogText "Standard import ($moduleName) test..."
try {
    # Import-Module -name $moduleName `
    Import-Module -Name "$global:scriptPath\$moduleName\$moduleName" `
        -Force `
        -ErrorAction Continue | LogText $global:LogFileNameFull
    # Import-Module -name Mdm_Modules -Force >> $global:logFileNameFull
}
catch {
    $logMessage = @( `
            " ", `
            "Failed to import module: $moduleName.", `
            "Error: $_"
    )
    LogText $logMessage $global:LogFileNameFull -isError
}

try {
    LogText "==================" $global:LogFileNameFull
    LogText "Automatic Function Imports Test (Build-ModuleExports $moduleName)" $global:LogFileNameFull
    LogText "Build-ModuleExports $global:scriptPath" $global:LogFileNameFull
    Build-ModuleExports "$global:scriptPath\$moduleName"
}
catch {
    $logMessage = @( `
            "Build-ModuleExports failed.", `
            "Error: $_"
    )
    LogText $logMessage $global:logFileNameFull -isError
}

if (-not $SkipHelp) {
    LogText "==================================================================" $global:LogFileNameFull `
        -ForegroundColor Green
    $logMessage = @( `
            "Updating System Help for Mdm Modules.", `
            "xxxxxxxxxxxxxxxxxx", `
            "Write-Mdm_Help" `
    )
    LogText $logMessage $global:LogFileNameFull -isError
    Write-Mdm_Help
    $logMessage = @( `
            "==================", `
            "Get-Mdm_Help"
    )
    LogText $logMessage $global:LogFileNameFull -isError
    Get-Mdm_Help
    # Generate-Documentation

    # Update system folders
    if ($DoNewWindow) {
        # $installProcess = 
        LogText "NOTE: Opening new window..." `
            -ForegroundColor Red
        Start-Process -FilePath "robocopy" -ArgumentList $roboCopyOptions -Verb RunAs
    }
    else {
        LogText "================================= Execute COPY command:"
        $commandLine = "Robocopy `"$helpSource`" `"$helpDestination`" $roboCopyOptions"
        $commandLine += " /LOG+:`"$global:logFileNameFull`"" # :: output status to LOG file (append to existing log).
        LogText $commandLine
        Invoke-Expression $commandLine
    }
}
# ================================= Wrapup
$timeCompleted = "{0:G}" -f (get-date)
$logMessage = @( `
        "==================================================================", `
        "Installation completed at $timeCompleted", `
        "started at $timeStarted", `
        "Source: $source", `
        "Destination: $destination", `
        "Logfile: $global:logFileNameFull", `
        "==================================================================" `
)
LogText $logMessage $global:LogFileNameFull

# ================================= Copy with progress %
# $source=ls c:\temp *.*
# $i=1
# $source| %{
#     [int]$percent = $i / $source.count * 100
#     Write-Progress -Activity "Copying ... ($percent %)" -status $_  -PercentComplete $percent -verbose
#     copy $_.fullName -Destination c:\test 
#     $i++
# }
#
# 2025/03/26 09:11:03 ERROR 5 (0x00000005) Accessing Destination Directory C:\Program Files\WindowsPowerShell\Modules\
# Access is denied.
# Waiting 30 seconds... Retrying...

# ================================= Robocopy documentation:
# /V - verbose
# /MIRror = /E /PURGE (cleans out depreciated files (scripts))
# /MIRror folder contents
# /FP : Include Full Pathname of files in the output.
# /NS : No Size - don’t log file sizes.
#
# Other Robocopy options:
# /L :: List only - don't copy, timestamp or delete any files.
# /X :: report all eXtra files, not just those selected.
# /V :: produce Verbose output, showing skipped files.
# /TS :: include source file Time Stamps in the output.
# /FP :: include Full Pathname of files in the output.
# /BYTES :: Print sizes as bytes.
# 
# /NS :: No Size - don't log file sizes.
# /NC :: No Class - don't log file classes.
# /NFL :: No File List - don't log file names.
# /NDL :: No Directory List - don't log directory names.
# 
# /NP :: No Progress - don't display percentage copied.
# /ETA :: show Estimated Time of Arrival of copied files.
# 
# /LOG:file :: output status to LOG file (overwrite existing log).
# /LOG+:file :: output status to LOG file (append to existing log).

